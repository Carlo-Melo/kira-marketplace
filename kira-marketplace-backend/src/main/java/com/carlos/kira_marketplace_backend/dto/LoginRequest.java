package com.carlos.kira_marketplace_backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LoginRequest {

    @Email
    @NotNull
    private String email;

    @NotBlank
    private String password;
}
