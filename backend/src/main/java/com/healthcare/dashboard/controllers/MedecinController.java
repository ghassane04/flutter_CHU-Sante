package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.MedecinDTO;
import com.healthcare.dashboard.services.MedecinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/medecins")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class MedecinController {
    
    private final MedecinService medecinService;
    
    @GetMapping
    public ResponseEntity<List<MedecinDTO>> getAllMedecins() {
        return ResponseEntity.ok(medecinService.getAllMedecins());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<MedecinDTO> getMedecinById(@PathVariable Long id) {
        return ResponseEntity.ok(medecinService.getMedecinById(id));
    }
    
    @GetMapping("/service/{serviceId}")
    public ResponseEntity<List<MedecinDTO>> getMedecinsByService(@PathVariable Long serviceId) {
        return ResponseEntity.ok(medecinService.getMedecinsByService(serviceId));
    }
    
    @GetMapping("/specialite/{specialite}")
    public ResponseEntity<List<MedecinDTO>> getMedecinsBySpecialite(@PathVariable String specialite) {
        return ResponseEntity.ok(medecinService.getMedecinsBySpecialite(specialite));
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<MedecinDTO>> searchMedecins(@RequestParam String query) {
        return ResponseEntity.ok(medecinService.searchMedecins(query));
    }
    
    @PostMapping
    public ResponseEntity<MedecinDTO> createMedecin(@RequestBody MedecinDTO medecinDTO) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(medecinService.createMedecin(medecinDTO));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<MedecinDTO> updateMedecin(@PathVariable Long id, @RequestBody MedecinDTO medecinDTO) {
        return ResponseEntity.ok(medecinService.updateMedecin(id, medecinDTO));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMedecin(@PathVariable Long id) {
        medecinService.deleteMedecin(id);
        return ResponseEntity.noContent().build();
    }
}
