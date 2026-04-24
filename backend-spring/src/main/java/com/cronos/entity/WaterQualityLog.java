package com.cronos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "water_quality_logs")
@SQLDelete(sql = "UPDATE water_quality_logs SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WaterQualityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("cultivation_cycle_id")
    @Column(name = "cultivation_cycle_id", nullable = false, columnDefinition = "uuid")
    private UUID cultivationCycleId;

    @Column(precision = 5, scale = 2)
    private BigDecimal temperature;

    @Column(precision = 4, scale = 2)
    private BigDecimal ph;

    @Column(precision = 5, scale = 2)
    private BigDecimal salinity;

    @JsonProperty("dissolved_oxygen")
    @Column(name = "dissolved_oxygen", precision = 5, scale = 2)
    private BigDecimal dissolvedOxygen;

    @JsonProperty("recorded_at")
    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @JsonProperty("created_at")
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @JsonIgnore
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cultivation_cycle_id", insertable = false, updatable = false)
    @JsonIgnore
    private CultivationCycle cultivationCycle;

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

