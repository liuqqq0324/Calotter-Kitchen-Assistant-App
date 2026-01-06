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
        
        // 安全地将 Object 转换为 BigDecimal
        BigDecimal consumedEnergy = convertToBigDecimal(consumedArray != null && consumedArray.length > 0 ? consumedArray[0] : null);
        BigDecimal consumedFat = convertToBigDecimal(consumedArray != null && consumedArray.length > 1 ? consumedArray[1] : null);
        BigDecimal consumedCarbs = convertToBigDecimal(consumedArray != null && consumedArray.length > 2 ? consumedArray[2] : null);
        BigDecimal consumedProtein = convertToBigDecimal(consumedArray != null && consumedArray.length > 3 ? consumedArray[3] : null);

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

    /**
     * 安全地将 Object 转换为 BigDecimal
     * 支持 Number、BigDecimal、Integer、Double、Long 等类型
     */
    private BigDecimal convertToBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        
        if (value instanceof BigDecimal) {
            return ((BigDecimal) value).setScale(2, RoundingMode.HALF_UP);
        } else if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue()).setScale(2, RoundingMode.HALF_UP);
        } else if (value instanceof String) {
            try {
                return new BigDecimal((String) value).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) {
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        } else {
            // 如果类型不匹配，尝试转换为字符串再解析
            try {
                return new BigDecimal(value.toString()).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) {
                log.warn("无法将值转换为 BigDecimal: {}, 类型: {}", value, value.getClass().getName());
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        }
    }
}
