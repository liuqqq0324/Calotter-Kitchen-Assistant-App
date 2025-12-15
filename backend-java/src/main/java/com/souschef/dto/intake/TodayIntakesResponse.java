package com.souschef.dto.intake;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TodayIntakesResponse {
    
    private LocalDate date;
    private String source;
    private List<IntakeItem> items;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IntakeItem {
        private Integer intakeId;
        private String sourceType;
        private Integer recipeId;
        private String recipeTitle;
        private String manualFoodName;
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
}
