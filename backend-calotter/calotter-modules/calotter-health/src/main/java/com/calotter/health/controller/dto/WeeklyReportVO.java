package com.calotter.health.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * 周健康报告VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyReportVO {
    
    private LocalDate weekStart;
    private LocalDate weekEnd;
    
    // 目标值（周目标 = 日目标 * 7）
    private NutritionStats weeklyTarget;
    
    // 实际摄入值（周累计）
    private NutritionStats weeklyActual;
    
    // 每日详情
    private List<DailyReport> dailyReports;
    
    // 内部类：营养统计
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionStats {
        private Integer energy;
        private Double protein;
        private Double fat;
        private Double carbohydrates;
        
        /**
         * 计算达标率（百分比）
         * 
         * @param target 目标值
         * @return 达标率（0-100）
         */
        public Double getEnergyProgress(NutritionStats target) {
            if (target == null || target.energy == null || target.energy == 0) {
                return 0.0;
            }
            if (energy == null) {
                return 0.0;
            }
            return (double) energy / target.energy * 100;
        }
    }
    
    // 内部类：每日报告
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyReport {
        private LocalDate date;
        private NutritionStats target;
        private NutritionStats actual;
    }
}

