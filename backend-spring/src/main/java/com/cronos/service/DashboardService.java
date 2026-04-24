package com.cronos.service;

import com.cronos.entity.CronosOrder;
import com.cronos.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final UserRepository userRepo;
    private final OrderRepository orderRepo;
    private final FarmRepository farmRepo;
    private final ProductRepository productRepo;
    private final CultivationCycleRepository cultivationRepo;
    private final HarvestRepository harvestRepo;
    private final ShipmentRepository shipmentRepo;

    private static final List<String> PAID_STATUSES = List.of("paid", "processing", "shipped", "delivered", "completed");

    public Map<String, Object> getAdminDashboard() {
        Map<String, Long> userCounts = userRepo.countByRole().stream().collect(Collectors.toMap(r -> (String) r[0], r -> (Long) r[1]));
        Map<String, Long> orderCounts = orderRepo.countByStatus().stream().collect(Collectors.toMap(r -> (String) r[0], r -> (Long) r[1]));
        BigDecimal totalRevenue = orderRepo.sumTotalRevenue(PAID_STATUSES);
        return Map.of("users", userCounts, "orders", orderCounts, "total_revenue", totalRevenue != null ? totalRevenue : BigDecimal.ZERO);
    }

    public Map<String, Object> getPetambakDashboard(UUID userId) {
        return Map.of(
            "total_farms", farmRepo.countByUserId(userId),
            "total_products", productRepo.countByUserId(userId),
            "total_cultivations", cultivationRepo.countByUserId(userId),
            "total_harvests", harvestRepo.countByUserId(userId),
            "total_revenue", Optional.ofNullable(orderRepo.sumRevenueBySellerIdAndStatuses(userId, PAID_STATUSES)).orElse(BigDecimal.ZERO)
        );
    }

    public Map<String, Object> getLogistikDashboard(UUID userId) {
        Map<String, Long> statusCounts = shipmentRepo.countByStatusAndCourierId(userId).stream().collect(Collectors.toMap(r -> (String) r[0], r -> (Long) r[1]));
        return Map.of("total_shipments", shipmentRepo.countByCourierId(userId), "shipment_status", statusCounts);
    }

    public Map<String, Object> getKonsumenDashboard(UUID userId) {
        var page = orderRepo.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(0, 5));
        Map<String, Long> statusCounts = page.getContent().stream().collect(Collectors.groupingBy(CronosOrder::getStatus, Collectors.counting()));
        return Map.of("total_orders", page.getTotalElements(), "recent_orders", page.getContent(), "order_status", statusCounts);
    }
}
