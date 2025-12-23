package com.healthcare.dashboard.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.DatasetRowDTO;
import com.healthcare.dashboard.dto.MLPredictionRequestDTO;
import com.healthcare.dashboard.dto.MLPredictionResponseDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.MLPredictionService;
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
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MLPredictionController.class)
class MLPredictionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MLPredictionService mlPredictionService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser
    void getDatasetJson_ShouldReturnList() throws Exception {
        DatasetRowDTO row = new DatasetRowDTO();
        row.setService("Urgences");
        row.setPatientsCount(100);
        
        when(mlPredictionService.generateDataset(any(LocalDate.class), any(LocalDate.class)))
                .thenReturn(Arrays.asList(row));

        mockMvc.perform(get("/api/ml/dataset/json")
                .param("startDate", "2024-01-01")
                .param("endDate", "2024-01-31"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Urgences"));
    }

    @Test
    @WithMockUser
    void exportDataset_ShouldReturnCsv() throws Exception {
        DatasetRowDTO row = new DatasetRowDTO();
        row.setService("Urgences");
        row.setPatientsCount(100);
        
        when(mlPredictionService.generateDataset(any(LocalDate.class), any(LocalDate.class)))
                .thenReturn(Arrays.asList(row));

        mockMvc.perform(get("/api/ml/dataset/export")
                .param("startDate", "2024-01-01")
                .param("endDate", "2024-01-31"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("text/csv"));
    }

    @Test
    @WithMockUser
    void generatePredictions_ShouldReturnResponse() throws Exception {
        MLPredictionRequestDTO request = new MLPredictionRequestDTO();
        request.setService("Urgences");
        request.setDaysAhead(30);
        request.setPredictionType("COUT");
        request.setStartDate(LocalDate.now());

        MLPredictionResponseDTO response = new MLPredictionResponseDTO();
        response.setService("Urgences");
        response.setPredictionType("COUT");
        
        when(mlPredictionService.generateMLPredictions(any(MLPredictionRequestDTO.class)))
                .thenReturn(response);

        mockMvc.perform(post("/api/ml/predictions/generate")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.service").value("Urgences"));
    }

    @Test
    @WithMockUser
    void getPredictionsForService_ShouldReturnResponse() throws Exception {
        MLPredictionResponseDTO response = new MLPredictionResponseDTO();
        response.setService("Cardiologie");
        response.setPredictionType("COUT");
        
        when(mlPredictionService.generateMLPredictions(any(MLPredictionRequestDTO.class)))
                .thenReturn(response);

        mockMvc.perform(get("/api/ml/predictions/service/Cardiologie")
                .param("daysAhead", "30")
                .param("predictionType", "COUT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.service").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void getCurrentStatistics_ShouldReturnStatistics() throws Exception {
        List<Map<String, Object>> stats = Arrays.asList(
                Map.of("service", "Urgences", "value", 150)
        );
        
        when(mlPredictionService.getCurrentStatisticsForAllServices("PATIENTS"))
                .thenReturn(stats);

        mockMvc.perform(get("/api/ml/statistics/current")
                .param("type", "PATIENTS"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Urgences"));
    }

    @Test
    @WithMockUser
    void getPredictionsAllServices_ShouldReturnList() throws Exception {
        MLPredictionResponseDTO response1 = new MLPredictionResponseDTO();
        response1.setService("Urgences");
        response1.setPredictionType("COUT");
        
        MLPredictionResponseDTO response2 = new MLPredictionResponseDTO();
        response2.setService("Chirurgie");
        response2.setPredictionType("COUT");
        
        when(mlPredictionService.generateMLPredictions(any(MLPredictionRequestDTO.class)))
                .thenReturn(response1, response2);

        mockMvc.perform(get("/api/ml/predictions/all-services")
                .param("daysAhead", "30")
                .param("predictionType", "COUT"))
                .andExpect(status().isOk());
    }

    @Test
    void getDatasetJson_Unauthorized_ShouldFail() throws Exception {
        mockMvc.perform(get("/api/ml/dataset/json")
                .param("startDate", "2024-01-01")
                .param("endDate", "2024-01-31"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser
    void generatePredictions_WithDefaultValues_ShouldReturnResponse() throws Exception {
        MLPredictionRequestDTO request = new MLPredictionRequestDTO();
        request.setService("Urgences");
        // No daysAhead, predictionType, or startDate - should use defaults

        MLPredictionResponseDTO response = new MLPredictionResponseDTO();
        response.setService("Urgences");
        response.setPredictionType("COUT");
        
        when(mlPredictionService.generateMLPredictions(any(MLPredictionRequestDTO.class)))
                .thenReturn(response);

        mockMvc.perform(post("/api/ml/predictions/generate")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.service").value("Urgences"));
    }

    @Test
    @WithMockUser
    void getCurrentStatistics_WithCoutType_ShouldReturnStats() throws Exception {
        List<Map<String, Object>> stats = Arrays.asList(
                Map.of("service", "Cardiologie", "cout_moyen", 12000.0)
        );
        
        when(mlPredictionService.getCurrentStatisticsForAllServices("COUT"))
                .thenReturn(stats);

        mockMvc.perform(get("/api/ml/statistics/current")
                .param("type", "COUT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Cardiologie"));
    }

    @Test
    @WithMockUser
    void getCurrentStatistics_WithOccupationType_ShouldReturnStats() throws Exception {
        List<Map<String, Object>> stats = Arrays.asList(
                Map.of("service", "Neurologie", "taux", 75.0)
        );
        
        when(mlPredictionService.getCurrentStatisticsForAllServices("OCCUPATION"))
                .thenReturn(stats);

        mockMvc.perform(get("/api/ml/statistics/current")
                .param("type", "OCCUPATION"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Neurologie"));
    }
}

