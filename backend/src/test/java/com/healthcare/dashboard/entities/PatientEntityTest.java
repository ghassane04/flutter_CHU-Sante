package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

class PatientEntityTest {

    @Test
    void testPatientCreation() {
        Patient patient = new Patient();
        patient.setId(1L);
        patient.setNom("Dupont");
        patient.setPrenom("Jean");
        patient.setNumeroSecuriteSociale("123456789012345");
        patient.setDateNaissance(LocalDate.of(1985, 5, 15));
        patient.setSexe("M");
        patient.setAdresse("123 Rue de Paris");
        patient.setTelephone("0612345678");
        patient.setEmail("jean.dupont@email.com");
        patient.setCreatedAt(LocalDateTime.now());
        patient.setUpdatedAt(LocalDateTime.now());

        assertThat(patient.getId()).isEqualTo(1L);
        assertThat(patient.getNom()).isEqualTo("Dupont");
        assertThat(patient.getPrenom()).isEqualTo("Jean");
        assertThat(patient.getNumeroSecuriteSociale()).isEqualTo("123456789012345");
        assertThat(patient.getSexe()).isEqualTo("M");
        assertThat(patient.getEmail()).isEqualTo("jean.dupont@email.com");
    }

    @Test
    void testPatientAllArgsConstructor() {
        LocalDate birthDate = LocalDate.of(1990, 3, 20);
        LocalDateTime now = LocalDateTime.now();
        
        Patient patient = new Patient(
            1L, 
            "Martin", 
            "Sophie", 
            "987654321098765", 
            birthDate,
            "F",
            "456 Avenue Victor Hugo",
            "0698765432",
            "sophie.martin@email.com",
            now,
            now
        );

        assertThat(patient.getNom()).isEqualTo("Martin");
        assertThat(patient.getPrenom()).isEqualTo("Sophie");
        assertThat(patient.getDateNaissance()).isEqualTo(birthDate);
    }

    @Test
    void testPatientEqualsAndHashCode() {
        Patient patient1 = new Patient();
        patient1.setId(1L);
        patient1.setNom("Test");
        patient1.setNumeroSecuriteSociale("123456789012345");

        Patient patient2 = new Patient();
        patient2.setId(1L);
        patient2.setNom("Test");
        patient2.setNumeroSecuriteSociale("123456789012345");

        assertThat(patient1).isEqualTo(patient2);
        assertThat(patient1.hashCode()).isEqualTo(patient2.hashCode());
    }

    @Test
    void testPatientPrePersist() {
        Patient patient = new Patient();
        patient.onCreate();

        assertThat(patient.getCreatedAt()).isNotNull();
        assertThat(patient.getUpdatedAt()).isNotNull();
    }
}
