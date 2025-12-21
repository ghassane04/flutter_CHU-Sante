package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ServiceDTO;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ServiceMedicalServiceTest {

    @Mock
    private ServiceRepository serviceRepository;

    @InjectMocks
    private ServiceMedicalService serviceMedicalService;

    private com.healthcare.dashboard.entities.Service service;
    private ServiceDTO serviceDTO;

    @BeforeEach
    void setUp() {
        service = new com.healthcare.dashboard.entities.Service();
        service.setId(1L);
        service.setNom("Cardiologie");
        service.setDescription("Service de cardiologie");
        service.setCapacite(50);
        service.setLitsDisponibles(20);

        serviceDTO = new ServiceDTO();
        serviceDTO.setId(1L);
        serviceDTO.setNom("Cardiologie");
        serviceDTO.setDescription("Service de cardiologie");
        serviceDTO.setCapacite(50);
        serviceDTO.setLitsDisponibles(20);
    }

    @Test
    void getAllServices_ShouldReturnList() {
        when(serviceRepository.findAll()).thenReturn(Arrays.asList(service));

        List<ServiceDTO> result = serviceMedicalService.getAllServices();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Cardiologie", result.get(0).getNom());
        verify(serviceRepository, times(1)).findAll();
    }

    @Test
    void getServiceById_ShouldReturnService() {
        when(serviceRepository.findById(1L)).thenReturn(Optional.of(service));

        ServiceDTO result = serviceMedicalService.getServiceById(1L);

        assertNotNull(result);
        assertEquals("Cardiologie", result.getNom());
    }

    @Test
    void getServiceById_ShouldThrowException_WhenNotFound() {
        when(serviceRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> serviceMedicalService.getServiceById(999L));
    }

    @Test
    void createService_ShouldReturnCreated() {
        when(serviceRepository.save(any(com.healthcare.dashboard.entities.Service.class))).thenReturn(service);

        ServiceDTO result = serviceMedicalService.createService(serviceDTO);

        assertNotNull(result);
        assertEquals("Cardiologie", result.getNom());
        verify(serviceRepository, times(1)).save(any(com.healthcare.dashboard.entities.Service.class));
    }

    @Test
    void updateService_ShouldReturnUpdated() {
        when(serviceRepository.findById(1L)).thenReturn(Optional.of(service));
        when(serviceRepository.save(any(com.healthcare.dashboard.entities.Service.class))).thenReturn(service);

        ServiceDTO result = serviceMedicalService.updateService(1L, serviceDTO);

        assertNotNull(result);
        assertEquals("Cardiologie", result.getNom());
    }

    @Test
    void deleteService_ShouldCallRepository() {
        doNothing().when(serviceRepository).deleteById(1L);

        serviceMedicalService.deleteService(1L);

        verify(serviceRepository, times(1)).deleteById(1L);
    }
}
