package com.cronos.repository;

import com.cronos.entity.CultivationCycle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CultivationCycleRepository extends JpaRepository<CultivationCycle, UUID> {
    List<CultivationCycle> findByPondIdOrderByCreatedAtDesc(UUID pondId);

    @Query("SELECT c FROM CultivationCycle c JOIN Pond p ON c.pondId = p.id JOIN Farm f ON p.farmId = f.id WHERE f.userId = :userId ORDER BY c.createdAt DESC")
    List<CultivationCycle> findByUserId(@Param("userId") UUID userId);

    @Query("SELECT COUNT(c) FROM CultivationCycle c JOIN Pond p ON c.pondId = p.id JOIN Farm f ON p.farmId = f.id WHERE f.userId = :userId")
    long countByUserId(@Param("userId") UUID userId);
}
