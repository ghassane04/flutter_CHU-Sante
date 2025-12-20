package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Investment;
import com.healthcare.dashboard.repositories.InvestmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/investments")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class InvestmentController {
    
    private final InvestmentRepository investmentRepository;
    
    @GetMapping
    public List<Investment> getAllInvestments() {
        return investmentRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Investment> getInvestmentById(@PathVariable Long id) {
        return investmentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/statut/{statut}")
    public List<Investment> getInvestmentsByStatut(@PathVariable String statut) {
        return investmentRepository.findByStatut(statut);
    }
    
    @GetMapping("/categorie/{categorie}")
    public List<Investment> getInvestmentsByCategorie(@PathVariable String categorie) {
        return investmentRepository.findByCategorie(categorie);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getInvestmentStats() {
        Map<String, Object> stats = new HashMap<>();
        
        Double totalInvesti = investmentRepository.findAll().stream()
                .mapToDouble(Investment::getMontant)
                .sum();
        
        Double montantEnCours = investmentRepository.sumMontantByStatutEnCours();
        Double montantTermine = investmentRepository.sumMontantByStatutTermine();
        
        stats.put("totalInvesti", totalInvesti != null ? totalInvesti : 0.0);
        stats.put("montantEnCours", montantEnCours != null ? montantEnCours : 0.0);
        stats.put("montantTermine", montantTermine != null ? montantTermine : 0.0);
        stats.put("nombreInvestissements", investmentRepository.count());
        
        return ResponseEntity.ok(stats);
    }
    
    @PostMapping
    public Investment createInvestment(@RequestBody Investment investment) {
        return investmentRepository.save(investment);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Investment> updateInvestment(@PathVariable Long id, @RequestBody Investment investment) {
        return investmentRepository.findById(id)
                .map(existing -> {
                    investment.setId(id);
                    return ResponseEntity.ok(investmentRepository.save(investment));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteInvestment(@PathVariable Long id) {
        if (investmentRepository.existsById(id)) {
            investmentRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
