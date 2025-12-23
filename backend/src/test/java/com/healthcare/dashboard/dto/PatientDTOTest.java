package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class PatientDTOTest {

    @Test
    void testPatientDTOCreationAndGetters() {
        PatientDTO dto = new PatientDTO();
        dto.setId(1L);
        dto.setNom("Dupont");
        dto.setPrenom("Marie");
        dto.setNumeroSecuriteSociale("123456789012345");
        dto.setDateNaissance(LocalDate.of(1990, 5, 20));
        dto.setSexe("F");
        dto.setAdresse("10 Rue de la Paix");
        dto.setTelephone("0612345678");
        dto.setEmail("marie.dupont@email.com");

        assertThat(dto.getId()).isEqualTo(1L);
        assertThat(dto.getNom()).isEqualTo("Dupont");
        assertThat(dto.getPrenom()).isEqualTo("Marie");
        assertThat(dto.getNumeroSecuriteSociale()).isEqualTo("123456789012345");
        assertThat(dto.getDateNaissance()).isEqualTo(LocalDate.of(1990, 5, 20));
        assertThat(dto.getSexe()).isEqualTo("F");
        assertThat(dto.getAdresse()).isEqualTo("10 Rue de la Paix");
        assertThat(dto.getTelephone()).isEqualTo("0612345678");
        assertThat(dto.getEmail()).isEqualTo("marie.dupont@email.com");
    }

    @Test
    void testPatientDTOEqualsAndHashCode() {
        PatientDTO dto1 = new PatientDTO();
        dto1.setId(1L);
        dto1.setNom("Test");
        dto1.setNumeroSecuriteSociale("123456789012345");

        PatientDTO dto2 = new PatientDTO();
        dto2.setId(1L);
        dto2.setNom("Test");
        dto2.setNumeroSecuriteSociale("123456789012345");

        assertThat(dto1).isEqualTo(dto2);
        assertThat(dto1.hashCode()).isEqualTo(dto2.hashCode());
    }
}
