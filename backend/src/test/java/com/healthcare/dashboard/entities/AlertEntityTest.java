package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class AlertEntityTest {

    @Test
    void testAlertCreation() {
        Alert alert = new Alert();
        alert.setId(1L);
        alert.setType("WARNING");
        alert.setTitre("Alerte importante");
        alert.setMessage("Stock faible");
        alert.setPriorite("MOYENNE");
        alert.setCategorie("MEDICAL");
        alert.setLu(false);
        alert.setResolu(false);
        alert.setCreatedAt(LocalDateTime.now());

        assertThat(alert.getId()).isEqualTo(1L);
        assertThat(alert.getType()).isEqualTo("WARNING");
        assertThat(alert.getMessage()).isEqualTo("Stock faible");
        assertThat(alert.getPriorite()).isEqualTo("MOYENNE");
        assertThat(alert.getLu()).isFalse();
        assertThat(alert.getResolu()).isFalse();
    }

    @Test
    void testAlertWithAllFields() {
        LocalDateTime created = LocalDateTime.now();
        LocalDateTime resolved = LocalDateTime.now().plusHours(2);
        
        Alert alert = new Alert();
        alert.setId(2L);
        alert.setType("ERROR");
        alert.setTitre("Erreur critique");
        alert.setMessage("Système critique");
        alert.setPriorite("HAUTE");
        alert.setCategorie("TECHNIQUE");
        alert.setLu(true);
        alert.setResolu(true);
        alert.setDateResolution(resolved);
        alert.setAssigneA("admin");
        alert.setCommentaire("Résolu avec succès");
        alert.setCreatedAt(created);
        alert.setUpdatedAt(resolved);

        assertThat(alert.getType()).isEqualTo("ERROR");
        assertThat(alert.getPriorite()).isEqualTo("HAUTE");
        assertThat(alert.getResolu()).isTrue();
        assertThat(alert.getAssigneA()).isEqualTo("admin");
        assertThat(alert.getDateResolution()).isEqualTo(resolved);
        assertThat(alert.getCommentaire()).isEqualTo("Résolu avec succès");
    }

    @Test
    void testAlertPrePersist() {
        Alert alert = new Alert();
        alert.onCreate();

        assertThat(alert.getCreatedAt()).isNotNull();
    }
}
