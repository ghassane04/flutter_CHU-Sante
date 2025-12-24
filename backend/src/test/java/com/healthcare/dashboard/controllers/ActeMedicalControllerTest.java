package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.ActeMedicalDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.ActeMedicalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

@WebMvcTest(ActeMedicalController.class)
class ActeMedicalControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ActeMedicalService acteMedicalService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    private ActeMedicalDTO acteMedicalDTO;

    @BeforeEach
    void setUp() {
        acteMedicalDTO = new ActeMedicalDTO();
        acteMedicalDTO.setId(1L);
        acteMedicalDTO.setSejourId(1L);
        acteMedicalDTO.setCode("CCAM123");
        acteMedicalDTO.setLibelle("Consultation");
        acteMedicalDTO.setType("CONSULTATION");
        acteMedicalDTO.setDateRealisation(LocalDateTime.now());
        acteMedicalDTO.setTarif(25.0);
        acteMedicalDTO.setMedecin("Dr. House");
        acteMedicalDTO.setNotes("Notes");
    }

    @Test
    @WithMockUser
    void getAllActes_ShouldReturnList() throws Exception {
        when(acteMedicalService.getAllActes()).thenReturn(Arrays.asList(acteMedicalDTO));

        mockMvc.perform(get("/api/actes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].code").value("CCAM123"));
    }

    @Test
    @WithMockUser
    void getActeById_ShouldReturnActe() throws Exception {
        when(acteMedicalService.getActeById(1L)).thenReturn(acteMedicalDTO);

        mockMvc.perform(get("/api/actes/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("CCAM123"));
    }

    @Test
    @WithMockUser
    void getActesBySejourId_ShouldReturnList() throws Exception {
        when(acteMedicalService.getActesBySejourId(1L)).thenReturn(Arrays.asList(acteMedicalDTO));

        mockMvc.perform(get("/api/actes/sejour/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].code").value("CCAM123"));
    }

    @Test
    @WithMockUser
    void countTotalActes_ShouldReturnCount() throws Exception {
        when(acteMedicalService.countTotalActes()).thenReturn(10L);

        mockMvc.perform(get("/api/actes/count"))
                .andExpect(status().isOk())
                .andExpect(content().string("10"));
    }

    @Test
    @WithMockUser
    void calculateRevenue_ShouldReturnRevenue() throws Exception {
        when(acteMedicalService.calculateTotalRevenue(any(), any())).thenReturn(1000.0);

        mockMvc.perform(get("/api/actes/revenue")
                .param("startDate", LocalDateTime.now().toString())
                .param("endDate", LocalDateTime.now().toString()))
                .andExpect(status().isOk())
                .andExpect(content().string("1000.0"));
    }

    @Test
    @WithMockUser
    void createActe_ShouldReturnCreated() throws Exception {
        when(acteMedicalService.createActe(any(ActeMedicalDTO.class))).thenReturn(acteMedicalDTO);

        mockMvc.perform(post("/api/actes")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(acteMedicalDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("CCAM123"));
    }

    @Test
    @WithMockUser
    void updateActe_ShouldReturnUpdated() throws Exception {
        when(acteMedicalService.updateActe(eq(1L), any(ActeMedicalDTO.class))).thenReturn(acteMedicalDTO);

        mockMvc.perform(put("/api/actes/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(acteMedicalDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("CCAM123"));
    }

    @Test
    @WithMockUser
    void deleteActe_ShouldReturnNoContent() throws Exception {
        doNothing().when(acteMedicalService).deleteActe(1L);

        mockMvc.perform(delete("/api/actes/1")
                .with(csrf()))
                .andExpect(status().isNoContent());
    }

    @Test
    @WithMockUser
    void getAllActes_ShouldReturnEmptyList_WhenNoActes() throws Exception {
        when(acteMedicalService.getAllActes()).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/actes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void getActes_Unauthorized_ShouldFail() throws Exception {
        mockMvc.perform(get("/api/actes"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser
    void countTotalActes_ShouldReturnZero_WhenNoActes() throws Exception {
        when(acteMedicalService.countTotalActes()).thenReturn(0L);

        mockMvc.perform(get("/api/actes/count"))
                .andExpect(status().isOk())
                .andExpect(content().string("0"));
    }

    @Test
    @WithMockUser
    void getActesBySejourId_ShouldReturnEmptyList_WhenNoActes() throws Exception {
        when(acteMedicalService.getActesBySejourId(999L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/actes/sejour/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    @WithMockUser
    void getActeById_ShouldReturnNull_WhenNotFound() throws Exception {
        when(acteMedicalService.getActeById(999L)).thenReturn(null);

        mockMvc.perform(get("/api/actes/999"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void calculateRevenue_ShouldReturnZero_WhenNoActes() throws Exception {
        when(acteMedicalService.calculateTotalRevenue(any(), any())).thenReturn(0.0);

        mockMvc.perform(get("/api/actes/revenue")
                .param("startDate", LocalDateTime.now().toString())
                .param("endDate", LocalDateTime.now().toString()))
                .andExpect(status().isOk())
                .andExpect(content().string("0.0"));
    }
}
