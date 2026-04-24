package com.cronos.security;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.UUID;

@Data
@AllArgsConstructor
public class JwtUserDetails {
    private UUID userId;
    private String email;
    private String role;
}
