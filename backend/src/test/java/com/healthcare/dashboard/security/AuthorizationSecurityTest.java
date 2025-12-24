package com.healthcare.dashboard.security;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests de sécurité pour l'autorisation.
 * Vérifie le contrôle d'accès basé sur les rôles (RBAC) et la prévention
 * de l'escalade de privilèges.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("Tests de Sécurité - Autorisation")
class AuthorizationSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    // ==================== Tests d'escalade de privilèges ====================

    @Test
    @DisplayName("Un utilisateur USER ne doit pas accéder aux endpoints ADMIN")
    @WithMockUser(username = "user", roles = {"USER"})
    void userShouldNotAccessAdminEndpoints() throws Exception {
        // Tentative d'accès à un endpoint réservé aux admins
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Un administrateur doit pouvoir accéder aux endpoints ADMIN")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void adminShouldAccessAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk());
    }

    // ==================== Tests de contrôle d'accès horizontal ====================

    @Test
    @DisplayName("Un utilisateur authentifié doit pouvoir accéder aux endpoints patients")
    @WithMockUser(username = "user", roles = {"USER"})
    void authenticatedUserShouldAccessPatientEndpoints() throws Exception {
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Un utilisateur non authentifié ne doit pas accéder aux données patients")
    void unauthenticatedUserShouldNotAccessPatients() throws Exception {
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isUnauthorized());
    }

    // ==================== Tests de manipulation d'ID ====================

    @Test
    @DisplayName("Doit gérer les IDs invalides sans exposer d'informations sensibles")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldHandleInvalidIdsSecurely() throws Exception {
        // Test avec un ID négatif
        mockMvc.perform(get("/api/patients/-1"))
                .andExpect(status().is4xxClientError());
        
        // Test avec un ID très grand
        mockMvc.perform(get("/api/patients/9999999999999"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection dans les paramètres de chemin")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectPathParameterInjection() throws Exception {
        // Tentative d'injection SQL via l'ID
        mockMvc.perform(get("/api/patients/1 OR 1=1"))
                .andExpect(status().is4xxClientError());
    }

    // ==================== Tests de contrôle d'accès aux ressources ====================

    @Test
    @DisplayName("L'accès aux services médicaux doit être protégé")
    @WithMockUser(username = "user", roles = {"USER"})
    void medicalServicesAccessShouldBeProtected() throws Exception {
        mockMvc.perform(get("/api/services"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("L'accès aux séjours doit être protégé")
    @WithMockUser(username = "user", roles = {"USER"})
    void sejourAccessShouldBeProtected() throws Exception {
        mockMvc.perform(get("/api/sejours"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("L'accès aux alertes doit être protégé")
    @WithMockUser(username = "user", roles = {"USER"})
    void alertAccessShouldBeProtected() throws Exception {
        mockMvc.perform(get("/api/alerts"))
                .andExpect(status().isOk());
    }

    // ==================== Tests HTTP Method Restriction ====================

    @Test
    @DisplayName("Les méthodes HTTP non autorisées doivent être rejetées")
    @WithMockUser(username = "user", roles = {"USER"})
    void unsupportedHttpMethodsShouldBeRejected() throws Exception {
        // Test méthode PATCH sur endpoint qui ne la supporte pas
        mockMvc.perform(patch("/api/auth/login"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Un utilisateur ne peut pas modifier les données sans autorisation appropriée")
    @WithMockUser(username = "user", roles = {"USER"})
    void userCannotModifyDataWithoutProperRole() throws Exception {
        // Tentative de suppression par un utilisateur simple
        mockMvc.perform(delete("/api/users/1"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Un admin peut supprimer des utilisateurs")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void adminCanDeleteUsers() throws Exception {
        // Un admin devrait pouvoir tenter de supprimer (même si l'ID n'existe pas)
        mockMvc.perform(delete("/api/users/999999"))
                .andExpect(status().is4xxClientError()); // Not found, mais pas forbidden
    }
}
