package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.MedecinDTO;
import com.healthcare.dashboard.entities.Medecin;
import com.healthcare.dashboard.entities.Service;
import com.healthcare.dashboard.repositories.MedecinRepository;
import com.healthcare.dashboard.repositories.ServiceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MedecinServiceTest {

    @Mock
    private MedecinRepository medecinRepository;

    @Mock
    private ServiceRepository serviceRepository;

    @InjectMocks
    private MedecinService medecinService;

    private Medecin medecin;
    private Service service;
    private MedecinDTO medecinDTO;

    @BeforeEach
    void setUp() {
        service = new Service();
        service.setId(1L);
        service.setNom("Cardiologie");

        medecin = new Medecin();
        medecin.setId(1L);
        medecin.setNom("House");
        medecin.setPrenom("Gregory");
        medecin.setNumeroInscription("MD12345");
        medecin.setService(service);

        medecinDTO = new MedecinDTO();
        medecinDTO.setNom("House");
        medecinDTO.setPrenom("Gregory");
        medecinDTO.setNumeroInscription("MD12345");
        medecinDTO.setServiceId(1L);
    }

    @Test
    void getAllMedecins_ShouldReturnList() {
        when(medecinRepository.findAll()).thenReturn(Arrays.asList(medecin));

        List<MedecinDTO> result = medecinService.getAllMedecins();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getNom()).isEqualTo("House");
    }

    @Test
    void getMedecinById_ShouldReturnMedecin() {
        when(medecinRepository.findById(1L)).thenReturn(Optional.of(medecin));

        MedecinDTO result = medecinService.getMedecinById(1L);

        assertThat(result.getNom()).isEqualTo("House");
    }

    @Test
    void createMedecin_ShouldReturnCreated() {
        when(serviceRepository.findById(1L)).thenReturn(Optional.of(service));
        when(medecinRepository.save(any(Medecin.class))).thenReturn(medecin);

        MedecinDTO result = medecinService.createMedecin(medecinDTO);

        assertThat(result.getNom()).isEqualTo("House");
        verify(medecinRepository).save(any(Medecin.class));
    }

    @Test
    void updateMedecin_ShouldReturnUpdated() {
        when(medecinRepository.findById(1L)).thenReturn(Optional.of(medecin));
        when(serviceRepository.findById(1L)).thenReturn(Optional.of(service));
        when(medecinRepository.save(any(Medecin.class))).thenReturn(medecin);

        MedecinDTO result = medecinService.updateMedecin(1L, medecinDTO);

        assertThat(result.getNom()).isEqualTo("House");
    }

    @Test
    void deleteMedecin_ShouldDelete() {
        when(medecinRepository.existsById(1L)).thenReturn(true);

        medecinService.deleteMedecin(1L);

        verify(medecinRepository).deleteById(1L);
    }

    @Test
    void deleteMedecin_ShouldThrowException_WhenNotFound() {
        when(medecinRepository.existsById(1L)).thenReturn(false);

        assertThrows(RuntimeException.class, () -> medecinService.deleteMedecin(1L));
    }
}
