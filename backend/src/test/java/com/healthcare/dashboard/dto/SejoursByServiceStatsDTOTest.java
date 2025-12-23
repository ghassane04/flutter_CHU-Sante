package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SejoursByServiceStatsDTOTest {

    @Test
    void testSejoursByServiceStatsDTO() {
        SejoursByServiceStatsDTO dto = new SejoursByServiceStatsDTO("Cardiologie", 15L, 30L);

        assertThat(dto.getService()).isEqualTo("Cardiologie");
        assertThat(dto.getActifs()).isEqualTo(15L);
        assertThat(dto.getTotal()).isEqualTo(30L);
    }

    @Test
    void testSejoursByServiceStatsDTOSetters() {
        SejoursByServiceStatsDTO dto = new SejoursByServiceStatsDTO();
        dto.setService("Urgences");
        dto.setActifs(20L);
        dto.setTotal(50L);

        assertThat(dto.getService()).isEqualTo("Urgences");
        assertThat(dto.getActifs()).isEqualTo(20L);
        assertThat(dto.getTotal()).isEqualTo(50L);
    }
}
