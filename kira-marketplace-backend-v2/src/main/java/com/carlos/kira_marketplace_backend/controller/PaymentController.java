package com.carlos.kira_marketplace_backend.controller;

import com.carlos.kira_marketplace_backend.entity.Payment;
import com.carlos.kira_marketplace_backend.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<Payment>> findAll(@RequestParam(required = false) Long bookingId) {
        if (bookingId != null) {
            return ResponseEntity.ok(List.of(paymentService.findByBookingId(bookingId)));
        }
        return ResponseEntity.ok(paymentService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> findById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.findById(id));
    }

    @PostMapping
    public ResponseEntity<Payment> create(@RequestBody Payment payload) {
        return ResponseEntity.ok(paymentService.create(payload));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Payment> update(@PathVariable Long id, @RequestBody Payment payload) {
        return ResponseEntity.ok(paymentService.update(id, payload));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        paymentService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
