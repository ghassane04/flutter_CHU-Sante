package com.healthcare.dashboard.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "actes_medicaux")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActeMedical {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "sejour_id", nullable = false)
    private Sejour sejour;
    
    @Column(nullable = false)
    private String code;
    
    @Column(nullable = false)
    private String libelle;
    
    @Column(nullable = false)
    private String type; // CONSULTATION, CHIRURGIE, RADIOLOGIE, LABORATOIRE, etc.
    
    @Column(nullable = false)
    private LocalDateTime dateRealisation;
    
    @Column(nullable = false)
    private Double tarif;
    
    private String medecin;
    
    private String notes;
    
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
