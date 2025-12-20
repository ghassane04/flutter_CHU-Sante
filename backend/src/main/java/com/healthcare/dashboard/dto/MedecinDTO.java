package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedecinDTO {
    private Long id;
    private String nom;
    private String prenom;
    private String numeroInscription;
    private String specialite;
    private String telephone;
    private String email;
    private Long serviceId;
    private String serviceNom;
    private String statut;
}
