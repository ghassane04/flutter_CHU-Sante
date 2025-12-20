package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.entities.Report;
import com.healthcare.dashboard.repositories.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:5173", "http://localhost:5174"})
public class ReportController {
    
    private final ReportRepository reportRepository;
    
    @GetMapping
    public List<Report> getAllReports() {
        return reportRepository.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Report> getReportById(@PathVariable Long id) {
        return reportRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/type/{type}")
    public List<Report> getReportsByType(@PathVariable String type) {
        return reportRepository.findByType(type);
    }
    
    @GetMapping("/periode/{periode}")
    public List<Report> getReportsByPeriode(@PathVariable String periode) {
        return reportRepository.findByPeriode(periode);
    }
    
    @PostMapping
    public Report createReport(@RequestBody Report report) {
        return reportRepository.save(report);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Report> updateReport(@PathVariable Long id, @RequestBody Report report) {
        return reportRepository.findById(id)
                .map(existing -> {
                    report.setId(id);
                    return ResponseEntity.ok(reportRepository.save(report));
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReport(@PathVariable Long id) {
        if (reportRepository.existsById(id)) {
            reportRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
