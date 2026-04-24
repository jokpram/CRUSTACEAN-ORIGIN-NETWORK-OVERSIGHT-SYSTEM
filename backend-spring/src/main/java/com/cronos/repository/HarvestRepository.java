package com.cronos.repository;

import com.cronos.entity.Harvest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface HarvestRepository extends JpaRepository<Harvest, UUID> {
    @Query("SELECT h FROM Harvest h JOIN CultivationCycle c ON h.cultivationCycleId = c.id JOIN Pond p ON c.pondId = p.id JOIN Farm f ON p.farmId = f.id WHERE f.userId = :userId ORDER BY h.createdAt DESC")
    List<Harvest> findByUserId(@Param("userId") UUID userId);

    @Query("SELECT COUNT(h) FROM Harvest h JOIN CultivationCycle c ON h.cultivationCycleId = c.id JOIN Pond p ON c.pondId = p.id JOIN Farm f ON p.farmId = f.id WHERE f.userId = :userId")
    long countByUserId(@Param("userId") UUID userId);
}
