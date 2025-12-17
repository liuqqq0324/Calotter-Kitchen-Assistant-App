package com.calotter.health.service.impl;

import com.calotter.health.repository.DailyNutrientAggregateRepository;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.INutritionService;
import com.calotter.health.service.INutritionService.Basis;
import com.calotter.health.service.INutritionService.Nutrition;
import com.calotter.health.service.INutritionService.NutritionTarget;
import com.calotter.health.service.INutritionService.WeeklyNutritionSummaryResponse;
import com.calotter.health.service.INutritionService.WeeklyNutritionTargetsResponse;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.service.UserHealthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;

/**
 * Nutrition Service Implementation
 * 营养服务实现类（使用 JPA）
 *
 * BMI 和目标营养数据从 calotter-user 模块的 UserHealthService 获取。
 * 使用 NutritionLogRepository 和 DailyNutrientAggregateRepository 获取实际摄入数据。
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class NutritionServiceImpl implements INutritionService {

    private final UserRepository userRepository;
    private final UserHealthService userHealthService;
    private final NutritionLogRepository nutritionLogRepository;
    private final DailyNutrientAggregateRepository aggregateRepository;

    @Override
    @Transactional(readOnly = true)
    public WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        // 从 calotter-user 模块获取健康信息（BMI 和目标营养）
        UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(userId);

        // 计算周营养目标（从日目标 * 7）
        NutritionTarget weeklyTarget = calculateWeeklyTarget(healthInfo);

        // 构建基础信息（BMI、目标类型等）- BMI 和目标营养都从 calotter-user 获取
        Basis basis = buildBasis(healthInfo, weekStart, weekEnd);

        WeeklyNutritionTargetsResponse response = new WeeklyNutritionTargetsResponse();
        response.setWeeklyTarget(weeklyTarget);
        response.setBasis(basis);

        return response;
    }

    @Override
    @Transactional(readOnly = true)
    public WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        // 从 calotter-user 模块获取健康信息（目标营养）
        UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(userId);

        // 计算周营养目标（从日目标 * 7）
        NutritionTarget weeklyTarget = calculateWeeklyTarget(healthInfo);

        // 获取实际摄入（从 NutritionLog 汇总）
        Object[] consumedArray = nutritionLogRepository.sumNutritionByDateRange(user, weekStart, weekEnd);
        
        BigDecimal consumedEnergy = consumedArray != null && consumedArray[0] != null
                ? BigDecimal.valueOf(((Number) consumedArray[0]).doubleValue()).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        
        BigDecimal consumedFat = consumedArray != null && consumedArray[1] != null
                ? BigDecimal.valueOf(((Number) consumedArray[1]).doubleValue()).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        
        BigDecimal consumedCarbs = consumedArray != null && consumedArray[2] != null
                ? BigDecimal.valueOf(((Number) consumedArray[2]).doubleValue()).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        
        BigDecimal consumedProtein = consumedArray != null && consumedArray[3] != null
                ? BigDecimal.valueOf(((Number) consumedArray[3]).doubleValue()).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

        // 计算剩余
        BigDecimal remainingEnergy = weeklyTarget.getEnergy() != null
                ? weeklyTarget.getEnergy().subtract(consumedEnergy).max(BigDecimal.ZERO)
                : BigDecimal.ZERO;
        BigDecimal remainingFat = weeklyTarget.getFat() != null
                ? weeklyTarget.getFat().subtract(consumedFat).max(BigDecimal.ZERO)
                : BigDecimal.ZERO;
        BigDecimal remainingCarbs = weeklyTarget.getCarbohydrates() != null
                ? weeklyTarget.getCarbohydrates().subtract(consumedCarbs).max(BigDecimal.ZERO)
                : BigDecimal.ZERO;
        BigDecimal remainingProtein = weeklyTarget.getProtein() != null
                ? weeklyTarget.getProtein().subtract(consumedProtein).max(BigDecimal.ZERO)
                : BigDecimal.ZERO;

        WeeklyNutritionSummaryResponse response = new WeeklyNutritionSummaryResponse();
        response.setPeriod("week");
        response.setWeekStart(weekStart);
        response.setWeekEnd(weekEnd);

        Nutrition consumed = new Nutrition();
        consumed.setEnergy(consumedEnergy);
        consumed.setFat(consumedFat);
        consumed.setCarbohydrates(consumedCarbs);
        consumed.setProtein(consumedProtein);
        response.setConsumed(consumed);

        Nutrition remaining = new Nutrition();
        remaining.setEnergy(remainingEnergy);
        remaining.setFat(remainingFat);
        remaining.setCarbohydrates(remainingCarbs);
        remaining.setProtein(remainingProtein);
        response.setRemaining(remaining);

        return response;
    }

    /**
     * 计算周营养目标（从 UserHealthInfo 的日目标 * 7）
     */
    private NutritionTarget calculateWeeklyTarget(UserHealthService.UserHealthInfo healthInfo) {
        NutritionTarget target = new NutritionTarget();
        
        // 日目标 * 7 = 周目标
        target.setEnergy(healthInfo.getDailyEnergy() != null
                ? BigDecimal.valueOf(healthInfo.getDailyEnergy() * 7)
                : BigDecimal.valueOf(14000)); // 默认 2000 kcal/day * 7
        target.setFat(healthInfo.getDailyFat() != null
                ? BigDecimal.valueOf(healthInfo.getDailyFat() * 7)
                : BigDecimal.valueOf(350)); // 默认 50g/day * 7
        target.setCarbohydrates(healthInfo.getDailyCarbohydrates() != null
                ? BigDecimal.valueOf(healthInfo.getDailyCarbohydrates() * 7)
                : BigDecimal.valueOf(1050)); // 默认 150g/day * 7
        target.setProtein(healthInfo.getDailyProtein() != null
                ? BigDecimal.valueOf(healthInfo.getDailyProtein() * 7)
                : BigDecimal.valueOf(490)); // 默认 70g/day * 7
        
        return target;
    }

    /**
     * 构建基础信息（BMI、目标类型等）
     * BMI 和目标营养都从 calotter-user 模块获取
     */
    private Basis buildBasis(UserHealthService.UserHealthInfo healthInfo, LocalDate weekStart, LocalDate weekEnd) {
        Basis basis = new Basis();
        basis.setWeekStart(weekStart);
        basis.setWeekEnd(weekEnd);
        
        // BMI 从 calotter-user 模块获取
        basis.setBmi(healthInfo.getBmi());
        
        // 目标类型从 calotter-user 模块获取
        basis.setGoalType(healthInfo.getGoalType() != null ? healthInfo.getGoalType() : "MAINTENANCE");
        basis.setCalculationModel("health_goal"); // 使用健康目标作为计算模型

        return basis;
    }

    /**
     * 获取周开始日期（周一）
     */
    private LocalDate getWeekStart(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToSubtract = dayOfWeek.getValue() - 1;
        return date.minusDays(daysToSubtract);
    }

    /**
     * 获取周结束日期（周日）
     */
    private LocalDate getWeekEnd(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToAdd = 7 - dayOfWeek.getValue();
        return date.plusDays(daysToAdd);
    }
}
