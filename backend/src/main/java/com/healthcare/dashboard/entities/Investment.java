package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "investments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Investment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String nom;
    
    @Column(nullable = false)
    private String categorie; // EQUIPEMENT, INFRASTRUCTURE, TECHNOLOGIE, FORMATION
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(nullable = false)
    private Double montant;
    
    @Column(nullable = false)
    private LocalDateTime dateInvestissement;
    
    private LocalDateTime dateFinPrevue;
    
    @Column(nullable = false)
    private String statut; // PLANIFIE, EN_COURS, TERMINE, ANNULE
    
    private String fournisseur;
    
    private String responsable;
    
    @Column(columnDefinition = "TEXT")
    private String beneficesAttendus;
    
    private Double retourInvestissement; // ROI en pourcentage
    
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
