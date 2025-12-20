package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "alerts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Alert {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String titre;
    
    @Column(columnDefinition = "TEXT")
    private String message;
    
    @Column(nullable = false)
    private String type; // INFO, WARNING, ERROR, SUCCESS
    
    @Column(nullable = false)
    private String priorite; // BASSE, MOYENNE, HAUTE, CRITIQUE
    
    @Column(nullable = false)
    private String categorie; // FINANCIER, MEDICAL, TECHNIQUE, ADMINISTRATIF
    
    @Column(nullable = false)
    private Boolean lu = false;
    
    @Column(nullable = false)
    private Boolean resolu = false;
    
    private String assigneA;
    
    private LocalDateTime dateResolution;
    
    @Column(columnDefinition = "TEXT")
    private String commentaire;
    
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
