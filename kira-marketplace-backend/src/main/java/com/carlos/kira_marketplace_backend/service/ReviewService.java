package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.entity.Review;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.BookingRepository;
import com.carlos.kira_marketplace_backend.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookingRepository bookingRepository;

    public List<Review> findAll() {
        return reviewRepository.findAll();
    }

    public Review findById(Long id) {
        return reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found: " + id));
    }

    public List<Review> findByProfessionalId(Long professionalId) {
        return reviewRepository.findByProfessionalId(professionalId);
    }

    public Review create(Review payload) {
        Long bookingId = payload.getBooking() == null ? null : payload.getBooking().getId();
        if (bookingId == null) {
            throw new IllegalArgumentException("booking.id is required");
        }
        if (reviewRepository.findByBookingId(bookingId).isPresent()) {
            throw new IllegalArgumentException("Booking already has a review");
        }

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + bookingId));
        payload.setBooking(booking);
        payload.setClient(booking.getClient());
        payload.setProfessional(booking.getProfessional());
        payload.setCreatedAt(LocalDateTime.now());
        return reviewRepository.save(payload);
    }

    public Review update(Long id, Review payload) {
        Review current = findById(id);
        current.setRating(payload.getRating());
        current.setComment(payload.getComment());
        return reviewRepository.save(current);
    }

    public void delete(Long id) {
        if (!reviewRepository.existsById(id)) {
            throw new ResourceNotFoundException("Review not found: " + id);
        }
        reviewRepository.deleteById(id);
    }
}
