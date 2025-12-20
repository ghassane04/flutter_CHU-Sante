package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private Long totalPatients;
    private Long sejoursEnCours;
    private Long totalActes;
    private Double revenusTotal;
    private Double revenusAnnee;
    private Double revenusMois;
}
