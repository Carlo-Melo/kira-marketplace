package com.carlos.kira_marketplace_backend.repository;

import com.carlos.kira_marketplace_backend.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByProfessionalId(Long professionalId);

    Optional<Review> findByBookingId(Long bookingId);
}
