package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.AIResponse;
import com.healthcare.dashboard.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AIService {
    
    @Value("${google.ai.api.key}")
    private String apiKey;
    
    @Value("${google.ai.model:gemini-1.5-flash}")
    private String model;
    
    private final PatientRepository patientRepository;
    private final ServiceRepository serviceRepository;
    private final SejourRepository sejourRepository;
    private final ActeMedicalRepository acteMedicalRepository;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    public AIResponse askAI(String question) {
        try {
            // Récupérer les statistiques de la base de données
            String context = buildContextFromDatabase();
            
            // Construire le prompt avec le contexte
            String fullPrompt = String.format(
                "Tu es un assistant AI spécialisé dans l'analyse de données hospitalières.\n\n" +
                "Contexte des données actuelles:\n%s\n\n" +
                "Question de l'utilisateur: %s\n\n" +
                "Réponds en français de manière professionnelle et précise. Utilise les données réelles fournies.",
                context, question
            );
            
            // Appeler l'API Google Gemini
            String url = String.format(
                "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                model, apiKey
            );
            
            Map<String, Object> requestBody = new HashMap<>();
            Map<String, Object> part = new HashMap<>();
            part.put("text", fullPrompt);
            
            Map<String, Object> content = new HashMap<>();
            content.put("parts", new Object[]{part});
            
            requestBody.put("contents", new Object[]{content});
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
            
            // Parser la réponse
            JsonNode jsonResponse = objectMapper.readTree(response.getBody());
            String answer = jsonResponse
                .path("candidates").get(0)
                .path("content")
                .path("parts").get(0)
                .path("text").asText();
            
            return new AIResponse(
                answer,
                0.9,
                new String[]{"Google Gemini AI", "Base de données MySQL en temps réel"}
            );
            
        } catch (Exception e) {
            e.printStackTrace();
            return new AIResponse(
                "Désolé, une erreur est survenue lors de l'analyse. Détails: " + e.getMessage(),
                0.0,
                new String[]{"Erreur système"}
            );
        }
    }
    
    private String buildContextFromDatabase() {
        try {
            // Compter les patients
            long totalPatients = patientRepository.count();
            
            // Compter les séjours en cours
            long sejoursEnCours = sejourRepository.countByStatut("EN_COURS");
            
            // Compter les actes médicaux
            long totalActes = acteMedicalRepository.count();
            
            // Calculer les revenus
            LocalDateTime startOfYear = LocalDate.now().withDayOfYear(1).atStartOfDay();
            LocalDateTime endOfYear = LocalDate.now().withDayOfYear(365).atTime(23, 59, 59);
            Double revenusAnnee = acteMedicalRepository.sumTarifByDateBetween(startOfYear, endOfYear);
            
            LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();
            LocalDateTime endOfMonth = LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth()).atTime(23, 59, 59);
            Double revenusMois = acteMedicalRepository.sumTarifByDateBetween(startOfMonth, endOfMonth);
            
            Double revenusTotal = acteMedicalRepository.sumAllTarif();
            
            // Compter les services
            long totalServices = serviceRepository.count();
            
            return String.format(
                "📊 Statistiques Hospitalières Actuelles:\n" +
                "• Total de patients: %d\n" +
                "• Séjours en cours: %d\n" +
                "• Actes médicaux réalisés: %d\n" +
                "• Services médicaux: %d\n" +
                "• Revenus total: %.2f €\n" +
                "• Revenus année en cours: %.2f €\n" +
                "• Revenus mois en cours: %.2f €\n",
                totalPatients,
                sejoursEnCours,
                totalActes,
                totalServices,
                revenusTotal != null ? revenusTotal : 0.0,
                revenusAnnee != null ? revenusAnnee : 0.0,
                revenusMois != null ? revenusMois : 0.0
            );
        } catch (Exception e) {
            return "Données non disponibles";
        }
    }
}
