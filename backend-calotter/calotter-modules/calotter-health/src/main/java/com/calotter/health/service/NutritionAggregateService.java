package com.calotter.health.service;

import com.calotter.health.domain.entity.DailyNutrientAggregate;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.repository.DailyNutrientAggregateRepository;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.service.UserHealthService;
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
    private final UserRepository userRepository;
    private final UserHealthService userHealthService;
    
    /**
     * 更新聚合表（通过事件监听器调用）
     * 
     * @param log 营养日志
     */
    @Transactional
    public void updateAggregate(NutritionLog log) {
        User user = log.getUser();
        LocalDate logDate = log.getLogDate();
        
        // 获取或创建聚合记录
        DailyNutrientAggregate aggregate = aggregateRepository
                .findByUserAndDate(user, logDate)
                .orElseGet(() -> {
                    DailyNutrientAggregate newAggregate = new DailyNutrientAggregate();
                    newAggregate.setUser(user);
                    newAggregate.setDate(logDate);
                    
                    // 快照当天的健康目标（从 calotter-user 模块获取）
                    UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(user.getId());
                    if (healthInfo.getDailyEnergy() != null) {
                        newAggregate.setGoalEnergySnapshot(healthInfo.getDailyEnergy());
                        newAggregate.setGoalProteinSnapshot(healthInfo.getDailyProtein());
                        newAggregate.setGoalFatSnapshot(healthInfo.getDailyFat());
                        newAggregate.setGoalCarbohydratesSnapshot(healthInfo.getDailyCarbohydrates());
                        newAggregate.setGoalFiberSnapshot(healthInfo.getDailyFiber());
                    }
                    
                    return newAggregate;
                });
        
        // 累加营养值
        aggregate.setTotalEnergy(
                (aggregate.getTotalEnergy() != null ? aggregate.getTotalEnergy() : 0) +
                (log.getEnergy() != null ? log.getEnergy() : 0));
        aggregate.setTotalProtein(
                (aggregate.getTotalProtein() != null ? aggregate.getTotalProtein() : 0.0) +
                (log.getProtein() != null ? log.getProtein() : 0.0));
        aggregate.setTotalFat(
                (aggregate.getTotalFat() != null ? aggregate.getTotalFat() : 0.0) +
                (log.getFat() != null ? log.getFat() : 0.0));
        aggregate.setTotalCarbohydrates(
                (aggregate.getTotalCarbohydrates() != null ? aggregate.getTotalCarbohydrates() : 0.0) +
                (log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0));
        aggregate.setTotalFiber(
                (aggregate.getTotalFiber() != null ? aggregate.getTotalFiber() : 0.0) +
                (log.getFiber() != null ? log.getFiber() : 0.0));
        
        aggregateRepository.save(aggregate);
    }
    
    /**
     * 获取周健康报告
     * 
     * @param userId 用户ID
     * @param weekStart 周开始日期
     * @return 周报告VO
     */
    @Transactional(readOnly = true)
    public com.calotter.health.controller.dto.WeeklyReportVO getWeeklyReport(Long userId, LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6);
        
        // 1. 获取用户
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));
        
        // 2. 从 calotter-user 模块获取健康目标
        UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(userId);
        
        // 3. 获取实际摄入（查询聚合表）
        List<DailyNutrientAggregate> actuals = aggregateRepository
                .findByUserAndDateBetween(user, weekStart, weekEnd);
        
        // 4. 计算本周总摄入
        com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats totalIntake =
                com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                        // DTO统一为 energy/carbohydrates，实体字段也已统一
                        .energy(actuals.stream()
                                .mapToInt(a -> a.getTotalEnergy() != null ? a.getTotalEnergy() : 0)
                                .sum())
                        .protein(actuals.stream()
                                .mapToDouble(a -> a.getTotalProtein() != null ? a.getTotalProtein() : 0.0)
                                .sum())
                        .fat(actuals.stream()
                                .mapToDouble(a -> a.getTotalFat() != null ? a.getTotalFat() : 0.0)
                                .sum())
                        .carbohydrates(actuals.stream()
                                .mapToDouble(a -> a.getTotalCarbohydrates() != null ? a.getTotalCarbohydrates() : 0.0)
                                .sum())
                        .build();
        
        // 5. 计算本周总目标（日目标 * 7）
        com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats weeklyTarget = null;
        if (healthInfo.getDailyEnergy() != null) {
            weeklyTarget = com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                    .energy(healthInfo.getDailyEnergy() * 7)
                    .protein(healthInfo.getDailyProtein() != null ? healthInfo.getDailyProtein() * 7.0 : null)
                    .fat(healthInfo.getDailyFat() != null ? healthInfo.getDailyFat() * 7.0 : null)
                    .carbohydrates(healthInfo.getDailyCarbohydrates() != null ? healthInfo.getDailyCarbohydrates() * 7.0 : null)
                    .build();
        }
        
        // 6. 构建每日详情
        List<com.calotter.health.controller.dto.WeeklyReportVO.DailyReport> dailyReports = new ArrayList<>();
        final UserHealthService.UserHealthInfo finalHealthInfo = healthInfo; // 用于lambda表达式
        for (LocalDate date = weekStart; !date.isAfter(weekEnd); date = date.plusDays(1)) {
            final LocalDate currentDate = date; // 用于lambda表达式
            Optional<DailyNutrientAggregate> aggregateOpt = actuals.stream()
                    .filter(a -> a.getDate().equals(currentDate))
                    .findFirst();
            
            com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats dailyActual = aggregateOpt
                    .map(a -> com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                            .energy(a.getTotalEnergy())
                            .protein(a.getTotalProtein())
                            .fat(a.getTotalFat())
                            .carbohydrates(a.getTotalCarbohydrates())
                            .build())
                    .orElse(com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                            .energy(0)
                            .protein(0.0)
                            .fat(0.0)
                            .carbohydrates(0.0)
                            .build());
            
                  com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats dailyTarget = null;
                  if (finalHealthInfo.getDailyEnergy() != null) {
                      dailyTarget = com.calotter.health.controller.dto.WeeklyReportVO.NutritionStats.builder()
                              .energy(finalHealthInfo.getDailyEnergy())
                              .protein(finalHealthInfo.getDailyProtein() != null ? finalHealthInfo.getDailyProtein().doubleValue() : null)
                              .fat(finalHealthInfo.getDailyFat() != null ? finalHealthInfo.getDailyFat().doubleValue() : null)
                              .carbohydrates(finalHealthInfo.getDailyCarbohydrates() != null ? finalHealthInfo.getDailyCarbohydrates().doubleValue() : null)
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
     * @param user 用户
     * @param date 日期
     * @return 日聚合记录
     */
    @Transactional
    public DailyNutrientAggregate getOrCreateDailyAggregate(User user, LocalDate date) {
        return aggregateRepository.findByUserAndDate(user, date)
                .orElseGet(() -> {
                    DailyNutrientAggregate aggregate = new DailyNutrientAggregate();
                    aggregate.setUser(user);
                    aggregate.setDate(date);
                    
                    // 快照当天的健康目标（从 calotter-user 模块获取）
                    UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(user.getId());
                    if (healthInfo.getDailyEnergy() != null) {
                        aggregate.setGoalEnergySnapshot(healthInfo.getDailyEnergy());
                        aggregate.setGoalProteinSnapshot(healthInfo.getDailyProtein());
                        aggregate.setGoalFatSnapshot(healthInfo.getDailyFat());
                        aggregate.setGoalCarbohydratesSnapshot(healthInfo.getDailyCarbohydrates());
                        aggregate.setGoalFiberSnapshot(healthInfo.getDailyFiber());
                    }
                    
                    return aggregateRepository.save(aggregate);
                });
    }
}

