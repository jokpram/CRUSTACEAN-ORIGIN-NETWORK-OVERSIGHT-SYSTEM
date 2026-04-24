package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {
    private final PaymentService paymentService;

    @PostMapping("/create")
    public ResponseEntity<?> create(@RequestBody Map<String, String> body) {
        try {
            UUID orderId = UUID.fromString(body.get("order_id"));
            return ResponseEntity.ok(ApiResponse.success("Payment created", paymentService.createPayment(orderId)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @PostMapping("/midtrans/webhook")
    public ResponseEntity<?> webhook(@RequestBody Map<String, Object> notification) {
        try {
            paymentService.handleWebhook(notification);
            return ResponseEntity.ok(ApiResponse.success("Webhook processed", null));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<?> getPayment(@PathVariable UUID orderId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Payment retrieved", paymentService.getPaymentByOrderId(orderId)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
