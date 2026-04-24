package com.cronos.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class CreateShipmentRequest {
    @JsonProperty("order_id")
    private UUID orderId;

    @JsonProperty("courier_id")
    private UUID courierId;

    @JsonProperty("tracking_number")
    private String trackingNumber;

    @JsonProperty("estimated_delivery")
    private LocalDateTime estimatedDelivery;
}
