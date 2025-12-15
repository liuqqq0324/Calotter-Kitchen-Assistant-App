package com.calotter.cooking.controller.dto;

import com.calotter.cooking.service.dto.MenuDTO;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 开始烹饪请求
 */
@Data
public class StartCookingRequest {
    @NotNull
    private Long householdId;
    @NotNull
    private Long initiatorId;

    /**
     * 已有菜品 ID（收藏或历史）
     */
    private Long dishId;

    /**
     * 直接携带菜谱（AI 生成临时的）
     */
    private MenuDTO.RecipeDTO recipe;
}
