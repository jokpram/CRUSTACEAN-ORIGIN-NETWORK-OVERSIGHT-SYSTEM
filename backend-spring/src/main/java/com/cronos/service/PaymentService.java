package com.cronos.service;

import com.cronos.entity.*;
import com.cronos.repository.*;
import com.midtrans.Config;
import com.midtrans.ConfigFactory;
import com.midtrans.service.MidtransSnapApi;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
    private final PaymentRepository paymentRepo;
    private final MidtransTransactionRepository midtransRepo;
    private final OrderRepository orderRepo;
    private final UserRepository userRepo;
    private final ProductRepository productRepo;

    @Value("${midtrans.server-key}") private String serverKey;
    @Value("${midtrans.client-key}") private String clientKey;
    @Value("${midtrans.is-production}") private boolean isProduction;

    public MidtransTransaction createPayment(UUID orderId) {
        CronosOrder order = orderRepo.findById(orderId).orElseThrow(() -> new RuntimeException("order not found"));
        if (!"pending".equals(order.getStatus())) throw new RuntimeException("order is not in pending status");

        Optional<Payment> existingOpt = paymentRepo.findByOrderId(orderId);
        if (existingOpt.isPresent() && existingOpt.get().getMidtransTransaction() != null) {
            return existingOpt.get().getMidtransTransaction();
        }

        Payment payment = Payment.builder().orderId(orderId).amount(order.getTotalAmount()).status("pending").build();
        paymentRepo.save(payment);

        try {
            MidtransSnapApi snapApi = new ConfigFactory(new Config(serverKey, clientKey, isProduction)).getSnapApi();
            String midtransOrderId = "CRONOS-" + order.getId().toString().substring(0, 8);
            User user = userRepo.findById(order.getUserId()).orElse(null);

            Map<String, Object> params = new HashMap<>();
            Map<String, Object> txDetails = new HashMap<>();
            txDetails.put("order_id", midtransOrderId);
            txDetails.put("gross_amount", order.getTotalAmount().longValue());
            params.put("transaction_details", txDetails);

            if (user != null) {
                Map<String, String> custDetails = new HashMap<>();
                custDetails.put("first_name", user.getName());
                custDetails.put("email", user.getEmail());
                custDetails.put("phone", user.getPhone() != null ? user.getPhone() : "");
                params.put("customer_details", custDetails);
            }

            var snapResponse = snapApi.createTransaction(params);
            String snapToken = snapResponse.get("token") != null ? snapResponse.get("token").toString() : "";
            String snapUrl = snapResponse.get("redirect_url") != null ? snapResponse.get("redirect_url").toString() : "";

            MidtransTransaction mt = MidtransTransaction.builder()
                .paymentId(payment.getId()).orderIdMidtrans(midtransOrderId)
                .snapToken(snapToken).snapUrl(snapUrl).build();
            midtransRepo.save(mt);
            return mt;
        } catch (Exception e) {
            throw new RuntimeException("failed to create snap token: " + e.getMessage());
        }
    }

    @Transactional
    public void handleWebhook(Map<String, Object> notification) {
        String orderIdMidtrans = (String) notification.get("order_id");
        String transactionStatus = (String) notification.get("transaction_status");
        String paymentType = (String) notification.get("payment_type");
        String fraudStatus = (String) notification.get("fraud_status");

        MidtransTransaction mt = midtransRepo.findByOrderIdMidtrans(orderIdMidtrans)
                .orElseThrow(() -> new RuntimeException("midtrans transaction not found"));
        mt.setTransactionStatus(transactionStatus);
        mt.setPaymentType(paymentType);
        mt.setFraudStatus(fraudStatus);

        Payment payment = paymentRepo.findById(mt.getPaymentId()).orElseThrow(() -> new RuntimeException("payment not found"));

        if ("paid".equals(payment.getStatus()) && ("capture".equals(transactionStatus) || "settlement".equals(transactionStatus))) {
            midtransRepo.save(mt);
            return;
        }

        switch (transactionStatus) {
            case "capture" -> {
                if ("accept".equals(fraudStatus)) {
                    payment.setStatus("paid"); payment.setPaidAt(LocalDateTime.now()); payment.setMethod(paymentType);
                    CronosOrder order = orderRepo.findById(payment.getOrderId()).get();
                    order.setStatus("paid"); orderRepo.save(order); creditSellerBalance(order);
                }
            }
            case "settlement" -> {
                payment.setStatus("paid"); payment.setPaidAt(LocalDateTime.now()); payment.setMethod(paymentType);
                CronosOrder order = orderRepo.findById(payment.getOrderId()).get();
                order.setStatus("paid"); orderRepo.save(order); creditSellerBalance(order);
            }
            case "deny", "cancel", "expire" -> {
                payment.setStatus("expire".equals(transactionStatus) ? "expired" : "failed");
                CronosOrder order = orderRepo.findById(payment.getOrderId()).get();
                order.setStatus("cancelled"); orderRepo.save(order);
            }
            case "pending" -> payment.setStatus("pending");
        }
        paymentRepo.save(payment);
        midtransRepo.save(mt);
    }

    private void creditSellerBalance(CronosOrder order) {
        if (order.getOrderItems() == null) return;
        Map<UUID, BigDecimal> sellerAmounts = new HashMap<>();
        for (OrderItem item : order.getOrderItems()) {
            productRepo.findById(item.getProductId()).ifPresent(p -> sellerAmounts.merge(p.getUserId(), item.getSubtotal(), BigDecimal::add));
        }
        sellerAmounts.forEach((sellerId, amount) -> userRepo.findById(sellerId).ifPresent(seller -> {
            seller.setBalance(seller.getBalance().add(amount));
            userRepo.save(seller);
        }));
    }

    public Payment getPaymentByOrderId(UUID orderId) { return paymentRepo.findByOrderId(orderId).orElseThrow(() -> new RuntimeException("payment not found")); }
}
