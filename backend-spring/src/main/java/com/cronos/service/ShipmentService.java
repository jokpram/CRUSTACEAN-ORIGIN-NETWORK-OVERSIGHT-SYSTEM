package com.cronos.service;

import com.cronos.blockchain.BlockchainLedger;
import com.cronos.dto.request.CreateShipmentRequest;
import com.cronos.entity.*;
import com.cronos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ShipmentService {
    private final ShipmentRepository shipmentRepo;
    private final ShipmentLogRepository shipmentLogRepo;
    private final OrderRepository orderRepo;
    private final BlockchainLedger ledger;

    public Shipment createShipment(CreateShipmentRequest req) {
        CronosOrder order = orderRepo.findById(req.getOrderId()).orElseThrow(() -> new RuntimeException("order not found"));
        if (!"paid".equals(order.getStatus()) && !"processing".equals(order.getStatus()) && !"pending".equals(order.getStatus()))
            throw new RuntimeException("order must be paid or pending before shipping");

        Shipment shipment = Shipment.builder().orderId(req.getOrderId()).courierId(req.getCourierId())
                .trackingNumber(req.getTrackingNumber()).status("pending").estimatedDelivery(req.getEstimatedDelivery()).build();
        shipmentRepo.save(shipment);
        order.setStatus("processing"); orderRepo.save(order);
        return shipmentRepo.findById(shipment.getId()).get();
    }

    @Transactional
    public Shipment updateShipmentStatus(UUID courierId, UUID shipmentId, String status, String location, String notes) {
        Shipment shipment = shipmentRepo.findById(shipmentId).orElseThrow(() -> new RuntimeException("shipment not found"));
        if (shipment.getCourierId() == null || !shipment.getCourierId().equals(courierId)) throw new RuntimeException("unauthorized");

        Map<String, List<String>> validTransitions = Map.of("pending", List.of("pickup"), "pickup", List.of("transit"), "transit", List.of("delivered"));
        List<String> allowed = validTransitions.get(shipment.getStatus());
        if (allowed == null) throw new RuntimeException("shipment already in final state");
        if (!allowed.contains(status)) throw new RuntimeException("invalid status transition from " + shipment.getStatus() + " to " + status);

        shipment.setStatus(status);
        if ("delivered".equals(status)) {
            shipment.setActualDelivery(LocalDateTime.now());
            CronosOrder order = orderRepo.findById(shipment.getOrderId()).get();
            order.setStatus("delivered"); orderRepo.save(order);
        } else if ("pickup".equals(status)) {
            CronosOrder order = orderRepo.findById(shipment.getOrderId()).get();
            order.setStatus("shipped"); orderRepo.save(order);
        }
        shipmentRepo.save(shipment);

        ShipmentLog log = ShipmentLog.builder().shipmentId(shipmentId).status(status).location(location).notes(notes).timestamp(LocalDateTime.now()).build();
        shipmentLogRepo.save(log);

        ledger.recordEvent("shipment_" + status, courierId, "shipment", shipment.getOrderId(), Map.of("status", status, "location", location != null ? location : ""));
        return shipmentRepo.findById(shipmentId).get();
    }

    public List<Shipment> getMyShipments(UUID courierId) { return shipmentRepo.findByCourierIdOrderByCreatedAtDesc(courierId); }
    public List<Shipment> getAllShipments() { return shipmentRepo.findAllByOrderByCreatedAtDesc(); }
    public List<ShipmentLog> getShipmentLogs(UUID shipmentId) { return shipmentLogRepo.findByShipmentIdOrderByTimestampDesc(shipmentId); }
}
