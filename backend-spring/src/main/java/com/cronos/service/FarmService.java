package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.entity.Farm;
import com.cronos.entity.Pond;
import com.cronos.repository.FarmRepository;
import com.cronos.repository.PondRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@RequiredArgsConstructor
public class FarmService {
    private final FarmRepository farmRepo;
    private final PondRepository pondRepo;
    private final BlockchainLedger ledger;

    public Farm createFarm(UUID userId, Farm farm) {
        farm.setUserId(userId);
        farmRepo.save(farm);
        ledger.recordEvent("farm_created", userId, "farm", farm.getId(),
                Map.of("name", farm.getName(), "location", farm.getLocation() != null ? farm.getLocation() : ""));
        return farm;
    }

    public List<Farm> getMyFarms(UUID userId) { return farmRepo.findByUserIdOrderByCreatedAtDesc(userId); }

    public Farm getFarm(UUID id) { return farmRepo.findById(id).orElseThrow(() -> new RuntimeException("farm not found")); }

    public Farm updateFarm(UUID userId, UUID farmId, Farm req) {
        Farm farm = farmRepo.findById(farmId).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        farm.setName(req.getName()); farm.setLocation(req.getLocation());
        farm.setArea(req.getArea()); farm.setDescription(req.getDescription());
        if (req.getImage() != null && !req.getImage().isEmpty()) farm.setImage(req.getImage());
        farmRepo.save(farm);
        return farm;
    }

    public void deleteFarm(UUID userId, UUID farmId) {
        Farm farm = farmRepo.findById(farmId).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        farmRepo.deleteById(farmId);
    }

    public Pond createPond(UUID userId, UUID farmId, Pond pond) {
        Farm farm = farmRepo.findById(farmId).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        pond.setFarmId(farmId);
        pondRepo.save(pond);
        return pond;
    }

    public List<Pond> getPonds(UUID farmId) { return pondRepo.findByFarmIdOrderByCreatedAtDesc(farmId); }

    public Pond updatePond(UUID userId, UUID pondId, Pond req) {
        Pond pond = pondRepo.findById(pondId).orElseThrow(() -> new RuntimeException("pond not found"));
        Farm farm = farmRepo.findById(pond.getFarmId()).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        pond.setName(req.getName()); pond.setArea(req.getArea());
        pond.setDepth(req.getDepth()); pond.setStatus(req.getStatus());
        pondRepo.save(pond);
        return pond;
    }

    public void deletePond(UUID userId, UUID pondId) {
        Pond pond = pondRepo.findById(pondId).orElseThrow(() -> new RuntimeException("pond not found"));
        Farm farm = farmRepo.findById(pond.getFarmId()).orElseThrow(() -> new RuntimeException("farm not found"));
        if (!farm.getUserId().equals(userId)) throw new RuntimeException("unauthorized");
        pondRepo.deleteById(pondId);
    }
}
