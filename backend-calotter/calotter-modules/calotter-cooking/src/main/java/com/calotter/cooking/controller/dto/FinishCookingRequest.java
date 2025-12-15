package com.calotter.cooking.controller.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 完成烹饪请求（带最终用料、营养快照）
 */
@Data
public class FinishCookingRequest {
    @NotNull
    private Long sessionId;

    @NotNull
    private List<FinalIngredient> finalIngredients;

    @NotNull
    private NutritionSnapshot totalNutrition;

    @Data
    public static class FinalIngredient {
        private String name;
        private Double amountValue;
        private String amountUnit;
        private String sourceType; // INVENTORY / MANUAL_ADD
    }

    @Data
    public static class NutritionSnapshot {
        private Double calories;
        private Double protein;
        private Double fat;
        private Double carbs;
    }
}
