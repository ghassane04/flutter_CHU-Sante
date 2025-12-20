package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Role;
import com.healthcare.dashboard.entities.User;
import com.healthcare.dashboard.repositories.RoleRepository;
import com.healthcare.dashboard.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class UserController {
    
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    
    /**
     * Récupérer tous les utilisateurs
     * Accessible uniquement aux ADMIN et DIRECTION
     */
    @GetMapping
    // @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTION', 'GESTIONNAIRE')") // Temporairement désactivé
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }
    
    /**
     * Récupérer un utilisateur par ID
     */
    @GetMapping("/{id}")
    // @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTION', 'GESTIONNAIRE')") // Temporairement désactivé
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Créer un nouvel utilisateur
     * Accessible uniquement aux ADMIN
     */
    @PostMapping
    // @PreAuthorize("hasRole('ADMIN')") // Temporairement désactivé pour debug
    public ResponseEntity<?> createUser(@RequestBody UserCreateRequest request) {
        // Vérifier si le nom d'utilisateur existe déjà
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("Ce nom d'utilisateur est déjà utilisé"));
        }
        
        // Vérifier si l'email existe déjà
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("Cet email est déjà utilisé"));
        }
        
        // Créer le nouvel utilisateur
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setNom(request.getNom() != null ? request.getNom() : "");
        user.setPrenom(request.getPrenom() != null ? request.getPrenom() : "");
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEnabled(request.getActif() != null ? request.getActif() : true);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        // Assigner les rôles
        Set<Role> roles = new HashSet<>();
        if (request.getRoleIds() != null && !request.getRoleIds().isEmpty()) {
            for (Long roleId : request.getRoleIds()) {
                roleRepository.findById(roleId).ifPresent(roles::add);
            }
        }
        // Si aucun rôle n'est assigné, ne rien faire (ou lever une erreur selon les besoins)
        if (!roles.isEmpty()) {
            user.setRoles(roles);
        }
        
        User savedUser = userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }
    
    /**
     * Mettre à jour un utilisateur
     * Accessible uniquement aux ADMIN
     */
    @PutMapping("/{id}")
    // @PreAuthorize("hasRole('ADMIN')") // Temporairement désactivé
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody UserUpdateRequest request) {
        return userRepository.findById(id)
                .map(user -> {
                    // Vérifier si le nouveau username est déjà utilisé par un autre utilisateur
                    if (request.getUsername() != null && !request.getUsername().equals(user.getUsername())) {
                        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
                            return ResponseEntity.badRequest()
                                    .body(new ErrorResponse("Ce nom d'utilisateur est déjà utilisé"));
                        }
                        user.setUsername(request.getUsername());
                    }
                    
                    // Vérifier si le nouvel email est déjà utilisé par un autre utilisateur
                    if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
                        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
                            return ResponseEntity.badRequest()
                                    .body(new ErrorResponse("Cet email est déjà utilisé"));
                        }
                        user.setEmail(request.getEmail());
                    }
                    
                    // Mettre à jour les autres champs
                    if (request.getNom() != null) user.setNom(request.getNom());
                    if (request.getPrenom() != null) user.setPrenom(request.getPrenom());
                    if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                        user.setPassword(passwordEncoder.encode(request.getPassword()));
                    }
                    if (request.getActif() != null) {
                        user.setEnabled(request.getActif());
                    }
                    
                    // Mettre à jour les rôles si fournis
                    if (request.getRoleIds() != null) {
                        Set<Role> roles = new HashSet<>();
                        for (Long roleId : request.getRoleIds()) {
                            roleRepository.findById(roleId).ifPresent(roles::add);
                        }
                        user.setRoles(roles);
                    }
                    
                    user.setUpdatedAt(LocalDateTime.now());
                    User updatedUser = userRepository.save(user);
                    return ResponseEntity.ok(updatedUser);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Supprimer un utilisateur
     * Accessible uniquement aux ADMIN
     */
    @DeleteMapping("/{id}")
    // @PreAuthorize("hasRole('ADMIN')") // Temporairement désactivé
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
    
    /**
     * Activer/Désactiver un utilisateur
     */
    @PutMapping("/{id}/toggle-status")
    // @PreAuthorize("hasRole('ADMIN')") // Temporairement désactivé
    public ResponseEntity<User> toggleUserStatus(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(user -> {
                    user.setEnabled(!user.getEnabled());
                    user.setUpdatedAt(LocalDateTime.now());
                    return ResponseEntity.ok(userRepository.save(user));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Récupérer tous les rôles disponibles
     */
    @GetMapping("/roles")
    // @PreAuthorize("hasAnyRole('ADMIN', 'DIRECTION')") // Temporairement désactivé
    public ResponseEntity<List<Role>> getAllRoles() {
        return ResponseEntity.ok(roleRepository.findAll());
    }
    
    // Classes internes pour les requêtes
    
    public static class UserCreateRequest {
        private String username;
        private String password;
        private String email;
        private String nom;
        private String prenom;
        private Boolean actif;
        private List<Long> roleIds;
        
        // Getters et Setters
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        
        public String getPrenom() { return prenom; }
        public void setPrenom(String prenom) { this.prenom = prenom; }
        
        public Boolean getActif() { return actif; }
        public void setActif(Boolean actif) { this.actif = actif; }
        
        public List<Long> getRoleIds() { return roleIds; }
        public void setRoleIds(List<Long> roleIds) { this.roleIds = roleIds; }
    }
    
    public static class UserUpdateRequest {
        private String username;
        private String password;
        private String email;
        private String nom;
        private String prenom;
        private Boolean actif;
        private List<Long> roleIds;
        
        // Getters et Setters
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        
        public String getPrenom() { return prenom; }
        public void setPrenom(String prenom) { this.prenom = prenom; }
        
        public Boolean getActif() { return actif; }
        public void setActif(Boolean actif) { this.actif = actif; }
        
        public List<Long> getRoleIds() { return roleIds; }
        public void setRoleIds(List<Long> roleIds) { this.roleIds = roleIds; }
    }
    
    public static class ErrorResponse {
        private String message;
        
        public ErrorResponse(String message) {
            this.message = message;
        }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
