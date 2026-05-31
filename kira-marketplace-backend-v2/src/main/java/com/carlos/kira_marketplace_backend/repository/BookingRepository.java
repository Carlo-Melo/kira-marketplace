package com.carlos.kira_marketplace_backend.repository;

import com.carlos.kira_marketplace_backend.entity.Booking;
import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByClient(User client);

    List<Booking> findByClientId(Long clientId);

    List<Booking> findByProfessional(Professional professional);

    List<Booking> findByProfessionalId(Long professionalId);
}
