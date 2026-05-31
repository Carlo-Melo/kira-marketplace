package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.Service;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.enums.BookingStatus;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.BookingRepository;
import com.carlos.kira_marketplace_backend.repository.ProfessionalRepository;
import com.carlos.kira_marketplace_backend.repository.ServiceRepository;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ProfessionalRepository professionalRepository;
    private final ServiceRepository serviceRepository;

    public List<Booking> findAll() {
        return bookingRepository.findAll();
    }

    public Booking findById(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + id));
    }

    public List<Booking> findByClientId(Long clientId) {
        return bookingRepository.findByClientId(clientId);
    }

    public List<Booking> findByProfessionalId(Long professionalId) {
        return bookingRepository.findByProfessionalId(professionalId);
    }

    public Booking create(Booking payload) {
        Long clientId = payload.getClient() == null ? null : payload.getClient().getId();
        Long professionalId = payload.getProfessional() == null ? null : payload.getProfessional().getId();
        Long serviceId = payload.getService() == null ? null : payload.getService().getId();

        if (clientId == null || professionalId == null || serviceId == null) {
            throw new IllegalArgumentException("client.id, professional.id and service.id are required");
        }

        User client = userRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + clientId));
        Professional professional = professionalRepository.findById(professionalId)
                .orElseThrow(() -> new ResourceNotFoundException("Professional not found: " + professionalId));
        Service service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found: " + serviceId));

        payload.setClient(client);
        payload.setProfessional(professional);
        payload.setService(service);
        if (payload.getStatus() == null) {
            payload.setStatus(BookingStatus.PENDING);
        }
        if (payload.getBookingDate() == null) {
            payload.setBookingDate(LocalDateTime.now());
        }
        return bookingRepository.save(payload);
    }

    public Booking update(Long id, Booking payload) {
        Booking current = findById(id);
        current.setBookingDate(payload.getBookingDate());
        current.setStatus(payload.getStatus());
        current.setPrice(payload.getPrice());
        return bookingRepository.save(current);
    }

    public void delete(Long id) {
        if (!bookingRepository.existsById(id)) {
            throw new ResourceNotFoundException("Booking not found: " + id);
        }
        bookingRepository.deleteById(id);
    }
}
