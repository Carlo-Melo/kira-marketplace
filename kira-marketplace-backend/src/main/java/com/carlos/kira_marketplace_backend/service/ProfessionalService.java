package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.ProfessionalRepository;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class ProfessionalService {

    private final ProfessionalRepository professionalRepository;
    private final UserRepository userRepository;

    public List<Professional> findAll() {
        return professionalRepository.findAll();
    }

    public Professional findById(Long id) {
        return professionalRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Professional not found: " + id));
    }

    public List<Professional> findByCity(String city) {
        return professionalRepository.findByCity(city);
    }

    public List<Professional> findByMinRating(Double rating) {
        return professionalRepository.findByRatingGreaterThanEqual(rating);
    }

    public Professional create(Professional payload) {
        Long userId = payload.getUser() == null ? null : payload.getUser().getId();
        if (userId == null) {
            throw new IllegalArgumentException("user.id is required");
        }
        if (professionalRepository.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("User is already a professional");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        payload.setUser(user);
        payload.setCreatedAt(LocalDateTime.now());
        return professionalRepository.save(payload);
    }

    public Professional update(Long id, Professional payload) {
        Professional current = findById(id);
        current.setDocumentType(payload.getDocumentType());
        current.setDocumentNumber(payload.getDocumentNumber());
        current.setBio(payload.getBio());
        current.setCity(payload.getCity());
        current.setAddress(payload.getAddress());
        current.setLatitude(payload.getLatitude());
        current.setLongitude(payload.getLongitude());
        current.setRating(payload.getRating());
        current.setTotalReviews(payload.getTotalReviews());
        return professionalRepository.save(current);
    }

    public void delete(Long id) {
        if (!professionalRepository.existsById(id)) {
            throw new ResourceNotFoundException("Professional not found: " + id);
        }
        professionalRepository.deleteById(id);
    }
}
