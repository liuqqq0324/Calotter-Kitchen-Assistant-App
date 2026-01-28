package com.calotter.cooking.controller.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 完成烹饪请求（带最终用料、营养快照）
 * 取代旧版 CookingCompletionRequest（已弃用并移除）：支持部分完成和用餐者信息
 */
@Data
public class FinishCookingRequest {
    @NotNull
    private Long sessionId;

    /**
     * 最终用料列表（可选）
     * 如果不提供，不扣减库存
     */
    private List<FinalIngredient> finalIngredients;

    /**
     * 总营养快照（可选）
     */
    private NutritionSnapshot totalNutrition;

    /**
     * 用餐者信息（可选）
     * 如果提供，可以用于健康模块记录摄入量
     */
    private List<DinerConsumption> diners;

    /**
     * 用餐时间（可选）
     */
    private LocalDateTime consumedAt = LocalDateTime.now();

    /**
     * 每个dish的总质量（可选）
     * 如果提供，后端会更新对应dish的totalWeightGram
     * 可以通过recipeId（recipe的title）或dishId来匹配
     */
    private List<DishTotalWeight> dishTotalWeights;

    @Data
    public static class FinalIngredient {
        private String name;
        private Double amountValue;
        private String amountUnit;
    }

    @Data
    public static class NutritionSnapshot {
        private Double calories;
        private Double protein;
        private Double fat;
        private Double carbs;
    }

    /**
     * 用餐者消费信息
     */
    @Data
    public static class DinerConsumption {
        @NotNull(message = "用户ID不能为空")
        private Long userId;
        
        @DecimalMin(value = "0.0", message = "比例不能小于0")
        @DecimalMax(value = "1.0", message = "比例不能大于1")
        private Double portionPercentage; // 例如 0.25 代表吃了 1/4
        
        private String note;
    }

    /**
     * Dish总质量信息
     */
    @Data
    public static class DishTotalWeight {
        /**
         * Recipe ID（可以是recipe的title，用于匹配dish的name）
         * 如果前端传递的是recipeId（字符串），后端会通过dish的name匹配
         */
        private String recipeId;
        
        /**
         * Dish ID（可选，如果提供则直接使用dishId匹配）
         */
        private Long dishId;
        
        /**
         * 总质量（克）
         */
        @NotNull
        private Integer totalWeightGram;
    }
}
