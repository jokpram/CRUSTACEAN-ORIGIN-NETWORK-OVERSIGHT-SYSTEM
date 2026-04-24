package com.cronos.repository;

import com.cronos.entity.Withdrawal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface WithdrawalRepository extends JpaRepository<Withdrawal, UUID> {
    List<Withdrawal> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<Withdrawal> findAllByOrderByCreatedAtDesc();
}
