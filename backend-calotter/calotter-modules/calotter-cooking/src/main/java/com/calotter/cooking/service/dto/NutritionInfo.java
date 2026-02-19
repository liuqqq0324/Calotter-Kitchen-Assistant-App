package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 营养信息DTO
 * 用于表示特定重量的营养摄入量
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionInfo {
    /**
     * 卡路里（kcal）
     */
    private Integer calories;
    
    /**
     * 蛋白质（g）
     */
    private Double protein;
    
    /**
     * 脂肪（g）
     */
    private Double fat;
    
    /**
     * 碳水（g）
     */
    private Double carb;
    
    /**
     * 膳食纤维（g）
     */
    private Double fiber;
}

