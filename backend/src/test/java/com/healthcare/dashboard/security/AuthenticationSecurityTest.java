package com.healthcare.dashboard.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.LoginRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests de sécurité pour l'authentification.
 * Vérifie la robustesse du système JWT contre les attaques courantes.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("Tests de Sécurité - Authentification")
class AuthenticationSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    // ==================== Tests JWT Token Tampering ====================

    @Test
    @DisplayName("Doit rejeter un token JWT avec signature invalide")
    void shouldRejectTokenWithInvalidSignature() throws Exception {
        // Token JWT avec une signature modifiée (dernier caractère changé)
        String tamperedToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwMzQ1MDAwMCwiZXhwIjoyMDAwMDAwMDAwfQ.INVALID_SIGNATURE";
        
        mockMvc.perform(get("/api/patients")
                .header("Authorization", "Bearer " + tamperedToken))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter un token JWT expiré")
    void shouldRejectExpiredToken() throws Exception {
        // Token expiré (exp dans le passé)
        String expiredToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTYwMDAwMDAwMCwiZXhwIjoxNjAwMDAwMDAxfQ.expired";
        
        mockMvc.perform(get("/api/patients")
                .header("Authorization", "Bearer " + expiredToken))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter un token JWT malformé")
    void shouldRejectMalformedToken() throws Exception {
        mockMvc.perform(get("/api/patients")
                .header("Authorization", "Bearer not.a.valid.jwt.token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter une requête sans token JWT")
    void shouldRejectRequestWithoutToken() throws Exception {
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter le préfixe Bearer manquant")
    void shouldRejectMissingBearerPrefix() throws Exception {
        String token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiJ9.signature";
        
        mockMvc.perform(get("/api/patients")
                .header("Authorization", token)) // Pas de "Bearer "
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter un token avec algorithme none")
    void shouldRejectNoneAlgorithmToken() throws Exception {
        // Token avec alg: "none" - attaque classique JWT
        String noneAlgToken = "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJhZG1pbiIsImFkbWluIjp0cnVlfQ.";
        
        mockMvc.perform(get("/api/patients")
                .header("Authorization", "Bearer " + noneAlgToken))
                .andExpect(status().isUnauthorized());
    }

    // ==================== Tests Brute Force Protection ====================

    @Test
    @DisplayName("Doit gérer plusieurs tentatives de login échouées")
    void shouldHandleMultipleFailedLoginAttempts() throws Exception {
        LoginRequest invalidLogin = new LoginRequest();
        invalidLogin.setUsername("attacker");
        invalidLogin.setPassword("wrongpassword");
        
        // Simuler 5 tentatives de connexion échouées
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(invalidLogin)))
                    .andExpect(status().isUnauthorized());
        }
        
        // Le système devrait toujours répondre (pas de crash)
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidLogin)))
                .andExpect(status().isUnauthorized());
    }

    // ==================== Tests d'injection dans l'authentification ====================

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection SQL dans le login")
    void shouldRejectSqlInjectionInLogin() throws Exception {
        LoginRequest maliciousLogin = new LoginRequest();
        maliciousLogin.setUsername("admin' OR '1'='1");
        maliciousLogin.setPassword("' OR '1'='1' --");
        
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(maliciousLogin)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Doit rejeter les payloads XSS dans le username")
    void shouldRejectXssPayloadInUsername() throws Exception {
        LoginRequest xssLogin = new LoginRequest();
        xssLogin.setUsername("<script>alert('XSS')</script>");
        xssLogin.setPassword("password");
        
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(xssLogin)))
                .andExpect(status().isUnauthorized())
                .andReturn();
        
        // Vérifier que le script n'est pas réfléchi dans la réponse
        String response = result.getResponse().getContentAsString();
        org.junit.jupiter.api.Assertions.assertFalse(
            response.contains("<script>"),
            "La réponse ne doit pas contenir de balises script"
        );
    }

    @Test
    @DisplayName("Doit permettre l'accès aux endpoints publics sans authentification")
    void shouldAllowAccessToPublicEndpointsWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/auth/check-username/test"))
                .andExpect(status().isOk());
    }
}
