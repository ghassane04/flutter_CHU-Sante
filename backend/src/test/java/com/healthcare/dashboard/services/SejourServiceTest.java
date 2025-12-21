package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.SejourDTO;
import com.healthcare.dashboard.entities.Patient;
import com.healthcare.dashboard.entities.Sejour;
import com.healthcare.dashboard.entities.Service;
import com.healthcare.dashboard.repositories.PatientRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
import com.healthcare.dashboard.repositories.ServiceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SejourServiceTest {

    @Mock
    private SejourRepository sejourRepository;

    @Mock
    private PatientRepository patientRepository;

    @Mock
    private ServiceRepository serviceRepository;

    @InjectMocks
    private SejourService sejourService;

    private Sejour sejour;
    private Patient patient;
    private Service service;
    private SejourDTO sejourDTO;

    @BeforeEach
    void setUp() {
        patient = new Patient();
        patient.setId(1L);
        patient.setNom("Doe");

        service = new Service();
        service.setId(1L);
        service.setNom("Cardiologie");

        sejour = new Sejour();
        sejour.setId(1L);
        sejour.setPatient(patient);
        sejour.setService(service);
        sejour.setStatut(Sejour.StatutSejour.EN_COURS);
        sejour.setDateEntree(LocalDateTime.now());

        sejourDTO = new SejourDTO();
        sejourDTO.setPatientId(1L);
        sejourDTO.setServiceId(1L);
        sejourDTO.setStatut("EN_COURS");
        sejourDTO.setDateEntree(LocalDateTime.now());
    }

    @Test
    void getAllSejours_ShouldReturnList() {
        when(sejourRepository.findAll()).thenReturn(Arrays.asList(sejour));

        List<SejourDTO> result = sejourService.getAllSejours();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getStatut()).isEqualTo("EN_COURS");
    }

    @Test
    void getSejourById_ShouldReturnSejour() {
        when(sejourRepository.findById(1L)).thenReturn(Optional.of(sejour));

        SejourDTO result = sejourService.getSejourById(1L);

        assertThat(result.getStatut()).isEqualTo("EN_COURS");
    }

    @Test
    void getSejoursEnCours_ShouldReturnList() {
        when(sejourRepository.findSejoursEnCours()).thenReturn(Arrays.asList(sejour));

        List<SejourDTO> result = sejourService.getSejoursEnCours();

        assertThat(result).hasSize(1);
    }

    @Test
    void countSejoursEnCours_ShouldReturnCount() {
        when(sejourRepository.countSejoursEnCours()).thenReturn(5L);

        Long result = sejourService.countSejoursEnCours();

        assertThat(result).isEqualTo(5L);
    }

    @Test
    void createSejour_ShouldReturnCreated() {
        when(patientRepository.findById(1L)).thenReturn(Optional.of(patient));
        when(serviceRepository.findById(1L)).thenReturn(Optional.of(service));
        when(sejourRepository.save(any(Sejour.class))).thenReturn(sejour);

        SejourDTO result = sejourService.createSejour(sejourDTO);

        assertThat(result.getStatut()).isEqualTo("EN_COURS");
    }

    @Test
    void updateSejour_ShouldReturnUpdated() {
        when(sejourRepository.findById(1L)).thenReturn(Optional.of(sejour));
        when(sejourRepository.save(any(Sejour.class))).thenReturn(sejour);

        SejourDTO result = sejourService.updateSejour(1L, sejourDTO);

        assertThat(result.getStatut()).isEqualTo("EN_COURS");
    }

    @Test
    void deleteSejour_ShouldDelete() {
        sejourService.deleteSejour(1L);
        verify(sejourRepository).deleteById(1L);
    }
}
