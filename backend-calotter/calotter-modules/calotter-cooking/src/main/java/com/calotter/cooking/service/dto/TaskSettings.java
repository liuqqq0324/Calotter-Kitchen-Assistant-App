package com.calotter.cooking.service.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * 任务设置
 */
@Data
@Builder
public class TaskSettings {
    private Integer dishCount;     // 几道菜 (e.g. 1主菜+1配菜)
    private Integer maxTimeMinutes;
    private String difficulty;     // "EASY", "HARD"
    private List<String> targetCuisines; // 本次想吃的菜系 (可选)
}
