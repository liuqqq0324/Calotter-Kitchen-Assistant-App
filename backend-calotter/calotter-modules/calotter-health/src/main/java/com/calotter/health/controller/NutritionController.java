package com.calotter.health.controller;

import com.calotter.common.core.Result;
import com.calotter.health.controller.dto.DailySummaryVO;
import com.calotter.health.controller.dto.DailyTargetVO;
import com.calotter.health.controller.dto.WeeklyReportVO;
import com.calotter.health.controller.dto.WeeklySummaryVO;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.NutritionLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;

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

    private final NutritionAggregateService aggregateService;
    private final NutritionLogService nutritionLogService;

    /**
     * 获取周健康报告（周营养目标）
     * GET /api/nutrition/targets/weekly?userId={userId}&weekStart={weekStart}
     * 
     * @param userId 用户ID
     * @param weekStart 周开始日期（可选，默认为本周一）
     * @return 周报告VO
     */
    @GetMapping("/targets/weekly")
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
     * 获取周营养摘要
     * GET /api/nutrition/summary?period=week&userId={userId}
     * 
     * @param period 时间段（目前只支持 "week"）
     * @param userId 用户ID
     * @return 周营养摘要VO
     */
    @GetMapping("/summary")
    public Result<WeeklySummaryVO> getWeeklySummary(
            @RequestParam(defaultValue = "week") String period,
            @RequestParam Long userId) {
        
        // 目前只支持周摘要
        if (!"week".equals(period)) {
            return Result.error("目前只支持 period=week");
        }
        
        // 如果没有指定weekStart，默认使用本周一
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1); // 本周一
        
        WeeklySummaryVO summary = aggregateService.getWeeklySummary(userId, weekStart);
        return Result.success(summary);
    }

    /**
     * 获取日营养摘要
     * GET /api/nutrition/summary/daily?userId={userId}&date={YYYY-MM-DD}
     */
    @GetMapping("/summary/daily")
    public Result<DailySummaryVO> getDailySummary(
            @RequestParam Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        LocalDate targetDate = date != null ? date : LocalDate.now();
        DailySummaryVO summary = aggregateService.getDailySummary(userId, targetDate);
        return Result.success(summary);
    }

    /**
     * 获取日营养目标
     * GET /api/nutrition/targets/daily?userId={userId}&date={YYYY-MM-DD}
     */
    @GetMapping("/targets/daily")
    public Result<DailyTargetVO> getDailyTarget(
            @RequestParam Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        LocalDate targetDate = date != null ? date : LocalDate.now();
        DailyTargetVO target = aggregateService.getDailyTarget(userId, targetDate);
        return Result.success(target);
    }

    /**
     * 创建手动营养日志
     * POST /api/nutrition/log/manual
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
