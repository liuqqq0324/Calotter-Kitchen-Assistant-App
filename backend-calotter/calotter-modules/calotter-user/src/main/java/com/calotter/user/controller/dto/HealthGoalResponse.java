package com.calotter.user.controller.dto;

import com.calotter.user.domain.entity.HealthGoal;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 健康目标响应DTO
 */
@Data
public class HealthGoalResponse {
    
    private Long id;
    private HealthGoal.GoalType goalType;
    private Double activityLevel;
    private BigDecimal startWeight;
    private Integer height;
    private Integer age;
    
    // 营养目标（AI建议）
    private Integer dailyCalories;
    private Integer protein;
    private Integer fat;
    private Integer carb;
    private Integer fiber;
}

