package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.ServiceDTO;
import com.healthcare.dashboard.services.ServiceMedicalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ServiceControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ServiceMedicalService serviceMedicalService;

    @Autowired
    private ObjectMapper objectMapper;

    private ServiceDTO serviceDTO;

    @BeforeEach
    void setUp() {
        serviceDTO = new ServiceDTO();
        serviceDTO.setId(1L);
        serviceDTO.setNom("Cardiologie");
    }

    @Test
    @WithMockUser
    void getAllServices_ShouldReturnList() throws Exception {
        when(serviceMedicalService.getAllServices()).thenReturn(Arrays.asList(serviceDTO));

        mockMvc.perform(get("/api/services"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nom").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void getServiceById_ShouldReturnService() throws Exception {
        when(serviceMedicalService.getServiceById(1L)).thenReturn(serviceDTO);

        mockMvc.perform(get("/api/services/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void createService_ShouldReturnCreated() throws Exception {
        when(serviceMedicalService.createService(any(ServiceDTO.class))).thenReturn(serviceDTO);

        mockMvc.perform(post("/api/services")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(serviceDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nom").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void updateService_ShouldReturnUpdated() throws Exception {
        when(serviceMedicalService.updateService(eq(1L), any(ServiceDTO.class))).thenReturn(serviceDTO);

        mockMvc.perform(put("/api/services/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(serviceDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void deleteService_ShouldReturnNoContent() throws Exception {
        mockMvc.perform(delete("/api/services/1")
                .with(csrf()))
                .andExpect(status().isNoContent());
    }
}
