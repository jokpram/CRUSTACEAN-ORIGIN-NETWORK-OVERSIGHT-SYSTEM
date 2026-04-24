package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.UUID;

@RestController
@RequestMapping("/api/sales")
@RequiredArgsConstructor
public class SalesController {
    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<?> getSellerOrders(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Sales orders retrieved", orderService.getSellerOrders((UUID) auth.getPrincipal())));
    }
}
