package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.services.DashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

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
        when(dashboardService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPatients").value(100));
    }

    @Test
    @WithMockUser
    void getActesByType_ShouldReturnList() throws Exception {
        ActesByTypeStatsDTO dto = new ActesByTypeStatsDTO("TEST", 1L, 10.0);
        when(dashboardService.getActesByType()).thenReturn(Collections.singletonList(dto));

        mockMvc.perform(get("/api/dashboard/actes-by-type"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("TEST"));
    }
}
