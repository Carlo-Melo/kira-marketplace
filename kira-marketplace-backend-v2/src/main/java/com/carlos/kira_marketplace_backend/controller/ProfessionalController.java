package com.carlos.kira_marketplace_backend.controller;

import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.service.ProfessionalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/professionals")
@RequiredArgsConstructor
public class ProfessionalController {

    private final ProfessionalService professionalService;

    @GetMapping
    public ResponseEntity<List<Professional>> findAll(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Double minRating
    ) {
        if (city != null && !city.isBlank()) {
            return ResponseEntity.ok(professionalService.findByCity(city));
        }
        if (minRating != null) {
            return ResponseEntity.ok(professionalService.findByMinRating(minRating));
        }
        return ResponseEntity.ok(professionalService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Professional> findById(@PathVariable Long id) {
        return ResponseEntity.ok(professionalService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Professional> create(@RequestBody Professional payload) {
        return ResponseEntity.ok(professionalService.create(payload));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Professional> update(@PathVariable Long id, @RequestBody Professional payload) {
        return ResponseEntity.ok(professionalService.update(id, payload));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        professionalService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
