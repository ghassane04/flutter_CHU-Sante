package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.ActesByTypeStatsDTO;
import com.healthcare.dashboard.dto.DashboardStatsDTO;
import com.healthcare.dashboard.dto.RevenusByMonthStatsDTO;
import com.healthcare.dashboard.dto.SejoursByServiceStatsDTO;
import com.healthcare.dashboard.services.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class DashboardController {
    
    private final DashboardService dashboardService;
    
    @GetMapping("/stats")
    public ResponseEntity<DashboardStatsDTO> getDashboardStats() {
        return ResponseEntity.ok(dashboardService.getDashboardStats());
    }
    
    @GetMapping("/actes-by-type")
    public ResponseEntity<List<ActesByTypeStatsDTO>> getActesByType() {
        return ResponseEntity.ok(dashboardService.getActesByType());
    }
    
    @GetMapping("/revenus-by-month")
    public ResponseEntity<List<RevenusByMonthStatsDTO>> getRevenusByMonth() {
        return ResponseEntity.ok(dashboardService.getRevenusByMonth());
    }
    
    @GetMapping("/sejours-by-service")
    public ResponseEntity<List<SejoursByServiceStatsDTO>> getSejoursByService() {
        return ResponseEntity.ok(dashboardService.getSejoursByService());
    }
}
