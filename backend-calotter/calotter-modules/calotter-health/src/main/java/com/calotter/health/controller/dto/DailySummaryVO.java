package com.calotter.health.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 日营养摘要 VO
 * 用于 GET /api/nutrition/summary/daily 接口
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailySummaryVO {

    private String period; // "day"
    private LocalDate date;

    // 已消耗的营养值
    private NutritionValues consumed;

    // 剩余的营养值（目标 - 已消耗，不能为负数）
    private NutritionValues remaining;

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


