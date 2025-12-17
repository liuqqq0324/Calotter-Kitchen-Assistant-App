package com.calotter.health.controller;

import com.calotter.common.core.Result;
import com.calotter.health.service.INutritionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Nutrition Controller
 * 营养相关API控制器（从旧版 homepage 迁移）
 *
 * 将旧版逻辑适配到当前模块：使用项目内的 Result 响应格式，保留原有接口形态。
 *
 * GET /api/nutrition/targets/weekly?userId={userId}
 * GET /api/nutrition/summary?period=week&userId={userId}
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/nutrition")
public class NutritionController {

    private final INutritionService nutritionService;

    /**
     * Get Weekly Nutrition Targets
     * GET /api/nutrition/targets/weekly?userId={userId}
     */
    @GetMapping("/targets/weekly")
    public Result<INutritionService.WeeklyNutritionTargetsResponse> getWeeklyNutritionTargets(
            @RequestParam("userId") Long userId) {
        try {
            INutritionService.WeeklyNutritionTargetsResponse response =
                    nutritionService.getWeeklyNutritionTargets(userId);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("Failed to get weekly nutrition targets: " + e.getMessage());
        }
    }

    /**
     * Get Weekly Nutrition Summary
     * GET /api/nutrition/summary?period=week&userId={userId}
     */
    @GetMapping("/summary")
    public Result<INutritionService.WeeklyNutritionSummaryResponse> getWeeklyNutritionSummary(
            @RequestParam(defaultValue = "week") String period,
            @RequestParam("userId") Long userId) {
        try {
            if (!"week".equals(period)) {
                return Result.error("Only 'week' period is currently supported");
            }

            INutritionService.WeeklyNutritionSummaryResponse response =
                    nutritionService.getWeeklyNutritionSummary(userId);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("Failed to get weekly nutrition summary: " + e.getMessage());
        }
    }
}
