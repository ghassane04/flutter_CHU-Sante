package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ServiceDTO {
    private Long id;
    private String nom;
    private String description;
    private String type;
    private Integer capacite;
    private Integer litsDisponibles;
    private String responsable;
    private Double budget;
    private Double depense;
}
