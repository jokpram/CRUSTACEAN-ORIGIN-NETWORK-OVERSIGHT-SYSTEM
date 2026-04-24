package com.cronos.repository;

import com.cronos.entity.WaterQualityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface WaterQualityLogRepository extends JpaRepository<WaterQualityLog, UUID> {
    List<WaterQualityLog> findByCultivationCycleIdOrderByRecordedAtDesc(UUID cultivationCycleId);
}
