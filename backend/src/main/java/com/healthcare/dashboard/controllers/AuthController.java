package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.JwtResponse;
import com.healthcare.dashboard.dto.LoginRequest;
import com.healthcare.dashboard.dto.MessageResponse;
import com.healthcare.dashboard.dto.SignupRequest;
import com.healthcare.dashboard.entities.Role;
import com.healthcare.dashboard.entities.User;
import com.healthcare.dashboard.repositories.RoleRepository;
import com.healthcare.dashboard.repositories.UserRepository;
import com.healthcare.dashboard.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);
            
            User user = userRepository.findByUsername(loginRequest.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            return ResponseEntity.ok(new JwtResponse(jwt, user.getId(), user.getUsername(), user.getEmail()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new MessageResponse("Identifiants incorrects"));
        }
    }
    
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@RequestBody SignupRequest signupRequest) {
        // Vérifier si le nom d'utilisateur existe déjà
        if (userRepository.findByUsername(signupRequest.getUsername()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Erreur: Ce nom d'utilisateur est déjà utilisé"));
        }
        
        // Vérifier si l'email existe déjà
        if (userRepository.findByEmail(signupRequest.getEmail()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Erreur: Cet email est déjà utilisé"));
        }
        
        // Créer le nouvel utilisateur
        User user = new User();
        user.setUsername(signupRequest.getUsername());
        user.setEmail(signupRequest.getEmail());
        user.setNom(signupRequest.getNom());
        user.setPrenom(signupRequest.getPrenom());
        user.setPassword(passwordEncoder.encode(signupRequest.getPassword()));
        user.setEnabled(true);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        // Assigner le rôle par défaut (USER)
        Set<Role> roles = new HashSet<>();
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> {
                    Role newRole = new Role();
                    newRole.setName("ROLE_USER");
                    return roleRepository.save(newRole);
                });
        roles.add(userRole);
        user.setRoles(roles);
        
        userRepository.save(user);
        
        return ResponseEntity.ok(new MessageResponse("Utilisateur enregistré avec succès"));
    }
    
    @GetMapping("/check-username/{username}")
    public ResponseEntity<?> checkUsername(@PathVariable String username) {
        boolean exists = userRepository.findByUsername(username).isPresent();
        return ResponseEntity.ok(new MessageResponse(exists ? "exists" : "available"));
    }
    
    @GetMapping("/check-email/{email}")
    public ResponseEntity<?> checkEmail(@PathVariable String email) {
        boolean exists = userRepository.findByEmail(email).isPresent();
        return ResponseEntity.ok(new MessageResponse(exists ? "exists" : "available"));
    }
}
