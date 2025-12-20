package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.ActeMedical;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActeMedicalRepository extends JpaRepository<ActeMedical, Long> {
    
    List<ActeMedical> findBySejourId(Long sejourId);
    
    @Query("SELECT a FROM ActeMedical a WHERE a.dateRealisation BETWEEN ?1 AND ?2")
    List<ActeMedical> findActesByDateRange(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT SUM(a.tarif) FROM ActeMedical a WHERE a.dateRealisation BETWEEN ?1 AND ?2")
    Double calculateTotalRevenue(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT SUM(a.tarif) FROM ActeMedical a WHERE a.dateRealisation BETWEEN ?1 AND ?2")
    Double sumTarifByDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT SUM(a.tarif) FROM ActeMedical a")
    Double sumAllTarif();
    
    @Query("SELECT COUNT(a) FROM ActeMedical a")
    Long countTotalActes();
    
    @Query(value = "SELECT type, COUNT(*) as count, COALESCE(SUM(tarif), 0) as revenus " +
           "FROM actes_medicaux GROUP BY type ORDER BY count DESC", nativeQuery = true)
    List<Object[]> findActesGroupedByType();
    
    @Query(value = "SELECT DATE_FORMAT(date_realisation, '%Y-%m') as mois, " +
           "COALESCE(SUM(tarif), 0) as revenus, COUNT(*) as actes " +
           "FROM actes_medicaux " +
           "WHERE date_realisation >= :startDate " +
           "GROUP BY DATE_FORMAT(date_realisation, '%Y-%m') " +
           "ORDER BY mois", nativeQuery = true)
    List<Object[]> findRevenusGroupedByMonth(LocalDateTime startDate);
    
    // Nouvelles requêtes pour ML
    @Query(value = "SELECT COUNT(*) as count, COALESCE(SUM(tarif), 0) as total, AVG(tarif) as avg " +
           "FROM actes_medicaux a " +
           "JOIN sejours s ON a.sejour_id = s.id " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE a.date_realisation >= :startDate AND a.date_realisation < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    List<Object[]> findStatsByDateAndService(LocalDateTime startDate, LocalDateTime endDate, String serviceName);
    
    @Query(value = "SELECT COALESCE(SUM(tarif), 0) as total " +
           "FROM actes_medicaux a " +
           "JOIN sejours s ON a.sejour_id = s.id " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE a.date_realisation >= :startDate AND a.date_realisation < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    Double findStatsByDateRangeAndService(LocalDateTime startDate, LocalDateTime endDate, String serviceName);
}
