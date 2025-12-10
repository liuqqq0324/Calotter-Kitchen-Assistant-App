package com.calotter.homepage.mapper;

import com.calotter.homepage.domain.IntakeRecord;
import com.calotter.homepage.domain.vo.IntakeRecordVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * hp_intake_record;This table stores user food intake records from recipes or manual input. mapper interface
 *
 * @author Auto Generated
 */
public interface IntakeRecordMapper extends BaseMapperPlus<IntakeRecord, IntakeRecordVo> {

    /**
     * Find intake records for a user on a specific date
     */
    List<IntakeRecordVo> selectByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * Find intake records for a user on a specific date by source type
     */
    List<IntakeRecordVo> selectByUserIdAndDateAndSourceType(@Param("userId") Long userId, 
                                                              @Param("date") LocalDate date, 
                                                              @Param("sourceType") String sourceType);

    /**
     * Find intake records for a user within a date range
     */
    List<IntakeRecordVo> selectByUserIdAndDateRange(@Param("userId") Long userId,
                                                      @Param("startDate") LocalDate startDate,
                                                      @Param("endDate") LocalDate endDate);

    /**
     * Sum effective nutrition values for a user within a date range
     */
    Map<String, Object> sumEffectiveNutritionByDateRange(@Param("userId") Long userId,
                                                            @Param("startDate") LocalDate startDate,
                                                            @Param("endDate") LocalDate endDate);

}
