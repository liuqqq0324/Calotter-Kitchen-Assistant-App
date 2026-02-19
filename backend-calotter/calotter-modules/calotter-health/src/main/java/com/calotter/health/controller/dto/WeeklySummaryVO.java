package com.calotter.health.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 周营养摘要VO
 * 用于 GET /api/nutrition/summary 接口
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklySummaryVO {
    
    private String period; // "week"
    private LocalDate weekStart;
    private LocalDate weekEnd;
    
    // 已消耗的营养值
    private NutritionValues consumed;
    
    // 剩余的营养值
    private NutritionValues remaining;
    
    // 内部类：营养值
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionValues {
        private Integer energy;
        private Double fat;
        private Double carbohydrates;
        private Double protein;
    }
}

