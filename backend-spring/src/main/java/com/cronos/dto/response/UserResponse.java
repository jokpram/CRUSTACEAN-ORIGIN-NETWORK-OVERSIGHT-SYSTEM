package com.cronos.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class UserResponse {
    private UUID id;
    private String name;
    private String email;
    private String phone;
    private String role;
    @JsonProperty("is_verified")
    private Boolean isVerified;
    private String address;
    private String avatar;
    private BigDecimal balance;
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    public static UserResponse fromEntity(com.cronos.entity.User user) {
        return UserResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .isVerified(user.getIsVerified())
                .address(user.getAddress())
                .avatar(user.getAvatar())
                .balance(user.getBalance())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
