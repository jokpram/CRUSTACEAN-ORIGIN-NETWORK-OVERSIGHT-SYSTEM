package com.cronos.service;

import com.cronos.dto.request.CreateUserRequest;
import com.cronos.dto.response.PaginationMeta;
import com.cronos.dto.response.UserResponse;
import com.cronos.entity.User;
import com.cronos.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;

    public Map<String, Object> getAllUsers(int page, int limit, String role, String search) {
        Page<User> usersPage = userRepo.findAllFiltered(
                role, search,
                PageRequest.of(page - 1, limit, Sort.by(Sort.Direction.DESC, "createdAt")));
        List<UserResponse> responses = usersPage.getContent().stream()
                .map(UserResponse::fromEntity).collect(Collectors.toList());
        PaginationMeta meta = PaginationMeta.builder()
                .currentPage(page).perPage(limit)
                .total(usersPage.getTotalElements())
                .totalPages(usersPage.getTotalPages()).build();
        return Map.of("users", responses, "meta", meta);
    }

    public UserResponse createUser(CreateUserRequest req) {
        if (userRepo.findByEmail(req.getEmail()).isPresent()) {
            throw new RuntimeException("email already registered");
        }
        User user = User.builder()
                .name(req.getName()).email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .phone(req.getPhone()).role(req.getRole())
                .isVerified(true).balance(BigDecimal.ZERO).build();
        userRepo.save(user);
        return UserResponse.fromEntity(user);
    }

    public UserResponse verifyUser(UUID userId) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        if (!"petambak".equals(user.getRole()) && !"logistik".equals(user.getRole())) {
            throw new RuntimeException("only petambak and logistik accounts need verification");
        }
        user.setIsVerified(true);
        userRepo.save(user);
        return UserResponse.fromEntity(user);
    }

    public UserResponse updateUserStatus(UUID userId, boolean isVerified) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        user.setIsVerified(isVerified);
        userRepo.save(user);
        return UserResponse.fromEntity(user);
    }

    public int[] parsePagination(String pageStr, String limitStr) {
        int page = 1, limit = 10;
        try { page = Integer.parseInt(pageStr); } catch (Exception ignored) {}
        try { limit = Integer.parseInt(limitStr); } catch (Exception ignored) {}
        if (page < 1) page = 1;
        if (limit < 1) limit = 10;
        if (limit > 100) limit = 100;
        return new int[]{page, limit};
    }
}
