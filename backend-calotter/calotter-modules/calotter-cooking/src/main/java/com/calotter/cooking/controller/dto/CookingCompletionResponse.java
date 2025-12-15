package com.calotter.cooking.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 烹饪完成响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CookingCompletionResponse {
    private Boolean success;
    private Integer logsCreated; // 生成了几条摄入记录
    private Boolean leftoverCreated; // 是否生成了剩菜记录
    private Integer totalCaloriesConsumed; // 本次进食总热量
    private String message;
}

