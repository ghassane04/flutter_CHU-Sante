package com.healthcare.dashboard.services;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthcare.dashboard.dto.AIResponse;
import com.healthcare.dashboard.repositories.ActeMedicalRepository;
import com.healthcare.dashboard.repositories.PatientRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import com.healthcare.dashboard.repositories.ServiceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AIServiceTest {

    @Mock
    private PatientRepository patientRepository;

    @Mock
    private ServiceRepository serviceRepository;

    @Mock
    private SejourRepository sejourRepository;

    @Mock
    private ActeMedicalRepository acteMedicalRepository;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private AIService aiService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(aiService, "apiKey", "test-key");
        ReflectionTestUtils.setField(aiService, "model", "test-model");
    }

    @Test
    void askAI_ShouldReturnResponse() throws Exception {
        String jsonResponse = "{ \"candidates\": [ { \"content\": { \"parts\": [ { \"text\": \"AI Response\" } ] } } ] }";
        JsonNode rootNode = new ObjectMapper().readTree(jsonResponse);

        when(patientRepository.count()).thenReturn(10L);
        when(sejourRepository.countByStatut("EN_COURS")).thenReturn(5L);
        when(restTemplate.exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(String.class)))
                .thenReturn(new ResponseEntity<>(jsonResponse, HttpStatus.OK));
        when(objectMapper.readTree(jsonResponse)).thenReturn(rootNode);

        AIResponse response = aiService.askAI("Question");

        assertThat(response.getAnswer()).isEqualTo("AI Response");
    }

    @Test
    void askAI_ShouldReturnError_WhenExceptionOccurs() {
        when(patientRepository.count()).thenThrow(new RuntimeException("DB Error"));

        AIResponse response = aiService.askAI("Question");

        assertThat(response.getAnswer()).contains("Désolé, une erreur est survenue");
    }
}
