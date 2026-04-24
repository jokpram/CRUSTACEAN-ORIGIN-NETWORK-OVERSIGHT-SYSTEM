package com.cronos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "traceability_logs")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TraceabilityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("previous_hash")
    @Column(name = "previous_hash", nullable = false, length = 64)
    private String previousHash;

    @JsonProperty("current_hash")
    @Column(name = "current_hash", nullable = false, unique = true, length = 64)
    private String currentHash;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @JsonProperty("event_type")
    @Column(name = "event_type", nullable = false, length = 100)
    private String eventType;

    @JsonProperty("actor_id")
    @Column(name = "actor_id", nullable = false, columnDefinition = "uuid")
    private UUID actorId;

    @JsonProperty("entity_type")
    @Column(name = "entity_type", nullable = false, length = 100)
    private String entityType;

    @JsonProperty("entity_id")
    @Column(name = "entity_id", nullable = false, columnDefinition = "uuid")
    private UUID entityId;

    @JsonProperty("data_payload")
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "data_payload", columnDefinition = "jsonb")
    private String dataPayload;

    @JsonProperty("created_at")
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @JsonIgnore
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id", insertable = false, updatable = false)
    @JsonIgnore
    private User actor;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

