package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.service.ShipmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/shipments")
@RequiredArgsConstructor
public class ShipmentController {
    private final ShipmentService shipmentService;

    @GetMapping
    public ResponseEntity<?> getMyShipments(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Shipments retrieved", shipmentService.getMyShipments((UUID) auth.getPrincipal())));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(Authentication auth, @PathVariable UUID id, @RequestBody Map<String, String> body) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Shipment status updated",
                    shipmentService.updateShipmentStatus((UUID) auth.getPrincipal(), id, body.get("status"), body.get("location"), body.get("notes"))));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/{id}/logs")
    public ResponseEntity<?> getLogs(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Shipment logs retrieved", shipmentService.getShipmentLogs(id)));
    }
}
