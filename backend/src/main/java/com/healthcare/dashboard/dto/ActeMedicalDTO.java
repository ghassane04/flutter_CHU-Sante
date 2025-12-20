package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActeMedicalDTO {
    private Long id;
    private Long sejourId;
    private String code;
    private String libelle;
    private String type;
    private LocalDateTime dateRealisation;
    private Double tarif;
    private String medecin;
    private String notes;
}
