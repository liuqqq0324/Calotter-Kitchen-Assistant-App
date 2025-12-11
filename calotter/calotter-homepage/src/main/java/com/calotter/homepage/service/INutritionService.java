package com.calotter.homepage.service;

import com.calotter.homepage.domain.vo.NutritionTargetVo;

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
     * Get weekly nutrition targets for a user
     * 获取用户的周营养目标
     *
     * @param userId User ID
     * @return Weekly nutrition targets response
     */
    WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long userId);

    /**
     * Get weekly nutrition summary (consumed and remaining)
     * 获取周营养摘要（已消费和剩余）
     *
     * @param userId User ID
     * @return Weekly nutrition summary response
     */
    WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long userId);

    /**
     * Weekly Nutrition Targets Response
     */
    class WeeklyNutritionTargetsResponse {
        public WeeklyTarget weeklyTarget;
        public Basis basis;

        public static class WeeklyTarget {
            public BigDecimal energy;
            public BigDecimal fat;
            public BigDecimal carbohydrates;
            public BigDecimal protein;
        }

        public static class Basis {
            public BigDecimal bmi;
            public String goalType;
            public String calculationModel;
            public LocalDate weekStart;
            public LocalDate weekEnd;
        }
    }

    /**
     * Weekly Nutrition Summary Response
     */
    class WeeklyNutritionSummaryResponse {
        public String period;
        public LocalDate weekStart;
        public LocalDate weekEnd;
        public NutritionValues consumed;
        public NutritionValues remaining;

        public static class NutritionValues {
            public BigDecimal energy;
            public BigDecimal fat;
            public BigDecimal carbohydrates;
            public BigDecimal protein;
        }
    }

}
