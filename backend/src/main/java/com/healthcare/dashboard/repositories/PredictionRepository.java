package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Prediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PredictionRepository extends JpaRepository<Prediction, Long> {
    
    List<Prediction> findByType(String type);
    
    List<Prediction> findByGenerePar(String generePar);
    
    List<Prediction> findByOrderByCreatedAtDesc();
}
