package com.calotter.homepage.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * hp_nutrition_target;This table stores weekly nutrition targets for users. object hp_nutrition_target
 *
 * @author Auto Generated
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName(value = "hp_nutrition_target", schema = "sous_chef_hp")
public class NutritionTarget extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Nutrition target id;Nutrition target ID (PK)
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * User id;User ID (FK, user_id -> users.user_id)
     */
    private Long userId;

    /**
     * Week start date;Start date of the week (Monday)
     */
    private LocalDate weekStart;

    /**
     * Week end date;End date of the week (Sunday)
     */
    private LocalDate weekEnd;

    /**
     * Weekly target energy;Weekly target energy in kcal
     */
    private BigDecimal weeklyTargetEnergy;

    /**
     * Weekly target fat;Weekly target fat in grams
     */
    private BigDecimal weeklyTargetFat;

    /**
     * Weekly target carbohydrates;Weekly target carbohydrates in grams
     */
    private BigDecimal weeklyTargetCarbohydrates;

    /**
     * Weekly target protein;Weekly target protein in grams
     */
    private BigDecimal weeklyTargetProtein;

    /**
     * BMI value;Body Mass Index used for calculation
     */
    private BigDecimal bmi;

    /**
     * Goal type;User goal type (fat_loss, muscle_gain, maintain, etc.)
     */
    private String goalType;

    /**
     * Calculation model;Nutrition calculation model (mifflin_st_jeor, harris_benedict, etc.)
     */
    private String calculationModel;

}
