package com.cronos.repository;

import com.cronos.entity.MidtransTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MidtransTransactionRepository extends JpaRepository<MidtransTransaction, UUID> {
    Optional<MidtransTransaction> findByOrderIdMidtrans(String orderIdMidtrans);
}
