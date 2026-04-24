package com.cronos.repository;

import com.cronos.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ShipmentRepository extends JpaRepository<Shipment, UUID> {
    Optional<Shipment> findByOrderId(UUID orderId);

    List<Shipment> findByCourierIdOrderByCreatedAtDesc(UUID courierId);

    List<Shipment> findAllByOrderByCreatedAtDesc();

    long countByCourierId(UUID courierId);

    @Query("SELECT s.status, COUNT(s) FROM Shipment s WHERE (:courierId IS NULL OR s.courierId = :courierId) GROUP BY s.status")
    List<Object[]> countByStatusAndCourierId(@Param("courierId") UUID courierId);
}
