package com.cronos.repository;

import com.cronos.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByProductIdOrderByCreatedAtDesc(UUID productId);
    Optional<Review> findByUserIdAndProductId(UUID userId, UUID productId);

    @Query("SELECT COALESCE(AVG(r.rating), 0), COUNT(r) FROM Review r WHERE r.productId = :productId")
    Object[] getAverageRatingAndCount(@Param("productId") UUID productId);
}
