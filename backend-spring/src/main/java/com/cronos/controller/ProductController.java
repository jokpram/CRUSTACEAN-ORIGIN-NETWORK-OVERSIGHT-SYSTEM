package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.Product;
import com.cronos.service.ProductService;
import com.cronos.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;
    private final ReviewService reviewService;

    @GetMapping
    public ResponseEntity<?> marketplace(
            @RequestParam(required = false) String page, @RequestParam(required = false) String limit,
            @RequestParam(required = false) String shrimp_type, @RequestParam(required = false) String size,
            @RequestParam(required = false) String search, @RequestParam(required = false) String sort_by,
            @RequestParam(required = false) String min_price, @RequestParam(required = false) String max_price) {
        var result = productService.getMarketplaceProducts(page, limit, shrimp_type, size, search, sort_by, min_price, max_price);
        return ResponseEntity.ok(ApiResponse.success("Products retrieved", result.get("products"), result.get("meta")));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getProduct(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Product retrieved", productService.getProduct(id)));
    }

    @GetMapping("/{id}/reviews")
    public ResponseEntity<?> getReviews(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success("Reviews retrieved", reviewService.getProductReviews(id)));
    }

    @GetMapping("/my")
    public ResponseEntity<?> getMyProducts(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Products retrieved", productService.getMyProducts((UUID) auth.getPrincipal())));
    }

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @RequestBody Product product) {
        return ResponseEntity.ok(ApiResponse.success("Product created", productService.createProduct((UUID) auth.getPrincipal(), product)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(Authentication auth, @PathVariable UUID id, @RequestBody Product req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Product updated", productService.updateProduct((UUID) auth.getPrincipal(), id, req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(Authentication auth, @PathVariable UUID id) {
        try {
            productService.deleteProduct((UUID) auth.getPrincipal(), id);
            return ResponseEntity.ok(ApiResponse.success("Product deleted", null));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
