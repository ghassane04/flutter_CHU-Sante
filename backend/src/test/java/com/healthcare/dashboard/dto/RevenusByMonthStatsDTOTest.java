package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RevenusByMonthStatsDTOTest {

    @Test
    void testRevenusByMonthStatsDTO() {
        RevenusByMonthStatsDTO dto = new RevenusByMonthStatsDTO("2024-01", 5000.0, 100L);

        assertThat(dto.getMois()).isEqualTo("2024-01");
        assertThat(dto.getRevenus()).isEqualTo(5000.0);
        assertThat(dto.getActes()).isEqualTo(100L);
    }

    @Test
    void testRevenusByMonthStatsDTOSetters() {
        RevenusByMonthStatsDTO dto = new RevenusByMonthStatsDTO();
        dto.setMois("2024-02");
        dto.setRevenus(6000.0);
        dto.setActes(120L);

        assertThat(dto.getMois()).isEqualTo("2024-02");
        assertThat(dto.getRevenus()).isEqualTo(6000.0);
        assertThat(dto.getActes()).isEqualTo(120L);
    }
}
