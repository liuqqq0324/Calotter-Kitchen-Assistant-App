package com.calotter.health.service.ai;

/**
 * Manual Nutrition Estimator Interface
 * 手动营养估算服务接口
 *
 * @author Auto Generated
 */
public interface ManualNutritionEstimator {

    /**
     * Estimate nutrition values for a food item
     * 估算食物的营养值
     *
     * @param foodName Food name
     * @param portionDescription Portion description (e.g., "1 bowl", "200g")
     * @return Nutrition estimate
     */
    NutritionEstimate estimate(String foodName, String portionDescription);
}

