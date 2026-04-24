package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.entity.*;
import com.cronos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@RequiredArgsConstructor
public class CultivationService {
    private final CultivationCycleRepository cultivationRepo;
    private final FeedLogRepository feedLogRepo;
    private final WaterQualityLogRepository waterQualityRepo;
    private final FarmRepository farmRepo;
    private final PondRepository pondRepo;
    private final BlockchainLedger ledger;

    public CultivationCycle createCycle(UUID userId, CultivationCycle cycle) {
        Pond pond = pondRepo.findById(cycle.getPondId()).orElseThrow(() -> new RuntimeException("pond not found"));
        Farm farm = farmRepo.findById(pond.getFarmId()).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        cultivationRepo.save(cycle);
        ledger.recordEvent("cultivation_started", userId, "cultivation", cycle.getId(),
                Map.of("pond_id", cycle.getPondId(), "shrimp_type", cycle.getShrimpTypeId(), "start_date", cycle.getStartDate().toString()));
        return cycle;
    }

    public List<CultivationCycle> getMyCycles(UUID userId) { return cultivationRepo.findByUserId(userId); }
    public CultivationCycle getCycle(UUID id) { return cultivationRepo.findById(id).orElseThrow(() -> new RuntimeException("cycle not found")); }

    public CultivationCycle updateCycle(UUID userId, UUID cycleId, CultivationCycle req) {
        CultivationCycle cycle = cultivationRepo.findById(cycleId).orElseThrow(() -> new RuntimeException("cycle not found"));
        if (req.getStatus() != null && !req.getStatus().isEmpty()) cycle.setStatus(req.getStatus());
        if (req.getActualEndDate() != null) cycle.setActualEndDate(req.getActualEndDate());
        if (req.getNotes() != null && !req.getNotes().isEmpty()) cycle.setNotes(req.getNotes());
        cultivationRepo.save(cycle);
        return cycle;
    }

    public FeedLog addFeedLog(UUID userId, FeedLog log) {
        feedLogRepo.save(log);
        ledger.recordEvent("feed_logged", userId, "cultivation", log.getCultivationCycleId(),
                Map.of("feed_type", log.getFeedType(), "quantity", log.getQuantity()));
        return log;
    }

    public List<FeedLog> getFeedLogs(UUID cycleId) { return feedLogRepo.findByCultivationCycleIdOrderByFeedingTimeDesc(cycleId); }

    public WaterQualityLog addWaterQualityLog(UUID userId, WaterQualityLog log) {
        waterQualityRepo.save(log);
        ledger.recordEvent("water_quality_logged", userId, "cultivation", log.getCultivationCycleId(),
                Map.of("temperature", log.getTemperature(), "ph", log.getPh(), "salinity", log.getSalinity(), "dissolved_oxygen", log.getDissolvedOxygen()));
        return log;
    }

    public List<WaterQualityLog> getWaterQualityLogs(UUID cycleId) { return waterQualityRepo.findByCultivationCycleIdOrderByRecordedAtDesc(cycleId); }
}
