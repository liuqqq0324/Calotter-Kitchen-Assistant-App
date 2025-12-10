package com.souschef.controller;

import com.souschef.dto.intake.AddManualIntakeRequest;
import com.souschef.dto.intake.AddManualIntakeResponse;
import com.souschef.dto.intake.TodayIntakesResponse;
import com.souschef.dto.intake.UpdateIntakeRequest;
import com.souschef.dto.intake.UpdateIntakeResponse;
import com.souschef.service.IntakeService;
import com.souschef.service.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/intake")
@CrossOrigin(origins = "*")
public class IntakeController {
    
    @Autowired
    private IntakeService intakeService;
    
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
     * Get Today Intakes
     * GET /api/intake/today?source=recipe|manual
     */
    @GetMapping("/today")
    public ResponseEntity<?> getTodayIntakes(
            @RequestParam(required = false, defaultValue = "all") String source,
            HttpServletRequest request) {
        try {
            Long userId = getCurrentUserId(request);
            if (userId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Unauthorized: Invalid or missing token"));
            }
            
            // Validate source parameter
            if (!"all".equals(source) && !"recipe".equals(source) && !"manual".equals(source)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("Invalid source parameter. Must be 'recipe', 'manual', or 'all'"));
            }
            
            TodayIntakesResponse response = intakeService.getTodayIntakes(userId, source);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to get today intakes: " + e.getMessage()));
        }
    }
    
    /**
     * Update Intake Percentage
     * PATCH /api/intake/{intake_id}
     */
    @PatchMapping("/{intake_id}")
    public ResponseEntity<?> updateIntakePercentage(
            @PathVariable("intake_id") Integer intakeId,
            @RequestBody UpdateIntakeRequest request,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            if (userId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Unauthorized: Invalid or missing token"));
            }
            
            if (request.getConsumedPercentage() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("consumed_percentage is required"));
            }
            
            if (request.getConsumedPercentage().compareTo(java.math.BigDecimal.ZERO) < 0 ||
                request.getConsumedPercentage().compareTo(java.math.BigDecimal.valueOf(100)) > 0) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("consumed_percentage must be between 0 and 100"));
            }
            
            UpdateIntakeResponse response = intakeService.updateIntakePercentage(userId, intakeId, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse(e.getMessage()));
            } else if (e.getMessage().contains("Unauthorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse(e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to update intake: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to update intake: " + e.getMessage()));
        }
    }
    
    /**
     * Add Manual Intake
     * POST /api/intake/manual
     */
    @PostMapping("/manual")
    public ResponseEntity<?> addManualIntake(
            @RequestBody AddManualIntakeRequest request,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            if (userId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new ErrorResponse("Unauthorized: Invalid or missing token"));
            }
            
            if (request.getFoodName() == null || request.getFoodName().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("food_name is required"));
            }
            
            AddManualIntakeResponse response = intakeService.addManualIntake(userId, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to add manual intake: " + e.getMessage()));
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
