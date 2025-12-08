package com.souschef.dto.recipe;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * 请求体字段与前端/AI prompt 对齐，接受 snake_case。
 */
@Data
public class RecipeGenerateRequest {

    private Integer servings;

    @JsonProperty("generation_settings")
    private GenerationSettings generationSettings;

    @JsonProperty("calorie_target")
    private CalorieTarget calorieTarget;

    private DietPreferences dietPreferences;

    private List<String> cookers;

    private List<String> seasonings;

    private List<InventoryItem> inventory;

    // 为兼容旧字段，保留顶层 dishCount / maxCookingTimeMin / difficultyTarget
    @JsonProperty("dish_count")
    private Integer dishCountLegacy;

    @JsonProperty("max_cooking_time_min")
    private Integer maxCookingTimeMinLegacy;

    @JsonProperty("difficulty_target")
    private String difficultyTargetLegacy;

    @Data
    public static class GenerationSettings {
        @JsonProperty("dish_count")
        private Integer dishCount;

        @JsonProperty("max_cooking_time_min")
        private Integer maxCookingTimeMin;

        @JsonProperty("difficulty_target")
        private String difficultyTarget;
    }

    @Data
    public static class CalorieTarget {
        @JsonProperty("min_total_kcal")
        private Double minTotalKcal;

        @JsonProperty("max_total_kcal")
        private Double maxTotalKcal;
    }

    @Data
    public static class DietPreferences {
        private List<String> allergies;

        @JsonProperty("avoid_ingredients")
        private List<String> avoidIngredients;

        @JsonProperty("cuisine_preferences")
        private List<String> cuisinePreferences;

        @JsonProperty("taste_preferences")
        private List<String> tastePreferences;
    }

    @Data
    public static class InventoryItem {
        private String name;

        @JsonProperty("amount_value")
        private Double amountValue;

        @JsonProperty("amount_unit")
        private String amountUnit; // g/ml/piece

        @JsonProperty("expires_at")
        private String expiresAt;
    }

    // 便捷方法：统一获取 dishCount / maxCookingTime / difficulty
    @JsonIgnore
    public Integer getResolvedDishCount() {
        if (generationSettings != null && generationSettings.getDishCount() != null) {
            return generationSettings.getDishCount();
        }
        return dishCountLegacy;
    }

    @JsonIgnore
    public Integer getResolvedMaxCookingTimeMin() {
        if (generationSettings != null && generationSettings.getMaxCookingTimeMin() != null) {
            return generationSettings.getMaxCookingTimeMin();
        }
        return maxCookingTimeMinLegacy;
    }

    @JsonIgnore
    public String getResolvedDifficultyTarget() {
        if (generationSettings != null && generationSettings.getDifficultyTarget() != null) {
            return generationSettings.getDifficultyTarget();
        }
        return difficultyTargetLegacy;
    }

    /**
        * 取卡路里筛选上限（如果有的话，用 max_total_kcal）
        */
    @JsonIgnore
    public Double getResolvedMaxCalorie() {
        if (calorieTarget != null && calorieTarget.getMaxTotalKcal() != null) {
            return calorieTarget.getMaxTotalKcal();
        }
        return null;
    }
}
