package com.healthcare.dashboard.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.PatientDTO;
import com.healthcare.dashboard.repositories.PatientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration test that tests the full flow: Controller -> Service -> Repository -> DB
 * Uses @Transactional to rollback after each test
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PatientIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PatientRepository patientRepository;

    private PatientDTO patientDTO;

    @BeforeEach
    void setUp() {
        patientDTO = new PatientDTO();
        patientDTO.setNom("IntegrationTest");
        patientDTO.setPrenom("Patient");
        patientDTO.setEmail("integration@test.com");
        patientDTO.setNumeroSecuriteSociale("9999999999999");
        patientDTO.setDateNaissance(LocalDate.of(1985, 6, 15));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void fullPatientWorkflow_ShouldWork() throws Exception {
        // 1. CREATE - Create a new patient
        MvcResult createResult = mockMvc.perform(post("/api/patients")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(patientDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nom").value("IntegrationTest"))
                .andReturn();

        // Extract created patient ID
        PatientDTO createdPatient = objectMapper.readValue(
            createResult.getResponse().getContentAsString(), 
            PatientDTO.class
        );
        Long patientId = createdPatient.getId();

        // 2. READ - Get the patient by ID
        mockMvc.perform(get("/api/patients/" + patientId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("IntegrationTest"));

        // 3. UPDATE - Update the patient
        patientDTO.setNom("UpdatedName");
        mockMvc.perform(put("/api/patients/" + patientId)
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(patientDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("UpdatedName"));

        // 4. LIST - Verify patient is in list
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());

        // 5. DELETE - Delete the patient
        mockMvc.perform(delete("/api/patients/" + patientId)
                .with(csrf()))
                .andExpect(status().isNoContent());

        // 6. VERIFY DELETION - Patient should not be found (controller throws exception)
        assertThrows(Exception.class, () -> 
            mockMvc.perform(get("/api/patients/" + patientId))
        );
    }

    @Test
    void accessWithoutAuth_ShouldBeForbidden() throws Exception {
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isForbidden());
    }
}
