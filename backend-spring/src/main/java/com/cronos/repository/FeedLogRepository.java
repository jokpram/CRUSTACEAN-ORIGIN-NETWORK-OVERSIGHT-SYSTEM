package com.cronos.repository;

import com.cronos.entity.FeedLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface FeedLogRepository extends JpaRepository<FeedLog, UUID> {
    List<FeedLog> findByCultivationCycleIdOrderByFeedingTimeDesc(UUID cultivationCycleId);
}
