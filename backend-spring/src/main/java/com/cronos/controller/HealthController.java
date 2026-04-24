package com.cronos.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HealthController {
    @GetMapping("/")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of("success", true, "message", "CRONOS Backend (Spring Boot) is running"));
    }
}
