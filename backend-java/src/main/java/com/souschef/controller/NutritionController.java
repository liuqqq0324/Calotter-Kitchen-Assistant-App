package com.souschef.controller;

import com.souschef.dto.nutrition.WeeklyNutritionSummaryResponse;
import com.souschef.dto.nutrition.WeeklyNutritionTargetsResponse;
import com.souschef.service.JwtService;
import com.souschef.service.NutritionService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/nutrition")
@CrossOrigin(origins = "*")
public class NutritionController {
    
    @Autowired
    private NutritionService nutritionService;
    
    @Autowired
    private JwtService jwtService;
    
    private Long getCurrentUserId(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            return jwtService.extractUserId(token);
        }
        return null;
    }
    
    /**
     * Get Weekly Nutrition Targets
     * GET /api/nutrition/targets/weekly
     */
    @GetMapping("/targets/weekly")
    public ResponseEntity<?> getWeeklyNutritionTargets(HttpServletRequest request) {
        try {
            Long userId = getCurrentUserId(request);
            if (userId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Unauthorized: Invalid or missing token"));
            }
            
            WeeklyNutritionTargetsResponse response = nutritionService.getWeeklyNutritionTargets(userId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to get weekly nutrition targets: " + e.getMessage()));
        }
    }
    
    /**
     * Get Weekly Nutrition Summary
     * GET /api/nutrition/summary?period=week
     */
    @GetMapping("/summary")
    public ResponseEntity<?> getWeeklyNutritionSummary(
            @RequestParam(defaultValue = "week") String period,
            HttpServletRequest request) {
        try {
            Long userId = getCurrentUserId(request);
            if (userId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Unauthorized: Invalid or missing token"));
            }
            
            if (!"week".equals(period)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("Only 'week' period is currently supported"));
            }
            
            WeeklyNutritionSummaryResponse response = nutritionService.getWeeklyNutritionSummary(userId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to get weekly nutrition summary: " + e.getMessage()));
        }
    }
    
    private static class ErrorResponse {
        private String message;
        
        public ErrorResponse(String message) {
            this.message = message;
        }
        
        public String getMessage() {
            return message;
        }
    }
}
