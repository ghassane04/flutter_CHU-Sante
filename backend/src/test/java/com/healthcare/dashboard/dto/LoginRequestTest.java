package com.healthcare.dashboard.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class LoginRequestTest {

    @Test
    void testLoginRequestCreation() {
        LoginRequest request = new LoginRequest();
        request.setUsername("testuser");
        request.setPassword("testpassword");

        assertThat(request.getUsername()).isEqualTo("testuser");
        assertThat(request.getPassword()).isEqualTo("testpassword");
    }

    @Test
    void testLoginRequestAllArgsConstructor() {
        LoginRequest request = new LoginRequest("admin", "admin123");

        assertThat(request.getUsername()).isEqualTo("admin");
        assertThat(request.getPassword()).isEqualTo("admin123");
    }
}
