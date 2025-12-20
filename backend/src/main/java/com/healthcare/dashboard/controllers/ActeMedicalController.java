package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ActeMedicalDTO;
import com.healthcare.dashboard.services.ActeMedicalService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/actes")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ActeMedicalController {
    
    private final ActeMedicalService acteMedicalService;
    
    @GetMapping
    public ResponseEntity<List<ActeMedicalDTO>> getAllActes() {
        return ResponseEntity.ok(acteMedicalService.getAllActes());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ActeMedicalDTO> getActeById(@PathVariable Long id) {
        return ResponseEntity.ok(acteMedicalService.getActeById(id));
    }
    
    @GetMapping("/sejour/{sejourId}")
    public ResponseEntity<List<ActeMedicalDTO>> getActesBySejourId(@PathVariable Long sejourId) {
        return ResponseEntity.ok(acteMedicalService.getActesBySejourId(sejourId));
    }
    
    @GetMapping("/count")
    public ResponseEntity<Long> countTotalActes() {
        return ResponseEntity.ok(acteMedicalService.countTotalActes());
    }
    
    @GetMapping("/revenue")
    public ResponseEntity<Double> calculateRevenue(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        return ResponseEntity.ok(acteMedicalService.calculateTotalRevenue(startDate, endDate));
    }
    
    @PostMapping
    public ResponseEntity<ActeMedicalDTO> createActe(@RequestBody ActeMedicalDTO acteDTO) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(acteMedicalService.createActe(acteDTO));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ActeMedicalDTO> updateActe(
            @PathVariable Long id,
            @RequestBody ActeMedicalDTO acteDTO) {
        return ResponseEntity.ok(acteMedicalService.updateActe(id, acteDTO));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteActe(@PathVariable Long id) {
        acteMedicalService.deleteActe(id);
        return ResponseEntity.noContent().build();
    }
}
