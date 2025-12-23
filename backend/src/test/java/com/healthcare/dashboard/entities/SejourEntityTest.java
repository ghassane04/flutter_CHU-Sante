package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class SejourEntityTest {

    @Test
    void testSejourCreation() {
        Patient patient = new Patient();
        patient.setId(1L);

        Service service = new Service();
        service.setId(1L);

        Sejour sejour = new Sejour();
        sejour.setId(1L);
        sejour.setPatient(patient);
        sejour.setService(service);
        sejour.setDateEntree(LocalDateTime.now());
        sejour.setMotif("Consultation urgente");
        sejour.setStatut(Sejour.StatutSejour.EN_COURS);

        assertThat(sejour.getId()).isEqualTo(1L);
        assertThat(sejour.getPatient()).isEqualTo(patient);
        assertThat(sejour.getService()).isEqualTo(service);
        assertThat(sejour.getMotif()).isEqualTo("Consultation urgente");
        assertThat(sejour.getStatut()).isEqualTo(Sejour.StatutSejour.EN_COURS);
    }

    @Test
    void testSejourWithDateSortie() {
        LocalDateTime dateEntree = LocalDateTime.of(2024, 1, 10, 8, 0);
        LocalDateTime dateSortie = LocalDateTime.of(2024, 1, 15, 10, 0);

        Sejour sejour = new Sejour();
        sejour.setDateEntree(dateEntree);
        sejour.setDateSortie(dateSortie);
        sejour.setStatut(Sejour.StatutSejour.TERMINE);
        sejour.setDiagnostic("Guérison complète");

        assertThat(sejour.getDateEntree()).isEqualTo(dateEntree);
        assertThat(sejour.getDateSortie()).isEqualTo(dateSortie);
        assertThat(sejour.getStatut()).isEqualTo(Sejour.StatutSejour.TERMINE);
        assertThat(sejour.getDiagnostic()).isEqualTo("Guérison complète");
    }

    @Test
    void testSejourPrePersist() {
        Sejour sejour = new Sejour();
        sejour.onCreate();

        assertThat(sejour.getCreatedAt()).isNotNull();
        assertThat(sejour.getUpdatedAt()).isNotNull();
    }
}
