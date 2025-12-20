package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RevenusByMonthStatsDTO {
    private String mois;
    private Double revenus;
    private Long actes;
}
