package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.Farm;
import com.cronos.entity.Pond;
import com.cronos.service.FarmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/farms")
@RequiredArgsConstructor
public class FarmController {
    private final FarmService farmService;

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @RequestBody Farm farm) {
        UUID userId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success("Farm created", farmService.createFarm(userId, farm)));
    }

    @GetMapping
    public ResponseEntity<?> getMyFarms(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success("Farms retrieved", farmService.getMyFarms(userId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getFarm(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Farm retrieved", farmService.getFarm(id)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(Authentication auth, @PathVariable UUID id, @RequestBody Farm req) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            return ResponseEntity.ok(ApiResponse.success("Farm updated", farmService.updateFarm(userId, id, req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(Authentication auth, @PathVariable UUID id) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            farmService.deleteFarm(userId, id); return ResponseEntity.ok(ApiResponse.success("Farm deleted", null));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @PostMapping("/{farmId}/ponds")
    public ResponseEntity<?> createPond(Authentication auth, @PathVariable UUID farmId, @RequestBody Pond pond) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            return ResponseEntity.ok(ApiResponse.success("Pond created", farmService.createPond(userId, farmId, pond)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping("/{farmId}/ponds")
    public ResponseEntity<?> getPonds(@PathVariable UUID farmId) {
        return ResponseEntity.ok(ApiResponse.success("Ponds retrieved", farmService.getPonds(farmId)));
    }

    @PutMapping("/ponds/{pondId}")
    public ResponseEntity<?> updatePond(Authentication auth, @PathVariable UUID pondId, @RequestBody Pond req) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            return ResponseEntity.ok(ApiResponse.success("Pond updated", farmService.updatePond(userId, pondId, req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @DeleteMapping("/ponds/{pondId}")
    public ResponseEntity<?> deletePond(Authentication auth, @PathVariable UUID pondId) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            farmService.deletePond(userId, pondId); return ResponseEntity.ok(ApiResponse.success("Pond deleted", null));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
