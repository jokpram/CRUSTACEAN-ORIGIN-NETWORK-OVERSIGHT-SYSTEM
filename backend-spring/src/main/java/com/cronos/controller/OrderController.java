package com.cronos.controller;

import com.cronos.dto.request.CreateOrderRequest;
import com.cronos.dto.response.ApiResponse;
import com.cronos.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @Valid @RequestBody CreateOrderRequest req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Order created", orderService.createOrder((UUID) auth.getPrincipal(), req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping
    public ResponseEntity<?> getMyOrders(Authentication auth, @RequestParam(defaultValue = "1") String page, @RequestParam(defaultValue = "10") String limit) {
        var result = orderService.getMyOrders((UUID) auth.getPrincipal(), page, limit);
        return ResponseEntity.ok(ApiResponse.success("Orders retrieved", result.get("orders"), result.get("meta")));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrder(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Order retrieved", orderService.getOrder(id)));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancel(Authentication auth, @PathVariable UUID id) {
        try {
            orderService.cancelOrder((UUID) auth.getPrincipal(), id);
            return ResponseEntity.ok(ApiResponse.success("Order cancelled", null));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
