package com.calotter.cooking.controller.dto;

import lombok.Data;

import java.util.List;

@Data
public class RecipeGenerationFilter {
    /**
     * 即将过期的食材（3天内），必须优先使用
     */
    private List<InventoryItem> urgentInventory;
    
    /**
     * 普通库存食材（3天以上或没有过期日期）
     */
    private List<InventoryItem> regularInventory;
    
    // 保留旧的 inventory 字段以向后兼容（已废弃，建议使用 urgentInventory + regularInventory）
    @Deprecated
    private List<InventoryItem> inventory;
    
    private CalorieTarget calorieTarget;
    private Integer servings;
    private DietPreferences dietPreferences;
    private GenerationSettings generationSettings;
    private List<String> cookers;
    private List<String> seasonings;

    @Data
    public static class InventoryItem {
        private String name;
        private Double amountValue;
        private String amountUnit;
    }

    @Data
    public static class CalorieTarget {
        private Double minTotalKcal;
        private Double maxTotalKcal;
    }

    @Data
    public static class DietPreferences {
        private List<String> cuisinePreferences;
        private List<String> tastePreferences;
        /**
         * 软性"避免食材"（不喜欢吃的具体食材），应当来自标准食材库（StandardIngredient）。
         */
        private List<String> avoidIngredients;
        /**
         * 硬性饮食习惯（如 vegetarian / halal / low_sodium 等），应当来自 PreferenceStandardLibrary.DIET_HABITS_OPTIONS。
         * 与 avoidIngredients 分开存储，便于前端展示与校验。
         */
        private List<String> dietHabits;
        private List<String> allergies;
    }

    @Data
    public static class GenerationSettings {
        private Integer dishCount;
        private Integer maxCookingTimeMin;
        private String difficultyTarget;
    }
}
