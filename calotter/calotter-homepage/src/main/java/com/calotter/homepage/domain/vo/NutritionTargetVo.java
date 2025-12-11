package com.calotter.homepage.domain.vo;

import com.calotter.homepage.domain.NutritionTarget;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * hp_nutrition_target;This table stores weekly nutrition targets for users. view object hp_nutrition_target
 *
 * @author Auto Generated
 */
@Data
@AutoMapper(target = NutritionTarget.class)
public class NutritionTargetVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long userId;
    private LocalDate weekStart;
    private LocalDate weekEnd;
    private BigDecimal weeklyTargetEnergy;
    private BigDecimal weeklyTargetFat;
    private BigDecimal weeklyTargetCarbohydrates;
    private BigDecimal weeklyTargetProtein;
    private BigDecimal bmi;
    private String goalType;
    private String calculationModel;

}
