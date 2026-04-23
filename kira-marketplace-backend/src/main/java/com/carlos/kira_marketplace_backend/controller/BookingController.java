package com.carlos.kira_marketplace_backend.controller;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @GetMapping
    public ResponseEntity<List<Booking>> findAll(
            @RequestParam(required = false) Long clientId,
            @RequestParam(required = false) Long professionalId
    ) {
        if (clientId != null) {
            return ResponseEntity.ok(bookingService.findByClientId(clientId));
        }
        if (professionalId != null) {
            return ResponseEntity.ok(bookingService.findByProfessionalId(professionalId));
        }
        return ResponseEntity.ok(bookingService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Booking> findById(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Booking> create(@RequestBody Booking payload) {
        return ResponseEntity.ok(bookingService.create(payload));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Booking> update(@PathVariable Long id, @RequestBody Booking payload) {
        return ResponseEntity.ok(bookingService.update(id, payload));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        bookingService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
