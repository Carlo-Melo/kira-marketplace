package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.dto.RegisterRequest;
import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.enums.DocumentType;
import com.carlos.kira_marketplace_backend.enums.UserRole;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.ProfessionalRepository;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProfessionalService {

    private final ProfessionalRepository professionalRepository;
    private final UserRepository userRepository;
    private final UserService userService;

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

    @Transactional
    public Professional registerProfessional(RegisterRequest request) {
        if (request.getRole() != null && request.getRole() != UserRole.ROLE_PROFESSIONAL) {
            throw new IllegalArgumentException("Professional registration requires ROLE_PROFESSIONAL");
        }

        validateProfessionalFields(request.getDocumentNumber(), request.getDocumentType());
        ensureDocumentNumberAvailable(request.getDocumentNumber(), null);

        User professionalUser = userService.create(
                User.builder()
                        .name(request.getName())
                        .email(request.getEmail())
                        .password(request.getPassword())
                        .cpf(request.getCpf())
                        .phone(request.getPhone())
                        .role(UserRole.ROLE_PROFESSIONAL)
                        .build()
        );

        Professional professional = Professional.builder()
                .user(professionalUser)
                .documentType(request.getDocumentType())
                .documentNumber(request.getDocumentNumber())
                .bio(request.getBio())
                .city(request.getCity())
                .address(request.getAddress())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .rating(0.0)
                .totalReviews(0)
                .build();
        return professionalRepository.save(professional);
    }

    public Professional create(Professional payload) {
        if (payload == null) {
            throw new IllegalArgumentException("Professional payload is required");
        }

        Long userId = payload.getUser() == null ? null : payload.getUser().getId();
        if (userId == null) {
            throw new IllegalArgumentException("user.id is required");
        }
        if (professionalRepository.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("User is already a professional");
        }
        validateProfessionalFields(payload.getDocumentNumber(), payload.getDocumentType());
        ensureDocumentNumberAvailable(payload.getDocumentNumber(), null);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        if (user.getRole() != UserRole.ROLE_PROFESSIONAL) {
            user.setRole(UserRole.ROLE_PROFESSIONAL);
            userRepository.save(user);
        }

        payload.setUser(user);
        if (payload.getRating() == null) {
            payload.setRating(0.0);
        }
        if (payload.getTotalReviews() == null) {
            payload.setTotalReviews(0);
        }
        return professionalRepository.save(payload);
    }

    public Professional update(Long id, Professional payload) {
        Professional current = findById(id);

        validateProfessionalFields(payload.getDocumentNumber(), payload.getDocumentType());
        ensureDocumentNumberAvailable(payload.getDocumentNumber(), id);

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

    private void validateProfessionalFields(String documentNumber, DocumentType documentType) {
        if (documentType == null) {
            throw new IllegalArgumentException("documentType is required");
        }
        if (documentNumber == null || documentNumber.isBlank()) {
            throw new IllegalArgumentException("documentNumber is required");
        }
    }

    private void ensureDocumentNumberAvailable(String documentNumber, Long currentProfessionalId) {
        Optional<Professional> existing = professionalRepository.findByDocumentNumber(documentNumber);
        if (existing.isPresent() && !existing.get().getId().equals(currentProfessionalId)) {
            throw new IllegalArgumentException("Document number already registered");
        }
    }
}
