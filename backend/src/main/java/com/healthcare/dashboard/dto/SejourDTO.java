package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SejourDTO {
    private Long id;
    private Long patientId;
    private String patientNom;
    private String patientPrenom;
    private Long serviceId;
    private String serviceNom;
    private LocalDateTime dateEntree;
    private LocalDateTime dateSortie;
    private String motif;
    private String diagnostic;
    private String statut;
    private String typeAdmission;
    private Double coutTotal;
}
