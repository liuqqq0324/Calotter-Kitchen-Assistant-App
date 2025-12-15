package com.calotter.health.service;

import com.calotter.health.domain.entity.DailyNutrientAggregate;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.repository.DailyNutrientAggregateRepository;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.FamilyMemberRepository;
import com.calotter.user.repository.HealthGoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 营养聚合服务
 * 负责更新和查询日营养聚合表
 */
@Service
@RequiredArgsConstructor
public class NutritionAggregateService {
    
    private final DailyNutrientAggregateRepository aggregateRepository;
    private final NutritionLogRepository nutritionLogRepository;
    private final FamilyMemberRepository familyMemberRepository;
    private final HealthGoalRepository healthGoalRepository;
    
    /**
     * 更新聚合表（通过事件监听器调用）
     * 
     * @param log 营养日志
     */
    @Transactional
    public void updateAggregate(NutritionLog log) {
        FamilyMember member = log.getFamilyMember();
        LocalDate logDate = log.getLogDate();
        
        // 获取或创建聚合记录
        DailyNutrientAggregate aggregate = aggregateRepository
                .findByFamilyMemberAndDate(member, logDate)
                .orElseGet(() -> {
                    DailyNutrientAggregate newAggregate = new DailyNutrientAggregate();
                    newAggregate.setFamilyMember(member);
                    newAggregate.setDate(logDate);
                    
                    // 快照当天的健康目标（如果存在）
                    HealthGoal goal = healthGoalRepository.findByFamilyMemberAndStatus(member, 1); // 1=ACTIVE
                    if (goal != null) {
                        newAggregate.setGoalCaloriesSnapshot(goal.getDailyCalories());
                        newAggregate.setGoalProteinSnapshot(goal.getProtein());
                        newAggregate.setGoalFatSnapshot(goal.getFat());
                        newAggregate.setGoalCarbSnapshot(goal.getCarb());
                        newAggregate.setGoalFiberSnapshot(goal.getFiber());
                    }
                    
                    return newAggregate;
                });
        
        // 累加营养值
        aggregate.setTotalCalories(
                (aggregate.getTotalCalories() != null ? aggregate.getTotalCalories() : 0) +
                (log.getCalories() != null ? log.getCalories() : 0));
        aggregate.setTotalProtein(
                (aggregate.getTotalProtein() != null ? aggregate.getTotalProtein() : 0.0) +
                (log.getProtein() != null ? log.getProtein() : 0.0));
        aggregate.setTotalFat(
                (aggregate.getTotalFat() != null ? aggregate.getTotalFat() : 0.0) +
                (log.getFat() != null ? log.getFat() : 0.0));
        aggregate.setTotalCarb(
                (aggregate.getTotalCarb() != null ? aggregate.getTotalCarb() : 0.0) +
                (log.getCarb() != null ? log.getCarb() : 0.0));
        aggregate.setTotalFiber(
                (aggregate.getTotalFiber() != null ? aggregate.getTotalFiber() : 0.0) +
                (log.getFiber() != null ? log.getFiber() : 0.0));
        
        aggregateRepository.save(aggregate);
    }
    
    /**
     * 获取周健康报告
     * 
     * @param memberId 家庭成员ID
     * @param weekStart 周开始日期
     * @return 周报告VO
     */
    @Transactional(readOnly = true)
    public com.calotter.health.controller.dto.WeeklyReportVO getWeeklyReport(Long memberId, LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6);
        
        // 1. 获取家庭成员
        FamilyMember member = familyMemberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("家庭成员不存在: " + memberId));
        
        // 2. 获取健康目标
        HealthGoal goal = healthGoalRepository.findByFamilyMemberAndStatus(member, 1); // 1=ACTIVE
        
        // 3. 获取实际摄入（查询聚合表）
        List<DailyNutrientAggregate> actuals = aggregateRepository
                .findByFamilyMemberAndDateBetween(member, weekStart, weekEnd);
        
        // 4. 计算本周总摄入
        com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats totalIntake = 
                com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                        .calories(actuals.stream()
                                .mapToInt(a -> a.getTotalCalories() != null ? a.getTotalCalories() : 0)
                                .sum())
                        .protein(actuals.stream()
                                .mapToDouble(a -> a.getTotalProtein() != null ? a.getTotalProtein() : 0.0)
                                .sum())
                        .fat(actuals.stream()
                                .mapToDouble(a -> a.getTotalFat() != null ? a.getTotalFat() : 0.0)
                                .sum())
                        .carb(actuals.stream()
                                .mapToDouble(a -> a.getTotalCarb() != null ? a.getTotalCarb() : 0.0)
                                .sum())
                        .fiber(actuals.stream()
                                .mapToDouble(a -> a.getTotalFiber() != null ? a.getTotalFiber() : 0.0)
                                .sum())
                        .build();
        
        // 5. 计算本周总目标（日目标 * 7）
        com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats weeklyTarget = null;
        if (goal != null) {
            weeklyTarget = com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                    .calories(goal.getDailyCalories() != null ? goal.getDailyCalories() * 7 : null)
                    .protein(goal.getProtein() != null ? goal.getProtein() * 7.0 : null)
                    .fat(goal.getFat() != null ? goal.getFat() * 7.0 : null)
                    .carb(goal.getCarb() != null ? goal.getCarb() * 7.0 : null)
                    .fiber(goal.getFiber() != null ? goal.getFiber() * 7.0 : null)
                    .build();
        }
        
        // 6. 构建每日详情
        List<com.calotter.health.controller.dto.WeeklyReportVO.DailyReport> dailyReports = new ArrayList<>();
        final HealthGoal finalGoal = goal; // 用于lambda表达式
        for (LocalDate date = weekStart; !date.isAfter(weekEnd); date = date.plusDays(1)) {
            final LocalDate currentDate = date; // 用于lambda表达式
            Optional<DailyNutrientAggregate> aggregateOpt = actuals.stream()
                    .filter(a -> a.getDate().equals(currentDate))
                    .findFirst();
            
            com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats dailyActual = aggregateOpt
                    .map(a -> com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                            .calories(a.getTotalCalories())
                            .protein(a.getTotalProtein())
                            .fat(a.getTotalFat())
                            .carb(a.getTotalCarb())
                            .fiber(a.getTotalFiber())
                            .build())
                    .orElse(com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                            .calories(0)
                            .protein(0.0)
                            .fat(0.0)
                            .carb(0.0)
                            .fiber(0.0)
                            .build());
            
            com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats dailyTarget = null;
            if (finalGoal != null) {
                dailyTarget = com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                        .calories(finalGoal.getDailyCalories())
                        .protein(finalGoal.getProtein() != null ? finalGoal.getProtein().doubleValue() : null)
                        .fat(finalGoal.getFat() != null ? finalGoal.getFat().doubleValue() : null)
                        .carb(finalGoal.getCarb() != null ? finalGoal.getCarb().doubleValue() : null)
                        .fiber(finalGoal.getFiber() != null ? finalGoal.getFiber().doubleValue() : null)
                        .build();
            }
            
            dailyReports.add(com.calotter.health.controller.dto.WeeklyReportVO.DailyReport.builder()
                    .date(currentDate)
                    .target(dailyTarget)
                    .actual(dailyActual)
                    .build());
        }
        
        // 7. 组装返回
        return com.calotter.health.controller.dto.WeeklyReportVO.builder()
                .weekStart(weekStart)
                .weekEnd(weekEnd)
                .weeklyTarget(weeklyTarget)
                .weeklyActual(totalIntake)
                .dailyReports(dailyReports)
                .build();
    }
    
    /**
     * 获取或创建日聚合记录
     * 
     * @param member 家庭成员
     * @param date 日期
     * @return 日聚合记录
     */
    @Transactional
    public DailyNutrientAggregate getOrCreateDailyAggregate(FamilyMember member, LocalDate date) {
        return aggregateRepository.findByFamilyMemberAndDate(member, date)
                .orElseGet(() -> {
                    DailyNutrientAggregate aggregate = new DailyNutrientAggregate();
                    aggregate.setFamilyMember(member);
                    aggregate.setDate(date);
                    
                    // 快照当天的健康目标（如果存在）
                    HealthGoal goal = healthGoalRepository.findByFamilyMemberAndStatus(member, 1);
                    if (goal != null) {
                        aggregate.setGoalCaloriesSnapshot(goal.getDailyCalories());
                        aggregate.setGoalProteinSnapshot(goal.getProtein());
                        aggregate.setGoalFatSnapshot(goal.getFat());
                        aggregate.setGoalCarbSnapshot(goal.getCarb());
                        aggregate.setGoalFiberSnapshot(goal.getFiber());
                    }
                    
                    return aggregateRepository.save(aggregate);
                });
    }
}

