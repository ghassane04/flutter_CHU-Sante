package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class ActeMedicalEntityTest {

    @Test
    void testActeMedicalCreation() {
        Sejour sejour = new Sejour();
        sejour.setId(1L);

        ActeMedical acte = new ActeMedical();
        acte.setId(1L);
        acte.setSejour(sejour);
        acte.setCode("CCAM001");
        acte.setLibelle("Consultation générale");
        acte.setType("CONSULTATION");
        acte.setTarif(50.0);
        acte.setMedecin("Dr. Smith");
        acte.setDateRealisation(LocalDateTime.now());
        acte.setNotes("RAS");

        assertThat(acte.getId()).isEqualTo(1L);
        assertThat(acte.getCode()).isEqualTo("CCAM001");
        assertThat(acte.getLibelle()).isEqualTo("Consultation générale");
        assertThat(acte.getTarif()).isEqualTo(50.0);
        assertThat(acte.getSejour()).isEqualTo(sejour);
    }

    @Test
    void testActeMedicalWithAllFields() {
        Sejour sejour = new Sejour();
        sejour.setId(2L);
        
        LocalDateTime dateRealisation = LocalDateTime.of(2024, 1, 15, 10, 30);
        LocalDateTime createdAt = LocalDateTime.now();
        LocalDateTime updatedAt = LocalDateTime.now();

        ActeMedical acte = new ActeMedical();
        acte.setId(10L);
        acte.setSejour(sejour);
        acte.setCode("CCAM999");
        acte.setLibelle("Intervention chirurgicale");
        acte.setType("CHIRURGIE");
        acte.setDateRealisation(dateRealisation);
        acte.setTarif(1500.0);
        acte.setMedecin("Dr. Johnson");
        acte.setNotes("Opération réussie");
        acte.setCreatedAt(createdAt);
        acte.setUpdatedAt(updatedAt);

        assertThat(acte.getType()).isEqualTo("CHIRURGIE");
        assertThat(acte.getTarif()).isEqualTo(1500.0);
        assertThat(acte.getDateRealisation()).isEqualTo(dateRealisation);
        assertThat(acte.getNotes()).isEqualTo("Opération réussie");
    }

    @Test
    void testActeMedicalPrePersist() {
        ActeMedical acte = new ActeMedical();
        acte.onCreate();

        assertThat(acte.getCreatedAt()).isNotNull();
        assertThat(acte.getUpdatedAt()).isNotNull();
    }
}
