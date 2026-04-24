package com.cronos.service;

import com.cronos.entity.ShrimpType;
import com.cronos.repository.ShrimpTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShrimpTypeService {
    private final ShrimpTypeRepository repo;

    public ShrimpType create(ShrimpType st) { repo.save(st); return st; }
    public List<ShrimpType> getAll() { return repo.findAllByOrderByNameAsc(); }
    public ShrimpType update(UUID id, ShrimpType req) {
        ShrimpType st = repo.findById(id).orElseThrow(() -> new RuntimeException("shrimp type not found"));
        if (req.getName() != null && !req.getName().isEmpty()) st.setName(req.getName());
        if (req.getDescription() != null && !req.getDescription().isEmpty()) st.setDescription(req.getDescription());
        if (req.getImage() != null && !req.getImage().isEmpty()) st.setImage(req.getImage());
        repo.save(st); return st;
    }
    public void delete(UUID id) { repo.deleteById(id); }
}
