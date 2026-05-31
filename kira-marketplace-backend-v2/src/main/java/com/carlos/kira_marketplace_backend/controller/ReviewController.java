package com.carlos.kira_marketplace_backend.controller;

import com.carlos.kira_marketplace_backend.entity.Review;
import com.carlos.kira_marketplace_backend.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping
    public ResponseEntity<List<Review>> findAll(@RequestParam(required = false) Long professionalId) {
        if (professionalId != null) {
            return ResponseEntity.ok(reviewService.findByProfessionalId(professionalId));
        }
        return ResponseEntity.ok(reviewService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Review> findById(@PathVariable Long id) {
        return ResponseEntity.ok(reviewService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Review> create(@RequestBody Review payload) {
        return ResponseEntity.ok(reviewService.create(payload));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Review> update(@PathVariable Long id, @RequestBody Review payload) {
        return ResponseEntity.ok(reviewService.update(id, payload));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        reviewService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
