package com.carlos.kira_marketplace_backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "services")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Service {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "professional_id", nullable = false)
    private Professional professional;

    @NotNull
    @Column(nullable = false)
    private String name;

    private String description;

    @Positive
    private BigDecimal price;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    private Boolean active;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
