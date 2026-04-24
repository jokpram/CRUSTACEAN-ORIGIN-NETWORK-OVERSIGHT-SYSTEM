package com.cronos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "shipments")
@SQLDelete(sql = "UPDATE shipments SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Shipment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("order_id")
    @Column(name = "order_id", nullable = false, columnDefinition = "uuid")
    private UUID orderId;

    @JsonProperty("courier_id")
    @Column(name = "courier_id", columnDefinition = "uuid")
    private UUID courierId;

    @JsonProperty("tracking_number")
    @Column(name = "tracking_number", length = 100)
    private String trackingNumber;

    @Column(length = 50)
    @Builder.Default
    private String status = "pending";

    @JsonProperty("estimated_delivery")
    @Column(name = "estimated_delivery")
    private LocalDateTime estimatedDelivery;

    @JsonProperty("actual_delivery")
    @Column(name = "actual_delivery")
    private LocalDateTime actualDelivery;

    @JsonProperty("created_at")
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @JsonIgnore
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", insertable = false, updatable = false)
    @JsonIgnore
    private CronosOrder order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "courier_id", insertable = false, updatable = false)
    @JsonIgnore
    private User courier;

    @OneToMany(mappedBy = "shipment", fetch = FetchType.LAZY)
    @JsonProperty("shipment_logs")
    private List<ShipmentLog> shipmentLogs;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

