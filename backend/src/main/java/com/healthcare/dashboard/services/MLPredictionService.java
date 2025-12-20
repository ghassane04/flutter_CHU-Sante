package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.DatasetRowDTO;
import com.healthcare.dashboard.dto.MLPredictionRequestDTO;
import com.healthcare.dashboard.dto.MLPredictionResponseDTO;
import com.healthcare.dashboard.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MLPredictionService {
    
    private final ActeMedicalRepository acteMedicalRepository;
    private final SejourRepository sejourRepository;
    private final ServiceRepository serviceRepository;
    private final PatientRepository patientRepository;
    private final MedecinRepository medecinRepository;
    private final InvestmentRepository investmentRepository;
    private final AlertRepository alertRepository;
    
    /**
     * Génère un dataset pour l'entraînement ML
     */
    @Transactional(readOnly = true)
    public List<DatasetRowDTO> generateDataset(LocalDate startDate, LocalDate endDate) {
        List<DatasetRowDTO> dataset = new ArrayList<>();
        
        // Pour chaque jour de la période
        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            final LocalDate date = currentDate;
            
            // Pour chaque service
            List<Object[]> services = serviceRepository.findAllBasicInfo();
            for (Object[] serviceInfo : services) {
                String serviceName = (String) serviceInfo[0];
                
                DatasetRowDTO row = buildDatasetRow(date, serviceName);
                if (row != null) {
                    dataset.add(row);
                }
            }
            
            currentDate = currentDate.plusDays(1);
        }
        
        return dataset;
    }
    
    /**
     * Construit une ligne de dataset pour une date et un service
     */
    private DatasetRowDTO buildDatasetRow(LocalDate date, String serviceName) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
        
        DatasetRowDTO row = new DatasetRowDTO();
        row.setDate(date.toString());
        row.setService(serviceName);
        
        // Informations temporelles
        row.setMois(date.getMonthValue());
        row.setAnnee(date.getYear());
        row.setJourSemaine(date.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.FRENCH).toLowerCase());
        row.setEstWeekend(date.getDayOfWeek() == DayOfWeek.SATURDAY || date.getDayOfWeek() == DayOfWeek.SUNDAY ? 1 : 0);
        row.setEstFerie(isHoliday(date) ? 1 : 0);
        row.setSaison(getSeason(date));
        
        // Météo simulée (à remplacer par vraies données si disponible)
        row.setMeteo(getSimulatedWeather(date));
        row.setTemperature(getSimulatedTemperature(date));
        
        try {
            // Statistiques des actes médicaux
            List<Object[]> actesStats = acteMedicalRepository.findStatsByDateAndService(startOfDay, endOfDay, serviceName);
            if (!actesStats.isEmpty()) {
                Object[] stats = actesStats.get(0);
                row.setActesCount(stats[0] != null ? ((Number) stats[0]).intValue() : 0);
                row.setCoutTotal(stats[1] != null ? ((Number) stats[1]).doubleValue() : 0.0);
                row.setTarifMoyen(stats[2] != null ? ((Number) stats[2]).doubleValue() : 0.0);
            } else {
                row.setActesCount(0);
                row.setCoutTotal(0.0);
                row.setTarifMoyen(0.0);
            }
            
            // Statistiques des séjours
            List<Object[]> sejoursStats = sejourRepository.findStatsByDateAndService(startOfDay, endOfDay, serviceName);
            if (!sejoursStats.isEmpty()) {
                Object[] stats = sejoursStats.get(0);
                row.setSejoursActifs(stats[0] != null ? ((Number) stats[0]).intValue() : 0);
                row.setDureeMoyenneSejour(stats[1] != null ? ((Number) stats[1]).doubleValue() : 0.0);
            } else {
                row.setSejoursActifs(0);
                row.setDureeMoyenneSejour(0.0);
            }
            
            // Patients uniques
            Long patientsCount = patientRepository.countDistinctPatientsWithSejoursOnDate(startOfDay, endOfDay, serviceName);
            row.setPatientsCount(patientsCount != null ? patientsCount.intValue() : 0);
            
            // Autres statistiques (valeurs simulées - à remplacer par vraies données)
            row.setCoutMoyenActe(row.getActesCount() > 0 ? row.getCoutTotal() / row.getActesCount() : 0.0);
            row.setTauxOccupation(calculateSimulatedOccupation(serviceName, row.getSejoursActifs()));
            row.setPersonnelPresent(getSimulatedStaff(serviceName));
            row.setEquipementsUtilises(getSimulatedEquipment(serviceName));
            row.setUrgencesAdmissions(serviceName.equals("Urgences") ? row.getPatientsCount() : 0);
            row.setInterventionsChirurgicales(serviceName.equals("Chirurgie") ? (int)(row.getActesCount() * 0.4) : 0);
            row.setExamensRadiologie(serviceName.equals("Radiologie") ? row.getActesCount() : 
                                      (int)(row.getActesCount() * 0.2));
            row.setConsultations((int)(row.getActesCount() * 0.6));
            row.setHospitalisations(row.getSejoursActifs());
            row.setCoutMaintenance(getSimulatedMaintenanceCost(serviceName));
            
            return row;
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Génère des prédictions ML basées sur les patterns historiques ET les données réelles actuelles
     */
    public MLPredictionResponseDTO generateMLPredictions(MLPredictionRequestDTO request) {
        MLPredictionResponseDTO response = new MLPredictionResponseDTO();
        response.setService(request.getService());
        response.setPredictionType(request.getPredictionType());
        
        List<MLPredictionResponseDTO.PredictionPoint> predictions = new ArrayList<>();
        LocalDate currentDate = request.getStartDate() != null ? request.getStartDate() : LocalDate.now();
        
        // Récupérer les données historiques pour calculer la tendance
        LocalDateTime startHistory = currentDate.minusMonths(3).atStartOfDay();
        LocalDateTime endHistory = currentDate.atStartOfDay();
        
        double baseValue = calculateHistoricalAverage(request.getService(), request.getPredictionType(), 
                                                       startHistory, endHistory);
        double trend = calculateTrend(request.getService(), request.getPredictionType(), 
                                      startHistory, endHistory);
        
        // NOUVEAUX FACTEURS DYNAMIQUES basés sur les données actuelles
        double medecinImpact = calculateMedecinImpact(request.getService());
        double investmentImpact = calculateInvestmentImpact(request.getService());
        double alertImpact = calculateAlertImpact(request.getService());
        
        // Facteur global d'impact (médecins, investissements, alertes)
        double dynamicFactor = 1.0 + medecinImpact + investmentImpact - alertImpact;
        
        // Confiance basée sur la disponibilité des données
        double confiance = 85.0 + Math.random() * 5;
        if (medecinImpact > 0) confiance += 2.0;
        if (investmentImpact > 0) confiance += 3.0;
        response.setConfiance(Math.min(confiance, 95.0));
        
        // Générer les prédictions pour chaque jour
        for (int i = 0; i < request.getDaysAhead(); i++) {
            LocalDate predDate = currentDate.plusDays(i);
            
            // Calculer la valeur prédite avec TOUS les facteurs
            double seasonalFactor = getSeasonalFactor(predDate, request.getService());
            double weekdayFactor = getWeekdayFactor(predDate);
            
            double predictedValue = baseValue * (1 + trend * i / 365.0) * 
                                    seasonalFactor * weekdayFactor * dynamicFactor;
            
            // Intervalle de confiance (±8-12% selon confiance)
            double confidenceInterval = 0.10 * (100 - response.getConfiance()) / 10;
            double min = predictedValue * (1 - confidenceInterval);
            double max = predictedValue * (1 + confidenceInterval);
            
            MLPredictionResponseDTO.PredictionPoint point = new MLPredictionResponseDTO.PredictionPoint();
            point.setDate(predDate);
            point.setValeur(Math.round(predictedValue * 100.0) / 100.0);
            point.setMin(Math.round(min * 100.0) / 100.0);
            point.setMax(Math.round(max * 100.0) / 100.0);
            
            predictions.add(point);
        }
        
        response.setPredictions(predictions);
        
        // Calculer les statistiques
        List<Double> values = predictions.stream().map(MLPredictionResponseDTO.PredictionPoint::getValeur).collect(Collectors.toList());
        response.setValeurMoyenne(values.stream().mapToDouble(Double::doubleValue).average().orElse(0.0));
        response.setValeurMin(values.stream().mapToDouble(Double::doubleValue).min().orElse(0.0));
        response.setValeurMax(values.stream().mapToDouble(Double::doubleValue).max().orElse(0.0));
        
        // Déterminer la tendance
        if (trend > 0.05) {
            response.setTendance("HAUSSE");
        } else if (trend < -0.05) {
            response.setTendance("BAISSE");
        } else {
            response.setTendance("STABLE");
        }
        
        // Facteurs clés et recommandations
        response.setFacteursCles(getFacteursCles(request.getPredictionType(), request.getService()));
        response.setRecommandations(getRecommandations(request.getPredictionType(), response.getTendance(), 
                                                        request.getService()));
        
        return response;
    }
    
    // Méthodes utilitaires
    
    private double calculateHistoricalAverage(String service, String type, LocalDateTime start, LocalDateTime end) {
        switch (type) {
            case "COUT":
                Double totalCout = acteMedicalRepository.findStatsByDateRangeAndService(start, end, service);
                if (totalCout != null && totalCout > 0) {
                    return totalCout / 90.0; // Moyenne quotidienne
                }
                // Si pas de données historiques, utiliser les données actuelles
                return getCurrentAverageValue(service, "COUT");
                
            case "PATIENTS":
                Long patientsCount = patientRepository.countDistinctPatientsWithSejoursInRange(start, end, service);
                if (patientsCount != null && patientsCount > 0) {
                    return patientsCount.doubleValue() / 90.0;
                }
                // Si pas de données historiques, utiliser les données actuelles
                return getCurrentAverageValue(service, "PATIENTS");
                
            case "OCCUPATION":
                Double avgDuration = sejourRepository.findAverageOccupationByService(start, end, service);
                if (avgDuration != null && avgDuration > 0) {
                    return avgDuration;
                }
                // Si pas de données historiques, utiliser les données actuelles
                return getCurrentAverageValue(service, "OCCUPATION");
                
            default:
                return 0.0;
        }
    }
    
    /**
     * Calcule la valeur moyenne ACTUELLE basée sur les données réelles existantes
     */
    private double getCurrentAverageValue(String service, String type) {
        try {
            switch (type) {
                case "COUT":
                    // Moyenne des coûts des séjours en cours ou récents
                    Double avgCout = sejourRepository.findAverageCoutByService(service);
                    return avgCout != null && avgCout > 0 ? avgCout : getDefaultValue(service, "COUT");
                    
                case "PATIENTS":
                    // Compter les patients RÉELS avec séjours dans ce service
                    Long totalPatients = sejourRepository.countDistinctPatientsByService(service);
                    if (totalPatients != null && totalPatients > 0) {
                        // Ramener à une moyenne quotidienne (diviser par 30 jours)
                        return Math.max(totalPatients.doubleValue() / 30.0, totalPatients.doubleValue());
                    }
                    return getDefaultValue(service, "PATIENTS");
                    
                case "OCCUPATION":
                    // Taux d'occupation basé sur les séjours actuels
                    Long activeSejoursCount = sejourRepository.countActiveSejoursByService(service);
                    if (activeSejoursCount != null && activeSejoursCount > 0) {
                        Map<String, Integer> capacities = Map.of(
                            "Urgences", 40, "Chirurgie", 60, "Cardiologie", 35, "Pediatrie", 30,
                            "Maternite", 25, "Radiologie", 15, "Oncologie", 20, "Neurologie", 18
                        );
                        int capacity = capacities.getOrDefault(service, 30);
                        return Math.min(100.0, (activeSejoursCount.doubleValue() / capacity) * 100.0);
                    }
                    return getDefaultValue(service, "OCCUPATION");
                    
                default:
                    return 0.0;
            }
        } catch (Exception e) {
            return getDefaultValue(service, type);
        }
    }
    
    private double calculateTrend(String service, String type, LocalDateTime start, LocalDateTime end) {
        // Calculer la tendance sur les 3 derniers mois (simple linear regression approximation)
        double recentAvg = calculateHistoricalAverage(service, type, end.minusMonths(1), end);
        double olderAvg = calculateHistoricalAverage(service, type, start, start.plusMonths(1));
        
        if (olderAvg > 0) {
            return (recentAvg - olderAvg) / olderAvg;
        }
        return 0.0;
    }
    
    private double getSeasonalFactor(LocalDate date, String service) {
        int month = date.getMonthValue();
        
        // Facteurs saisonniers par type de service
        if (service.equals("Urgences")) {
            // Plus d'urgences en hiver et été
            if (month >= 11 || month <= 2) return 1.15; // Hiver
            if (month >= 6 && month <= 8) return 1.10; // Été
            return 1.0;
        } else if (service.equals("Maternite")) {
            // Pic au printemps
            if (month >= 3 && month <= 5) return 1.12;
            return 1.0;
        } else if (service.equals("Chirurgie")) {
            // Moins en été (vacances)
            if (month >= 7 && month <= 8) return 0.90;
            return 1.0;
        }
        
        return 1.0;
    }
    
    private double getWeekdayFactor(LocalDate date) {
        // Moins d'activité le weekend
        if (date.getDayOfWeek() == DayOfWeek.SATURDAY) return 0.85;
        if (date.getDayOfWeek() == DayOfWeek.SUNDAY) return 0.75;
        return 1.0;
    }
    
    /**
     * Calcule l'impact du nombre de médecins actifs sur les prédictions
     * Plus de médecins = plus de capacité = augmentation potentielle des revenus/patients
     */
    private double calculateMedecinImpact(String serviceName) {
        try {
            Long medecinCount = medecinRepository.countByServiceNomAndStatut(serviceName, "ACTIF");
            if (medecinCount == null || medecinCount == 0) return 0.0;
            
            // Impact: +2% par médecin actif au-delà de 2 (max +20%)
            double baseCount = 2.0;
            if (medecinCount > baseCount) {
                return Math.min((medecinCount - baseCount) * 0.02, 0.20);
            }
            return 0.0;
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    /**
     * Calcule l'impact des investissements récents (3 derniers mois)
     * Nouveaux équipements = augmentation efficacité = plus de patients/revenus
     */
    private double calculateInvestmentImpact(String serviceName) {
        try {
            LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
            List<Object[]> recentInvestments = investmentRepository
                .findByServiceNomAndDateAfter(serviceName, threeMonthsAgo);
            
            if (recentInvestments.isEmpty()) return 0.0;
            
            // Calculer l'impact basé sur le montant total investi
            double totalAmount = 0.0;
            for (Object[] inv : recentInvestments) {
                if (inv[1] != null) {
                    totalAmount += ((Number) inv[1]).doubleValue();
                }
            }
            
            // Impact: +1% par tranche de 50k€ investis (max +15%)
            return Math.min(totalAmount / 50000.0 * 0.01, 0.15);
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    /**
     * Calcule l'impact négatif des alertes actives
     * Plus d'alertes = problèmes = potentielle diminution activité
     */
    private double calculateAlertImpact(String serviceName) {
        try {
            Long activeAlerts = alertRepository.countByServiceNomAndStatus(serviceName, "ACTIVE");
            if (activeAlerts == null || activeAlerts == 0) return 0.0;
            
            // Impact négatif: -3% par alerte active (max -15%)
            return Math.min(activeAlerts * 0.03, 0.15);
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    private double getDefaultValue(String service, String type) {
        // IMPORTANT: Essayer d'abord de récupérer les données RÉELLES du système
        try {
            switch (type) {
                case "PATIENTS":
                    // Compter le nombre RÉEL de patients dans le service
                    Long realPatients = sejourRepository.countDistinctPatientsByService(service);
                    if (realPatients != null && realPatients > 0) {
                        // Retourner la moyenne quotidienne basée sur les patients réels
                        return Math.max(realPatients.doubleValue() / 30.0, 5.0);
                    }
                    break;
                    
                case "COUT":
                    // Utiliser le coût moyen RÉEL des séjours
                    Double realCout = sejourRepository.findAverageCoutByService(service);
                    if (realCout != null && realCout > 0) {
                        return realCout;
                    }
                    break;
                    
                case "OCCUPATION":
                    // Calculer le taux d'occupation RÉEL
                    Long activeSejours = sejourRepository.countActiveSejoursByService(service);
                    if (activeSejours != null && activeSejours > 0) {
                        Map<String, Integer> capacities = Map.of(
                            "Urgences", 40, "Chirurgie", 60, "Cardiologie", 35, "Pediatrie", 30,
                            "Maternite", 25, "Radiologie", 15, "Oncologie", 20, "Neurologie", 18
                        );
                        int capacity = capacities.getOrDefault(service, 30);
                        return Math.min(100.0, (activeSejours.doubleValue() / capacity) * 100.0);
                    }
                    break;
            }
        } catch (Exception e) {
            // En cas d'erreur, utiliser les valeurs par défaut ci-dessous
        }
        
        // Valeurs par défaut MINIMALES (utilisées uniquement si aucune donnée réelle)
        Map<String, Map<String, Double>> defaults = Map.of(
            "Urgences", Map.of("COUT", 8000.0, "PATIENTS", 15.0, "OCCUPATION", 75.0),
            "Chirurgie", Map.of("COUT", 25000.0, "PATIENTS", 10.0, "OCCUPATION", 80.0),
            "Cardiologie", Map.of("COUT", 12000.0, "PATIENTS", 12.0, "OCCUPATION", 78.0),
            "Pediatrie", Map.of("COUT", 8500.0, "PATIENTS", 18.0, "OCCUPATION", 70.0),
            "Maternite", Map.of("COUT", 18000.0, "PATIENTS", 8.0, "OCCUPATION", 65.0),
            "Radiologie", Map.of("COUT", 30000.0, "PATIENTS", 25.0, "OCCUPATION", 60.0),
            "Oncologie", Map.of("COUT", 45000.0, "PATIENTS", 10.0, "OCCUPATION", 85.0),
            "Neurologie", Map.of("COUT", 11000.0, "PATIENTS", 12.0, "OCCUPATION", 72.0)
        );
        
        return defaults.getOrDefault(service, Map.of("COUT", 12000.0, "PATIENTS", 12.0, "OCCUPATION", 75.0))
                      .getOrDefault(type, 0.0);
    }
    
    private List<String> getFacteursCles(String type, String service) {
        List<String> facteurs = new ArrayList<>();
        
        switch (type) {
            case "COUT":
                facteurs.add("Volume d'actes médicaux");
                facteurs.add("Tarifs moyens des interventions");
                facteurs.add("Taux d'occupation des lits");
                facteurs.add("Coûts de personnel");
                break;
            case "PATIENTS":
                facteurs.add("Saisonnalité épidémiologique");
                facteurs.add("Capacité d'accueil du service");
                facteurs.add("Référencements externes");
                facteurs.add("Conditions météorologiques");
                break;
            case "OCCUPATION":
                facteurs.add("Durée moyenne de séjour");
                facteurs.add("Admissions quotidiennes");
                facteurs.add("Taux de sortie");
                facteurs.add("Transferts inter-services");
                break;
        }
        
        return facteurs;
    }
    
    private List<String> getRecommandations(String type, String tendance, String service) {
        List<String> recommandations = new ArrayList<>();
        
        if (tendance.equals("HAUSSE")) {
            switch (type) {
                case "COUT":
                    recommandations.add("Analyser les postes de dépenses en augmentation");
                    recommandations.add("Optimiser l'utilisation des ressources");
                    recommandations.add("Renégocier les contrats fournisseurs si nécessaire");
                    break;
                case "PATIENTS":
                    recommandations.add("Prévoir un renforcement du personnel");
                    recommandations.add("Vérifier la disponibilité des équipements");
                    recommandations.add("Optimiser les plannings d'admission");
                    break;
                case "OCCUPATION":
                    recommandations.add("Surveiller la capacité maximale");
                    recommandations.add("Planifier des sorties anticipées si possible");
                    recommandations.add("Préparer des solutions de débordement");
                    break;
            }
        } else if (tendance.equals("BAISSE")) {
            recommandations.add("Analyser les causes de la diminution");
            recommandations.add("Évaluer l'impact sur la qualité des soins");
            recommandations.add("Ajuster les ressources en conséquence");
        } else {
            recommandations.add("Maintenir la surveillance des indicateurs");
            recommandations.add("Continuer les bonnes pratiques actuelles");
            recommandations.add("Anticiper les variations saisonnières");
        }
        
        return recommandations;
    }
    
    // Méthodes de simulation (à remplacer par vraies données)
    
    private String getSeason(LocalDate date) {
        int month = date.getMonthValue();
        if (month >= 3 && month <= 5) return "printemps";
        if (month >= 6 && month <= 8) return "ete";
        if (month >= 9 && month <= 11) return "automne";
        return "hiver";
    }
    
    private boolean isHoliday(LocalDate date) {
        // Jours fériés français simplifiés
        int month = date.getMonthValue();
        int day = date.getDayOfMonth();
        return (month == 1 && day == 1) || (month == 5 && day == 1) || 
               (month == 5 && day == 8) || (month == 7 && day == 14) ||
               (month == 11 && day == 1) || (month == 11 && day == 11) ||
               (month == 12 && day == 25);
    }
    
    private String getSimulatedWeather(LocalDate date) {
        String[] weathers = {"ensoleille", "nuageux", "pluie", "neige"};
        int month = date.getMonthValue();
        if (month >= 6 && month <= 8) return "ensoleille";
        if (month >= 12 || month <= 2) return Math.random() > 0.7 ? "neige" : "nuageux";
        return Math.random() > 0.5 ? "nuageux" : "pluie";
    }
    
    private int getSimulatedTemperature(LocalDate date) {
        int month = date.getMonthValue();
        if (month >= 12 || month <= 2) return (int)(Math.random() * 8); // 0-8°C
        if (month >= 3 && month <= 5) return (int)(10 + Math.random() * 10); // 10-20°C
        if (month >= 6 && month <= 8) return (int)(20 + Math.random() * 15); // 20-35°C
        return (int)(10 + Math.random() * 8); // 10-18°C
    }
    
    private double calculateSimulatedOccupation(String service, int sejoursActifs) {
        Map<String, Integer> capacities = Map.of(
            "Urgences", 40, "Chirurgie", 60, "Cardiologie", 35, "Pediatrie", 30,
            "Maternite", 25, "Radiologie", 15, "Oncologie", 20, "Neurologie", 18
        );
        int capacity = capacities.getOrDefault(service, 30);
        return Math.min(1.0, (double) sejoursActifs / capacity);
    }
    
    private int getSimulatedStaff(String service) {
        Map<String, Integer> staffCounts = Map.of(
            "Urgences", 16, "Chirurgie", 23, "Cardiologie", 19, "Pediatrie", 15,
            "Maternite", 13, "Radiologie", 10, "Oncologie", 15, "Neurologie", 12
        );
        return staffCounts.getOrDefault(service, 15);
    }
    
    private int getSimulatedEquipment(String service) {
        Map<String, Integer> equipmentCounts = Map.of(
            "Urgences", 9, "Chirurgie", 13, "Cardiologie", 11, "Pediatrie", 9,
            "Maternite", 7, "Radiologie", 15, "Oncologie", 8, "Neurologie", 9
        );
        return equipmentCounts.getOrDefault(service, 10);
    }
    
    private double getSimulatedMaintenanceCost(String service) {
        Map<String, Double> costs = Map.of(
            "Urgences", 450.0, "Chirurgie", 680.0, "Cardiologie", 520.0, "Pediatrie", 380.0,
            "Maternite", 320.0, "Radiologie", 780.0, "Oncologie", 650.0, "Neurologie", 420.0
        );
        return costs.getOrDefault(service, 500.0);
    }
    
    /**
     * Récupère les statistiques actuelles RÉELLES pour tous les services
     */
    public List<Map<String, Object>> getCurrentStatisticsForAllServices(String type) {
        List<String> services = List.of("Urgences", "Chirurgie", "Cardiologie", "Pediatrie", 
                                       "Maternite", "Radiologie", "Oncologie", "Neurologie");
        
        List<Map<String, Object>> statistics = new ArrayList<>();
        
        for (String service : services) {
            Map<String, Object> stat = new HashMap<>();
            stat.put("service", service);
            
            try {
                switch (type) {
                    case "PATIENTS":
                        Long totalPatients = sejourRepository.countDistinctPatientsByService(service);
                        Long activePatients = sejourRepository.countActiveSejoursByService(service);
                        stat.put("total", totalPatients != null ? totalPatients : 0);
                        stat.put("actifs", activePatients != null ? activePatients : 0);
                        stat.put("moyenne_journaliere", totalPatients != null ? totalPatients.doubleValue() / 30.0 : 0.0);
                        break;
                        
                    case "COUT":
                        Double avgCout = sejourRepository.findAverageCoutByService(service);
                        stat.put("cout_moyen", avgCout != null ? avgCout : 0.0);
                        stat.put("total", avgCout != null ? avgCout : 0.0);
                        break;
                        
                    case "OCCUPATION":
                        Long activeSejours = sejourRepository.countActiveSejoursByService(service);
                        Map<String, Integer> capacities = Map.of(
                            "Urgences", 40, "Chirurgie", 60, "Cardiologie", 35, "Pediatrie", 30,
                            "Maternite", 25, "Radiologie", 15, "Oncologie", 20, "Neurologie", 18
                        );
                        int capacity = capacities.getOrDefault(service, 30);
                        double occupation = activeSejours != null ? 
                            Math.min(100.0, (activeSejours.doubleValue() / capacity) * 100.0) : 0.0;
                        stat.put("taux", occupation);
                        stat.put("capacite", capacity);
                        stat.put("occupe", activeSejours != null ? activeSejours : 0);
                        break;
                }
            } catch (Exception e) {
                stat.put("total", 0);
                stat.put("error", e.getMessage());
            }
            
            statistics.add(stat);
        }
        
        return statistics;
    }
}
