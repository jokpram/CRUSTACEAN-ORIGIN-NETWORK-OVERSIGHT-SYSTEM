package com.cronos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "midtrans_transactions")
@SQLDelete(sql = "UPDATE midtrans_transactions SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MidtransTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @JsonProperty("payment_id")
    @Column(name = "payment_id", nullable = false, unique = true, columnDefinition = "uuid")
    private UUID paymentId;

    @JsonProperty("order_id_midtrans")
    @Column(name = "order_id_midtrans", unique = true, length = 100)
    private String orderIdMidtrans;

    @JsonProperty("snap_token")
    @Column(name = "snap_token", length = 500)
    private String snapToken;

    @JsonProperty("snap_url")
    @Column(name = "snap_url", length = 500)
    private String snapUrl;

    @JsonProperty("transaction_status")
    @Column(name = "transaction_status", length = 50)
    private String transactionStatus;

    @JsonProperty("payment_type")
    @Column(name = "payment_type", length = 50)
    private String paymentType;

    @JsonProperty("fraud_status")
    @Column(name = "fraud_status", length = 50)
    private String fraudStatus;

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
    @JoinColumn(name = "payment_id", insertable = false, updatable = false)
    @JsonIgnore
    private Payment payment;

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

