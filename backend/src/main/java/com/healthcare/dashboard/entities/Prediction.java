package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "predictions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Prediction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String type; // REVENUS, PATIENTS, OCCUPATION, COUTS, TENDANCES
    
    @Column(nullable = false)
    private String titre;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(nullable = false)
    private LocalDateTime periodePrevue;
    
    @Column(columnDefinition = "TEXT")
    private String donneesHistoriques; // JSON format
    
    @Column(columnDefinition = "TEXT")
    private String resultatPrediction; // JSON format avec valeurs prédites
    
    private Double confiance; // Niveau de confiance en pourcentage
    
    @Column(columnDefinition = "TEXT")
    private String methodologie; // Description de l'algorithme utilisé
    
    @Column(columnDefinition = "TEXT")
    private String facteursCles;
    
    @Column(columnDefinition = "TEXT")
    private String recommandations;
    
    private String generePar; // AI ou utilisateur
    
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
