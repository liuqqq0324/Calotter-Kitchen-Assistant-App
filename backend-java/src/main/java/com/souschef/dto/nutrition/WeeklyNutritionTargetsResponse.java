package com.souschef.dto.nutrition;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyNutritionTargetsResponse {
    
    private WeeklyTarget weeklyTarget;
    private Basis basis;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklyTarget {
        private BigDecimal energy;
        private BigDecimal fat;
        private BigDecimal carbohydrates;
        private BigDecimal protein;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Basis {
        private BigDecimal bmi;
        private String goalType;
        private String calculationModel;
        private LocalDate weekStart;
        private LocalDate weekEnd;
    }
}
