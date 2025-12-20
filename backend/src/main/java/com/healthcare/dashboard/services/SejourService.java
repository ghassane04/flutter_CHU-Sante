package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.SejourDTO;
import com.healthcare.dashboard.entities.Patient;
import com.healthcare.dashboard.entities.Sejour;
import com.healthcare.dashboard.repositories.PatientRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import com.healthcare.dashboard.repositories.ServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SejourService {
    
    private final SejourRepository sejourRepository;
    private final PatientRepository patientRepository;
    private final ServiceRepository serviceRepository;
    
    @Transactional(readOnly = true)
    public List<SejourDTO> getAllSejours() {
        return sejourRepository.findAll().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public SejourDTO getSejourById(Long id) {
        Sejour sejour = sejourRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Séjour non trouvé avec l'id: " + id));
        return convertToDTO(sejour);
    }
    
    @Transactional(readOnly = true)
    public List<SejourDTO> getSejoursEnCours() {
        return sejourRepository.findSejoursEnCours().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public Long countSejoursEnCours() {
        return sejourRepository.countSejoursEnCours();
    }
    
    @Transactional
    public SejourDTO createSejour(SejourDTO sejourDTO) {
        Patient patient = patientRepository.findById(sejourDTO.getPatientId())
            .orElseThrow(() -> new RuntimeException("Patient non trouvé"));
        
        com.healthcare.dashboard.entities.Service service = serviceRepository.findById(sejourDTO.getServiceId())
            .orElseThrow(() -> new RuntimeException("Service non trouvé"));
        
        Sejour sejour = new Sejour();
        sejour.setPatient(patient);
        sejour.setService(service);
        sejour.setDateEntree(sejourDTO.getDateEntree());
        sejour.setDateSortie(sejourDTO.getDateSortie());
        sejour.setMotif(sejourDTO.getMotif());
        sejour.setDiagnostic(sejourDTO.getDiagnostic());
        sejour.setStatut(Sejour.StatutSejour.valueOf(sejourDTO.getStatut()));
        sejour.setTypeAdmission(sejourDTO.getTypeAdmission());
        sejour.setCoutTotal(sejourDTO.getCoutTotal());
        
        Sejour savedSejour = sejourRepository.save(sejour);
        return convertToDTO(savedSejour);
    }
    
    @Transactional
    public SejourDTO updateSejour(Long id, SejourDTO sejourDTO) {
        Sejour sejour = sejourRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Séjour non trouvé avec l'id: " + id));
        
        sejour.setDateSortie(sejourDTO.getDateSortie());
        sejour.setMotif(sejourDTO.getMotif());
        sejour.setDiagnostic(sejourDTO.getDiagnostic());
        sejour.setStatut(Sejour.StatutSejour.valueOf(sejourDTO.getStatut()));
        sejour.setCoutTotal(sejourDTO.getCoutTotal());
        
        Sejour updatedSejour = sejourRepository.save(sejour);
        return convertToDTO(updatedSejour);
    }
    
    @Transactional
    public void deleteSejour(Long id) {
        sejourRepository.deleteById(id);
    }
    
    private SejourDTO convertToDTO(Sejour sejour) {
        SejourDTO dto = new SejourDTO();
        dto.setId(sejour.getId());
        dto.setPatientId(sejour.getPatient().getId());
        dto.setPatientNom(sejour.getPatient().getNom());
        dto.setPatientPrenom(sejour.getPatient().getPrenom());
        dto.setServiceId(sejour.getService().getId());
        dto.setServiceNom(sejour.getService().getNom());
        dto.setDateEntree(sejour.getDateEntree());
        dto.setDateSortie(sejour.getDateSortie());
        dto.setMotif(sejour.getMotif());
        dto.setDiagnostic(sejour.getDiagnostic());
        dto.setStatut(sejour.getStatut().name());
        dto.setTypeAdmission(sejour.getTypeAdmission());
        dto.setCoutTotal(sejour.getCoutTotal());
        return dto;
    }
}
