package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 剩菜详情DTO（包含完整信息）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeftoverDishDetailDTO {
    /**
     * 剩菜ID
     */
    private Long id;
    
    /**
     * 原始Dish ID
     */
    private Long originalDishId;
    
    /**
     * 菜品名称（从Dish获取）
     */
    private String name;
    
    /**
     * 菜品描述（从Dish获取）
     */
    private String description;
    
    /**
     * 封面图（从Dish获取）
     */
    private String coverImage;
    
    /**
     * 当前剩余重量（克）
     */
    private Integer currentQuantityGram;
    
    /**
     * 制作时间
     */
    private LocalDateTime producedTime;
    
    /**
     * 创建时间（审计字段）
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间（审计字段）
     */
    private LocalDateTime updateTime;
    
    // --- 计算的营养信息 ---
    
    /**
     * 当前剩菜的总卡路里（基于currentQuantityGram计算）
     */
    private Integer currentCalories;
    
    /**
     * 每100克的卡路里（从Dish获取）
     */
    private Integer caloriesPer100g;
    
    /**
     * 当前剩菜的总营养信息
     */
    private NutritionInfo currentNutrition;
}

