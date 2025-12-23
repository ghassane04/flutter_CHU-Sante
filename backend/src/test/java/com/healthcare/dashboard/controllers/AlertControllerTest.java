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
}
