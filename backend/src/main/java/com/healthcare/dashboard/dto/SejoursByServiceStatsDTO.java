package com.healthcare.dashboard.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SejoursByServiceStatsDTO {
    private String service;
    private Long actifs;
    private Long total;
}
