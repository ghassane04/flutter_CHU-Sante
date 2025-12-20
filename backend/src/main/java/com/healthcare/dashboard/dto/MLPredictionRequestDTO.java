package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MLPredictionRequestDTO {
    private String service;
    private Integer daysAhead; // 30, 90, 180, 365
    private String predictionType; // COUT, PATIENTS, OCCUPATION
    private LocalDate startDate;
}
