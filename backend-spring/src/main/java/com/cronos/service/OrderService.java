package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.dto.request.CreateOrderRequest;
import com.cronos.dto.response.PaginationMeta;
import com.cronos.entity.*;
import com.cronos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepo;
    private final OrderItemRepository orderItemRepo;
    private final ProductRepository productRepo;
    private final BlockchainLedger ledger;

    @Transactional
    public CronosOrder createOrder(UUID userId, CreateOrderRequest req) {
        CronosOrder order = CronosOrder.builder().userId(userId).shippingAddress(req.getShippingAddress()).notes(req.getNotes()).status("pending").build();
        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();

        for (var item : req.getItems()) {
            Product product = productRepo.findById(item.getProductId()).orElseThrow(() -> new RuntimeException("product not found: " + item.getProductId()));
            if (product.getStock() < item.getQuantity()) throw new RuntimeException("insufficient stock for product: " + product.getName());
            BigDecimal subtotal = product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            totalAmount = totalAmount.add(subtotal);
            items.add(OrderItem.builder().productId(item.getProductId()).quantity(item.getQuantity()).price(product.getPrice()).subtotal(subtotal).build());
        }
        order.setTotalAmount(totalAmount);
        orderRepo.save(order);

        for (OrderItem item : items) {
            item.setOrderId(order.getId());
            orderItemRepo.save(item);
            Product product = productRepo.findById(item.getProductId()).get();
            product.setStock(product.getStock() - item.getQuantity());
            productRepo.save(product);
        }
        ledger.recordEvent("order_created", userId, "order", order.getId(), Map.of("total_amount", totalAmount, "items_count", items.size()));
        return orderRepo.findById(order.getId()).get();
    }

    public Map<String, Object> getMyOrders(UUID userId, String pageStr, String limitStr) {
        int page = parseIntOr(pageStr, 1); int limit = parseIntOr(limitStr, 10);
        Page<CronosOrder> ordersPage = orderRepo.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(page - 1, limit));
        PaginationMeta meta = PaginationMeta.builder().currentPage(page).perPage(limit).total(ordersPage.getTotalElements()).totalPages(ordersPage.getTotalPages()).build();
        return Map.of("orders", ordersPage.getContent(), "meta", meta);
    }

    public Map<String, Object> getAllOrders(String pageStr, String limitStr, String status) {
        int page = parseIntOr(pageStr, 1); int limit = parseIntOr(limitStr, 10);
        Page<CronosOrder> ordersPage = orderRepo.findAllFiltered(status, PageRequest.of(page - 1, limit));
        PaginationMeta meta = PaginationMeta.builder().currentPage(page).perPage(limit).total(ordersPage.getTotalElements()).totalPages(ordersPage.getTotalPages()).build();
        return Map.of("orders", ordersPage.getContent(), "meta", meta);
    }

    public CronosOrder getOrder(UUID id) { return orderRepo.findById(id).orElseThrow(() -> new RuntimeException("order not found")); }

    @Transactional
    public void cancelOrder(UUID userId, UUID orderId) {
        CronosOrder order = orderRepo.findById(orderId).orElseThrow(() -> new RuntimeException("order not found"));
        if (!order.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        if (!"pending".equals(order.getStatus())) throw new RuntimeException("only pending orders can be cancelled");
        order.setStatus("cancelled");
        if (order.getOrderItems() != null) {
            for (OrderItem item : order.getOrderItems()) {
                Product product = productRepo.findById(item.getProductId()).get();
                product.setStock(product.getStock() + item.getQuantity());
                productRepo.save(product);
            }
        }
        orderRepo.save(order);
    }

    public List<CronosOrder> getSellerOrders(UUID sellerId) { return orderRepo.findBySellerIdDistinct(sellerId); }

    private int parseIntOr(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
