package com.calotter.homepage.domain.vo;

import com.calotter.homepage.domain.IntakeRecord;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * hp_intake_record;This table stores user food intake records from recipes or manual input. view object hp_intake_record
 *
 * @author Auto Generated
 */
@Data
@AutoMapper(target = IntakeRecord.class)
public class IntakeRecordVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long userId;
    private LocalDate date;
    private String sourceType;
    private Integer recipeId;
    private String recipeTitle;
    private String manualFoodName;
    private String portionDescription;
    private BigDecimal consumedPercentage;
    private BigDecimal baseEnergy;
    private BigDecimal baseFat;
    private BigDecimal baseCarbohydrates;
    private BigDecimal baseProtein;
    private BigDecimal effectiveEnergy;
    private BigDecimal effectiveFat;
    private BigDecimal effectiveCarbohydrates;
    private BigDecimal effectiveProtein;

}
