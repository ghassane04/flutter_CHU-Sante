package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SignupRequestTest {

    @Test
    void testSignupRequestCreation() {
        SignupRequest request = new SignupRequest();
        request.setUsername("newuser");
        request.setEmail("newuser@example.com");
        request.setPassword("password123");

        assertThat(request.getUsername()).isEqualTo("newuser");
        assertThat(request.getEmail()).isEqualTo("newuser@example.com");
        assertThat(request.getPassword()).isEqualTo("password123");
    }

    @Test
    void testSignupRequestWithAllFields() {
        SignupRequest request = new SignupRequest();
        request.setUsername("johndoe");
        request.setEmail("john.doe@example.com");
        request.setPassword("securepass");
        request.setNom("Doe");
        request.setPrenom("John");

        assertThat(request.getNom()).isEqualTo("Doe");
        assertThat(request.getPrenom()).isEqualTo("John");
    }
}
