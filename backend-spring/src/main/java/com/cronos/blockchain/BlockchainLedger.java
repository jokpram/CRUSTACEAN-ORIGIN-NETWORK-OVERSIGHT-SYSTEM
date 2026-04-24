package com.cronos.blockchain;

import com.cronos.entity.Batch;
import com.cronos.entity.CultivationCycle;
import com.cronos.entity.CronosOrder;
import com.cronos.entity.Harvest;
import com.cronos.entity.OrderItem;
import com.cronos.entity.Pond;
import com.cronos.entity.Product;
import com.cronos.entity.TraceabilityLog;
import com.cronos.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.*;

@Component
@RequiredArgsConstructor
@Slf4j
public class BlockchainLedger {

    private final TraceabilityLogRepository traceabilityLogRepo;
    private final BatchRepository batchRepo;
    private final HarvestRepository harvestRepo;
    private final CultivationCycleRepository cultivationRepo;
    private final PondRepository pondRepo;
    private final ProductRepository productRepo;
    private final OrderItemRepository orderItemRepo;
    private final ObjectMapper objectMapper;

    public void recordEvent(String eventType, UUID actorId, String entityType, UUID entityId, Object dataPayload) {
        try {
            String payloadJson = objectMapper.writeValueAsString(dataPayload);
            String previousHash = getLastHash();
            LocalDateTime timestamp = LocalDateTime.now();
            String currentHash = calculateHash(previousHash, payloadJson, eventType, timestamp);

            TraceabilityLog traceLog = TraceabilityLog.builder()
                    .previousHash(previousHash)
                    .currentHash(currentHash)
                    .timestamp(timestamp)
                    .eventType(eventType)
                    .actorId(actorId)
                    .entityType(entityType)
                    .entityId(entityId)
                    .dataPayload(payloadJson)
                    .build();

            traceabilityLogRepo.save(traceLog);
        } catch (Exception e) {
            log.error("Failed to record blockchain event: {}", e.getMessage());
        }
    }

    private String getLastHash() {
        return traceabilityLogRepo.findTopByOrderByCreatedAtDesc()
                .map(TraceabilityLog::getCurrentHash)
                .orElse("0000000000000000000000000000000000000000000000000000000000000000");
    }

    private String calculateHash(String previousHash, String dataPayload, String eventType, LocalDateTime timestamp) {
        try {
            String data = previousHash + dataPayload + eventType + timestamp.toString();
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to calculate hash", e);
        }
    }

    public List<TraceabilityLog> getTraceByBatchCode(String batchCode) {
        Optional<Batch> batchOpt = batchRepo.findByBatchCode(batchCode);
        if (batchOpt.isEmpty()) {
            throw new RuntimeException("batch not found");
        }
        Batch batch = batchOpt.get();
        List<TraceabilityLog> logs = new ArrayList<>();

        logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("batch", batch.getId()));

        harvestRepo.findById(batch.getHarvestId()).ifPresent(harvest -> {
            logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("harvest", harvest.getId()));
            logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("cultivation", harvest.getCultivationCycleId()));

            cultivationRepo.findById(harvest.getCultivationCycleId()).ifPresent(cycle -> {
                pondRepo.findById(cycle.getPondId()).ifPresent(pond -> {
                    logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("farm", pond.getFarmId()));
                });
            });
        });

        List<Product> products = productRepo.findByBatchId(batch.getId());
        for (Product product : products) {
            logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("product", product.getId()));
            List<OrderItem> orderItems = orderItemRepo.findByProductId(product.getId());
            for (OrderItem item : orderItems) {
                logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("order", item.getOrderId()));
                logs.addAll(traceabilityLogRepo.findByEntityTypeAndEntityId("shipment", item.getOrderId()));
            }
        }

        logs.sort(Comparator.comparing(TraceabilityLog::getTimestamp));
        return logs;
    }

    public boolean verifyChain() {
        List<TraceabilityLog> logs = traceabilityLogRepo.findAllByOrderByCreatedAtAsc();
        for (int i = 1; i < logs.size(); i++) {
            if (!logs.get(i).getPreviousHash().equals(logs.get(i - 1).getCurrentHash())) {
                throw new RuntimeException("Chain broken at log " + logs.get(i).getId());
            }
        }
        return true;
    }
}
