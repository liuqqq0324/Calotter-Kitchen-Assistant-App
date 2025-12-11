package com.calotter.homepage.controller;

import com.calotter.common.core.domain.R;
import com.calotter.common.web.core.BaseController;
import com.calotter.homepage.service.INutritionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * Nutrition Controller
 * 营养相关API控制器
 *
 * @author Auto Generated
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/nutrition")
public class NutritionController extends BaseController {

    private final INutritionService nutritionService;

    /**
     * Get Weekly Nutrition Targets
     * GET /api/nutrition/targets/weekly?userId={userId}
     */
    @GetMapping("/targets/weekly")
    public R<INutritionService.WeeklyNutritionTargetsResponse> getWeeklyNutritionTargets(
            @RequestParam("userId") Long userId) {
        try {
            INutritionService.WeeklyNutritionTargetsResponse response = nutritionService.getWeeklyNutritionTargets(userId);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to get weekly nutrition targets: " + e.getMessage());
        }
    }

    /**
     * Get Weekly Nutrition Summary
     * GET /api/nutrition/summary?period=week&userId={userId}
     */
    @GetMapping("/summary")
    public R<INutritionService.WeeklyNutritionSummaryResponse> getWeeklyNutritionSummary(
            @RequestParam(defaultValue = "week") String period,
            @RequestParam("userId") Long userId) {
        try {
            if (!"week".equals(period)) {
                return R.fail("Only 'week' period is currently supported");
            }

            INutritionService.WeeklyNutritionSummaryResponse response = nutritionService.getWeeklyNutritionSummary(userId);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to get weekly nutrition summary: " + e.getMessage());
        }
    }
}
