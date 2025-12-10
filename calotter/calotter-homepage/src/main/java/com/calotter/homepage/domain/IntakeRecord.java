package com.calotter.homepage.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * hp_intake_record;This table stores user food intake records from recipes or manual input. object hp_intake_record
 *
 * @author Auto Generated
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName(value = "hp_intake_record", schema = "sous_chef_hp")
public class IntakeRecord extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Intake record id;Intake record ID (PK)
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * User id;User ID (FK, user_id -> users.user_id)
     */
    private Long userId;

    /**
     * Intake date;Date when the food was consumed
     */
    private LocalDate date;

    /**
     * Source type;Source type: recipe or manual
     */
    private String sourceType;

    /**
     * Recipe id;Recipe ID (FK, recipe_id -> rms_recipe.id), NULL if manual
     */
    private Integer recipeId;

    /**
     * Recipe title;Recipe title for display, NULL if manual
     */
    private String recipeTitle;

    /**
     * Manual food name;Food name for manual intake, NULL if recipe
     */
    private String manualFoodName;

    /**
     * Portion description;Portion description for manual intake (e.g., "1 bowl")
     */
    private String portionDescription;

    /**
     * Consumed percentage;Percentage of food consumed (0-100)
     */
    private BigDecimal consumedPercentage;

    /**
     * Base energy;Base energy in kcal before percentage adjustment
     */
    private BigDecimal baseEnergy;

    /**
     * Base fat;Base fat in grams before percentage adjustment
     */
    private BigDecimal baseFat;

    /**
     * Base carbohydrates;Base carbohydrates in grams before percentage adjustment
     */
    private BigDecimal baseCarbohydrates;

    /**
     * Base protein;Base protein in grams before percentage adjustment
     */
    private BigDecimal baseProtein;

    /**
     * Effective energy;Effective energy after percentage adjustment
     */
    private BigDecimal effectiveEnergy;

    /**
     * Effective fat;Effective fat after percentage adjustment
     */
    private BigDecimal effectiveFat;

    /**
     * Effective carbohydrates;Effective carbohydrates after percentage adjustment
     */
    private BigDecimal effectiveCarbohydrates;

    /**
     * Effective protein;Effective protein after percentage adjustment
     */
    private BigDecimal effectiveProtein;

    /**
     * Calculate effective nutrition values based on consumed percentage
     */
    public void calculateEffectiveNutrition() {
        if (consumedPercentage == null || baseEnergy == null) {
            return;
        }

        BigDecimal percentage = consumedPercentage.divide(BigDecimal.valueOf(100), 4, java.math.RoundingMode.HALF_UP);

        if (baseEnergy != null) {
            this.effectiveEnergy = baseEnergy.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseFat != null) {
            this.effectiveFat = baseFat.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseCarbohydrates != null) {
            this.effectiveCarbohydrates = baseCarbohydrates.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseProtein != null) {
            this.effectiveProtein = baseProtein.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
    }

}
