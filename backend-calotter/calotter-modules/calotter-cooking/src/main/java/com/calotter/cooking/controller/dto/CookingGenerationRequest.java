package com.calotter.cooking.controller.dto;

import lombok.Data;

import java.util.List;

/**
 * 烹饪生成请求
 */
@Data
public class CookingGenerationRequest {
    private List<Long> userIds;  // 用户ID列表
    private List<GuestInfo> guests; // 客人信息（可选）
    private Integer dishCount;      // 几道菜
    private Integer maxTimeMinutes; // 最大时间（分钟）
    private String difficulty;      // 难度
    private List<String> targetCuisines; // 目标菜系

    @Data
    public static class GuestInfo {
        private String name;
        private List<String> allergies;
        private java.util.Map<String, List<String>> preferences;
    }
}
