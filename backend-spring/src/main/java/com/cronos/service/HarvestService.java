package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.entity.Batch;
import com.cronos.entity.Harvest;
import com.cronos.repository.BatchRepository;
import com.cronos.repository.HarvestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.Year;
import java.util.*;

@Service
@RequiredArgsConstructor
public class HarvestService {
    private final HarvestRepository harvestRepo;
    private final BatchRepository batchRepo;
    private final BlockchainLedger ledger;

    public Harvest createHarvest(UUID userId, Harvest harvest) {
        harvestRepo.save(harvest);
        ledger.recordEvent("harvest_completed", userId, "harvest", harvest.getId(),
                Map.of("total_weight", harvest.getTotalWeight(), "shrimp_size", harvest.getShrimpSize() != null ? harvest.getShrimpSize() : "",
                        "quality_grade", harvest.getQualityGrade() != null ? harvest.getQualityGrade() : ""));
        return harvest;
    }

    public List<Harvest> getMyHarvests(UUID userId) { return harvestRepo.findByUserId(userId); }
    public Harvest getHarvest(UUID id) { return harvestRepo.findById(id).orElseThrow(() -> new RuntimeException("harvest not found")); }

    public Batch createBatch(UUID userId, Batch batch) {
        long serial = batchRepo.count() + 1;
        batch.setBatchCode(String.format("CRN-VNM-%d-%06d", Year.now().getValue(), serial));
        batchRepo.save(batch);
        ledger.recordEvent("batch_created", userId, "batch", batch.getId(),
                Map.of("batch_code", batch.getBatchCode(), "quantity", batch.getQuantity()));
        return batch;
    }

    public List<Batch> getMyBatches(UUID userId) { return batchRepo.findByUserId(userId); }
    public Batch getBatchByCode(String code) { return batchRepo.findByBatchCode(code).orElseThrow(() -> new RuntimeException("batch not found")); }
}
