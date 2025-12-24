package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Alert;
import com.healthcare.dashboard.repositories.AlertRepository;
import com.healthcare.dashboard.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AlertController.class)
class AlertControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AlertRepository alertRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    private Alert alert;

    @BeforeEach
    void setUp() {
        alert = new Alert();
        alert.setId(1L);
        alert.setType("CRITICAL");
        alert.setMessage("Test alert");
        alert.setLu(false);
        alert.setResolu(false);
    }

    @Test
    @WithMockUser
    void getAllAlerts_ShouldReturnList() throws Exception {
        when(alertRepository.findAll()).thenReturn(Arrays.asList(alert));

        mockMvc.perform(get("/api/alerts"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].message").value("Test alert"));
    }

    @Test
    @WithMockUser
    void getAlertById_ShouldReturnAlert() throws Exception {
        when(alertRepository.findById(1L)).thenReturn(Optional.of(alert));

        mockMvc.perform(get("/api/alerts/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Test alert"));
    }

    @Test
    @WithMockUser
    void getUnreadAlerts_ShouldReturnList() throws Exception {
        when(alertRepository.findByLuFalse()).thenReturn(Arrays.asList(alert));

        mockMvc.perform(get("/api/alerts/non-lues"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].lu").value(false));
    }

    @Test
    @WithMockUser
    void markAsRead_ShouldReturnUpdated() throws Exception {
        when(alertRepository.findById(1L)).thenReturn(Optional.of(alert));
        alert.setLu(true);
        when(alertRepository.save(any(Alert.class))).thenReturn(alert);

        mockMvc.perform(put("/api/alerts/1/lire")
                .with(csrf()))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void deleteAlert_ShouldReturnOk() throws Exception {
        when(alertRepository.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/alerts/1")
                .with(csrf()))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void getAlertById_ShouldReturnNotFound_WhenNotExists() throws Exception {
        when(alertRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/alerts/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void getUnresolvedAlerts_ShouldReturnList() throws Exception {
        when(alertRepository.findByResoluFalse()).thenReturn(Arrays.asList(alert));

        mockMvc.perform(get("/api/alerts/non-resolues"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].resolu").value(false));
    }

    @Test
    @WithMockUser
    void getAlertStats_ShouldReturnStats() throws Exception {
        when(alertRepository.count()).thenReturn(10L);
        when(alertRepository.countNonLues()).thenReturn(5L);
        when(alertRepository.countNonResolues()).thenReturn(3L);
        when(alertRepository.countCritiquesNonResolues()).thenReturn(1L);

        mockMvc.perform(get("/api/alerts/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalAlertes").value(10))
                .andExpect(jsonPath("$.nonLues").value(5));
    }

    @Test
    @WithMockUser
    void createAlert_ShouldReturnCreated() throws Exception {
        when(alertRepository.save(any(Alert.class))).thenReturn(alert);

        mockMvc.perform(post("/api/alerts")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\":\"CRITICAL\",\"message\":\"New alert\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Test alert"));
    }

    @Test
    @WithMockUser
    void updateAlert_ShouldReturnUpdated() throws Exception {
        when(alertRepository.findById(1L)).thenReturn(Optional.of(alert));
        when(alertRepository.save(any(Alert.class))).thenReturn(alert);

        mockMvc.perform(put("/api/alerts/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\":\"CRITICAL\",\"message\":\"Updated alert\"}"))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void updateAlert_ShouldReturnNotFound() throws Exception {
        when(alertRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/alerts/999")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\":\"CRITICAL\",\"message\":\"Updated alert\"}"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void markAsRead_ShouldReturnNotFound() throws Exception {
        when(alertRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/alerts/999/lire")
                .with(csrf()))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void markAsResolved_ShouldReturnUpdated() throws Exception {
        when(alertRepository.findById(1L)).thenReturn(Optional.of(alert));
        when(alertRepository.save(any(Alert.class))).thenReturn(alert);

        mockMvc.perform(put("/api/alerts/1/resoudre")
                .with(csrf()))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    void markAsResolved_ShouldReturnNotFound() throws Exception {
        when(alertRepository.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/alerts/999/resoudre")
                .with(csrf()))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser
    void deleteAlert_ShouldReturnNotFound() throws Exception {
        when(alertRepository.existsById(999L)).thenReturn(false);

        mockMvc.perform(delete("/api/alerts/999")
                .with(csrf()))
                .andExpect(status().isNotFound());
    }
}
