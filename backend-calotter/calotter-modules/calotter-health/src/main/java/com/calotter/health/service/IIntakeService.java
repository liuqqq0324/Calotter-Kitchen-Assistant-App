package com.calotter.health.service;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

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
     * @param userId Family Member ID
     * @param source Source type (recipe, manual, all)
     * @return Today intakes response
     */
    TodayIntakesResponse getTodayIntakes(Long userId, String source);

    /**
     * Update intake percentage
     * 更新摄入百分比
     *
     * @param userId Family Member ID
     * @param intakeId Intake record ID
     * @param consumedPercentage New consumed percentage
     * @return Update intake response
     */
    UpdateIntakeResponse updateIntakePercentage(Long userId, Long intakeId, BigDecimal consumedPercentage);

    /**
     * Add manual intake
     * 添加手动摄入
     *
     * @param userId Family Member ID
     * @param date Intake date
     * @param foodName Food name
     * @param portionDescription Portion description
     * @return Add manual intake response
     */
    AddManualIntakeResponse addManualIntake(Long userId, LocalDate date, String foodName, String portionDescription);

    /**
     * Delete an intake record
     * 删除摄入记录（需要校验归属）
     *
     * @param userId Family Member ID
     * @param intakeId Intake record ID
     * @return Delete intake response
     */
    DeleteIntakeResponse deleteIntake(Long userId, Long intakeId);

    /**
     * Get selectable leftover dishes for "Today's Dish Intake"
     * 获取可选的剩菜列表（仅 leftover）
     *
     * @param userId Family Member ID
     * @return dish options response
     */
    DishOptionsResponse getDishOptions(Long userId);

    /**
     * Add a leftover dish intake record
     * 添加剩菜摄入（仅 leftover）
     *
     * @param userId Family Member ID
     * @param request add request
     * @return add response
     */
    AddDishIntakeResponse addDishIntake(Long userId, AddDishIntakeRequest request);

    /**
     * Today Intakes Response
     * 今日摄入响应
     */
    @Data
    class TodayIntakesResponse {
        private LocalDate date;
        private String source;
        private List<IntakeItem> items;
    }

    /**
     * Intake Item
     * 摄入项
     */
    @Data
    class IntakeItem {
        private Long intakeId;
        private String sourceType; // recipe | manual
        private Long leftoverId;
        private String leftoverTitle;
        private String manualFoodName;
        private String portionDescription;
        private BigDecimal consumedPercentage;
        /**
         * For leftover intakes: the maximum consumable percentage of the ORIGINAL leftover (0-100),
         * i.e. how much was available when this intake was created.
         * Example: if a leftover initially had 1000g and at intake creation time it had 360g left,
         * maxConsumablePercentage = 36.0.
         *
         * Frontend can clamp slider max to this value.
         */
        private BigDecimal maxConsumablePercentage;
        private Nutrition baseNutrition;
        private Nutrition effectiveNutrition;
    }

    /**
     * Nutrition Values
     * 营养值
     */
    @Data
    class Nutrition {
        private BigDecimal energy;
        private BigDecimal fat;
        private BigDecimal carbohydrates;
        private BigDecimal protein;
    }

    /**
     * Update Intake Response
     * 更新摄入响应
     */
    @Data
    class UpdateIntakeResponse {
        private UpdateIntakeItem intake;
        private WeeklySummary weeklySummary;
    }

    /**
     * Update Intake Item (with date field)
     * 更新摄入项（包含日期字段）
     */
    @Data
    class UpdateIntakeItem {
        private Long intakeId;
        private String sourceType;
        private Long leftoverId;
        private String leftoverTitle;
        private LocalDate date;
        private BigDecimal consumedPercentage;
        private BigDecimal maxConsumablePercentage;
        private Nutrition baseNutrition;
        private Nutrition effectiveNutrition;
    }

    /**
     * Add Manual Intake Response
     * 添加手动摄入响应
     */
    @Data
    class AddManualIntakeResponse {
        private ManualIntakeItem intake;
        /**
         * All manual foods of the same date (typically "today") after this insertion.
         * Intended for UI "loading box" rendering without an extra fetch.
         * 插入后同一天（通常是"今天"）的所有手动食物列表。
         * 用于 UI "加载框" 渲染，无需额外获取。
         */
        private List<ManualFoodItem> todayManualFoods;
        private WeeklySummary weeklySummary;
    }

    /**
     * Manual Intake Item
     * 手动摄入项
     */
    @Data
    class ManualIntakeItem {
        private Long intakeId;
        private String sourceType;
        private LocalDate date;
        private String manualFoodName;
        private String portionDescription;
        private Nutrition effectiveNutrition;
    }

    /**
     * Manual Food Item
     * 手动食物项
     */
    @Data
    class ManualFoodItem {
        private Long intakeId;
        private LocalDate date;
        private String manualFoodName;
        private String portionDescription;
        private Nutrition effectiveNutrition;
    }

    /**
     * Delete Intake Response
     * 删除摄入响应
     */
    @Data
    class DeleteIntakeResponse {
        private Long deletedIntakeId;
        private LocalDate date;
        private List<ManualFoodItem> todayManualFoods;
        private WeeklySummary weeklySummary;
    }

    /**
     * Dish Options Response (leftovers only)
     */
    @Data
    class DishOptionsResponse {
        private List<DishOption> options;
    }

    /**
     * Dish Option (leftover only)
     */
    @Data
    class DishOption {
        /**
         * Always "leftover"
         */
        private String type;
        /**
         * LeftoverDish ID
         */
        private Long id;
        private String title;
        private String subtitle;
        /**
         * For leftovers: current remaining percentage vs initial (0-100).
         */
        private BigDecimal maxConsumablePercentage;
    }

    /**
     * Add Dish Intake Request (leftover only)
     */
    @Data
    class AddDishIntakeRequest {
        /**
         * Optional. Must be "leftover" if provided.
         */
        private String type;
        /**
         * LeftoverDish ID
         */
        private Long id;
        /**
         * Batch: LeftoverDish IDs
         */
        @JsonDeserialize(contentAs = Long.class)
        private List<Long> ids;
        /**
         * 0-100
         */
        private BigDecimal consumedPercentage;
    }

    /**
     * Add Dish Intake Response (leftover only)
     */
    @Data
    class AddDishIntakeResponse {
        /**
         * Backward compatible: single intake created (when request.id is used).
         * If batch is used, this may be the first created item.
         */
        private IntakeItem intake;
        /**
         * Batch: the intakes created in this request.
         */
        private List<IntakeItem> addedIntakes;
        /**
         * All leftover dish intakes of today after insertion (for quick UI refresh)
         */
        private List<IntakeItem> todayDishIntakes;
        private WeeklySummary weeklySummary;
    }

    /**
     * Weekly Summary
     * 周汇总
     */
    @Data
    class WeeklySummary {
        private LocalDate weekStart;
        private LocalDate weekEnd;
        private Nutrition consumed;
    }
}

