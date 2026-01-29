package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 剩菜响应 DTO
 * 
 * 包含菜品名称、封面图和营养信息（通过 cooking 模块的 LeftoverDishService 获取）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeftoverResponse {
    
    private Long id;
    private Long householdId;
    private Long originalDishId;
    
    // ✅ 菜品信息（从 Dish 获取）
    private String dishName;        // 菜品名称
    private String coverImage;     // 封面图（可选）
    /** 烹饪分类（与 CookingCategory 枚举一致，如 STIR_FRY_PAN_FRY, SOUP 等） */
    private String category;

    // ✅ 剩菜信息
    private Integer currentQuantityGram; // 当前剩余重量（克）
    private LocalDateTime producedTime;  // 制作时间
    
    // ✅ 营养信息（可选，用于前端显示）
    private Integer caloriesPer100g;     // 每100克的卡路里
}
