package com.cronos.util;

import com.cronos.entity.User;
import com.cronos.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        long adminCount = userRepository.findByEmail("admin@cronos.id").stream().count();
        if (adminCount > 0) {
            log.info("Admin user already exists, skipping seed");
            return;
        }

        User admin = User.builder()
                .name("Admin CRONOS")
                .email("admin@cronos.id")
                .password(passwordEncoder.encode("Admin@123"))
                .phone("081234567890")
                .role("admin")
                .isVerified(true)
                .balance(BigDecimal.ZERO)
                .build();

        userRepository.save(admin);
        log.info("Admin user seeded successfully: admin@cronos.id / Admin@123");
    }
}
