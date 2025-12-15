package com.calotter.health.controller;

import com.calotter.common.core.Result;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.controller.dto.WeeklyReportVO;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.NutritionLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 营养管理Controller
 */
@RestController
@RequestMapping("/api/nutrition")
@RequiredArgsConstructor
public class NutritionController {
    
    private final NutritionLogService nutritionLogService;
    private final NutritionAggregateService aggregateService;
    
    /**
     * 获取周健康报告
     * 
     * @param memberId 家庭成员ID
     * @param weekStart 周开始日期（可选，默认为本周一）
     * @return 周报告VO
     */
    @GetMapping("/weekly")
    public Result<WeeklyReportVO> getWeeklyReport(
            @RequestParam Long memberId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart) {
        
        // 如果没有指定weekStart，默认使用本周一
        if (weekStart == null) {
            LocalDate today = LocalDate.now();
            weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1); // 本周一
        }
        
        WeeklyReportVO report = aggregateService.getWeeklyReport(memberId, weekStart);
        return Result.success(report);
    }
    
    /**
     * 手动记录营养摄入
     * 
     * @param request 手动记录请求
     * @return 创建的营养日志
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
     * @param memberId 家庭成员ID
     * @param consumedGram 食用重量（克）
     * @param eatenAt 进食时间（可选，默认为当前时间）
     * @return 创建的营养日志
     */
    @PostMapping("/log/leftover")
    public Result<NutritionLog> createFromLeftover(
            @RequestParam Long leftoverId,
            @RequestParam Long memberId,
            @RequestParam Integer consumedGram,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime eatenAt) {
        
        if (eatenAt == null) {
            eatenAt = LocalDateTime.now();
        }
        
        NutritionLog log = nutritionLogService.createFromLeftover(leftoverId, memberId, consumedGram, eatenAt);
        return Result.success(log);
    }
}

