package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.dto.RevenusByMonthStatsDTO;
import com.healthcare.dashboard.dto.SejoursByServiceStatsDTO;
import com.healthcare.dashboard.repositories.ActeMedicalRepository;
import com.healthcare.dashboard.repositories.PatientRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private PatientRepository patientRepository;
    @Mock
    private SejourRepository sejourRepository;
    @Mock
    private ActeMedicalRepository acteMedicalRepository;

    @InjectMocks
    private DashboardService dashboardService;

    @Test
    void getDashboardStats_ShouldReturnAggregatedStats() {
        when(patientRepository.countTotalPatients()).thenReturn(100L);
        when(sejourRepository.countSejoursEnCours()).thenReturn(5L);
        when(acteMedicalRepository.countTotalActes()).thenReturn(50L);
        when(acteMedicalRepository.calculateTotalRevenue(any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(1000.0);

        DashboardStatsDTO stats = dashboardService.getDashboardStats();

        assertNotNull(stats);
        assertEquals(100L, stats.getTotalPatients());
        assertEquals(5L, stats.getSejoursEnCours());
        assertEquals(50L, stats.getTotalActes());
        assertEquals(1000.0, stats.getRevenusAnnee());
    }

    @Test
    void getActesByType_ShouldReturnStats() {
        List<Object[]> mockResult = new ArrayList<>();
        mockResult.add(new Object[]{"CONSULTATION", 10L, 500.0});
        
        when(acteMedicalRepository.findActesGroupedByType()).thenReturn(mockResult);

        List<ActesByTypeStatsDTO> result = dashboardService.getActesByType();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("CONSULTATION", result.get(0).getType());
        assertEquals(10L, result.get(0).getCount());
    }

    @Test
    void getRevenusByMonth_ShouldReturnStats() {
        List<Object[]> mockResult = new ArrayList<>();
        mockResult.add(new Object[]{"JANUARY", 2000.0, 20L});
        
        when(acteMedicalRepository.findRevenusGroupedByMonth(any(LocalDateTime.class))).thenReturn(mockResult);

        List<RevenusByMonthStatsDTO> result = dashboardService.getRevenusByMonth();

        assertNotNull(result);
        assertEquals("JANUARY", result.get(0).getMois());
    }

    @Test
    void getSejoursByService_ShouldReturnStats() {
        List<Object[]> mockResult = new ArrayList<>();
        mockResult.add(new Object[]{"CARDIOLOGIE", 5L, 10L});
        
        when(sejourRepository.findSejoursGroupedByService()).thenReturn(mockResult);

        List<SejoursByServiceStatsDTO> result = dashboardService.getSejoursByService();

        assertNotNull(result);
        assertEquals("CARDIOLOGIE", result.get(0).getService());
    }
}
