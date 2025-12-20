package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.MedecinDTO;
import com.healthcare.dashboard.entities.Medecin;
import com.healthcare.dashboard.repositories.MedecinRepository;
import com.healthcare.dashboard.repositories.ServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

// Don't import Service entity to avoid ambiguity with @Service annotation
// Use fully qualified name: com.healthcare.dashboard.entities.Service

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class MedecinService {
    
    private final MedecinRepository medecinRepository;
    private final ServiceRepository serviceRepository;
    
    public List<MedecinDTO> getAllMedecins() {
        return medecinRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public MedecinDTO getMedecinById(Long id) {
        Medecin medecin = medecinRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Médecin non trouvé avec l'ID: " + id));
        return convertToDTO(medecin);
    }
    
    public List<MedecinDTO> getMedecinsByService(Long serviceId) {
        return medecinRepository.findByServiceId(serviceId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public List<MedecinDTO> getMedecinsBySpecialite(String specialite) {
        return medecinRepository.findBySpecialite(specialite).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public List<MedecinDTO> searchMedecins(String query) {
        return medecinRepository.findByNomContainingIgnoreCaseOrPrenomContainingIgnoreCase(query, query).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public MedecinDTO createMedecin(MedecinDTO medecinDTO) {
        Medecin medecin = new Medecin();
        medecin.setNom(medecinDTO.getNom());
        medecin.setPrenom(medecinDTO.getPrenom());
        medecin.setNumeroInscription(medecinDTO.getNumeroInscription());
        medecin.setSpecialite(medecinDTO.getSpecialite());
        medecin.setTelephone(medecinDTO.getTelephone());
        medecin.setEmail(medecinDTO.getEmail());
        medecin.setStatut(medecinDTO.getStatut() != null ? medecinDTO.getStatut() : "ACTIF");
        medecin.setCreatedAt(LocalDateTime.now());
        medecin.setUpdatedAt(LocalDateTime.now());
        
        if (medecinDTO.getServiceId() != null) {
            com.healthcare.dashboard.entities.Service service = serviceRepository.findById(medecinDTO.getServiceId())
                    .orElseThrow(() -> new RuntimeException("Service non trouvé avec l'ID: " + medecinDTO.getServiceId()));
            medecin.setService(service);
        }
        
        Medecin saved = medecinRepository.save(medecin);
        return convertToDTO(saved);
    }
    
    @Transactional
    public MedecinDTO updateMedecin(Long id, MedecinDTO medecinDTO) {
        Medecin medecin = medecinRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Médecin non trouvé avec l'ID: " + id));
        
        medecin.setNom(medecinDTO.getNom());
        medecin.setPrenom(medecinDTO.getPrenom());
        medecin.setNumeroInscription(medecinDTO.getNumeroInscription());
        medecin.setSpecialite(medecinDTO.getSpecialite());
        medecin.setTelephone(medecinDTO.getTelephone());
        medecin.setEmail(medecinDTO.getEmail());
        medecin.setStatut(medecinDTO.getStatut());
        medecin.setUpdatedAt(LocalDateTime.now());
        
        if (medecinDTO.getServiceId() != null) {
            com.healthcare.dashboard.entities.Service service = serviceRepository.findById(medecinDTO.getServiceId())
                    .orElseThrow(() -> new RuntimeException("Service non trouvé avec l'ID: " + medecinDTO.getServiceId()));
            medecin.setService(service);
        }
        
        Medecin updated = medecinRepository.save(medecin);
        return convertToDTO(updated);
    }
    
    @Transactional
    public void deleteMedecin(Long id) {
        if (!medecinRepository.existsById(id)) {
            throw new RuntimeException("Médecin non trouvé avec l'ID: " + id);
        }
        medecinRepository.deleteById(id);
    }
    
    private MedecinDTO convertToDTO(Medecin medecin) {
        MedecinDTO dto = new MedecinDTO();
        dto.setId(medecin.getId());
        dto.setNom(medecin.getNom());
        dto.setPrenom(medecin.getPrenom());
        dto.setNumeroInscription(medecin.getNumeroInscription());
        dto.setSpecialite(medecin.getSpecialite());
        dto.setTelephone(medecin.getTelephone());
        dto.setEmail(medecin.getEmail());
        dto.setStatut(medecin.getStatut());
        
        if (medecin.getService() != null) {
            dto.setServiceId(medecin.getService().getId());
            dto.setServiceNom(medecin.getService().getNom());
        }
        
        return dto;
    }
}
