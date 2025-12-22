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
    
    @Value("${google.ai.model:gemini-2.5-flash-lite}")
    private String model;
    
    private final PatientRepository patientRepository;
    private final ServiceRepository serviceRepository;
    private final SejourRepository sejourRepository;
    private final ActeMedicalRepository acteMedicalRepository;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
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
                "https://generativelanguage.googleapis.com/v1/models/%s:generateContent?key=%s",
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
        StringBuilder context = new StringBuilder();
        context.append("📊 Statistiques Hospitalières Actuelles:\n\n");
        
        try {
            // Compter les patients
            long totalPatients = patientRepository.count();
            context.append(String.format("👥 PATIENTS:\n• Total de patients enregistrés: %d\n", totalPatients));
            
            // Récupérer quelques patients pour le contexte
            var patients = patientRepository.findAll();
            if (!patients.isEmpty()) {
                context.append("• Exemples de patients:\n");
                patients.stream().limit(5).forEach(p -> 
                    context.append(String.format("  - %s %s (né(e) le %s)\n", 
                        p.getPrenom(), p.getNom(), 
                        p.getDateNaissance() != null ? p.getDateNaissance().toString() : "N/A"))
                );
            }
        } catch (Exception e) {
            context.append("• Patients: Erreur de récupération\n");
        }
        
        try {
            // Compter les services
            long totalServices = serviceRepository.count();
            context.append(String.format("\n🏥 SERVICES:\n• Total de services: %d\n", totalServices));
            
            var services = serviceRepository.findAll();
            if (!services.isEmpty()) {
                context.append("• Liste des services:\n");
                services.forEach(s -> 
                    context.append(String.format("  - %s (Responsable: %s, Lits: %d)\n", 
                        s.getNom(), 
                        s.getResponsable() != null ? s.getResponsable() : "N/A",
                        s.getLitsDisponibles() != null ? s.getLitsDisponibles() : 0))
                );
            }
        } catch (Exception e) {
            context.append("• Services: Erreur de récupération\n");
        }
        
        try {
            // Compter les séjours
            long totalSejours = sejourRepository.count();
            long sejoursEnCours = 0;
            try {
                sejoursEnCours = sejourRepository.countByStatut("EN_COURS");
            } catch (Exception ignored) {}
            
            context.append(String.format("\n🛏️ SÉJOURS:\n• Total de séjours: %d\n• Séjours en cours: %d\n", 
                totalSejours, sejoursEnCours));
        } catch (Exception e) {
            context.append("• Séjours: Erreur de récupération\n");
        }
        
        try {
            // Compter les actes médicaux et revenus
            long totalActes = acteMedicalRepository.count();
            context.append(String.format("\n💊 ACTES MÉDICAUX:\n• Total d'actes réalisés: %d\n", totalActes));
            
            Double revenusTotal = null;
            Double revenusMois = null;
            Double revenusAnnee = null;
            
            try {
                revenusTotal = acteMedicalRepository.sumAllTarif();
            } catch (Exception ignored) {}
            
            try {
                LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();
                LocalDateTime endOfMonth = LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth()).atTime(23, 59, 59);
                revenusMois = acteMedicalRepository.sumTarifByDateBetween(startOfMonth, endOfMonth);
            } catch (Exception ignored) {}
            
            try {
                LocalDateTime startOfYear = LocalDate.now().withDayOfYear(1).atStartOfDay();
                LocalDateTime endOfYear = LocalDate.now().withMonth(12).withDayOfMonth(31).atTime(23, 59, 59);
                revenusAnnee = acteMedicalRepository.sumTarifByDateBetween(startOfYear, endOfYear);
            } catch (Exception ignored) {}
            
            context.append(String.format("\n💰 REVENUS:\n• Revenus total: %.2f €\n• Revenus année en cours: %.2f €\n• Revenus mois en cours: %.2f €\n",
                revenusTotal != null ? revenusTotal : 0.0,
                revenusAnnee != null ? revenusAnnee : 0.0,
                revenusMois != null ? revenusMois : 0.0));
                
        } catch (Exception e) {
            context.append("• Actes/Revenus: Erreur de récupération\n");
        }
        
        return context.toString();
    }
}
