package com.cronos.service;

import com.cronos.dto.request.CreateReviewRequest;
import com.cronos.entity.Review;
import com.cronos.repository.ProductRepository;
import com.cronos.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviewRepo;
    private final ProductRepository productRepo;

    @Transactional
    public Review createReview(UUID userId, CreateReviewRequest req) {
        if (reviewRepo.findByUserIdAndProductId(userId, req.getProductId()).isPresent())
            throw new RuntimeException("you have already reviewed this product");

        Review review = Review.builder()
                .userId(userId)
                .productId(req.getProductId())
                .rating(req.getRating())
                .comment(req.getComment())
                .build();
        reviewRepo.save(review);

        Object queryResult = reviewRepo.getAverageRatingAndCount(req.getProductId());
        Object[] row;
        if (queryResult instanceof Object[]) {
            Object[] arr = (Object[]) queryResult;
            if (arr.length > 0 && arr[0] instanceof Object[]) {
                row = (Object[]) arr[0];
            } else {
                row = arr;
            }
        } else {
            row = new Object[]{BigDecimal.ZERO, 0};
        }
        BigDecimal avg;
        if (row[0] != null) {
            if (row[0] instanceof BigDecimal) {
                avg = (BigDecimal) row[0];
            } else if (row[0] instanceof Number) {
                avg = BigDecimal.valueOf(((Number) row[0]).doubleValue()).setScale(2, RoundingMode.HALF_UP);
            } else {
                avg = new BigDecimal(row[0].toString()).setScale(2, RoundingMode.HALF_UP);
            }
        } else {
            avg = BigDecimal.ZERO;
        }
        Integer count = (row.length > 1 && row[1] != null) ? ((Number) row[1]).intValue() : 0;
        productRepo.updateRating(req.getProductId(), avg, count);
        return review;
    }

    public List<Review> getProductReviews(UUID productId) { return reviewRepo.findByProductIdOrderByCreatedAtDesc(productId); }
}
