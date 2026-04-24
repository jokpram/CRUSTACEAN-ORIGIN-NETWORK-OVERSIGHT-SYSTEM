package com.cronos.service;

import com.cronos.dto.request.LoginRequest;
import com.cronos.dto.request.RegisterRequest;
import com.cronos.dto.request.UpdateProfileRequest;
import com.cronos.dto.response.UserResponse;
import com.cronos.entity.User;
import com.cronos.repository.UserRepository;
import com.cronos.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public Map<String, Object> register(RegisterRequest req) {
        if (userRepo.findByEmail(req.getEmail()).isPresent()) {
            throw new RuntimeException("email already registered");
        }
        User user = User.builder()
                .name(req.getName())
                .email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .phone(req.getPhone())
                .role(req.getRole())
                .isVerified("konsumen".equals(req.getRole()))
                .balance(BigDecimal.ZERO)
                .build();
        userRepo.save(user);
        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail(), user.getRole());
        return Map.of("user", UserResponse.fromEntity(user), "token", token);
    }

    public Map<String, Object> login(LoginRequest req) {
        User user = userRepo.findByEmail(req.getEmail())
                .orElseThrow(() -> new RuntimeException("invalid email or password"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new RuntimeException("invalid email or password");
        }
        if (!user.getIsVerified() && ("petambak".equals(user.getRole()) || "logistik".equals(user.getRole()))) {
            throw new RuntimeException("your account is pending verification by admin");
        }
        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail(), user.getRole());
        return Map.of("user", UserResponse.fromEntity(user), "token", token);
    }

    public UserResponse getProfile(UUID userId) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        return UserResponse.fromEntity(user);
    }

    public UserResponse updateProfile(UUID userId, UpdateProfileRequest req) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        if (req.getName() != null && !req.getName().isEmpty()) user.setName(req.getName());
        if (req.getPhone() != null && !req.getPhone().isEmpty()) user.setPhone(req.getPhone());
        if (req.getAddress() != null && !req.getAddress().isEmpty()) user.setAddress(req.getAddress());
        if (req.getAvatar() != null && !req.getAvatar().isEmpty()) user.setAvatar(req.getAvatar());
        userRepo.save(user);
        return UserResponse.fromEntity(user);
    }
}
