package com.carlos.kira_marketplace_backend.repository;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    Optional<Payment> findByBooking(Booking booking);

    Optional<Payment> findByBookingId(Long bookingId);
}
