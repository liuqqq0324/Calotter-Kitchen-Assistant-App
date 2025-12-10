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
     * GET /api/nutrition/targets/weekly
     */
    @GetMapping("/targets/weekly")
    public R<INutritionService.WeeklyNutritionTargetsResponse> getWeeklyNutritionTargets(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            // TODO: 从JWT token中提取userId
            Long userId = extractUserIdFromToken(authHeader);
            if (userId == null) {
                return R.fail("Unauthorized: Invalid or missing token");
            }

            INutritionService.WeeklyNutritionTargetsResponse response = nutritionService.getWeeklyNutritionTargets(userId);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to get weekly nutrition targets: " + e.getMessage());
        }
    }

    /**
     * Get Weekly Nutrition Summary
     * GET /api/nutrition/summary?period=week
     */
    @GetMapping("/summary")
    public R<INutritionService.WeeklyNutritionSummaryResponse> getWeeklyNutritionSummary(
            @RequestParam(defaultValue = "week") String period,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            Long userId = extractUserIdFromToken(authHeader);
            if (userId == null) {
                return R.fail("Unauthorized: Invalid or missing token");
            }

            if (!"week".equals(period)) {
                return R.fail("Only 'week' period is currently supported");
            }

            INutritionService.WeeklyNutritionSummaryResponse response = nutritionService.getWeeklyNutritionSummary(userId);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to get weekly nutrition summary: " + e.getMessage());
        }
    }

    /**
     * Extract user ID from JWT token
     * TODO: 实现JWT token解析逻辑
     */
    private Long extractUserIdFromToken(String authHeader) {
        // TODO: 实现JWT解析
        // 临时返回1用于测试
        return 1L;
    }
}
