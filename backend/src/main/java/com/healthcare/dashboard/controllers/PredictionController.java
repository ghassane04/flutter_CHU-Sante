package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Prediction;
import com.healthcare.dashboard.repositories.PredictionRepository;
import com.healthcare.dashboard.services.PredictionService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/predictions")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class PredictionController {
    
    private final PredictionRepository predictionRepository;
    private final PredictionService predictionService;
    
    @GetMapping
    public List<Prediction> getAllPredictions() {
        return predictionRepository.findByOrderByCreatedAtDesc();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Prediction> getPredictionById(@PathVariable Long id) {
        return predictionRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/type/{type}")
    public List<Prediction> getPredictionsByType(@PathVariable String type) {
        return predictionRepository.findByType(type);
    }
    
    @PostMapping("/generate")
    public ResponseEntity<Prediction> generatePrediction(@RequestBody Map<String, String> request) {
        String type = request.get("type");
        String titre = request.get("titre");
        LocalDateTime periodePrevue = LocalDateTime.parse(request.get("periodePrevue"));
        
        Prediction prediction = predictionService.generatePrediction(type, titre, periodePrevue);
        return ResponseEntity.ok(prediction);
    }
    
    @PostMapping
    public Prediction createPrediction(@RequestBody Prediction prediction) {
        return predictionRepository.save(prediction);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Prediction> updatePrediction(@PathVariable Long id, @RequestBody Prediction prediction) {
        return predictionRepository.findById(id)
                .map(existing -> {
                    prediction.setId(id);
                    return ResponseEntity.ok(predictionRepository.save(prediction));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePrediction(@PathVariable Long id) {
        if (predictionRepository.existsById(id)) {
            predictionRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
