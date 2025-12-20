package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MLPredictionResponseDTO {
    private String service;
    private String predictionType;
    private List<PredictionPoint> predictions;
    private Double confiance;
    private String tendance; // HAUSSE, BAISSE, STABLE
    private Double valeurMoyenne;
    private Double valeurMin;
    private Double valeurMax;
    private List<String> facteursCles;
    private List<String> recommandations;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PredictionPoint {
        private LocalDate date;
        private Double valeur;
        private Double min;
        private Double max;
    }
}
