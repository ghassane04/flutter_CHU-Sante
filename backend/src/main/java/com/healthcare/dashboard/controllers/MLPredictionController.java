package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.DatasetRowDTO;
import com.healthcare.dashboard.dto.MLPredictionRequestDTO;
import com.healthcare.dashboard.dto.MLPredictionResponseDTO;
import com.healthcare.dashboard.services.MLPredictionService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ml")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MLPredictionController {
    
    private final MLPredictionService mlPredictionService;
    
    /**
     * GET /api/ml/dataset/export
     * Exporte le dataset pour l'entraînement ML
     */
    @GetMapping("/dataset/export")
    public ResponseEntity<String> exportDataset(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        try {
            List<DatasetRowDTO> dataset = mlPredictionService.generateDataset(startDate, endDate);
            
            // Convertir en CSV
            StringBuilder csv = new StringBuilder();
            
            // Header
            csv.append("date,service,patients_count,actes_count,sejours_actifs,duree_moyenne_sejour,");
            csv.append("cout_total,cout_moyen_acte,taux_occupation,personnel_present,equipements_utilises,");
            csv.append("urgences_admissions,interventions_chirurgicales,examens_radiologie,consultations,");
            csv.append("hospitalisations,tarif_moyen,cout_maintenance,saison,jour_semaine,est_weekend,");
            csv.append("est_ferie,meteo,temperature,mois,annee\n");
            
            // Données
            for (DatasetRowDTO row : dataset) {
                csv.append(row.getDate()).append(",");
                csv.append(row.getService()).append(",");
                csv.append(row.getPatientsCount()).append(",");
                csv.append(row.getActesCount()).append(",");
                csv.append(row.getSejoursActifs()).append(",");
                csv.append(row.getDureeMoyenneSejour()).append(",");
                csv.append(row.getCoutTotal()).append(",");
                csv.append(row.getCoutMoyenActe()).append(",");
                csv.append(row.getTauxOccupation()).append(",");
                csv.append(row.getPersonnelPresent()).append(",");
                csv.append(row.getEquipementsUtilises()).append(",");
                csv.append(row.getUrgencesAdmissions()).append(",");
                csv.append(row.getInterventionsChirurgicales()).append(",");
                csv.append(row.getExamensRadiologie()).append(",");
                csv.append(row.getConsultations()).append(",");
                csv.append(row.getHospitalisations()).append(",");
                csv.append(row.getTarifMoyen()).append(",");
                csv.append(row.getCoutMaintenance()).append(",");
                csv.append(row.getSaison()).append(",");
                csv.append(row.getJourSemaine()).append(",");
                csv.append(row.getEstWeekend()).append(",");
                csv.append(row.getEstFerie()).append(",");
                csv.append(row.getMeteo()).append(",");
                csv.append(row.getTemperature()).append(",");
                csv.append(row.getMois()).append(",");
                csv.append(row.getAnnee()).append("\n");
            }
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("text/csv"));
            headers.setContentDispositionFormData("attachment", "healthcare_dataset.csv");
            
            return new ResponseEntity<>(csv.toString(), headers, HttpStatus.OK);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                .body("Erreur lors de la génération du dataset: " + e.getMessage());
        }
    }
    
    /**
     * GET /api/ml/dataset/json
     * Retourne le dataset en format JSON
     */
    @GetMapping("/dataset/json")
    public ResponseEntity<List<DatasetRowDTO>> getDatasetJson(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        try {
            List<DatasetRowDTO> dataset = mlPredictionService.generateDataset(startDate, endDate);
            return ResponseEntity.ok(dataset);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * POST /api/ml/predictions/generate
     * Génère des prédictions ML
     */
    @PostMapping("/predictions/generate")
    public ResponseEntity<MLPredictionResponseDTO> generatePredictions(
            @RequestBody MLPredictionRequestDTO request
    ) {
        try {
            // Valeurs par défaut
            if (request.getStartDate() == null) {
                request.setStartDate(LocalDate.now());
            }
            if (request.getDaysAhead() == null) {
                request.setDaysAhead(30);
            }
            if (request.getPredictionType() == null) {
                request.setPredictionType("COUT");
            }
            
            MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(request);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * GET /api/ml/predictions/service/{serviceName}
     * Prédictions rapides pour un service
     */
    @GetMapping("/predictions/service/{serviceName}")
    public ResponseEntity<MLPredictionResponseDTO> getPredictionsForService(
            @PathVariable String serviceName,
            @RequestParam(defaultValue = "30") Integer daysAhead,
            @RequestParam(defaultValue = "COUT") String predictionType
    ) {
        try {
            MLPredictionRequestDTO request = new MLPredictionRequestDTO();
            request.setService(serviceName);
            request.setDaysAhead(daysAhead);
            request.setPredictionType(predictionType);
            request.setStartDate(LocalDate.now());
            
            MLPredictionResponseDTO response = mlPredictionService.generateMLPredictions(request);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * GET /api/ml/predictions/all-services
     * Prédictions pour tous les services
     */
    @GetMapping("/predictions/all-services")
    public ResponseEntity<List<MLPredictionResponseDTO>> getPredictionsAllServices(
            @RequestParam(defaultValue = "30") Integer daysAhead,
            @RequestParam(defaultValue = "COUT") String predictionType
    ) {
        try {
            List<String> services = List.of("Urgences", "Chirurgie", "Cardiologie", "Pediatrie", 
                                           "Maternite", "Radiologie", "Oncologie", "Neurologie");
            
            List<MLPredictionResponseDTO> predictions = services.stream()
                    .map(service -> {
                        MLPredictionRequestDTO request = new MLPredictionRequestDTO();
                        request.setService(service);
                        request.setDaysAhead(daysAhead);
                        request.setPredictionType(predictionType);
                        request.setStartDate(LocalDate.now());
                        return mlPredictionService.generateMLPredictions(request);
                    })
                    .collect(Collectors.toList());
            
            return ResponseEntity.ok(predictions);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * GET /api/ml/statistics/current
     * Récupère les statistiques RÉELLES actuelles pour afficher l'état réel
     */
    @GetMapping("/statistics/current")
    public ResponseEntity<?> getCurrentStatistics(@RequestParam(defaultValue = "PATIENTS") String type) {
        try {
            List<String> services = List.of("Urgences", "Chirurgie", "Cardiologie", "Pediatrie", 
                                           "Maternite", "Radiologie", "Oncologie", "Neurologie");
            
            List<java.util.Map<String, Object>> statistics = mlPredictionService.getCurrentStatisticsForAllServices(type);
            
            return ResponseEntity.ok(statistics);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
