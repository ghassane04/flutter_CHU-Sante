package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Report;
import com.healthcare.dashboard.repositories.ReportRepository;
import com.healthcare.dashboard.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ReportController.class)
class ReportControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ReportRepository reportRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    private Report report;

    @BeforeEach
    void setUp() {
        report = new Report();
        report.setId(1L);
        report.setType("FINANCIER");
        report.setPeriode("2024-01");
    }

    @Test
    @WithMockUser
    void getAllReports_ShouldReturnList() throws Exception {
        when(reportRepository.findAll()).thenReturn(Arrays.asList(report));

        mockMvc.perform(get("/api/reports"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("FINANCIER"));
    }

    @Test
    @WithMockUser
    void getReportById_ShouldReturnReport() throws Exception {
        when(reportRepository.findById(1L)).thenReturn(Optional.of(report));

        mockMvc.perform(get("/api/reports/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("FINANCIER"));
    }

    @Test
    @WithMockUser
    void getReportsByType_ShouldReturnList() throws Exception {
        when(reportRepository.findByType("FINANCIER")).thenReturn(Arrays.asList(report));

        mockMvc.perform(get("/api/reports/type/FINANCIER"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("FINANCIER"));
    }

    @Test
    @WithMockUser
    void deleteReport_ShouldReturnOk() throws Exception {
        when(reportRepository.existsById(1L)).thenReturn(true);

        mockMvc.perform(delete("/api/reports/1")
                .with(csrf()))
                .andExpect(status().isOk());
    }
}
