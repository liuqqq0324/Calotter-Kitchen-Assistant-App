package com.calotter.health.service.ai;

import java.math.BigDecimal;

/**
 * Nutrition Estimate Record
 * 营养估算结果
 *
 * @param energy Energy in kcal
 * @param fat Fat in grams
 * @param carbohydrates Carbohydrates in grams
 * @param protein Protein in grams
 * @param source Source/provider of the estimate (e.g., "groq", "usda")
 *
 * @author Auto Generated
 */
public record NutritionEstimate(
        BigDecimal energy,
        BigDecimal fat,
        BigDecimal carbohydrates,
        BigDecimal protein,
        String source
) {
}

