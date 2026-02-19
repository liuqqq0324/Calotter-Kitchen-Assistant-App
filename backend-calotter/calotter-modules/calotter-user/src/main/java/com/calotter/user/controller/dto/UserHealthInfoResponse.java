package com.calotter.user.controller.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 用户健康信息响应DTO
 */
@Data
public class UserHealthInfoResponse {
    
    /**
     * BMI值
     */
    private BigDecimal bmi;
    
    /**
     * 目标类型
     */
    private String goalType;
    
    /**
     * 每日营养目标
     */
    private Integer dailyEnergy;
    private Integer dailyProtein;
    private Integer dailyFat;
    private Integer dailyCarbohydrates;
    private Integer dailyFiber;
}

