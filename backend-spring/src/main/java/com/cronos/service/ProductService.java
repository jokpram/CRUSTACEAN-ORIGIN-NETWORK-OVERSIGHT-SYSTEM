package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.dto.response.PaginationMeta;
import com.cronos.entity.Product;
import com.cronos.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepo;
    private final BlockchainLedger ledger;

    public Product createProduct(UUID userId, Product product) {
        product.setUserId(userId);
        productRepo.save(product);
        ledger.recordEvent("product_listed", userId, "product", product.getId(),
                Map.of("name", product.getName(), "price", product.getPrice(), "stock", product.getStock()));
        return product;
    }

    public Map<String, Object> getMarketplaceProducts(String pageStr, String limitStr, String shrimpType, String size, String search, String sortBy, String minPriceStr, String maxPriceStr) {
        int page = parseIntOr(pageStr, 1); if (page < 1) page = 1;
        int limit = parseIntOr(limitStr, 12); if (limit < 1) limit = 12;
        BigDecimal minPrice = parseBigDecimalOr(minPriceStr, null);
        BigDecimal maxPrice = parseBigDecimalOr(maxPriceStr, null);

        Sort sort = switch (sortBy != null ? sortBy : "") {
            case "price_asc" -> Sort.by("price").ascending();
            case "price_desc" -> Sort.by("price").descending();
            case "rating" -> Sort.by("ratingAvg").descending();
            default -> Sort.by("createdAt").descending();
        };

        Page<Product> productsPage = productRepo.findMarketplaceProducts(shrimpType, size, search, minPrice, maxPrice, PageRequest.of(page - 1, limit, sort));
        PaginationMeta meta = PaginationMeta.builder().currentPage(page).perPage(limit).total(productsPage.getTotalElements()).totalPages(productsPage.getTotalPages()).build();
        return Map.of("products", productsPage.getContent(), "meta", meta);
    }

    public Product getProduct(UUID id) { return productRepo.findById(id).orElseThrow(() -> new RuntimeException("product not found")); }
    public List<Product> getMyProducts(UUID userId) { return productRepo.findByUserIdOrderByCreatedAtDesc(userId); }

    public Product updateProduct(UUID userId, UUID productId, Product req) {
        Product product = productRepo.findById(productId).orElseThrow(() -> new RuntimeException("product not found"));
        if (!product.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        if (req.getName() != null && !req.getName().isEmpty()) product.setName(req.getName());
        if (req.getDescription() != null && !req.getDescription().isEmpty()) product.setDescription(req.getDescription());
        if (req.getPrice() != null && req.getPrice().compareTo(BigDecimal.ZERO) > 0) product.setPrice(req.getPrice());
        if (req.getStock() != null && req.getStock() >= 0) product.setStock(req.getStock());
        if (req.getShrimpType() != null && !req.getShrimpType().isEmpty()) product.setShrimpType(req.getShrimpType());
        if (req.getSize() != null && !req.getSize().isEmpty()) product.setSize(req.getSize());
        if (req.getIsAvailable() != null) product.setIsAvailable(req.getIsAvailable());
        productRepo.save(product);
        return product;
    }

    public void deleteProduct(UUID userId, UUID productId) {
        Product product = productRepo.findById(productId).orElseThrow(() -> new RuntimeException("product not found"));
        if (!product.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        productRepo.deleteById(productId);
    }

    private int parseIntOr(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
    private BigDecimal parseBigDecimalOr(String s, BigDecimal def) { try { BigDecimal v = new BigDecimal(s); return v.compareTo(BigDecimal.ZERO) > 0 ? v : def; } catch (Exception e) { return def; } }
}
