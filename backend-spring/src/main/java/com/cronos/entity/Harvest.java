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
@Table(name = "harvests")
@SQLDelete(sql = "UPDATE harvests SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Harvest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("cultivation_cycle_id")
    @Column(name = "cultivation_cycle_id", nullable = false, columnDefinition = "uuid")
    private UUID cultivationCycleId;

    @JsonProperty("harvest_date")
    @Column(name = "harvest_date", nullable = false)
    private LocalDateTime harvestDate;

    @JsonProperty("total_weight")
    @Column(name = "total_weight", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalWeight;

    @JsonProperty("shrimp_size")
    @Column(name = "shrimp_size", length = 50)
    private String shrimpSize;

    @JsonProperty("quality_grade")
    @Column(name = "quality_grade", length = 10)
    private String qualityGrade;

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
    @JsonProperty("cultivation_cycle")
    private CultivationCycle cultivationCycle;

    @OneToMany(mappedBy = "harvest", fetch = FetchType.LAZY)
    @JsonProperty("batches")
    private List<Batch> batches;

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

