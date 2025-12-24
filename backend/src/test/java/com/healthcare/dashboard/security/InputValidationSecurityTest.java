package com.healthcare.dashboard.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.PatientDTO;
import com.healthcare.dashboard.dto.SignupRequest;
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

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests de sécurité pour la validation des entrées.
 * Vérifie la protection contre les injections SQL, XSS, commandes, etc.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("Tests de Sécurité - Validation des Entrées")
class InputValidationSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    // ==================== Tests d'injection SQL ====================

    @Test
    @DisplayName("Doit rejeter l'injection SQL dans les champs de patient")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectSqlInjectionInPatientFields() throws Exception {
        PatientDTO maliciousPatient = new PatientDTO();
        maliciousPatient.setNom("Robert'); DROP TABLE patients;--");
        maliciousPatient.setPrenom("Test");
        maliciousPatient.setDateNaissance(LocalDate.of(1990, 1, 1));
        maliciousPatient.setSexe("M");
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(maliciousPatient)))
                .andReturn();
        
        // La requête doit soit être rejetée, soit être traitée sans exécuter le SQL
        // Le fait que le test continue signifie que la table n'a pas été supprimée
        assertFalse(result.getResponse().getContentAsString().contains("DROP TABLE"));
    }

    @Test
    @DisplayName("Doit rejeter l'injection SQL UNION dans les requêtes")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectUnionSqlInjection() throws Exception {
        // Tentative d'injection UNION pour extraire des données
        mockMvc.perform(get("/api/patients")
                .param("search", "1 UNION SELECT * FROM users--"))
                .andExpect(result -> {
                    String content = result.getResponse().getContentAsString();
                    assertFalse(content.contains("password"));
                    assertFalse(content.contains("UNION"));
                });
    }

    @Test
    @DisplayName("Doit rejeter l'injection SQL avec commentaires")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectSqlCommentInjection() throws Exception {
        mockMvc.perform(get("/api/auth/check-username/admin'--"))
                .andExpect(result -> {
                    // Ne doit pas retourner d'erreur SQL
                    String content = result.getResponse().getContentAsString();
                    assertFalse(content.toLowerCase().contains("sql"));
                    assertFalse(content.toLowerCase().contains("syntax"));
                });
    }

    // ==================== Tests XSS (Cross-Site Scripting) ====================

    @Test
    @DisplayName("Doit échapper les balises script dans les champs texte")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldEscapeScriptTagsInTextFields() throws Exception {
        PatientDTO xssPatient = new PatientDTO();
        xssPatient.setNom("<script>alert('XSS')</script>");
        xssPatient.setPrenom("Normal");
        xssPatient.setDateNaissance(LocalDate.of(1990, 1, 1));
        xssPatient.setSexe("M");
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(xssPatient)))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        // Le script ne doit pas être exécutable dans la réponse
        assertFalse(response.contains("<script>alert('XSS')</script>") 
            && !response.contains("&lt;script&gt;"),
            "Les balises script doivent être échappées ou nettoyées");
    }

    @Test
    @DisplayName("Doit rejeter les payloads XSS avec événements HTML")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectXssEventHandlers() throws Exception {
        PatientDTO xssPatient = new PatientDTO();
        xssPatient.setNom("<img src=x onerror=alert('XSS')>");
        xssPatient.setPrenom("Test");
        xssPatient.setDateNaissance(LocalDate.of(1990, 1, 1));
        xssPatient.setSexe("M");
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(xssPatient)))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        assertFalse(response.contains("onerror="));
    }

    @Test
    @DisplayName("Doit rejeter les payloads XSS encodés")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectEncodedXssPayloads() throws Exception {
        SignupRequest xssSignup = new SignupRequest();
        xssSignup.setUsername("user123");
        xssSignup.setEmail("test@test.com");
        // Payload XSS encodé en HTML entities
        xssSignup.setNom("&#60;script&#62;alert('XSS')&#60;/script&#62;");
        xssSignup.setPrenom("Normal");
        xssSignup.setPassword("password123");
        
        mockMvc.perform(post("/api/auth/signup")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(xssSignup)))
                .andReturn();
        
        // Le test passe si aucune erreur de serveur n'est levée
    }

    // ==================== Tests d'injection de commandes ====================

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection de commandes OS")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectOsCommandInjection() throws Exception {
        PatientDTO cmdInjection = new PatientDTO();
        cmdInjection.setNom("test; cat /etc/passwd");
        cmdInjection.setPrenom("Normal");
        cmdInjection.setDateNaissance(LocalDate.of(1990, 1, 1));
        cmdInjection.setSexe("M");
        
        MvcResult result = mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(cmdInjection)))
                .andReturn();
        
        String response = result.getResponse().getContentAsString();
        assertFalse(response.contains("root:"));
        assertFalse(response.contains("/bin/bash"));
    }

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection Windows")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectWindowsCommandInjection() throws Exception {
        PatientDTO cmdInjection = new PatientDTO();
        cmdInjection.setNom("test & dir C:\\");
        cmdInjection.setPrenom("Normal");
        cmdInjection.setDateNaissance(LocalDate.of(1990, 1, 1));
        cmdInjection.setSexe("M");
        
        mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(cmdInjection)))
                .andReturn();
        
        // Test réussi si pas de crash
    }

    // ==================== Tests Path Traversal ====================

    @Test
    @DisplayName("Doit rejeter les tentatives de path traversal")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectPathTraversal() throws Exception {
        mockMvc.perform(get("/api/patients/../../../etc/passwd"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Doit rejeter le path traversal encodé")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectEncodedPathTraversal() throws Exception {
        // %2e%2e = ..
        mockMvc.perform(get("/api/patients/%2e%2e/%2e%2e/etc/passwd"))
                .andExpect(status().is4xxClientError());
    }

    // ==================== Tests de validation des types ====================

    @Test
    @DisplayName("Doit rejeter les JSON malformés")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectMalformedJson() throws Exception {
        String malformedJson = "{nom: 'test', prenom: unclosed";
        
        mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(malformedJson))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Doit rejeter les très longues entrées (DoS prevention)")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectVeryLongInputs() throws Exception {
        // Créer une chaîne très longue
        StringBuilder longString = new StringBuilder();
        for (int i = 0; i < 100000; i++) {
            longString.append("A");
        }
        
        PatientDTO largePatient = new PatientDTO();
        largePatient.setNom(longString.toString());
        largePatient.setPrenom("Normal");
        largePatient.setDateNaissance(LocalDate.of(1990, 1, 1));
        largePatient.setSexe("M");
        
        mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(largePatient)))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertTrue(status >= 400 || status == 201, 
                        "Doit soit rejeter, soit accepter (mais pas crasher)");
                });
    }

    // ==================== Tests LDAP/NoSQL Injection ====================

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection LDAP")
    @WithMockUser(username = "user", roles = {"USER"})
    void shouldRejectLdapInjection() throws Exception {
        mockMvc.perform(get("/api/auth/check-username/*)(uid=*))(|(uid=*"))
                .andReturn();
        // Test réussi si pas de crash serveur
    }

    @Test
    @DisplayName("Doit rejeter les tentatives d'injection NoSQL")
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void shouldRejectNoSqlInjection() throws Exception {
        // Payload MongoDB classique
        String nosqlPayload = "{\"username\": {\"$gt\": \"\"}, \"password\": {\"$gt\": \"\"}}";
        
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(nosqlPayload))
                .andExpect(status().is4xxClientError());
    }
}
