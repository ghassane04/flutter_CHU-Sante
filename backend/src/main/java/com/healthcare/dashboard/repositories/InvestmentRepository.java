package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Investment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface InvestmentRepository extends JpaRepository<Investment, Long> {
    
    List<Investment> findByStatut(String statut);
    
    List<Investment> findByCategorie(String categorie);
    
    @Query("SELECT SUM(i.montant) FROM Investment i WHERE i.statut = 'TERMINE'")
    Double sumMontantByStatutTermine();
    
    @Query("SELECT SUM(i.montant) FROM Investment i WHERE i.statut = 'EN_COURS'")
    Double sumMontantByStatutEnCours();
    
    @Query("SELECT SUM(i.montant) FROM Investment i WHERE i.dateInvestissement BETWEEN ?1 AND ?2")
    Double sumMontantByDateBetween(LocalDateTime start, LocalDateTime end);
    
    @Query("SELECT i.categorie, SUM(i.montant) FROM Investment i GROUP BY i.categorie")
    List<Object[]> sumMontantByCategorie();
    
    @Query(value = "SELECT i.nom, i.montant FROM investments i " +
           "JOIN services s ON i.service_id = s.id " +
           "WHERE s.nom = :serviceName AND i.date_investissement >= :afterDate", nativeQuery = true)
    List<Object[]> findByServiceNomAndDateAfter(String serviceName, LocalDateTime afterDate);
}
