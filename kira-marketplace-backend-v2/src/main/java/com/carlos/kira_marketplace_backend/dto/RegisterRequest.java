package com.carlos.kira_marketplace_backend.dto;

import com.carlos.kira_marketplace_backend.enums.DocumentType;
import com.carlos.kira_marketplace_backend.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank
    private String name;

    @Email
    @NotNull
    private String email;

    @NotBlank
    private String password;

    @NotBlank
    private String cpf;

    private String phone;

    private UserRole role;

    private DocumentType documentType;

    private String documentNumber;

    private String bio;

    private String city;

    private String address;

    private Double latitude;

    private Double longitude;
}
