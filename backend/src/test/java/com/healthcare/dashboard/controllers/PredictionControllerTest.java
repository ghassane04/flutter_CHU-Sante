package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Prediction;
import com.healthcare.dashboard.repositories.PredictionRepository;
import com.healthcare.dashboard.services.PredictionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class PredictionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PredictionRepository predictionRepository;

    @MockBean
    private PredictionService predictionService;

    private Prediction prediction;

    @BeforeEach
    void setUp() {
        prediction = new Prediction();
        prediction.setId(1L);
        prediction.setType("COUT");
        prediction.setTitre("Cost Prediction Q1");
    }

    @Test
    @WithMockUser
    void getAllPredictions_ShouldReturnList() throws Exception {
        when(predictionRepository.findByOrderByCreatedAtDesc()).thenReturn(Arrays.asList(prediction));

        mockMvc.perform(get("/api/predictions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("COUT"));
    }

    @Test
    @WithMockUser
    void getPredictionById_ShouldReturnPrediction() throws Exception {
        when(predictionRepository.findById(1L)).thenReturn(Optional.of(prediction));

        mockMvc.perform(get("/api/predictions/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("COUT"));
    }

    @Test
    @WithMockUser
    void getPredictionsByType_ShouldReturnList() throws Exception {
        when(predictionRepository.findByType("COUT")).thenReturn(Arrays.asList(prediction));

        mockMvc.perform(get("/api/predictions/type/COUT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("COUT"));
    }

    @Test
    @WithMockUser
    void deletePrediction_ShouldReturnOk() throws Exception {
        when(predictionRepository.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/predictions/1")
                .with(csrf()))
                .andExpect(status().isOk());
    }
}
