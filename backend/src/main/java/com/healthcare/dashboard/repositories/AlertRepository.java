package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    
    List<Alert> findByLuFalse();
    
    List<Alert> findByResoluFalse();
    
    List<Alert> findByType(String type);
    
    List<Alert> findByPriorite(String priorite);
    
    List<Alert> findByCategorie(String categorie);
    
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.lu = false")
    Long countNonLues();
    
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.resolu = false")
    Long countNonResolues();
    
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.priorite = 'CRITIQUE' AND a.resolu = false")
    Long countCritiquesNonResolues();
    
    @Query(value = "SELECT COUNT(*) FROM alerts a " +
           "JOIN services s ON a.service_id = s.id " +
           "WHERE s.nom = :serviceName AND a.status = :status", nativeQuery = true)
    Long countByServiceNomAndStatus(String serviceName, String status);
}
