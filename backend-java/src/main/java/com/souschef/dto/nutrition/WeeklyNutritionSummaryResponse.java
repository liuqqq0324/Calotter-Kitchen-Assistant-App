package com.souschef.dto.nutrition;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyNutritionSummaryResponse {
    
    private String period;
    private LocalDate weekStart;
    private LocalDate weekEnd;
    private NutritionValues consumed;
    private NutritionValues remaining;
    
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
