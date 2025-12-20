package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.dto.RevenusByMonthStatsDTO;
import com.healthcare.dashboard.dto.SejoursByServiceStatsDTO;
import com.healthcare.dashboard.repositories.ActeMedicalRepository;
import com.healthcare.dashboard.repositories.PatientRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {
    
    private final PatientRepository patientRepository;
    private final SejourRepository sejourRepository;
    private final ActeMedicalRepository acteMedicalRepository;
    
    @Transactional(readOnly = true)
    public DashboardStatsDTO getDashboardStats() {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        
        stats.setTotalPatients(patientRepository.countTotalPatients());
        stats.setSejoursEnCours(sejourRepository.countSejoursEnCours());
        stats.setTotalActes(acteMedicalRepository.countTotalActes());
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startOfYear = now.with(TemporalAdjusters.firstDayOfYear()).withHour(0).withMinute(0).withSecond(0);
        LocalDateTime startOfMonth = now.with(TemporalAdjusters.firstDayOfMonth()).withHour(0).withMinute(0).withSecond(0);
        
        Double revenusAnnee = acteMedicalRepository.calculateTotalRevenue(startOfYear, now);
        Double revenusMois = acteMedicalRepository.calculateTotalRevenue(startOfMonth, now);
        
        stats.setRevenusAnnee(revenusAnnee != null ? revenusAnnee : 0.0);
        stats.setRevenusMois(revenusMois != null ? revenusMois : 0.0);
        stats.setRevenusTotal(revenusAnnee != null ? revenusAnnee : 0.0);
        
        return stats;
    }
    
    @Transactional(readOnly = true)
    public List<ActesByTypeStatsDTO> getActesByType() {
        List<Object[]> results = acteMedicalRepository.findActesGroupedByType();
        List<ActesByTypeStatsDTO> stats = new ArrayList<>();
        
        for (Object[] result : results) {
            String type = (String) result[0];
            Long count = ((Number) result[1]).longValue();
            Double revenus = result[2] != null ? ((Number) result[2]).doubleValue() : 0.0;
            stats.add(new ActesByTypeStatsDTO(type, count, revenus));
        }
        
        return stats;
    }
    
    @Transactional(readOnly = true)
    public List<RevenusByMonthStatsDTO> getRevenusByMonth() {
        LocalDateTime startDate = LocalDateTime.now().minusMonths(12);
        List<Object[]> results = acteMedicalRepository.findRevenusGroupedByMonth(startDate);
        List<RevenusByMonthStatsDTO> stats = new ArrayList<>();
        
        for (Object[] result : results) {
            String mois = (String) result[0];
            Double revenus = result[1] != null ? ((Number) result[1]).doubleValue() : 0.0;
            Long actes = ((Number) result[2]).longValue();
            stats.add(new RevenusByMonthStatsDTO(mois, revenus, actes));
        }
        
        return stats;
    }
    
    @Transactional(readOnly = true)
    public List<SejoursByServiceStatsDTO> getSejoursByService() {
        List<Object[]> results = sejourRepository.findSejoursGroupedByService();
        List<SejoursByServiceStatsDTO> stats = new ArrayList<>();
        
        for (Object[] result : results) {
            String service = (String) result[0];
            Long actifs = result[1] != null ? ((Number) result[1]).longValue() : 0L;
            Long total = ((Number) result[2]).longValue();
            stats.add(new SejoursByServiceStatsDTO(service, actifs, total));
        }
        
        return stats;
    }
}
