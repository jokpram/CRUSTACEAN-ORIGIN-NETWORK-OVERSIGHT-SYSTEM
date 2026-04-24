package com.cronos.controller;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/traceability")
@RequiredArgsConstructor
public class TraceabilityController {
    private final BlockchainLedger ledger;

    @GetMapping("/{batchCode}")
    public ResponseEntity<?> trace(@PathVariable String batchCode) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Traceability data retrieved", ledger.getTraceByBatchCode(batchCode)));
        } catch (RuntimeException e) { return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage())); }
    }
}
