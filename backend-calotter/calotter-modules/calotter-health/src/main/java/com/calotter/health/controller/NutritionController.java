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
     * 获取周健康报告
     * 
     * @param userId 用户ID
     * @param weekStart 周开始日期（可选，默认为本周一）
     * @return 周报告VO
     */
    @GetMapping("/weekly")
    public Result<WeeklyReportVO> getWeeklyReport(
            @RequestParam Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart) {
        
        // 如果没有指定weekStart，默认使用本周一
        if (weekStart == null) {
            LocalDate today = LocalDate.now();
            weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1); // 本周一
        }
        
        WeeklyReportVO report = aggregateService.getWeeklyReport(userId, weekStart);
        return Result.success(report);
    }

    /**
     * Get Weekly Nutrition Summary
     * GET /api/nutrition/summary?period=week&userId={userId}
     */
    @PostMapping("/log/manual")
    public Result<NutritionLog> createManualLog(@Valid @RequestBody ManualNutritionLogRequest request) {
        NutritionLog log = nutritionLogService.createManual(request);
        return Result.success(log);
    }
    
    /**
     * 从剩菜记录营养摄入
     * 
     * @param leftoverId 剩菜ID
     * @param userId 用户ID
     * @param consumedGram 食用重量（克）
     * @param eatenAt 进食时间（可选，默认为当前时间）
     * @return 创建的营养日志
     */
    @PostMapping("/log/leftover")
    public Result<NutritionLog> createFromLeftover(
            @RequestParam Long leftoverId,
            @RequestParam Long userId,
            @RequestParam Integer consumedGram,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime eatenAt) {
        
        if (eatenAt == null) {
            eatenAt = LocalDateTime.now();
        }
        
        NutritionLog log = nutritionLogService.createFromLeftover(leftoverId, userId, consumedGram, eatenAt);
        return Result.success(log);
    }
}
