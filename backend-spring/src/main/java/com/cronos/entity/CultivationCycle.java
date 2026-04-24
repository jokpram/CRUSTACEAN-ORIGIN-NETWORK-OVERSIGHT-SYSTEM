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
import java.util.List;
import java.util.UUID;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "cultivation_cycles")
@SQLDelete(sql = "UPDATE cultivation_cycles SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CultivationCycle {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("pond_id")
    @Column(name = "pond_id", nullable = false, columnDefinition = "uuid")
    private UUID pondId;

    @JsonProperty("shrimp_type_id")
    @Column(name = "shrimp_type_id", nullable = false, columnDefinition = "uuid")
    private UUID shrimpTypeId;

    @JsonProperty("start_date")
    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;

    @JsonProperty("expected_end_date")
    @Column(name = "expected_end_date")
    private LocalDateTime expectedEndDate;

    @JsonProperty("actual_end_date")
    @Column(name = "actual_end_date")
    private LocalDateTime actualEndDate;

    @Column(length = 50)
    @Builder.Default
    private String status = "active";

    @Column(precision = 10, scale = 2)
    private BigDecimal density;

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
    @JoinColumn(name = "pond_id", insertable = false, updatable = false)
    @JsonIgnore
    private Pond pond;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shrimp_type_id", insertable = false, updatable = false)
    @JsonProperty("shrimp_type")
    private ShrimpType shrimpType;

    @OneToMany(mappedBy = "cultivationCycle", fetch = FetchType.LAZY)
    @JsonProperty("feed_logs")
    @JsonIgnore
    private List<FeedLog> feedLogs;

    @OneToMany(mappedBy = "cultivationCycle", fetch = FetchType.LAZY)
    @JsonProperty("water_quality_logs")
    @JsonIgnore
    private List<WaterQualityLog> waterQualityLogs;

    @OneToMany(mappedBy = "cultivationCycle", fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Harvest> harvests;

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

