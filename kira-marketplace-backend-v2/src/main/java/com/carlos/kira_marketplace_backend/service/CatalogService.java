package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.Service;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.ProfessionalRepository;
import com.carlos.kira_marketplace_backend.repository.ServiceRepository;
import lombok.RequiredArgsConstructor;

import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class CatalogService {

    private final ServiceRepository serviceRepository;
    private final ProfessionalRepository professionalRepository;

    public List<Service> findAll() {
        return serviceRepository.findAll();
    }

    public Service findById(Long id) {
        return serviceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found: " + id));
    }

    public List<Service> findByProfessionalId(Long professionalId) {
        return serviceRepository.findByProfessionalId(professionalId);
    }

    public List<Service> searchByName(String q) {
        return serviceRepository.findByNameContainingIgnoreCase(q);
    }

    public Service create(Service payload) {
        Long professionalId = payload.getProfessional() == null ? null : payload.getProfessional().getId();
        if (professionalId == null) {
            throw new IllegalArgumentException("professional.id is required");
        }

        Professional professional = professionalRepository.findById(professionalId)
                .orElseThrow(() -> new ResourceNotFoundException("Professional not found: " + professionalId));

        payload.setProfessional(professional);
        if (payload.getActive() == null) {
            payload.setActive(Boolean.TRUE);
        }
        return serviceRepository.save(payload);
    }

    public Service update(Long id, Service payload) {
        Service current = findById(id);
        current.setName(payload.getName());
        current.setDescription(payload.getDescription());
        current.setPrice(payload.getPrice());
        current.setDurationMinutes(payload.getDurationMinutes());
        current.setActive(payload.getActive());
        return serviceRepository.save(current);
    }

    public void delete(Long id) {
        if (!serviceRepository.existsById(id)) {
            throw new ResourceNotFoundException("Service not found: " + id);
        }
        serviceRepository.deleteById(id);
    }
}
