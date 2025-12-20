package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "reports")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Report {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String titre;
    
    @Column(nullable = false)
    private String type; // FINANCIER, MEDICAL, ACTIVITE, QUALITE, RESSOURCES
    
    @Column(nullable = false)
    private String periode; // JOURNALIER, HEBDOMADAIRE, MENSUEL, ANNUEL
    
    @Column(columnDefinition = "TEXT")
    private String resume;
    
    @Column(nullable = false)
    private LocalDateTime dateDebut;
    
    @Column(nullable = false)
    private LocalDateTime dateFin;
    
    private String generePar;
    
    @Column(columnDefinition = "TEXT")
    private String donneesPrincipales; // JSON format
    
    @Column(columnDefinition = "TEXT")
    private String conclusions;
    
    @Column(columnDefinition = "TEXT")
    private String recommandations;
    
    @Column(nullable = false)
    private String statut; // BROUILLON, PUBLIE, ARCHIVE
    
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
