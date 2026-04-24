package com.cronos.repository;

import com.cronos.entity.Batch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BatchRepository extends JpaRepository<Batch, UUID> {
    Optional<Batch> findByBatchCode(String batchCode);

    @Query("SELECT b FROM Batch b JOIN Harvest h ON b.harvestId = h.id JOIN CultivationCycle c ON h.cultivationCycleId = c.id JOIN Pond p ON c.pondId = p.id JOIN Farm f ON p.farmId = f.id WHERE f.userId = :userId ORDER BY b.createdAt DESC")
    List<Batch> findByUserId(@Param("userId") UUID userId);
}
