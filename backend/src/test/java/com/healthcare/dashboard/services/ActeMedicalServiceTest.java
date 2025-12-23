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
    void getActeById_ShouldThrowWhenNotFound() {
        when(acteMedicalRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> acteMedicalService.getActeById(99L));
    }

    @Test
    void createActe_ShouldThrowWhenSejourNotFound() {
        when(sejourRepository.findById(99L)).thenReturn(Optional.empty());
        acteMedicalDTO.setSejourId(99L);

        assertThrows(RuntimeException.class, () -> acteMedicalService.createActe(acteMedicalDTO));
    }

    @Test
    void updateActe_ShouldThrowWhenNotFound() {
        when(acteMedicalRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> acteMedicalService.updateActe(99L, acteMedicalDTO));
    }

    @Test
    void deleteActe_ShouldCallRepository() {
        doNothing().when(acteMedicalRepository).deleteById(1L);

        acteMedicalService.deleteActe(1L);

        verify(acteMedicalRepository, times(1)).deleteById(1L);
    }

    @Test
    void getActesBySejourId_ShouldReturnList() {
        when(acteMedicalRepository.findBySejourId(1L)).thenReturn(Arrays.asList(acteMedical));

        List<ActeMedicalDTO> result = acteMedicalService.getActesBySejourId(1L);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getCode()).isEqualTo("CCAM123");
    }

    @Test
    void countTotalActes_ShouldReturnCount() {
        when(acteMedicalRepository.countTotalActes()).thenReturn(100L);

        Long count = acteMedicalService.countTotalActes();

        assertThat(count).isEqualTo(100L);
    }

    @Test
    void calculateTotalRevenue_ShouldReturnAmount() {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 0, 0);
        LocalDateTime end = LocalDateTime.of(2024, 12, 31, 23, 59);
        when(acteMedicalRepository.calculateTotalRevenue(start, end)).thenReturn(50000.0);

        Double revenue = acteMedicalService.calculateTotalRevenue(start, end);

        assertThat(revenue).isEqualTo(50000.0);
    }

    @Test
    void deleteActe_ShouldDelete() {
        acteMedicalService.deleteActe(1L);
        verify(acteMedicalRepository).deleteById(1L);
    }
}
