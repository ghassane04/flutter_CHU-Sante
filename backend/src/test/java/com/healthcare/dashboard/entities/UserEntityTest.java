package com.healthcare.dashboard.entities;

import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class UserEntityTest {

    @Test
    void testUserCreation() {
        User user = new User();
        user.setId(1L);
        user.setUsername("johndoe");
        user.setEmail("john.doe@example.com");
        user.setPassword("hashedpassword");
        user.setNom("Doe");
        user.setPrenom("John");

        assertThat(user.getId()).isEqualTo(1L);
        assertThat(user.getUsername()).isEqualTo("johndoe");
        assertThat(user.getEmail()).isEqualTo("john.doe@example.com");
        assertThat(user.getNom()).isEqualTo("Doe");
        assertThat(user.getPrenom()).isEqualTo("John");
    }

    @Test
    void testUserWithAllFields() {
        LocalDateTime now = LocalDateTime.now();
        
        User user = new User();
        user.setId(2L);
        user.setUsername("admin");
        user.setEmail("admin@hospital.com");
        user.setPassword("securepassword");
        user.setNom("Admin");
        user.setPrenom("Super");
        user.setEnabled(true);
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        assertThat(user.getUsername()).isEqualTo("admin");
        assertThat(user.getEnabled()).isTrue();
        assertThat(user.getCreatedAt()).isEqualTo(now);
    }

    @Test
    void testUserPrePersist() {
        User user = new User();
        user.onCreate();

        assertThat(user.getCreatedAt()).isNotNull();
        assertThat(user.getUpdatedAt()).isNotNull();
    }
}
