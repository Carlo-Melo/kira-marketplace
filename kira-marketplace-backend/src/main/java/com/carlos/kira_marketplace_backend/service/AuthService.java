package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.dto.AuthResponse;
import com.carlos.kira_marketplace_backend.dto.LoginRequest;
import com.carlos.kira_marketplace_backend.dto.RegisterRequest;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.enums.UserRole;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import com.carlos.kira_marketplace_backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        if (userRepository.existsByCpf(request.getCpf())) {
            throw new IllegalArgumentException("CPF already registered");
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .cpf(request.getCpf())
                .phone(request.getPhone())
                .role(request.getRole() == null ? UserRole.ROLE_CLIENT : request.getRole())
                .createdAt(LocalDateTime.now())
                .build();

        userRepository.save(user);
        return AuthResponse.builder()
                .token(jwtService.generateToken(user))
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Invalid credentials");
        }

        return AuthResponse.builder()
                .token(jwtService.generateToken(user))
                .build();
    }
}
