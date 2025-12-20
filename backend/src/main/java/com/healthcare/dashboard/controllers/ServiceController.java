package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ServiceDTO;
import com.healthcare.dashboard.services.ServiceMedicalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/services")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ServiceController {
    
    private final ServiceMedicalService serviceMedicalService;
    
    @GetMapping
    public ResponseEntity<List<ServiceDTO>> getAllServices() {
        return ResponseEntity.ok(serviceMedicalService.getAllServices());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ServiceDTO> getServiceById(@PathVariable Long id) {
        return ResponseEntity.ok(serviceMedicalService.getServiceById(id));
    }
    
    @PostMapping
    public ResponseEntity<ServiceDTO> createService(@RequestBody ServiceDTO serviceDTO) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(serviceMedicalService.createService(serviceDTO));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ServiceDTO> updateService(
            @PathVariable Long id,
            @RequestBody ServiceDTO serviceDTO) {
        return ResponseEntity.ok(serviceMedicalService.updateService(id, serviceDTO));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteService(@PathVariable Long id) {
        serviceMedicalService.deleteService(id);
        return ResponseEntity.noContent().build();
    }
}
