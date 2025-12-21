package com.healthcare.dashboard.services;

import com.healthcare.dashboard.entities.Prediction;
import com.healthcare.dashboard.repositories.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PredictionServiceTest {

    @Mock
    private PredictionRepository predictionRepository;

    @Mock
    private PatientRepository patientRepository;

    @Mock
    private ActeMedicalRepository acteMedicalRepository;

    @Mock
    private SejourRepository sejourRepository;

    @Mock
    private ServiceRepository serviceRepository;

    @InjectMocks
    private PredictionService predictionService;

    @BeforeEach
    void setUp() {
        // Set the API key for tests (will fail API call but we can test the flow)
        ReflectionTestUtils.setField(predictionService, "apiKey", "test-api-key");
        ReflectionTestUtils.setField(predictionService, "model", "gemini-1.5-flash");
    }

    @Test
    void generatePrediction_ShouldHandleError_WhenApiCallFails() {
        // Since we can't mock RestTemplate (inline instantiation), 
        // the API call will fail and error handling should trigger
        when(acteMedicalRepository.count()).thenReturn(100L);
        when(acteMedicalRepository.sumAllTarif()).thenReturn(50000.0);
        
        Prediction savedPrediction = new Prediction();
        savedPrediction.setId(1L);
        savedPrediction.setType("REVENUS");
        savedPrediction.setTitre("Test Prediction");
        savedPrediction.setResultatPrediction("Erreur:");
        savedPrediction.setConfiance(0.0);
        when(predictionRepository.save(any(Prediction.class))).thenReturn(savedPrediction);

        Prediction result = predictionService.generatePrediction(
            "REVENUS", 
            "Test Prediction", 
            LocalDateTime.now().plusMonths(3)
        );

        assertNotNull(result);
        verify(predictionRepository, times(1)).save(any(Prediction.class));
    }

    @Test
    void generatePrediction_PATIENTS_ShouldUseCorrectData() {
        when(patientRepository.count()).thenReturn(500L);
        when(sejourRepository.countByStatut("EN_COURS")).thenReturn(50L);
        
        Prediction savedPrediction = new Prediction();
        savedPrediction.setId(1L);
        savedPrediction.setType("PATIENTS");
        when(predictionRepository.save(any(Prediction.class))).thenReturn(savedPrediction);

        Prediction result = predictionService.generatePrediction(
            "PATIENTS", 
            "Patient Prediction", 
            LocalDateTime.now().plusMonths(3)
        );

        assertNotNull(result);
        verify(patientRepository, times(1)).count();
        verify(sejourRepository, times(1)).countByStatut("EN_COURS");
    }

    @Test
    void generatePrediction_OCCUPATION_ShouldUseCorrectData() {
        when(sejourRepository.countByStatut("EN_COURS")).thenReturn(75L);
        when(serviceRepository.count()).thenReturn(8L);
        
        Prediction savedPrediction = new Prediction();
        savedPrediction.setId(1L);
        savedPrediction.setType("OCCUPATION");
        when(predictionRepository.save(any(Prediction.class))).thenReturn(savedPrediction);

        Prediction result = predictionService.generatePrediction(
            "OCCUPATION", 
            "Occupation Prediction", 
            LocalDateTime.now().plusMonths(3)
        );

        assertNotNull(result);
        verify(sejourRepository, times(1)).countByStatut("EN_COURS");
        verify(serviceRepository, times(1)).count();
    }
}
