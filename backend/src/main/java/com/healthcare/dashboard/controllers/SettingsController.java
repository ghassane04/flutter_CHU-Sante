package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Settings;
import com.healthcare.dashboard.repositories.SettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/settings")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class SettingsController {
    
    private final SettingsRepository settingsRepository;
    
    @GetMapping
    public List<Settings> getAllSettings() {
        return settingsRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Settings> getSettingById(@PathVariable Long id) {
        return settingsRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/cle/{cle}")
    public ResponseEntity<Settings> getSettingByCle(@PathVariable String cle) {
        return settingsRepository.findByCle(cle)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/categorie/{categorie}")
    public List<Settings> getSettingsByCategorie(@PathVariable String categorie) {
        return settingsRepository.findByCategorie(categorie);
    }
    
    @PostMapping
    public Settings createSetting(@RequestBody Settings settings) {
        return settingsRepository.save(settings);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Settings> updateSetting(@PathVariable Long id, @RequestBody Settings settings) {
        return settingsRepository.findById(id)
                .map(existing -> {
                    settings.setId(id);
                    return ResponseEntity.ok(settingsRepository.save(settings));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSetting(@PathVariable Long id) {
        if (settingsRepository.existsById(id)) {
            settingsRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
