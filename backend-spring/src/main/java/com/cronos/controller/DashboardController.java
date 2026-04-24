package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.service.DashboardService;
import com.cronos.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.UUID;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    private final DashboardService dashboardService;

    @GetMapping("/petambak")
    public ResponseEntity<?> petambak(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Dashboard retrieved", dashboardService.getPetambakDashboard((UUID) auth.getPrincipal())));
    }

    @GetMapping("/logistik")
    public ResponseEntity<?> logistik(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Dashboard retrieved", dashboardService.getLogistikDashboard((UUID) auth.getPrincipal())));
    }

    @GetMapping("/konsumen")
    public ResponseEntity<?> konsumen(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Dashboard retrieved", dashboardService.getKonsumenDashboard((UUID) auth.getPrincipal())));
    }
}
