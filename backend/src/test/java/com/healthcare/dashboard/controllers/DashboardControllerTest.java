package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.dto.RevenusByMonthStatsDTO;
import com.healthcare.dashboard.dto.SejoursByServiceStatsDTO;
import com.healthcare.dashboard.services.DashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DashboardService dashboardService;

    @Test
    @WithMockUser
    void getDashboardStats_ShouldReturnStats() throws Exception {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalPatients(100L);
        stats.setTotalMedecins(25L);
        stats.setTotalSejours(50L);
        stats.setTotalActes(200L);
        when(dashboardService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPatients").value(100))
                .andExpect(jsonPath("$.totalMedecins").value(25));
    }

    @Test
    @WithMockUser
    void getActesByType_ShouldReturnList() throws Exception {
        ActesByTypeStatsDTO dto = new ActesByTypeStatsDTO("Consultation", 50L, 2500.0);
        ActesByTypeStatsDTO dto2 = new ActesByTypeStatsDTO("Chirurgie", 20L, 15000.0);
        when(dashboardService.getActesByType()).thenReturn(Arrays.asList(dto, dto2));

        mockMvc.perform(get("/api/dashboard/actes-by-type"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("Consultation"))
                .andExpect(jsonPath("$[1].type").value("Chirurgie"));
    }

    @Test
    @WithMockUser
    void getRevenusByMonth_ShouldReturnList() throws Exception {
        RevenusByMonthStatsDTO dto1 = new RevenusByMonthStatsDTO("2024-01", 50000.0);
        RevenusByMonthStatsDTO dto2 = new RevenusByMonthStatsDTO("2024-02", 55000.0);
        when(dashboardService.getRevenusByMonth()).thenReturn(Arrays.asList(dto1, dto2));

        mockMvc.perform(get("/api/dashboard/revenus-by-month"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].month").value("2024-01"))
                .andExpect(jsonPath("$[1].totalRevenu").value(55000.0));
    }

    @Test
    @WithMockUser
    void getSejoursByService_ShouldReturnList() throws Exception {
        SejoursByServiceStatsDTO dto1 = new SejoursByServiceStatsDTO("Cardiologie", 30L);
        SejoursByServiceStatsDTO dto2 = new SejoursByServiceStatsDTO("Urgences", 45L);
        when(dashboardService.getSejoursByService()).thenReturn(Arrays.asList(dto1, dto2));

        mockMvc.perform(get("/api/dashboard/sejours-by-service"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Cardiologie"))
                .andExpect(jsonPath("$[1].count").value(45));
    }

    @Test
    void getDashboardStats_Unauthorized_ShouldFail() throws Exception {
        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser
    void getDashboardStats_ShouldReturnEmptyStats_WhenNoData() throws Exception {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalPatients(0L);
        stats.setTotalMedecins(0L);
        when(dashboardService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPatients").value(0));
    }
}

