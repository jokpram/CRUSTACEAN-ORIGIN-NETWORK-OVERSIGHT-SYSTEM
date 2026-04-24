package com.cronos.repository;

import com.cronos.entity.CronosOrder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<CronosOrder, UUID> {
    Page<CronosOrder> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    @Query("SELECT o FROM CronosOrder o WHERE (:status IS NULL OR :status = '' OR o.status = :status) ORDER BY o.createdAt DESC")
    Page<CronosOrder> findAllFiltered(@Param("status") String status, Pageable pageable);

    @Query("SELECT DISTINCT o FROM CronosOrder o JOIN OrderItem oi ON oi.orderId = o.id JOIN Product p ON oi.productId = p.id WHERE p.userId = :sellerId ORDER BY o.createdAt DESC")
    List<CronosOrder> findBySellerIdDistinct(@Param("sellerId") UUID sellerId);

    @Query("SELECT o.status, COUNT(o) FROM CronosOrder o GROUP BY o.status")
    List<Object[]> countByStatus();

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM CronosOrder o WHERE o.status IN :statuses")
    BigDecimal sumTotalRevenue(@Param("statuses") List<String> statuses);

    @Query("SELECT COALESCE(SUM(oi.subtotal), 0) FROM OrderItem oi JOIN Product p ON oi.productId = p.id JOIN CronosOrder o ON oi.orderId = o.id WHERE p.userId = :sellerId AND o.status IN :statuses")
    BigDecimal sumRevenueBySellerIdAndStatuses(@Param("sellerId") UUID sellerId, @Param("statuses") List<String> statuses);
}
