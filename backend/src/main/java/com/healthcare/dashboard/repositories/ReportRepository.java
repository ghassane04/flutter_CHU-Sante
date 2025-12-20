package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    
    List<Report> findByType(String type);
    
    List<Report> findByPeriode(String periode);
    
    List<Report> findByStatut(String statut);
    
    List<Report> findByGenerePar(String generePar);
}
