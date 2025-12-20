package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "settings")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Settings {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String cle;
    
    @Column(nullable = false)
    private String categorie; // GENERAL, NOTIFICATIONS, SECURITE, AFFICHAGE, RAPPORTS
    
    @Column(nullable = false)
    private String libelle;
    
    @Column(columnDefinition = "TEXT")
    private String valeur;
    
    @Column(nullable = false)
    private String typeValeur; // STRING, NUMBER, BOOLEAN, JSON
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    private String valeurParDefaut;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
