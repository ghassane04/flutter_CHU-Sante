package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.PatientDTO;
import com.healthcare.dashboard.entities.Patient;
import com.healthcare.dashboard.repositories.PatientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PatientServiceTest {

    @Mock
    private PatientRepository patientRepository;

    @InjectMocks
    private PatientService patientService;

    private Patient patient;
    private PatientDTO patientDTO;

    @BeforeEach
    void setUp() {
        patient = new Patient();
        patient.setId(1L);
        patient.setNom("Doe");
        patient.setPrenom("John");
        patient.setNumeroSecuriteSociale("123456789012345");
        patient.setDateNaissance(LocalDate.of(1980, 1, 1));
        patient.setEmail("john.doe@example.com");

        patientDTO = new PatientDTO();
        patientDTO.setNom("Doe");
        patientDTO.setPrenom("John");
        patientDTO.setNumeroSecuriteSociale("123456789012345");
        patientDTO.setDateNaissance(LocalDate.of(1980, 1, 1));
        patientDTO.setEmail("john.doe@example.com");
    }

    @Test
    void getAllPatients_ShouldReturnList() {
        when(patientRepository.findAll()).thenReturn(Arrays.asList(patient));

        List<PatientDTO> result = patientService.getAllPatients();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Doe", result.get(0).getNom());
        verify(patientRepository, times(1)).findAll();
    }

    @Test
    void getPatientById_ShouldReturnPatient() {
        when(patientRepository.findById(1L)).thenReturn(Optional.of(patient));

        PatientDTO result = patientService.getPatientById(1L);

        assertNotNull(result);
        assertEquals("John", result.getPrenom());
        verify(patientRepository, times(1)).findById(1L);
    }

    @Test
    void getPatientById_ShouldThrowWhenNotFound() {
        when(patientRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> patientService.getPatientById(99L));
    }

    @Test
    void createPatient_ShouldReturnSavedPatient() {
        when(patientRepository.save(any(Patient.class))).thenReturn(patient);

        PatientDTO result = patientService.createPatient(patientDTO);

        assertNotNull(result);
        assertEquals("Doe", result.getNom());
        verify(patientRepository, times(1)).save(any(Patient.class));
    }

    @Test
    void updatePatient_ShouldReturnUpdatedPatient() {
        when(patientRepository.findById(1L)).thenReturn(Optional.of(patient));
        when(patientRepository.save(any(Patient.class))).thenReturn(patient);

        PatientDTO updateDTO = new PatientDTO();
        updateDTO.setNom("Smith");
        updateDTO.setPrenom("John");

        PatientDTO result = patientService.updatePatient(1L, updateDTO);

        assertNotNull(result);
        // Note: The logic in actual service copies properties. 
        // Since we mock save to return the original (or modified) entity, we verify the interaction.
        verify(patientRepository, times(1)).save(any(Patient.class));
    }

    @Test
    void deletePatient_ShouldCallRepository() {
        doNothing().when(patientRepository).deleteById(1L);

        patientService.deletePatient(1L);

        verify(patientRepository, times(1)).deleteById(1L);
    }

    @Test
    void countTotalPatients_ShouldReturnCount() {
        when(patientRepository.countTotalPatients()).thenReturn(10L);

        Long result = patientService.countTotalPatients();

        assertEquals(10L, result);
        verify(patientRepository, times(1)).countTotalPatients();
    }
}
