package com.cronos.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class CreateOrderRequest {
    @NotBlank
    @JsonProperty("shipping_address")
    private String shippingAddress;

    private String notes;

    @NotEmpty
    private List<OrderItemRequest> items;

    @Data
    public static class OrderItemRequest {
        @JsonProperty("product_id")
        private UUID productId;
        private Integer quantity;
    }
}
