package com.cronos.security;

import com.cronos.dto.response.ApiResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final ObjectMapper objectMapper;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    objectMapper.writeValue(response.getOutputStream(),
                            ApiResponse.error("Authorization header is required"));
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    objectMapper.writeValue(response.getOutputStream(),
                            ApiResponse.error("You don't have permission to access this resource"));
                })
            )
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/", "/api/auth/register", "/api/auth/login").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/products", "/api/products/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/shrimp-types").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/traceability/**").permitAll()
                .requestMatchers("/api/payments/midtrans/webhook").permitAll()
                .requestMatchers("/api/chat/ws/**").permitAll()
                .requestMatchers("/uploads/**", "/error").permitAll()

                // Admin endpoints
                .requestMatchers("/api/admin/**").hasRole("ADMIN")

                // Petambak endpoints (use method-qualified matchers)
                .requestMatchers(HttpMethod.GET, "/api/farms", "/api/farms/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/farms", "/api/farms/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.PUT, "/api/farms", "/api/farms/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.DELETE, "/api/farms/**").hasRole("PETAMBAK")

                .requestMatchers(HttpMethod.GET, "/api/cultivations", "/api/cultivations/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/cultivations", "/api/cultivations/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.PUT, "/api/cultivations", "/api/cultivations/**").hasRole("PETAMBAK")

                .requestMatchers(HttpMethod.GET, "/api/harvests", "/api/harvests/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/harvests", "/api/harvests/**").hasRole("PETAMBAK")

                .requestMatchers(HttpMethod.GET, "/api/batches", "/api/batches/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/batches", "/api/batches/**").hasRole("PETAMBAK")

                .requestMatchers(HttpMethod.GET, "/api/products/my").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/products").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.PUT, "/api/products/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.DELETE, "/api/products/**").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.GET, "/api/sales").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.GET, "/api/dashboard/petambak").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.POST, "/api/withdrawals").hasRole("PETAMBAK")
                .requestMatchers(HttpMethod.GET, "/api/withdrawals").hasRole("PETAMBAK")

                // Logistik endpoints
                .requestMatchers(HttpMethod.GET, "/api/dashboard/logistik").hasRole("LOGISTIK")
                .requestMatchers(HttpMethod.GET, "/api/shipments").hasRole("LOGISTIK")
                .requestMatchers(HttpMethod.PUT, "/api/shipments/*/status").hasRole("LOGISTIK")
                .requestMatchers(HttpMethod.GET, "/api/shipments/*/logs").hasRole("LOGISTIK")

                // Konsumen endpoints
                .requestMatchers(HttpMethod.GET, "/api/dashboard/konsumen").hasRole("KONSUMEN")
                .requestMatchers("/api/orders", "/api/orders/**").hasRole("KONSUMEN")
                .requestMatchers(HttpMethod.POST, "/api/payments/create").hasRole("KONSUMEN")
                .requestMatchers(HttpMethod.GET, "/api/payments/**").hasRole("KONSUMEN")
                .requestMatchers(HttpMethod.POST, "/api/reviews").hasRole("KONSUMEN")

                // Chat - any authenticated user
                .requestMatchers("/api/chat/**").authenticated()

                // Any authenticated user
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
