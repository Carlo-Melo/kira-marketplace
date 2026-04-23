package com.carlos.kira_marketplace_backend.controller;

import com.carlos.kira_marketplace_backend.entity.Service;
import com.carlos.kira_marketplace_backend.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/services")
@RequiredArgsConstructor
public class CatalogController {

    private final CatalogService catalogService;

    @GetMapping
    public ResponseEntity<List<Service>> findAll(
            @RequestParam(required = false) Long professionalId,
            @RequestParam(required = false) String q
    ) {
        if (professionalId != null) {
            return ResponseEntity.ok(catalogService.findByProfessionalId(professionalId));
        }
        if (q != null && !q.isBlank()) {
            return ResponseEntity.ok(catalogService.searchByName(q));
        }
        return ResponseEntity.ok(catalogService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Service> findById(@PathVariable Long id) {
        return ResponseEntity.ok(catalogService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Service> create(@RequestBody Service payload) {
        return ResponseEntity.ok(catalogService.create(payload));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Service> update(@PathVariable Long id, @RequestBody Service payload) {
        return ResponseEntity.ok(catalogService.update(id, payload));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        catalogService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
