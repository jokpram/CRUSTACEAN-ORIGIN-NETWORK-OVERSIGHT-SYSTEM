package com.cronos.repository;

import com.cronos.entity.ShrimpType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ShrimpTypeRepository extends JpaRepository<ShrimpType, UUID> {
    List<ShrimpType> findAllByOrderByNameAsc();
}
