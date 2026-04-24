package com.cronos.repository;

import com.cronos.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {
    @Query("SELECT p FROM Product p WHERE p.isAvailable = true AND p.stock > 0 " +
           "AND (:shrimpType IS NULL OR :shrimpType = '' OR p.shrimpType = :shrimpType) " +
           "AND (:size IS NULL OR :size = '' OR p.size = :size) " +
           "AND (:search IS NULL OR :search = '' OR LOWER(p.name) LIKE LOWER(CONCAT('%',:search,'%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%',:search,'%'))) " +
           "AND (:minPrice IS NULL OR p.price >= :minPrice) " +
           "AND (:maxPrice IS NULL OR p.price <= :maxPrice)")
    Page<Product> findMarketplaceProducts(
            @Param("shrimpType") String shrimpType,
            @Param("size") String size,
            @Param("search") String search,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice,
            Pageable pageable);

    List<Product> findByUserIdOrderByCreatedAtDesc(UUID userId);

    long countByUserId(UUID userId);

    List<Product> findByBatchId(UUID batchId);

    @Modifying
    @Query("UPDATE Product p SET p.ratingAvg = :avg, p.ratingCount = :count WHERE p.id = :productId")
    void updateRating(@Param("productId") UUID productId, @Param("avg") BigDecimal avg, @Param("count") Integer count);
}
