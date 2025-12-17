package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.AiMenuService;
import com.calotter.cooking.service.FavoriteRecipeService;
import com.calotter.cooking.service.dto.MenuDTO;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 收藏菜谱管理
 */
@RestController
@RequestMapping("/api/recipes")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteRecipeService favoriteRecipeService;
    private final AiMenuService aiMenuService;

    /**
     * 收藏/取消收藏
     */
    @PostMapping("/favorite")
    public Result<Dish> toggleFavorite(@RequestParam("householdId") Long householdId,
                                       @RequestBody MenuDTO.RecipeDTO recipe) {
        return Result.success(favoriteRecipeService.toggleFavorite(householdId, recipe));
    }

    /**
     * 收藏列表
     */
    @GetMapping("/favorites")
    public Result<List<Dish>> listFavorites(@RequestParam("householdId") @NotNull Long householdId) {
        return Result.success(favoriteRecipeService.listFavorites(householdId));
    }

    /**
     * 获取默认 Filter（基于用户的偏好和健康目标）
     */
    @GetMapping("/default-filter")
    public Result<RecipeGenerationFilter> getDefaultFilter(
            @RequestParam("householdId") @NotNull Long householdId) {
        return Result.success(aiMenuService.getDefaultFilter(householdId));
    }
}
