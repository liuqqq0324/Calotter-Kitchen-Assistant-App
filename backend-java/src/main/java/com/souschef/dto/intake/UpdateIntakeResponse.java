package com.souschef.dto.intake;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateIntakeResponse {
    
    private IntakeItem intake;
    private WeeklySummary weeklySummary;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IntakeItem {
        private Integer intakeId;
        private String sourceType;
        private Integer recipeId;
        private String recipeTitle;
        private LocalDate date;
        private BigDecimal consumedPercentage;
        private NutritionValues baseNutrition;
        private NutritionValues effectiveNutrition;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionValues {
        private BigDecimal energy;
        private BigDecimal fat;
        private BigDecimal carbohydrates;
        private BigDecimal protein;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeeklySummary {
        private LocalDate weekStart;
        private LocalDate weekEnd;
        private NutritionValues consumed;
    }
}
