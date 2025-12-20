package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Alert;
import com.healthcare.dashboard.repositories.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class AlertController {
    
    private final AlertRepository alertRepository;
    
    @GetMapping
    public List<Alert> getAllAlerts() {
        return alertRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Alert> getAlertById(@PathVariable Long id) {
        return alertRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/non-lues")
    public List<Alert> getUnreadAlerts() {
        return alertRepository.findByLuFalse();
    }
    
    @GetMapping("/non-resolues")
    public List<Alert> getUnresolvedAlerts() {
        return alertRepository.findByResoluFalse();
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getAlertStats() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalAlertes", alertRepository.count());
        stats.put("nonLues", alertRepository.countNonLues());
        stats.put("nonResolues", alertRepository.countNonResolues());
        stats.put("critiquesNonResolues", alertRepository.countCritiquesNonResolues());
        
        return ResponseEntity.ok(stats);
    }
    
    @PostMapping
    public Alert createAlert(@RequestBody Alert alert) {
        return alertRepository.save(alert);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Alert> updateAlert(@PathVariable Long id, @RequestBody Alert alert) {
        return alertRepository.findById(id)
                .map(existing -> {
                    alert.setId(id);
                    return ResponseEntity.ok(alertRepository.save(alert));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}/lire")
    public ResponseEntity<Alert> markAsRead(@PathVariable Long id) {
        return alertRepository.findById(id)
                .map(alert -> {
                    alert.setLu(true);
                    return ResponseEntity.ok(alertRepository.save(alert));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}/resoudre")
    public ResponseEntity<Alert> markAsResolved(@PathVariable Long id) {
        return alertRepository.findById(id)
                .map(alert -> {
                    alert.setResolu(true);
                    alert.setDateResolution(java.time.LocalDateTime.now());
                    return ResponseEntity.ok(alertRepository.save(alert));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlert(@PathVariable Long id) {
        if (alertRepository.existsById(id)) {
            alertRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
