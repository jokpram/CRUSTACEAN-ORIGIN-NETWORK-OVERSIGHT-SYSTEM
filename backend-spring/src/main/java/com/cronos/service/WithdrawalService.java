package com.cronos.service;

import com.cronos.entity.Withdrawal;
import com.cronos.entity.User;
import com.cronos.repository.WithdrawalRepository;
import com.cronos.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class WithdrawalService {
    private final WithdrawalRepository withdrawalRepo;
    private final UserRepository userRepo;

    public Withdrawal createWithdrawal(UUID userId, Withdrawal req) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("user not found"));
        if (user.getBalance().compareTo(req.getAmount()) < 0) throw new RuntimeException("insufficient balance");
        req.setUserId(userId); req.setStatus("pending");
        withdrawalRepo.save(req);
        return req;
    }

    public List<Withdrawal> getMyWithdrawals(UUID userId) { return withdrawalRepo.findByUserIdOrderByCreatedAtDesc(userId); }
    public List<Withdrawal> getAllWithdrawals() { return withdrawalRepo.findAllByOrderByCreatedAtDesc(); }

    @Transactional
    public Withdrawal updateWithdrawal(UUID withdrawalId, String status, String notes) {
        Withdrawal withdrawal = withdrawalRepo.findById(withdrawalId).orElseThrow(() -> new RuntimeException("withdrawal not found"));
        if (!"pending".equals(withdrawal.getStatus()) && !"approved".equals(withdrawal.getStatus()))
            throw new RuntimeException("withdrawal cannot be updated from current status");
        if (!Set.of("approved", "rejected", "paid").contains(status)) throw new RuntimeException("invalid status");

        String oldStatus = withdrawal.getStatus();
        withdrawal.setStatus(status); withdrawal.setNotes(notes); withdrawal.setProcessedAt(LocalDateTime.now());

        if (("approved".equals(status) || "paid".equals(status)) && "pending".equals(oldStatus)) {
            User user = userRepo.findById(withdrawal.getUserId()).get();
            if (user.getBalance().compareTo(withdrawal.getAmount()) < 0) throw new RuntimeException("user has insufficient balance");
            user.setBalance(user.getBalance().subtract(withdrawal.getAmount()));
            userRepo.save(user);
        }
        if ("rejected".equals(status) && "approved".equals(oldStatus)) {
            User user = userRepo.findById(withdrawal.getUserId()).get();
            user.setBalance(user.getBalance().add(withdrawal.getAmount()));
            userRepo.save(user);
        }
        withdrawalRepo.save(withdrawal);
        return withdrawal;
    }
}
