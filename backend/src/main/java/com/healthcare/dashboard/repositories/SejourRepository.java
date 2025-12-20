package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Sejour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SejourRepository extends JpaRepository<Sejour, Long> {
    
    List<Sejour> findByPatientId(Long patientId);
    
    List<Sejour> findByServiceId(Long serviceId);
    
    @Query("SELECT s FROM Sejour s WHERE s.statut = 'EN_COURS'")
    List<Sejour> findSejoursEnCours();
    
    @Query("SELECT COUNT(s) FROM Sejour s WHERE s.statut = 'EN_COURS'")
    Long countSejoursEnCours();
    
    @Query("SELECT COUNT(s) FROM Sejour s WHERE s.statut = ?1")
    Long countByStatut(String statut);
    
    @Query("SELECT s FROM Sejour s WHERE s.dateEntree BETWEEN ?1 AND ?2")
    List<Sejour> findSejoursByDateRange(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query(value = "SELECT sv.nom as service, " +
           "SUM(CASE WHEN s.statut = 'EN_COURS' THEN 1 ELSE 0 END) as actifs, " +
           "COUNT(s.id) as total " +
           "FROM sejours s JOIN services sv ON s.service_id = sv.id " +
           "GROUP BY sv.nom " +
           "ORDER BY actifs DESC", nativeQuery = true)
    List<Object[]> findSejoursGroupedByService();
    
    // Nouvelles requêtes pour ML
    @Query(value = "SELECT COUNT(*) as count, AVG(TIMESTAMPDIFF(DAY, date_entree, COALESCE(date_sortie, NOW()))) as avg_duration " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE s.date_entree >= :startDate AND s.date_entree < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    List<Object[]> findStatsByDateAndService(LocalDateTime startDate, LocalDateTime endDate, String serviceName);
    
    @Query(value = "SELECT AVG(TIMESTAMPDIFF(DAY, date_entree, COALESCE(date_sortie, NOW()))) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE s.date_entree >= :startDate AND s.date_entree < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    Double findAverageOccupationByService(LocalDateTime startDate, LocalDateTime endDate, String serviceName);
    
    // Nouvelles requêtes pour utiliser les données actuelles
    @Query(value = "SELECT AVG(COALESCE(s.cout_total, 0)) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE sv.nom = :serviceName", nativeQuery = true)
    Double findAverageCoutByService(String serviceName);
    
    @Query(value = "SELECT COUNT(DISTINCT s.patient_id) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE sv.nom = :serviceName", nativeQuery = true)
    Long countDistinctPatientsByService(String serviceName);
    
    @Query(value = "SELECT COUNT(*) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE sv.nom = :serviceName AND s.statut = 'EN_COURS'", nativeQuery = true)
    Long countActiveSejoursByService(String serviceName);
}
