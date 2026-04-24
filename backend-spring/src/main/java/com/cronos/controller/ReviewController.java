package com.cronos.controller;

import com.cronos.dto.request.CreateReviewRequest;
import com.cronos.dto.response.ApiResponse;
import com.cronos.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {
    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @RequestBody CreateReviewRequest req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Review created", reviewService.createReview((UUID) auth.getPrincipal(), req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
