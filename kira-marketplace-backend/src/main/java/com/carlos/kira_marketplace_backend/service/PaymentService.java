package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.entity.Payment;
import com.carlos.kira_marketplace_backend.enums.PaymentStatus;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.BookingRepository;
import com.carlos.kira_marketplace_backend.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;

    public List<Payment> findAll() {
        return paymentRepository.findAll();
    }

    public Payment findById(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found: " + id));
    }

    public Payment findByBookingId(Long bookingId) {
        return paymentRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found for booking: " + bookingId));
    }

    public Payment create(Payment payload) {
        Long bookingId = payload.getBooking() == null ? null : payload.getBooking().getId();
        if (bookingId == null) {
            throw new IllegalArgumentException("booking.id is required");
        }
        if (paymentRepository.findByBookingId(bookingId).isPresent()) {
            throw new IllegalArgumentException("Booking already has a payment");
        }

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + bookingId));
        payload.setBooking(booking);
        if (payload.getStatus() == null) {
            payload.setStatus(PaymentStatus.PENDING);
        }
        payload.setCreatedAt(LocalDateTime.now());
        return paymentRepository.save(payload);
    }

    public Payment update(Long id, Payment payload) {
        Payment current = findById(id);
        current.setAmount(payload.getAmount());
        current.setMethod(payload.getMethod());
        current.setStatus(payload.getStatus());
        current.setTransactionId(payload.getTransactionId());
        return paymentRepository.save(current);
    }

    public void delete(Long id) {
        if (!paymentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Payment not found: " + id);
        }
        paymentRepository.deleteById(id);
    }
}
