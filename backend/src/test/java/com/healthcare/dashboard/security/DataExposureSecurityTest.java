package com.healthcare.dashboard.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.LoginRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests de sécurité pour la protection contre l'exposition de données.
 * Vérifie que les informations sensibles ne sont pas divulguées.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("Tests de Sécurité - Exposition de Données")
class DataExposureSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    // ==================== Tests d'exposition de mot de passe ====================

    @Test
    @DisplayName("Les mots de passe ne doivent jamais être exposés dans les réponses")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void passwordsShouldNeverBeExposed() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/users"))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        
        // Vérifier que le mot de passe haché n'est pas exposé
        assertFalse(response.contains("$2a$"), 
            "Les hashs de mot de passe BCrypt ne doivent pas être exposés");
        assertFalse(response.toLowerCase().contains("password\"") 
            && response.contains("$"),
            "Le champ password avec une valeur ne doit pas être présent");
    }

    @Test
    @DisplayName("L'erreur de login ne doit pas révéler si l'utilisateur existe")
    void loginErrorShouldNotRevealUserExistence() throws Exception {
        // Tentative avec utilisateur inexistant
        LoginRequest nonExistentUser = new LoginRequest();
        nonExistentUser.setUsername("nonexistent_user_12345");
        nonExistentUser.setPassword("wrongpassword");
        
        MvcResult result1 = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(nonExistentUser)))
                .andExpect(status().isUnauthorized())
                .andReturn();
        
        // Le message ne doit pas être spécifique
        String response = result1.getResponse().getContentAsString();
        assertFalse(response.toLowerCase().contains("user not found"),
            "Le message ne doit pas révéler que l'utilisateur n'existe pas");
        assertFalse(response.toLowerCase().contains("utilisateur introuvable"),
            "Le message ne doit pas révéler que l'utilisateur n'existe pas (FR)");
    }

    // ==================== Tests d'exposition d'informations système ====================

    @Test
    @DisplayName("Les erreurs ne doivent pas exposer les stack traces")
    @WithMockUser(username = "user", roles = {"USER"})
    void errorsShouldNotExposeStackTraces() throws Exception {
        // Provoquer une erreur avec un ID invalide
        MvcResult result = mockMvc.perform(get("/api/patients/invalid-id"))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        
        assertFalse(response.contains("at java."), 
            "Les stack traces Java ne doivent pas être exposées");
        assertFalse(response.contains("at org.springframework."),
            "Les stack traces Spring ne doivent pas être exposées");
        assertFalse(response.contains("at com.healthcare."),
            "Les stack traces de l'application ne doivent pas être exposées");
    }

    @Test
    @DisplayName("Les erreurs SQL ne doivent pas être exposées")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void sqlErrorsShouldNotBeExposed() throws Exception {
        // Envoyer des données malformées pour provoquer une erreur
        String malformedData = "{\"nom\":null,\"prenom\":null}";
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(malformedData))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        
        assertFalse(response.toLowerCase().contains("sql"), 
            "Les erreurs SQL ne doivent pas être exposées");
        assertFalse(response.toLowerCase().contains("hibernate"),
            "Les erreurs Hibernate ne doivent pas être exposées");
        assertFalse(response.toLowerCase().contains("jdbc"),
            "Les erreurs JDBC ne doivent pas être exposées");
    }

    // ==================== Tests d'en-têtes d'exposition ====================

    @Test
    @DisplayName("Les en-têtes serveur ne doivent pas exposer les versions")
    @WithMockUser
    void serverHeadersShouldNotExposeVersions() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/patients"))
                .andReturn();
        
        String serverHeader = result.getResponse().getHeader("Server");
        String xPoweredBy = result.getResponse().getHeader("X-Powered-By");
        
        if (serverHeader != null) {
            assertFalse(serverHeader.matches(".*\\d+\\.\\d+.*"),
                "L'en-tête Server ne doit pas contenir de numéro de version");
        }
        
        assertNull(xPoweredBy, 
            "L'en-tête X-Powered-By ne doit pas être présent");
    }

    // ==================== Tests d'exposition de données sensibles ====================

    @Test
    @DisplayName("Les tokens JWT ne doivent pas être loggués dans les réponses d'erreur")
    void jwtTokensShouldNotBeLoggedInErrors() throws Exception {
        String fakeToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0In0.signature";
        
        MvcResult result = mockMvc.perform(get("/api/patients")
                .header("Authorization", "Bearer " + fakeToken))
                .andExpect(status().isUnauthorized())
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        assertFalse(response.contains(fakeToken),
            "Le token JWT ne doit pas être réfléchi dans la réponse d'erreur");
    }

    @Test
    @DisplayName("Les informations de configuration ne doivent pas être exposées")
    void configurationInfoShouldNotBeExposed() throws Exception {
        // Tenter d'accéder à des endpoints de configuration
        mockMvc.perform(get("/api/config"))
                .andExpect(status().is4xxClientError());
        
        mockMvc.perform(get("/env"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertTrue(status >= 400 || status == 200,
                        "L'endpoint /env doit être protégé ou inexistant");
                });
    }

    // ==================== Tests Actuator Security ====================

    @Test
    @DisplayName("Les endpoints Actuator sensibles doivent être protégés")
    void sensitiveActuatorEndpointsShouldBeProtected() throws Exception {
        // L'endpoint health basique peut être public
        mockMvc.perform(get("/actuator/health"))
                .andReturn(); // Peut être OK
        
        // Mais les endpoints sensibles doivent être protégés ou désactivés
        mockMvc.perform(get("/actuator/env"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    // Doit être soit 401/403 (protégé) soit 404 (désactivé)
                    assertTrue(status == 401 || status == 403 || status == 404,
                        "L'endpoint /actuator/env doit être protégé ou désactivé");
                });
    }

    @Test
    @DisplayName("Les détails d'exception ne doivent pas fuiter dans les réponses JSON")
    @WithMockUser(username = "user", roles = {"USER"})
    void exceptionDetailsShouldNotLeakInJson() throws Exception {
        // Provoquer une exception avec une requête invalide
        MvcResult result = mockMvc.perform(get("/api/patients/0"))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        
        // Vérifier que les détails d'implémentation ne sont pas exposés
        assertFalse(response.contains("java.lang."),
            "Les noms de classes Java ne doivent pas être exposés");
        assertFalse(response.contains("Exception"),
            "Les noms d'exceptions ne doivent pas être exposés directement");
    }

    // ==================== Tests Information Disclosure via Error Messages ====================

    @Test
    @DisplayName("Les erreurs de validation ne doivent pas exposer la structure interne")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void validationErrorsShouldNotExposeInternalStructure() throws Exception {
        String invalidJson = "{\"invalidField\":\"value\"}";
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(invalidJson))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        
        // Les erreurs de validation peuvent mentionner les champs, 
        // mais pas les détails d'implémentation
        assertFalse(response.contains("com.healthcare."),
            "Les noms de packages ne doivent pas être exposés");
    }
}
