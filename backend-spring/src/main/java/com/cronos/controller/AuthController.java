package com.cronos.controller;

import com.cronos.dto.request.LoginRequest;
import com.cronos.dto.request.RegisterRequest;
import com.cronos.dto.request.UpdateProfileRequest;
import com.cronos.dto.response.ApiResponse;
import com.cronos.security.JwtUserDetails;
import com.cronos.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        try {
            var result = authService.register(req);
            return ResponseEntity.ok(ApiResponse.success("Registration successful", result));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest req) {
        try {
            var result = authService.login(req);
            return ResponseEntity.ok(ApiResponse.success("Login successful", result));
        } catch (RuntimeException e) {
            return ResponseEntity.status(401).body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success("Profile retrieved", authService.getProfile(userId)));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(Authentication auth, @RequestBody UpdateProfileRequest req) {
        UUID userId = (UUID) auth.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success("Profile updated", authService.updateProfile(userId, req)));
    }
}
