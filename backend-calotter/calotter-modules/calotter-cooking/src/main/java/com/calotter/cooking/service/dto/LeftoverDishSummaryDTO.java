package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 剩菜摘要DTO（用于列表展示）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeftoverDishSummaryDTO {
    /**
     * 剩菜ID
     */
    private Long id;
    
    /**
     * 菜品名称（从Dish获取）
     */
    private String name;
    
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
     * 每100克的卡路里（从Dish计算）
     */
    private Integer caloriesPer100g;
}

