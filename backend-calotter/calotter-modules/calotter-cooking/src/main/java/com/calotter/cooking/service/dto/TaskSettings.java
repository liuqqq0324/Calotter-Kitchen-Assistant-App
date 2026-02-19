package com.calotter.cooking.service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 任务设置
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskSettings {
    private Integer dishCount;     // 几道菜 (e.g. 1主菜+1配菜)
    private Integer maxTimeMinutes;
    private String difficulty;     // "EASY", "HARD"
    private List<String> targetCuisines; // 本次想吃的菜系 (可选)
}
