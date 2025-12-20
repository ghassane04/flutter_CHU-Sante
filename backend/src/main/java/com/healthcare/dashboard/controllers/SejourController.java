package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.SejourDTO;
import com.healthcare.dashboard.services.SejourService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/sejours")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class SejourController {
    
    private final SejourService sejourService;
    
    @GetMapping
    public ResponseEntity<List<SejourDTO>> getAllSejours() {
        return ResponseEntity.ok(sejourService.getAllSejours());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<SejourDTO> getSejourById(@PathVariable Long id) {
        return ResponseEntity.ok(sejourService.getSejourById(id));
    }
    
    @GetMapping("/en-cours")
    public ResponseEntity<List<SejourDTO>> getSejoursEnCours() {
        return ResponseEntity.ok(sejourService.getSejoursEnCours());
    }
    
    @GetMapping("/count/en-cours")
    public ResponseEntity<Long> countSejoursEnCours() {
        return ResponseEntity.ok(sejourService.countSejoursEnCours());
    }
    
    @PostMapping
    public ResponseEntity<SejourDTO> createSejour(@RequestBody SejourDTO sejourDTO) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(sejourService.createSejour(sejourDTO));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<SejourDTO> updateSejour(
            @PathVariable Long id,
            @RequestBody SejourDTO sejourDTO) {
        return ResponseEntity.ok(sejourService.updateSejour(id, sejourDTO));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSejour(@PathVariable Long id) {
        sejourService.deleteSejour(id);
        return ResponseEntity.noContent().build();
    }
}
