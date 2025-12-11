package com.calotter.homepage.service;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Intake Service Interface
 * 摄入记录管理服务接口
 *
 * @author Auto Generated
 */
public interface IIntakeService {

    /**
     * Get today's intake records by source type
     * 获取今日摄入记录
     *
     * @param userId User ID
     * @param source Source type (recipe, manual, all)
     * @return Today intakes response
     */
    TodayIntakesResponse getTodayIntakes(Long userId, String source);

    /**
     * Update intake percentage
     * 更新摄入百分比
     *
     * @param userId User ID
     * @param intakeId Intake record ID
     * @param consumedPercentage New consumed percentage
     * @return Update intake response
     */
    UpdateIntakeResponse updateIntakePercentage(Long userId, Long intakeId, BigDecimal consumedPercentage);

    /**
     * Add manual intake
     * 添加手动摄入
     *
     * @param userId User ID
     * @param date Intake date
     * @param foodName Food name
     * @param portionDescription Portion description
     * @return Add manual intake response
     */
    AddManualIntakeResponse addManualIntake(Long userId, LocalDate date, String foodName, String portionDescription);

    /**
     * Today Intakes Response
     */
    class TodayIntakesResponse {
        public LocalDate date;
        public String source;
        public java.util.List<IntakeItem> items;

        public static class IntakeItem {
            public Long intakeId;
            public String sourceType;
            public Integer recipeId;
            public String recipeTitle;
            public String manualFoodName;
            public BigDecimal consumedPercentage;
            public NutritionValues baseNutrition;
            public NutritionValues effectiveNutrition;
        }

        public static class NutritionValues {
            public BigDecimal energy;
            public BigDecimal fat;
            public BigDecimal carbohydrates;
            public BigDecimal protein;
        }
    }

    /**
     * Update Intake Response
     */
    class UpdateIntakeResponse {
        public IntakeItem intake;
        public WeeklySummary weeklySummary;

        public static class IntakeItem {
            public Long intakeId;
            public String sourceType;
            public Integer recipeId;
            public String recipeTitle;
            public LocalDate date;
            public BigDecimal consumedPercentage;
            public NutritionValues baseNutrition;
            public NutritionValues effectiveNutrition;
        }

        public static class NutritionValues {
            public BigDecimal energy;
            public BigDecimal fat;
            public BigDecimal carbohydrates;
            public BigDecimal protein;
        }

        public static class WeeklySummary {
            public LocalDate weekStart;
            public LocalDate weekEnd;
            public NutritionValues consumed;
        }
    }

    /**
     * Add Manual Intake Response
     */
    class AddManualIntakeResponse {
        public IntakeItem intake;
        public WeeklySummary weeklySummary;

        public static class IntakeItem {
            public Long intakeId;
            public String sourceType;
            public LocalDate date;
            public String manualFoodName;
            public String portionDescription;
            public NutritionValues effectiveNutrition;
        }

        public static class NutritionValues {
            public BigDecimal energy;
            public BigDecimal fat;
            public BigDecimal carbohydrates;
            public BigDecimal protein;
        }

        public static class WeeklySummary {
            public LocalDate weekStart;
            public LocalDate weekEnd;
            public NutritionValues consumed;
        }
    }

}
