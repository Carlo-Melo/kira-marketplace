package com.carlos.kira_marketplace_backend.entity;

import com.carlos.kira_marketplace_backend.enums.DocumentType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "professionals")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Professional {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "document_type", nullable = false)
    private DocumentType documentType;

    @NotNull
    @Column(name = "document_number", nullable = false, unique = true)
    private String documentNumber;

    private String bio;

    private String city;

    private String address;

    private Double latitude;

    private Double longitude;

    private Double rating;

    @Column(name = "total_reviews")
    private Integer totalReviews;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
