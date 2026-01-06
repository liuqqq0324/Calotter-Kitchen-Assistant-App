package com.calotter.user.controller.dto;

import com.calotter.user.domain.entity.HealthGoal;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 健康目标请求DTO
 */
@Data
public class HealthGoalRequest {
    
    /**
     * 目标类型
     */
    @NotNull(message = "目标类型不能为空")
    private HealthGoal.GoalType goalType;
    
    /**
     * 活动水平（可选）
     * 1.2 = 久坐（很少运动）
     * 1.375 = 轻度活动（每周1-3次运动）
     * 1.55 = 中度活动（每周3-5次运动）
     * 1.725 = 高度活动（每周6-7次运动）
     * 1.9 = 极高活动（每天高强度运动）
     */
    private Double activityLevel;
}

