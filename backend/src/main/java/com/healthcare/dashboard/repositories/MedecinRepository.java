package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Medecin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MedecinRepository extends JpaRepository<Medecin, Long> {
    
    List<Medecin> findByServiceId(Long serviceId);
    
    List<Medecin> findBySpecialite(String specialite);
    
    List<Medecin> findByStatut(String statut);
    
    Optional<Medecin> findByNumeroInscription(String numeroInscription);
    
    List<Medecin> findByNomContainingIgnoreCaseOrPrenomContainingIgnoreCase(String nom, String prenom);
    
    @Query(value = "SELECT COUNT(*) FROM medecins m " +
           "JOIN services s ON m.service_id = s.id " +
           "WHERE s.nom = :serviceName AND m.statut = :statut", nativeQuery = true)
    Long countByServiceNomAndStatut(String serviceName, String statut);
}
