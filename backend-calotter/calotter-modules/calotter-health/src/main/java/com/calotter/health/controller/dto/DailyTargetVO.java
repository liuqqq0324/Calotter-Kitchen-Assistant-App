package com.calotter.health.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 日营养目标 VO
 * 用于 GET /api/nutrition/targets/daily 接口
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyTargetVO {

    private LocalDate date;
    private NutritionValues dailyTarget;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionValues {
        private Integer energy;
        private Double fat;
        private Double carbohydrates;
        private Double protein;
        private Double fiber;
    }
}


