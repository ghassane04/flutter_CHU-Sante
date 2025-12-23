package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.dto.RevenusByMonthStatsDTO;
import com.healthcare.dashboard.dto.SejoursByServiceStatsDTO;
import com.healthcare.dashboard.security.JwtTokenProvider;
import com.healthcare.dashboard.services.DashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(DashboardController.class)
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DashboardService dashboardService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private UserDetailsService userDetailsService;

    @Test
    @WithMockUser
    void getDashboardStats_ShouldReturnStats() throws Exception {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalPatients(100L);
        stats.setSejoursEnCours(50L);
        stats.setTotalActes(200L);
        stats.setRevenusTotal(50000.0);
        when(dashboardService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPatients").value(100))
                .andExpect(jsonPath("$.sejoursEnCours").value(50));
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
        RevenusByMonthStatsDTO dto1 = new RevenusByMonthStatsDTO("2024-01", 50000.0, 100L);
        RevenusByMonthStatsDTO dto2 = new RevenusByMonthStatsDTO("2024-02", 55000.0, 110L);
        when(dashboardService.getRevenusByMonth()).thenReturn(Arrays.asList(dto1, dto2));

        mockMvc.perform(get("/api/dashboard/revenus-by-month"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].mois").value("2024-01"))
                .andExpect(jsonPath("$[1].revenus").value(55000.0));
    }

    @Test
    @WithMockUser
    void getSejoursByService_ShouldReturnList() throws Exception {
        SejoursByServiceStatsDTO dto1 = new SejoursByServiceStatsDTO("Cardiologie", 25L, 30L);
        SejoursByServiceStatsDTO dto2 = new SejoursByServiceStatsDTO("Urgences", 40L, 45L);
        when(dashboardService.getSejoursByService()).thenReturn(Arrays.asList(dto1, dto2));

        mockMvc.perform(get("/api/dashboard/sejours-by-service"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].service").value("Cardiologie"))
                .andExpect(jsonPath("$[1].actifs").value(40));
    }

    @Test
    void getDashboardStats_Unauthorized_ShouldFail() throws Exception {
        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser
    void getDashboardStats_ShouldReturnEmptyStats_WhenNoData() throws Exception {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalPatients(0L);
        stats.setSejoursEnCours(0L);
        stats.setTotalActes(0L);
        when(dashboardService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPatients").value(0));
    }

    @Test
    @WithMockUser
    void getActesByType_ShouldReturnEmptyList_WhenNoData() throws Exception {
        when(dashboardService.getActesByType()).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/dashboard/actes-by-type"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    @WithMockUser
    void getRevenusByMonth_ShouldReturnEmptyList_WhenNoData() throws Exception {
        when(dashboardService.getRevenusByMonth()).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/dashboard/revenus-by-month"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    @WithMockUser
    void getSejoursByService_ShouldReturnEmptyList_WhenNoData() throws Exception {
        when(dashboardService.getSejoursByService()).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/dashboard/sejours-by-service"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    @WithMockUser
    void getActesByType_ShouldReturnMultipleItems() throws Exception {
        ActesByTypeStatsDTO dto1 = new ActesByTypeStatsDTO("Consultation", 50L, 2500.0);
        ActesByTypeStatsDTO dto2 = new ActesByTypeStatsDTO("Chirurgie", 20L, 15000.0);
        ActesByTypeStatsDTO dto3 = new ActesByTypeStatsDTO("Radiologie", 30L, 4500.0);
        when(dashboardService.getActesByType()).thenReturn(Arrays.asList(dto1, dto2, dto3));

        mockMvc.perform(get("/api/dashboard/actes-by-type"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].type").value("Consultation"))
                .andExpect(jsonPath("$[1].type").value("Chirurgie"))
                .andExpect(jsonPath("$[2].type").value("Radiologie"));
    }

    @Test
    @WithMockUser
    void getRevenusByMonth_ShouldReturnMultipleMonths() throws Exception {
        RevenusByMonthStatsDTO dto1 = new RevenusByMonthStatsDTO("2024-01", 50000.0, 100L);
        RevenusByMonthStatsDTO dto2 = new RevenusByMonthStatsDTO("2024-02", 55000.0, 110L);
        RevenusByMonthStatsDTO dto3 = new RevenusByMonthStatsDTO("2024-03", 60000.0, 120L);
        when(dashboardService.getRevenusByMonth()).thenReturn(Arrays.asList(dto1, dto2, dto3));

        mockMvc.perform(get("/api/dashboard/revenus-by-month"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[2].mois").value("2024-03"))
                .andExpect(jsonPath("$[2].revenus").value(60000.0));
    }
}

