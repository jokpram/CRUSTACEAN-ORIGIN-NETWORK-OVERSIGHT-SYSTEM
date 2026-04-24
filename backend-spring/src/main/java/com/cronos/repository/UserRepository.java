package com.cronos.repository;

import com.cronos.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.role <> 'admin' " +
           "AND (:role IS NULL OR :role = '' OR u.role = :role) " +
           "AND (:search IS NULL OR :search = '' OR LOWER(u.name) LIKE LOWER(CONCAT('%',:search,'%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%',:search,'%')))")
    Page<User> findAllFiltered(@Param("role") String role, @Param("search") String search, Pageable pageable);

    List<User> findByIsVerifiedFalseAndRoleIn(List<String> roles);

    @Query("SELECT u.role, COUNT(u) FROM User u GROUP BY u.role")
    List<Object[]> countByRole();

    List<User> findByRoleNot(String role);
}
