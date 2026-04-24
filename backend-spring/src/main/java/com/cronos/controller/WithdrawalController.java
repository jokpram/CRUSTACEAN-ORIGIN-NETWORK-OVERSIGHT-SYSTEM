package com.cronos.controller;

import com.cronos.dto.response.ApiResponse;
import com.cronos.entity.Withdrawal;
import com.cronos.service.WithdrawalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/withdrawals")
@RequiredArgsConstructor
public class WithdrawalController {
    private final WithdrawalService withdrawalService;

    @PostMapping
    public ResponseEntity<?> create(Authentication auth, @RequestBody Withdrawal req) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Withdrawal request created", withdrawalService.createWithdrawal((UUID) auth.getPrincipal(), req)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }

    @GetMapping
    public ResponseEntity<?> getMyWithdrawals(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.success("Withdrawals retrieved", withdrawalService.getMyWithdrawals((UUID) auth.getPrincipal())));
    }
}
