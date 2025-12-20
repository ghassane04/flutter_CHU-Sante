package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.Period;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PatientDTO {
    private Long id;
    private String nom;
    private String prenom;
    private String numeroSecuriteSociale;
    private LocalDate dateNaissance;
    private String sexe;
    private String adresse;
    private String telephone;
    private String email;
    private Integer age; // Calculé automatiquement
    
    // Méthode pour calculer l'âge
    public Integer getAge() {
        if (dateNaissance != null) {
            return Period.between(dateNaissance, LocalDate.now()).getYears();
        }
        return null;
    }
}
