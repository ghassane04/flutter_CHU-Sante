package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DashboardStatsDTOTest {

    @Test
    void testDashboardStatsDTO() {
        DashboardStatsDTO dto = new DashboardStatsDTO();
        dto.setTotalPatients(100L);
        dto.setSejoursEnCours(15L);
        dto.setTotalActes(250L);
        dto.setRevenusTotal(50000.0);
        dto.setRevenusAnnee(45000.0);
        dto.setRevenusMois(5000.0);

        assertThat(dto.getTotalPatients()).isEqualTo(100L);
        assertThat(dto.getSejoursEnCours()).isEqualTo(15L);
        assertThat(dto.getTotalActes()).isEqualTo(250L);
        assertThat(dto.getRevenusTotal()).isEqualTo(50000.0);
        assertThat(dto.getRevenusAnnee()).isEqualTo(45000.0);
        assertThat(dto.getRevenusMois()).isEqualTo(5000.0);
    }

    @Test
    void testDashboardStatsDTOAllArgsConstructor() {
        DashboardStatsDTO dto = new DashboardStatsDTO(200L, 20L, 300L, 75000.0, 70000.0, 8000.0);

        assertThat(dto.getTotalPatients()).isEqualTo(200L);
        assertThat(dto.getSejoursEnCours()).isEqualTo(20L);
        assertThat(dto.getTotalActes()).isEqualTo(300L);
        assertThat(dto.getRevenusTotal()).isEqualTo(75000.0);
        assertThat(dto.getRevenusAnnee()).isEqualTo(70000.0);
        assertThat(dto.getRevenusMois()).isEqualTo(8000.0);
    }
}
