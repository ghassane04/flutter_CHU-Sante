package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Settings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SettingsRepository extends JpaRepository<Settings, Long> {
    
    Optional<Settings> findByCle(String cle);
    
    List<Settings> findByCategorie(String categorie);
}
