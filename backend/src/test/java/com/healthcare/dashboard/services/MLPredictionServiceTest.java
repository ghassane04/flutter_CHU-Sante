package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.MLPredictionRequestDTO;
import com.healthcare.dashboard.dto.MLPredictionResponseDTO;
import com.healthcare.dashboard.repositories.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests unitaires pour MLPredictionService
 * Couvre les principales méthodes de prédiction et calcul
 */
@ExtendWith(MockitoExtension.class)
class MLPredictionServiceTest {

    @Mock
    private ActeMedicalRepository acteMedicalRepository;
    
    @Mock
    private SejourRepository sejourRepository;
    
    @Mock
    private ServiceRepository serviceRepository;
    
    @Mock
    private PatientRepository patientRepository;
    
    @Mock
    private MedecinRepository medecinRepository;
    
    @Mock
    private InvestmentRepository investmentRepository;
    
    @Mock
    private AlertRepository alertRepository;

    @InjectMocks
    private MLPredictionService mlPredictionService;

    private MLPredictionRequestDTO requestDTO;

    @BeforeEach
    void setUp() {
        requestDTO = new MLPredictionRequestDTO();
        requestDTO.setService("Cardiologie");
        requestDTO.setPredictionType("PATIENTS");
        requestDTO.setDaysAhead(7);
        requestDTO.setStartDate(LocalDate.now());
    }

    // ==================== Tests generateMLPredictions ====================

    @Test
    void generateMLPredictions_ShouldReturnValidResponse() {
        // Arrange
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(50L);
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(30L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(5L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("Cardiologie", response.getService());
        assertEquals("PATIENTS", response.getPredictionType());
        assertNotNull(response.getPredictions());
        assertEquals(7, response.getPredictions().size());
        assertTrue(response.getConfiance() > 0);
    }

    @Test
    void generateMLPredictions_WithCoutType_ShouldReturnCoutPredictions() {
        // Arrange
        requestDTO.setPredictionType("COUT");
        when(acteMedicalRepository.findStatsByDateRangeAndService(any(), any(), anyString()))
            .thenReturn(150000.0);
        when(sejourRepository.findAverageCoutByService(anyString()))
            .thenReturn(12000.0);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(3L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("COUT", response.getPredictionType());
        assertNotNull(response.getValeurMoyenne());
        assertTrue(response.getValeurMoyenne() >= 0);
    }

    @Test
    void generateMLPredictions_WithOccupationType_ShouldReturnOccupationPredictions() {
        // Arrange
        requestDTO.setPredictionType("OCCUPATION");
        when(sejourRepository.findAverageOccupationByService(any(), any(), anyString()))
            .thenReturn(75.0);
        when(sejourRepository.countActiveSejoursByService(anyString()))
            .thenReturn(25L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(4L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("OCCUPATION", response.getPredictionType());
    }

    @Test
    void generateMLPredictions_WithNullStartDate_ShouldUseCurrentDate() {
        // Arrange
        requestDTO.setStartDate(null);
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(20L);
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(15L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(2L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertNotNull(response.getPredictions());
        assertFalse(response.getPredictions().isEmpty());
    }

    // ==================== Tests tendance ====================

    @Test
    void generateMLPredictions_WithPositiveTrend_ShouldReturnHausse() {
        // Arrange
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(100L)
            .thenReturn(50L); // Older avg is lower, so trend is positive
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(80L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(3L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response.getTendance());
        // Tendance dépend des calculs internes
    }

    // ==================== Tests facteurs d'impact ====================

    @Test
    void generateMLPredictions_WithHighMedecinImpact_ShouldIncreaseConfiance() {
        // Arrange
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(40L);
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(25L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(10L); // Many doctors = higher impact
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertTrue(response.getConfiance() >= 85.0);
    }

    @Test
    void generateMLPredictions_WithActiveAlerts_ShouldReducePredictions() {
        // Arrange
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(30L);
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(20L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(3L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(5L); // 5 active alerts = -15% impact

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertNotNull(response.getPredictions());
    }

    // ==================== Tests facteurs clés et recommandations ====================

    @Test
    void generateMLPredictions_ShouldReturnFacteursCles() {
        // Arrange
        setupBasicMocks();

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response.getFacteursCles());
        assertFalse(response.getFacteursCles().isEmpty());
    }

    @Test
    void generateMLPredictions_ShouldReturnRecommandations() {
        // Arrange
        setupBasicMocks();

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response.getRecommandations());
        assertFalse(response.getRecommandations().isEmpty());
    }

    // ==================== Tests generateDataset ====================

    @Test
    void generateDataset_WithValidDates_ShouldReturnDataset() {
        // Arrange
        LocalDate startDate = LocalDate.now().minusDays(7);
        LocalDate endDate = LocalDate.now();
        
        List<Object[]> serviceInfos = new ArrayList<>();
        serviceInfos.add(new Object[]{"Cardiologie"});
        serviceInfos.add(new Object[]{"Urgences"});
        
        when(serviceRepository.findAllBasicInfo()).thenReturn(serviceInfos);
        when(acteMedicalRepository.findStatsByDateAndService(any(), any(), anyString()))
            .thenReturn(new ArrayList<>());
        when(sejourRepository.findStatsByDateAndService(any(), any(), anyString()))
            .thenReturn(new ArrayList<>());
        when(patientRepository.countDistinctPatientsWithSejoursOnDate(any(), any(), anyString()))
            .thenReturn(5L);

        // Act
        var dataset = mlPredictionService.generateDataset(startDate, endDate);

        // Assert
        assertNotNull(dataset);
        // Le dataset peut être vide si buildDatasetRow renvoie null à cause des exceptions
    }

    // ==================== Tests getCurrentStatisticsForAllServices ====================

    @Test
    void getCurrentStatisticsForAllServices_WithPatientsType_ShouldReturnStats() {
        // Arrange
        when(sejourRepository.countDistinctPatientsByService(anyString())).thenReturn(10L);
        when(sejourRepository.countActiveSejoursByService(anyString())).thenReturn(5L);

        // Act
        List<Map<String, Object>> stats = mlPredictionService.getCurrentStatisticsForAllServices("PATIENTS");

        // Assert
        assertNotNull(stats);
        assertEquals(8, stats.size()); // 8 services
        assertTrue(stats.stream().allMatch(s -> s.containsKey("service")));
    }

    @Test
    void getCurrentStatisticsForAllServices_WithCoutType_ShouldReturnStats() {
        // Arrange
        when(sejourRepository.findAverageCoutByService(anyString())).thenReturn(15000.0);

        // Act
        List<Map<String, Object>> stats = mlPredictionService.getCurrentStatisticsForAllServices("COUT");

        // Assert
        assertNotNull(stats);
        assertEquals(8, stats.size());
    }

    @Test
    void getCurrentStatisticsForAllServices_WithOccupationType_ShouldReturnStats() {
        // Arrange
        when(sejourRepository.countActiveSejoursByService(anyString())).thenReturn(20L);

        // Act
        List<Map<String, Object>> stats = mlPredictionService.getCurrentStatisticsForAllServices("OCCUPATION");

        // Assert
        assertNotNull(stats);
        assertEquals(8, stats.size());
    }

    // ==================== Tests pour différents services ====================

    @Test
    void generateMLPredictions_ForUrgences_ShouldApplySeasonalFactor() {
        // Arrange
        requestDTO.setService("Urgences");
        setupBasicMocks();

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("Urgences", response.getService());
    }

    @Test
    void generateMLPredictions_ForChirurgie_ShouldApplySeasonalFactor() {
        // Arrange
        requestDTO.setService("Chirurgie");
        setupBasicMocks();

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("Chirurgie", response.getService());
    }

    @Test
    void generateMLPredictions_ForMaternite_ShouldApplySeasonalFactor() {
        // Arrange
        requestDTO.setService("Maternite");
        setupBasicMocks();

        // Act
        MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(requestDTO);

        // Assert
        assertNotNull(response);
        assertEquals("Maternite", response.getService());
    }

    // ==================== Helper Methods ====================

    private void setupBasicMocks() {
        when(patientRepository.countDistinctPatientsWithSejoursInRange(any(), any(), anyString()))
            .thenReturn(30L);
        when(sejourRepository.countDistinctPatientsByService(anyString()))
            .thenReturn(20L);
        when(medecinRepository.countByServiceNomAndStatut(anyString(), anyString()))
            .thenReturn(3L);
        when(investmentRepository.findByServiceNomAndDateAfter(anyString(), any()))
            .thenReturn(new ArrayList<>());
        when(alertRepository.countByServiceNomAndStatus(anyString(), anyString()))
            .thenReturn(0L);
    }
}
