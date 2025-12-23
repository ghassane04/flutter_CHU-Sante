package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class MedecinEntityTest {

    @Test
    void testMedecinCreation() {
        Service service = new Service();
        service.setId(1L);

        Medecin medecin = new Medecin();
        medecin.setId(1L);
        medecin.setNom("Dubois");
        medecin.setPrenom("Marie");
        medecin.setSpecialite("Cardiologie");
        medecin.setNumeroInscription("123456");
        medecin.setService(service);
        medecin.setTelephone("0123456789");
        medecin.setEmail("marie.dubois@hospital.com");

        assertThat(medecin.getId()).isEqualTo(1L);
        assertThat(medecin.getNom()).isEqualTo("Dubois");
        assertThat(medecin.getPrenom()).isEqualTo("Marie");
        assertThat(medecin.getSpecialite()).isEqualTo("Cardiologie");
        assertThat(medecin.getNumeroInscription()).isEqualTo("123456");
        assertThat(medecin.getService()).isEqualTo(service);
    }

    @Test
    void testMedecinWithAllFields() {
        Medecin medecin = new Medecin();
        medecin.setId(2L);
        medecin.setNom("Leroy");
        medecin.setPrenom("Pierre");
        medecin.setSpecialite("Chirurgie");
        medecin.setNumeroInscription("789012");
        medecin.setTelephone("0198765432");
        medecin.setEmail("pierre.leroy@hospital.com");
        medecin.setStatut("ACTIF");
        medecin.setCreatedAt(LocalDateTime.now());
        medecin.setUpdatedAt(LocalDateTime.now());

        assertThat(medecin.getSpecialite()).isEqualTo("Chirurgie");
        assertThat(medecin.getTelephone()).isEqualTo("0198765432");
        assertThat(medecin.getEmail()).isEqualTo("pierre.leroy@hospital.com");
        assertThat(medecin.getStatut()).isEqualTo("ACTIF");
    }

    @Test
    void testMedecinPreUpdate() {
        Medecin medecin = new Medecin();
        LocalDateTime before = LocalDateTime.now();
        medecin.onUpdate();

        assertThat(medecin.getUpdatedAt()).isAfterOrEqualTo(before);
    }
}
