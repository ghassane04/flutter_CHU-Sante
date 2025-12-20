package com.healthcare.dashboard.services;

import com.healthcare.dashboard.dto.ServiceDTO;
import com.healthcare.dashboard.repositories.ServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ServiceMedicalService {
    
    private final ServiceRepository serviceRepository;
    
    @Transactional(readOnly = true)
    public List<ServiceDTO> getAllServices() {
        return serviceRepository.findAll().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public ServiceDTO getServiceById(Long id) {
        com.healthcare.dashboard.entities.Service service = serviceRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Service non trouvé avec l'id: " + id));
        return convertToDTO(service);
    }
    
    @Transactional
    public ServiceDTO createService(ServiceDTO serviceDTO) {
        com.healthcare.dashboard.entities.Service service = convertToEntity(serviceDTO);
        com.healthcare.dashboard.entities.Service savedService = serviceRepository.save(service);
        return convertToDTO(savedService);
    }
    
    @Transactional
    public ServiceDTO updateService(Long id, ServiceDTO serviceDTO) {
        com.healthcare.dashboard.entities.Service service = serviceRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Service non trouvé avec l'id: " + id));
        
        service.setNom(serviceDTO.getNom());
        service.setDescription(serviceDTO.getDescription());
        service.setType(serviceDTO.getType());
        service.setCapacite(serviceDTO.getCapacite());
        service.setLitsDisponibles(serviceDTO.getLitsDisponibles());
        service.setResponsable(serviceDTO.getResponsable());
        service.setBudget(serviceDTO.getBudget());
        service.setDepense(serviceDTO.getDepense());
        
        com.healthcare.dashboard.entities.Service updatedService = serviceRepository.save(service);
        return convertToDTO(updatedService);
    }
    
    @Transactional
    public void deleteService(Long id) {
        serviceRepository.deleteById(id);
    }
    
    private ServiceDTO convertToDTO(com.healthcare.dashboard.entities.Service service) {
        ServiceDTO dto = new ServiceDTO();
        dto.setId(service.getId());
        dto.setNom(service.getNom());
        dto.setDescription(service.getDescription());
        dto.setType(service.getType());
        dto.setCapacite(service.getCapacite());
        dto.setLitsDisponibles(service.getLitsDisponibles());
        dto.setResponsable(service.getResponsable());
        dto.setBudget(service.getBudget());
        dto.setDepense(service.getDepense());
        return dto;
    }
    
    private com.healthcare.dashboard.entities.Service convertToEntity(ServiceDTO dto) {
        com.healthcare.dashboard.entities.Service service = new com.healthcare.dashboard.entities.Service();
        service.setNom(dto.getNom());
        service.setDescription(dto.getDescription());
        service.setType(dto.getType());
        service.setCapacite(dto.getCapacite());
        service.setLitsDisponibles(dto.getLitsDisponibles());
        service.setResponsable(dto.getResponsable());
        service.setBudget(dto.getBudget());
        service.setDepense(dto.getDepense());
        return service;
    }
}
