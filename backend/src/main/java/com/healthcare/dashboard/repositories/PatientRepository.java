package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {
    
    Optional<Patient> findByNumeroSecuriteSociale(String numeroSecuriteSociale);
    
    @Query("SELECT COUNT(p) FROM Patient p")
    Long countTotalPatients();
    
    // Nouvelles requêtes pour ML
    @Query(value = "SELECT COUNT(DISTINCT s.patient_id) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE s.date_entree >= :startDate AND s.date_entree < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    Long countDistinctPatientsWithSejoursOnDate(java.time.LocalDateTime startDate, java.time.LocalDateTime endDate, String serviceName);
    
    @Query(value = "SELECT COUNT(DISTINCT s.patient_id) " +
           "FROM sejours s " +
           "JOIN services sv ON s.service_id = sv.id " +
           "WHERE s.date_entree >= :startDate AND s.date_entree < :endDate " +
           "AND sv.nom = :serviceName", nativeQuery = true)
    Long countDistinctPatientsWithSejoursInRange(java.time.LocalDateTime startDate, java.time.LocalDateTime endDate, String serviceName);
}
