package com.carlos.kira_marketplace_backend.service;

import com.carlos.kira_marketplace_backend.entity.User;
import com.carlos.kira_marketplace_backend.exception.ResourceNotFoundException;
import com.carlos.kira_marketplace_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;

@org.springframework.stereotype.Service
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

    public User create(User user) {
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        if (userRepository.existsByCpf(user.getCpf())) {
            throw new IllegalArgumentException("CPF already registered");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setCreatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }

    public User update(Long id, User payload) {
        User current = findById(id);
        current.setName(payload.getName());
        current.setEmail(payload.getEmail());
        current.setCpf(payload.getCpf());
        current.setPhone(payload.getPhone());
        current.setRole(payload.getRole());
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
}
