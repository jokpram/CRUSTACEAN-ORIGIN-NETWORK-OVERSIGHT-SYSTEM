package com.cronos.repository;

import com.cronos.entity.TraceabilityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TraceabilityLogRepository extends JpaRepository<TraceabilityLog, UUID> {
    Optional<TraceabilityLog> findTopByOrderByCreatedAtDesc();

    List<TraceabilityLog> findByEntityTypeAndEntityIdOrderByTimestampAsc(String entityType, UUID entityId);

    List<TraceabilityLog> findByEntityTypeAndEntityId(String entityType, UUID entityId);

    List<TraceabilityLog> findAllByOrderByCreatedAtAsc();

    List<TraceabilityLog> findTop100ByOrderByTimestampDesc();
}
