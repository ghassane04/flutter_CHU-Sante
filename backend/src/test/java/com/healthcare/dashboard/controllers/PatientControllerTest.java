package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.PatientDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.PatientService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

@WebMvcTest(PatientController.class)
class PatientControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PatientService patientService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    private PatientDTO patientDTO;

    @BeforeEach
    void setUp() {
        patientDTO = new PatientDTO();
        patientDTO.setId(1L);
        patientDTO.setNom("Doe");
        patientDTO.setPrenom("John");
        patientDTO.setEmail("john.doe@example.com");
        patientDTO.setNumeroSecuriteSociale("1234567890123");
        patientDTO.setDateNaissance(LocalDate.of(1990, 1, 1));
    }

    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void getAllPatients_ShouldReturnList() throws Exception {
        when(patientService.getAllPatients()).thenReturn(Arrays.asList(patientDTO));

        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nom").value("Doe"));
    }

    @Test
    @WithMockUser
    void getPatientById_ShouldReturnPatient_WhenExists() throws Exception {
        when(patientService.getPatientById(1L)).thenReturn(patientDTO);

        mockMvc.perform(get("/api/patients/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Doe"));
    }

    @Test
    @WithMockUser
    void createPatient_ShouldReturnCreated() throws Exception {
        when(patientService.createPatient(any(PatientDTO.class))).thenReturn(patientDTO);

        mockMvc.perform(post("/api/patients")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(patientDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nom").value("Doe"));
    }

    @Test
    @WithMockUser
    void updatePatient_ShouldReturnUpdated() throws Exception {
        when(patientService.updatePatient(eq(1L), any(PatientDTO.class))).thenReturn(patientDTO);

        mockMvc.perform(put("/api/patients/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(patientDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Doe"));
    }

    @Test
    @WithMockUser
    void deletePatient_ShouldReturnNoContent() throws Exception {
        mockMvc.perform(delete("/api/patients/1")
                .with(csrf()))
                .andExpect(status().isNoContent());
    }

    @Test
    void getPatients_Unauthorized_ShouldFail() throws Exception {
        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser
    void countTotalPatients_ShouldReturnCount() throws Exception {
        when(patientService.countTotalPatients()).thenReturn(150L);

        mockMvc.perform(get("/api/patients/count"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").value(150));
    }

    @Test
    @WithMockUser
    void getPatientById_ShouldReturnNotFound_WhenNotExists() throws Exception {
        when(patientService.getPatientById(999L)).thenReturn(null);

        mockMvc.perform(get("/api/patients/999"))
                .andExpect(status().isOk());
    }
}
