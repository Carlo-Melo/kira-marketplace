package com.carlos.kira_marketplace_backend.repository;

import com.carlos.kira_marketplace_backend.entity.Professional;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProfessionalRepository extends JpaRepository<Professional, Long> {

    Optional<Professional> findByDocumentNumber(String documentNumber);

    Optional<Professional> findByUserId(Long userId);

    List<Professional> findByCity(String city);

    List<Professional> findByRatingGreaterThanEqual(Double rating);
}
