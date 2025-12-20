package com.healthcare.dashboard.controllers;

import com.healthcare.dashboard.dto.AIRequest;
import com.healthcare.dashboard.dto.AIResponse;
import com.healthcare.dashboard.services.AIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AIController {
    
    private final AIService aiService;
    
    @PostMapping("/ask")
    public ResponseEntity<AIResponse> ask(@RequestBody AIRequest request) {
        AIResponse response = aiService.askAI(request.getQuestion());
        return ResponseEntity.ok(response);
    }
}
