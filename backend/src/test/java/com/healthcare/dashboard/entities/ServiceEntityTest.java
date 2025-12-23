package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class ServiceEntityTest {

    @Test
    void testServiceCreation() {
        Service service = new Service();
        service.setId(1L);
        service.setNom("Cardiologie");
        service.setDescription("Service de cardiologie");
        service.setType("Médical");
        service.setResponsable("Dr. Martin");
        service.setCapacite(50);

        assertThat(service.getId()).isEqualTo(1L);
        assertThat(service.getNom()).isEqualTo("Cardiologie");
        assertThat(service.getDescription()).isEqualTo("Service de cardiologie");
        assertThat(service.getResponsable()).isEqualTo("Dr. Martin");
        assertThat(service.getCapacite()).isEqualTo(50);
    }

    @Test
    void testServiceWithAllFields() {
        LocalDateTime now = LocalDateTime.now();
        
        Service service = new Service();
        service.setId(2L);
        service.setNom("Urgences");
        service.setDescription("Service d'urgence 24/7");
        service.setType("Urgence");
        service.setResponsable("Dr. Dupont");
        service.setCapacite(100);
        service.setLitsDisponibles(75);
        service.setBudget(500000.0);
        service.setDepense(350000.0);
        service.setCreatedAt(now);
        service.setUpdatedAt(now);

        assertThat(service.getNom()).isEqualTo("Urgences");
        assertThat(service.getCapacite()).isEqualTo(100);
        assertThat(service.getBudget()).isEqualTo(500000.0);
        assertThat(service.getCreatedAt()).isEqualTo(now);
    }

    @Test
    void testServicePrePersist() {
        Service service = new Service();
        service.onCreate();

        assertThat(service.getCreatedAt()).isNotNull();
        assertThat(service.getUpdatedAt()).isNotNull();
    }
}
