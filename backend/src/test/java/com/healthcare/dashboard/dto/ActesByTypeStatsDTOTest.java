package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ActesByTypeStatsDTOTest {

    @Test
    void testActesByTypeStatsDTO() {
        ActesByTypeStatsDTO dto = new ActesByTypeStatsDTO("CONSULTATION", 50L, 2500.0);

        assertThat(dto.getType()).isEqualTo("CONSULTATION");
        assertThat(dto.getCount()).isEqualTo(50L);
        assertThat(dto.getRevenus()).isEqualTo(2500.0);
    }

    @Test
    void testActesByTypeStatsDTOSetters() {
        ActesByTypeStatsDTO dto = new ActesByTypeStatsDTO();
        dto.setType("CHIRURGIE");
        dto.setCount(10L);
        dto.setRevenus(15000.0);

        assertThat(dto.getType()).isEqualTo("CHIRURGIE");
        assertThat(dto.getCount()).isEqualTo(10L);
        assertThat(dto.getRevenus()).isEqualTo(15000.0);
    }
}
