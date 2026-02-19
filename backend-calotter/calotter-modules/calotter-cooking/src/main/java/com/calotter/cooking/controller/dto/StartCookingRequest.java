package com.calotter.cooking.controller.dto;

import com.calotter.cooking.service.dto.MenuDTO;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

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
     * 已有菜品 ID（收藏或历史）- 向后兼容
     */
    private Long dishId;

    /**
     * 直接携带菜谱（AI 生成临时的）- 向后兼容
     */
    private MenuDTO.RecipeDTO recipe;

    /**
     * 整个 Menu 的菜品列表（支持多道菜）
     */
    private List<MenuDTO.RecipeDTO> recipes;

    /**
     * Menu ID（可选，用于标识）
     */
    private Integer menuId;
}
