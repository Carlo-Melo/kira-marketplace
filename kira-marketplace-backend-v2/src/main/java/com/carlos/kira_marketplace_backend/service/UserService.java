package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.dto.RegisterRequest;
import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.enums.UserRole;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
    }

    public User register(RegisterRequest request) {
        return create(buildUserFromRequest(request));
    }

    public User create(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User payload is required");
        }
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (user.getCpf() == null || user.getCpf().isBlank()) {
            throw new IllegalArgumentException("CPF is required");
        }
        if (user.getPassword() == null || user.getPassword().isBlank()) {
            throw new IllegalArgumentException("Password is required");
        }

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        if (userRepository.existsByCpf(user.getCpf())) {
            throw new IllegalArgumentException("CPF already registered");
        }

        if (user.getRole() == null) {
            user.setRole(UserRole.ROLE_CLIENT);
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public User update(Long id, User payload) {
        User current = findById(id);

        if (payload.getEmail() != null
                && !payload.getEmail().equalsIgnoreCase(current.getEmail())
                && userRepository.existsByEmail(payload.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        if (payload.getCpf() != null
                && !payload.getCpf().equals(current.getCpf())
                && userRepository.existsByCpf(payload.getCpf())) {
            throw new IllegalArgumentException("CPF already registered");
        }

        current.setName(payload.getName());
        current.setEmail(payload.getEmail());
        current.setCpf(payload.getCpf());
        current.setPhone(payload.getPhone());
        if (payload.getRole() != null) {
            current.setRole(payload.getRole());
        }
        if (payload.getPassword() != null && !payload.getPassword().isBlank()) {
            current.setPassword(passwordEncoder.encode(payload.getPassword()));
        }
        return userRepository.save(current);
    }

    public void delete(Long id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User not found: " + id);
        }
        userRepository.deleteById(id);
    }

    private User buildUserFromRequest(RegisterRequest request) {
        return User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(request.getPassword())
                .cpf(request.getCpf())
                .phone(request.getPhone())
                .role(UserRole.ROLE_CLIENT)
                .build();
    }
}
