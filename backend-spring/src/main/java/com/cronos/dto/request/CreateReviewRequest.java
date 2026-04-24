package com.cronos.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.UUID;

@Data
public class CreateReviewRequest {
    @JsonProperty("product_id")
    private UUID productId;

    private Integer rating;

    private String comment;
}
