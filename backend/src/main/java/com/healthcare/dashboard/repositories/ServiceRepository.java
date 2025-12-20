package com.healthcare.dashboard.repositories;

import com.healthcare.dashboard.entities.Service;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ServiceRepository extends JpaRepository<Service, Long> {
    
    Optional<Service> findByNom(String nom);
    
    @Query(value = "SELECT nom FROM services", nativeQuery = true)
    List<Object[]> findAllBasicInfo();
}
