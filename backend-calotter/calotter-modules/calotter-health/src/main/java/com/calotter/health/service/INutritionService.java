package com.calotter.health.service;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Nutrition Service Interface
 * 营养相关服务接口
 *
 * @author Auto Generated
 */
public interface INutritionService {

    /**
     * Get weekly nutrition targets for a family member
     * 获取家庭成员的周营养目标
     *
     * @param userId Family Member ID
     * @return Weekly nutrition targets response
     */
    WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long userId);

    /**
     * Get weekly nutrition summary (consumed and remaining)
     * 获取周营养摘要（已消费和剩余）
     *
     * @param userId Family Member ID
     * @return Weekly nutrition summary response
     */
    WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long userId);

    /**
     * Weekly Nutrition Targets Response
     * 周营养目标响应
     */
    @Data
    class WeeklyNutritionTargetsResponse {
        private NutritionTarget weeklyTarget;
        private Basis basis;
    }

    /**
     * Weekly Nutrition Summary Response
     * 周营养摘要响应
     */
    @Data
    class WeeklyNutritionSummaryResponse {
        private String period;
        private LocalDate weekStart;
        private LocalDate weekEnd;
        private Nutrition consumed;
        private Nutrition remaining;
    }

    /**
     * Weekly Target (Nutrition Target)
     * 周营养目标
     */
    @Data
    class NutritionTarget {
        private BigDecimal energy;
        private BigDecimal fat;
        private BigDecimal carbohydrates;
        private BigDecimal protein;
    }

    /**
     * Basis information for nutrition calculation
     * 营养计算的基础信息
     */
    @Data
    class Basis {
        private BigDecimal bmi;
        private String goalType;
        private String calculationModel;
        private LocalDate weekStart;
        private LocalDate weekEnd;
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
}

