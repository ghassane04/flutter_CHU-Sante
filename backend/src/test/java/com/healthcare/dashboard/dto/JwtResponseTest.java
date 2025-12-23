package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class JwtResponseTest {

    @Test
    void testJwtResponseCreation() {
        JwtResponse response = new JwtResponse();
        response.setToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...");
        response.setType("Bearer");
        response.setUsername("testuser");

        assertThat(response.getToken()).isEqualTo("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...");
        assertThat(response.getType()).isEqualTo("Bearer");
        assertThat(response.getUsername()).isEqualTo("testuser");
    }

    @Test
    void testJwtResponseWithAllFields() {
        JwtResponse response = new JwtResponse();
        response.setToken("token123");
        response.setType("Bearer");
        response.setId(1L);
        response.setUsername("admin");
        response.setEmail("admin@hospital.com");

        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getEmail()).isEqualTo("admin@hospital.com");
    }
}
