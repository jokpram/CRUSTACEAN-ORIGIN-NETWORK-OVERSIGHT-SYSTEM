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
@Table(name = "feed_logs")
@SQLDelete(sql = "UPDATE feed_logs SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class FeedLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("cultivation_cycle_id")
    @Column(name = "cultivation_cycle_id", nullable = false, columnDefinition = "uuid")
    private UUID cultivationCycleId;

    @JsonProperty("feed_type")
    @Column(name = "feed_type", nullable = false, length = 255)
    private String feedType;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity;

    @JsonProperty("feeding_time")
    @Column(name = "feeding_time", nullable = false)
    private LocalDateTime feedingTime;

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

