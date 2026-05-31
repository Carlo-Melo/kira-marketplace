package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.dto.AuthResponse;
import com.carlos.kira_marketplace_backend.dto.LoginRequest;
import com.carlos.kira_marketplace_backend.dto.RegisterRequest;
import com.carlos.kira_marketplace_backend.entity.Professional;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.enums.UserRole;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import com.carlos.kira_marketplace_backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final UserService userService;
    private final ProfessionalService professionalService;
    private final JwtService jwtService;

    public AuthResponse register(RegisterRequest request) {
        UserRole role = request.getRole() == null ? UserRole.ROLE_CLIENT : request.getRole();

        User registeredUser;
        if (role == UserRole.ROLE_PROFESSIONAL) {
            Professional professional = professionalService.registerProfessional(request);
            registeredUser = professional.getUser();
        } else {
            registeredUser = userService.register(request);
        }

        return generateAuthResponse(registeredUser);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
        return generateAuthResponse(user);
    }

    private AuthResponse generateAuthResponse(User user) {
        return AuthResponse.builder()
                .token(jwtService.generateToken(user))
                .userId(user.getId())
                .name(user.getName())
                .role(user.getRole().name())
                .build();
    }
}
