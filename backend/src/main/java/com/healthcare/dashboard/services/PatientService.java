package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.PatientDTO;
import com.healthcare.dashboard.entities.Patient;
import com.healthcare.dashboard.repositories.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PatientService {
    
    private final PatientRepository patientRepository;
    
    @Transactional(readOnly = true)
    public List<PatientDTO> getAllPatients() {
        return patientRepository.findAll().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public PatientDTO getPatientById(Long id) {
        Patient patient = patientRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Patient non trouvé avec l'id: " + id));
        return convertToDTO(patient);
    }
    
    @Transactional
    public PatientDTO createPatient(PatientDTO patientDTO) {
        Patient patient = convertToEntity(patientDTO);
        Patient savedPatient = patientRepository.save(patient);
        return convertToDTO(savedPatient);
    }
    
    @Transactional
    public PatientDTO updatePatient(Long id, PatientDTO patientDTO) {
        Patient patient = patientRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Patient non trouvé avec l'id: " + id));
        
        patient.setNom(patientDTO.getNom());
        patient.setPrenom(patientDTO.getPrenom());
        patient.setNumeroSecuriteSociale(patientDTO.getNumeroSecuriteSociale());
        patient.setDateNaissance(patientDTO.getDateNaissance());
        patient.setSexe(patientDTO.getSexe());
        patient.setAdresse(patientDTO.getAdresse());
        patient.setTelephone(patientDTO.getTelephone());
        patient.setEmail(patientDTO.getEmail());
        
        Patient updatedPatient = patientRepository.save(patient);
        return convertToDTO(updatedPatient);
    }
    
    @Transactional
    public void deletePatient(Long id) {
        patientRepository.deleteById(id);
    }
    
    @Transactional(readOnly = true)
    public Long countTotalPatients() {
        return patientRepository.countTotalPatients();
    }
    
    private PatientDTO convertToDTO(Patient patient) {
        PatientDTO dto = new PatientDTO();
        dto.setId(patient.getId());
        dto.setNom(patient.getNom());
        dto.setPrenom(patient.getPrenom());
        dto.setNumeroSecuriteSociale(patient.getNumeroSecuriteSociale());
        dto.setDateNaissance(patient.getDateNaissance());
        dto.setSexe(patient.getSexe());
        dto.setAdresse(patient.getAdresse());
        dto.setTelephone(patient.getTelephone());
        dto.setEmail(patient.getEmail());
        return dto;
    }
    
    private Patient convertToEntity(PatientDTO dto) {
        Patient patient = new Patient();
        patient.setNom(dto.getNom());
        patient.setPrenom(dto.getPrenom());
        patient.setNumeroSecuriteSociale(dto.getNumeroSecuriteSociale());
        patient.setDateNaissance(dto.getDateNaissance());
        patient.setSexe(dto.getSexe());
        patient.setAdresse(dto.getAdresse());
        patient.setTelephone(dto.getTelephone());
        patient.setEmail(dto.getEmail());
        return patient;
    }
}
