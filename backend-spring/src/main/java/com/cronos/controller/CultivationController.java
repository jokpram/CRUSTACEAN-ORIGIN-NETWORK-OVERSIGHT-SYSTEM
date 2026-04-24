package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.*;
import com.cronos.service.CultivationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/cultivations")
@RequiredArgsConstructor
public class CultivationController {
    private final CultivationService cultivationService;

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @RequestBody CultivationCycle cycle) {
        UUID userId = (UUID) auth.getPrincipal();
        try {
            return ResponseEntity.ok(ApiResponse.success("Cultivation cycle created", cultivationService.createCycle(userId, cycle)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping
    public ResponseEntity<?> getMyCycles(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Cycles retrieved", cultivationService.getMyCycles((UUID) auth.getPrincipal())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getCycle(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Cycle retrieved", cultivationService.getCycle(id)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(Authentication auth, @PathVariable UUID id, @RequestBody CultivationCycle req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Cycle updated", cultivationService.updateCycle((UUID) auth.getPrincipal(), id, req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @PostMapping("/{cycleId}/feed-logs")
    public ResponseEntity<?> addFeedLog(Authentication auth, @PathVariable UUID cycleId, @RequestBody FeedLog log) {
        log.setCultivationCycleId(cycleId);
        return ResponseEntity.ok(ApiResponse.success("Feed log added", cultivationService.addFeedLog((UUID) auth.getPrincipal(), log)));
    }

    @GetMapping("/{cycleId}/feed-logs")
    public ResponseEntity<?> getFeedLogs(@PathVariable UUID cycleId) {
        return ResponseEntity.ok(ApiResponse.success("Feed logs retrieved", cultivationService.getFeedLogs(cycleId)));
    }

    @PostMapping("/{cycleId}/water-quality")
    public ResponseEntity<?> addWaterQuality(Authentication auth, @PathVariable UUID cycleId, @RequestBody WaterQualityLog log) {
        log.setCultivationCycleId(cycleId);
        return ResponseEntity.ok(ApiResponse.success("Water quality log added", cultivationService.addWaterQualityLog((UUID) auth.getPrincipal(), log)));
    }

    @GetMapping("/{cycleId}/water-quality")
    public ResponseEntity<?> getWaterQuality(@PathVariable UUID cycleId) {
        return ResponseEntity.ok(ApiResponse.success("Water quality logs retrieved", cultivationService.getWaterQualityLogs(cycleId)));
    }
}
