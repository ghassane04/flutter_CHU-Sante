package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ActeMedicalDTO;
import com.healthcare.dashboard.entities.ActeMedical;
import com.healthcare.dashboard.entities.Sejour;
import com.healthcare.dashboard.repositories.ActeMedicalRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ActeMedicalService {
    
    private final ActeMedicalRepository acteMedicalRepository;
    private final SejourRepository sejourRepository;
    
    @Transactional(readOnly = true)
    public List<ActeMedicalDTO> getAllActes() {
        return acteMedicalRepository.findAll().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public ActeMedicalDTO getActeById(Long id) {
        ActeMedical acte = acteMedicalRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Acte médical non trouvé avec l'id: " + id));
        return convertToDTO(acte);
    }
    
    @Transactional(readOnly = true)
    public List<ActeMedicalDTO> getActesBySejourId(Long sejourId) {
        return acteMedicalRepository.findBySejourId(sejourId).stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public Long countTotalActes() {
        return acteMedicalRepository.countTotalActes();
    }
    
    @Transactional(readOnly = true)
    public Double calculateTotalRevenue(LocalDateTime startDate, LocalDateTime endDate) {
        return acteMedicalRepository.calculateTotalRevenue(startDate, endDate);
    }
    
    @Transactional
    public ActeMedicalDTO createActe(ActeMedicalDTO acteDTO) {
        Sejour sejour = sejourRepository.findById(acteDTO.getSejourId())
            .orElseThrow(() -> new RuntimeException("Séjour non trouvé"));
        
        ActeMedical acte = new ActeMedical();
        acte.setSejour(sejour);
        acte.setCode(acteDTO.getCode());
        acte.setLibelle(acteDTO.getLibelle());
        acte.setType(acteDTO.getType());
        acte.setDateRealisation(acteDTO.getDateRealisation());
        acte.setTarif(acteDTO.getTarif());
        acte.setMedecin(acteDTO.getMedecin());
        acte.setNotes(acteDTO.getNotes());
        
        ActeMedical savedActe = acteMedicalRepository.save(acte);
        return convertToDTO(savedActe);
    }
    
    @Transactional
    public ActeMedicalDTO updateActe(Long id, ActeMedicalDTO acteDTO) {
        ActeMedical acte = acteMedicalRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Acte médical non trouvé avec l'id: " + id));
        
        acte.setCode(acteDTO.getCode());
        acte.setLibelle(acteDTO.getLibelle());
        acte.setType(acteDTO.getType());
        acte.setDateRealisation(acteDTO.getDateRealisation());
        acte.setTarif(acteDTO.getTarif());
        acte.setMedecin(acteDTO.getMedecin());
        acte.setNotes(acteDTO.getNotes());
        
        ActeMedical updatedActe = acteMedicalRepository.save(acte);
        return convertToDTO(updatedActe);
    }
    
    @Transactional
    public void deleteActe(Long id) {
        acteMedicalRepository.deleteById(id);
    }
    
    private ActeMedicalDTO convertToDTO(ActeMedical acte) {
        ActeMedicalDTO dto = new ActeMedicalDTO();
        dto.setId(acte.getId());
        dto.setSejourId(acte.getSejour().getId());
        dto.setCode(acte.getCode());
        dto.setLibelle(acte.getLibelle());
        dto.setType(acte.getType());
        dto.setDateRealisation(acte.getDateRealisation());
        dto.setTarif(acte.getTarif());
        dto.setMedecin(acte.getMedecin());
        dto.setNotes(acte.getNotes());
        return dto;
    }
}
