package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.Batch;
import com.cronos.entity.Harvest;
import com.cronos.service.HarvestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class HarvestController {
    private final HarvestService harvestService;

    @PostMapping("/api/harvests")
    public ResponseEntity<?> createHarvest(Authentication auth, @RequestBody Harvest harvest) {
        return ResponseEntity.ok(ApiResponse.success("Harvest created", harvestService.createHarvest((UUID) auth.getPrincipal(), harvest)));
    }

    @GetMapping("/api/harvests")
    public ResponseEntity<?> getMyHarvests(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Harvests retrieved", harvestService.getMyHarvests((UUID) auth.getPrincipal())));
    }

    @GetMapping("/api/harvests/{id}")
    public ResponseEntity<?> getHarvest(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Harvest retrieved", harvestService.getHarvest(id)));
    }

    @PostMapping("/api/batches")
    public ResponseEntity<?> createBatch(Authentication auth, @RequestBody Batch batch) {
        return ResponseEntity.ok(ApiResponse.success("Batch created", harvestService.createBatch((UUID) auth.getPrincipal(), batch)));
    }

    @GetMapping("/api/batches")
    public ResponseEntity<?> getMyBatches(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Batches retrieved", harvestService.getMyBatches((UUID) auth.getPrincipal())));
    }
}
