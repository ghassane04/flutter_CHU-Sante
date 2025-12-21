package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ActeMedicalDTO;
import com.healthcare.dashboard.entities.ActeMedical;
import com.healthcare.dashboard.entities.Sejour;
import com.healthcare.dashboard.repositories.ActeMedicalRepository;
import com.healthcare.dashboard.repositories.SejourRepository;
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
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ActeMedicalServiceTest {

    @Mock
    private ActeMedicalRepository acteMedicalRepository;

    @Mock
    private SejourRepository sejourRepository;

    @InjectMocks
    private ActeMedicalService acteMedicalService;

    private ActeMedical acteMedical;
    private Sejour sejour;
    private ActeMedicalDTO acteMedicalDTO;

    @BeforeEach
    void setUp() {
        sejour = new Sejour();
        sejour.setId(1L);

        acteMedical = new ActeMedical();
        acteMedical.setId(1L);
        acteMedical.setSejour(sejour);
        acteMedical.setCode("CCAM123");
        acteMedical.setLibelle("Consultation");
        acteMedical.setTarif(25.0);
        acteMedical.setDateRealisation(LocalDateTime.now());

        acteMedicalDTO = new ActeMedicalDTO();
        acteMedicalDTO.setSejourId(1L);
        acteMedicalDTO.setCode("CCAM123");
        acteMedicalDTO.setLibelle("Consultation");
        acteMedicalDTO.setTarif(25.0);
        acteMedicalDTO.setDateRealisation(LocalDateTime.now());
    }

    @Test
    void getAllActes_ShouldReturnList() {
        when(acteMedicalRepository.findAll()).thenReturn(Arrays.asList(acteMedical));

        List<ActeMedicalDTO> result = acteMedicalService.getAllActes();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getCode()).isEqualTo("CCAM123");
    }

    @Test
    void getActeById_ShouldReturnActe() {
        when(acteMedicalRepository.findById(1L)).thenReturn(Optional.of(acteMedical));

        ActeMedicalDTO result = acteMedicalService.getActeById(1L);

        assertThat(result.getCode()).isEqualTo("CCAM123");
    }

    @Test
    void createActe_ShouldReturnCreated() {
        when(sejourRepository.findById(1L)).thenReturn(Optional.of(sejour));
        when(acteMedicalRepository.save(any(ActeMedical.class))).thenReturn(acteMedical);

        ActeMedicalDTO result = acteMedicalService.createActe(acteMedicalDTO);

        assertThat(result.getCode()).isEqualTo("CCAM123");
    }

    @Test
    void updateActe_ShouldReturnUpdated() {
        when(acteMedicalRepository.findById(1L)).thenReturn(Optional.of(acteMedical));
        when(acteMedicalRepository.save(any(ActeMedical.class))).thenReturn(acteMedical);

        ActeMedicalDTO result = acteMedicalService.updateActe(1L, acteMedicalDTO);

        assertThat(result.getCode()).isEqualTo("CCAM123");
    }

    @Test
    void deleteActe_ShouldDelete() {
        acteMedicalService.deleteActe(1L);
        verify(acteMedicalRepository).deleteById(1L);
    }
}
