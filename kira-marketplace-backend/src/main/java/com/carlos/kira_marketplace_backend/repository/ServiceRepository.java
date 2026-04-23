package com.carlos.kira_marketplace_backend.repository;

import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.Service;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceRepository extends JpaRepository<Service, Long> {

    List<Service> findByProfessional(Professional professional);

    List<Service> findByProfessionalId(Long professionalId);

    List<Service> findByActiveTrue();

    List<Service> findByNameContainingIgnoreCase(String name);
}
