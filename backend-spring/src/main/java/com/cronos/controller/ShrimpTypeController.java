package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.service.ShrimpTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/shrimp-types")
@RequiredArgsConstructor
public class ShrimpTypeController {
    private final ShrimpTypeService shrimpTypeService;

    @GetMapping
    public ResponseEntity<?> getAll() {
        return ResponseEntity.ok(ApiResponse.success("Shrimp types retrieved", shrimpTypeService.getAll()));
    }
}
