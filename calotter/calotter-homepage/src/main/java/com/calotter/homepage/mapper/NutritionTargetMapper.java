package com.calotter.homepage.mapper;

import com.calotter.homepage.domain.NutritionTarget;
import com.calotter.homepage.domain.vo.NutritionTargetVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.Optional;

/**
 * hp_nutrition_target;This table stores weekly nutrition targets for users. mapper interface
 *
 * @author Auto Generated
 */
public interface NutritionTargetMapper extends BaseMapperPlus<NutritionTarget, NutritionTargetVo> {

    /**
     * Find nutrition target for a user in a specific week
     */
    NutritionTargetVo selectByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * Find nutrition target for a user by week start date
     */
    NutritionTargetVo selectByUserIdAndWeekStart(@Param("userId") Long userId, @Param("weekStart") LocalDate weekStart);

}
