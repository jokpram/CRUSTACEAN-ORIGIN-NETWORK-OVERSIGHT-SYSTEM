package com.cronos.controller;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.dto.request.CreateShipmentRequest;
import com.cronos.dto.request.CreateUserRequest;
import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.ShrimpType;
import com.cronos.entity.TraceabilityLog;
import com.cronos.repository.TraceabilityLogRepository;
import com.cronos.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {
    private final UserService userService;
    private final DashboardService dashboardService;
    private final WithdrawalService withdrawalService;
    private final OrderService orderService;
    private final ShipmentService shipmentService;
    private final ShrimpTypeService shrimpTypeService;
    private final BlockchainLedger blockchainLedger;
    private final TraceabilityLogRepository traceRepo;

    @GetMapping("/users")
    public ResponseEntity<?> getUsers(@RequestParam(defaultValue = "1") String page, @RequestParam(defaultValue = "10") String limit,
                                      @RequestParam(required = false) String role, @RequestParam(required = false) String search) {
        int[] p = userService.parsePagination(page, limit);
        var result = userService.getAllUsers(p[0], p[1], role, search);
        return ResponseEntity.ok(ApiResponse.success("Users retrieved", result.get("users"), result.get("meta")));
    }

    @PostMapping("/users")
    public ResponseEntity<?> createUser(@Valid @RequestBody CreateUserRequest req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("User created", userService.createUser(req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @PutMapping("/users/{id}/verify")
    public ResponseEntity<?> verifyUser(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(ApiResponse.success("User verified", userService.verifyUser(id)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @PutMapping("/users/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable UUID id, @RequestBody Map<String, Boolean> body) {
        try {
            return ResponseEntity.ok(ApiResponse.success("User status updated", userService.updateUserStatus(id, body.getOrDefault("is_verified", false))));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/dashboard")
    public ResponseEntity<?> dashboard() {
        return ResponseEntity.ok(ApiResponse.success("Admin dashboard", dashboardService.getAdminDashboard()));
    }

    @GetMapping("/withdrawals")
    public ResponseEntity<?> getWithdrawals() {
        return ResponseEntity.ok(ApiResponse.success("Withdrawals retrieved", withdrawalService.getAllWithdrawals()));
    }

    @PutMapping("/withdrawals/{id}")
    public ResponseEntity<?> updateWithdrawal(@PathVariable UUID id, @RequestBody Map<String, String> body) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Withdrawal updated", withdrawalService.updateWithdrawal(id, body.get("status"), body.get("notes"))));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/orders")
    public ResponseEntity<?> getOrders(@RequestParam(defaultValue = "1") String page, @RequestParam(defaultValue = "10") String limit, @RequestParam(required = false) String status) {
        var result = orderService.getAllOrders(page, limit, status);
        return ResponseEntity.ok(ApiResponse.success("Orders retrieved", result.get("orders"), result.get("meta")));
    }

    @PostMapping("/shrimp-types")
    public ResponseEntity<?> createShrimpType(@RequestBody ShrimpType st) {
        return ResponseEntity.ok(ApiResponse.success("Shrimp type created", shrimpTypeService.create(st)));
    }

    @PutMapping("/shrimp-types/{id}")
    public ResponseEntity<?> updateShrimpType(@PathVariable UUID id, @RequestBody ShrimpType req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Shrimp type updated", shrimpTypeService.update(id, req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @DeleteMapping("/shrimp-types/{id}")
    public ResponseEntity<?> deleteShrimpType(@PathVariable UUID id) {
        shrimpTypeService.delete(id); return ResponseEntity.ok(ApiResponse.success("Shrimp type deleted", null));
    }

    @PostMapping("/shipments")
    public ResponseEntity<?> createShipment(@RequestBody CreateShipmentRequest req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Shipment created", shipmentService.createShipment(req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/shipments")
    public ResponseEntity<?> getAllShipments() {
        return ResponseEntity.ok(ApiResponse.success("Shipments retrieved", shipmentService.getAllShipments()));
    }

    @GetMapping("/traceability/logs")
    public ResponseEntity<?> getTraceLogs() {
        List<TraceabilityLog> logs = traceRepo.findTop100ByOrderByTimestampDesc();
        return ResponseEntity.ok(ApiResponse.success("Traceability logs retrieved", logs));
    }

    @GetMapping("/traceability/verify")
    public ResponseEntity<?> verifyChain() {
        try {
            blockchainLedger.verifyChain();
            return ResponseEntity.ok(ApiResponse.success("Blockchain integrity verified", Map.of("valid", true)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
