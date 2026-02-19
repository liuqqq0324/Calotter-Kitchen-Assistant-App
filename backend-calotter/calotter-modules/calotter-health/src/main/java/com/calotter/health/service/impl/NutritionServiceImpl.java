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
        
        // ✅ 修复：处理 Hibernate 可能返回嵌套 Object[] 的情况
        // Hibernate 可能返回：
        // 1. Object[] 包含4个标量值：[energy, fat, carbs, protein] - 正常情况
        // 2. Object[] 包含1个元素，该元素是 Object[]：[Object[]{energy, fat, carbs, protein}] - 嵌套情况
        // 3. Object[] 中的每个元素本身是 Object[]（Hibernate 在某些配置下可能这样返回）
        Object[] actualArray = consumedArray;
        if (consumedArray != null) {
            if (consumedArray.length == 1 && consumedArray[0] instanceof Object[]) {
                // 情况2：展开嵌套数组
                actualArray = (Object[]) consumedArray[0];
            } else if (consumedArray.length > 0 && consumedArray[0] instanceof Object[]) {
                // 情况3：第一个元素是数组，但还有其他元素（异常情况，取第一个元素）
                actualArray = (Object[]) consumedArray[0];
            }
        }
        
        // 安全地将 Object 转换为 BigDecimal
        // 注意：如果 actualArray 中的元素本身是 Object[]，convertToBigDecimal 会递归处理
        // 但需要确保我们传递的是单个元素，而不是整个数组
        Object energyValue = actualArray != null && actualArray.length > 0 ? actualArray[0] : null;
        Object fatValue = actualArray != null && actualArray.length > 1 ? actualArray[1] : null;
        Object carbsValue = actualArray != null && actualArray.length > 2 ? actualArray[2] : null;
        Object proteinValue = actualArray != null && actualArray.length > 3 ? actualArray[3] : null;
        
        BigDecimal consumedEnergy = convertToBigDecimal(energyValue);
        BigDecimal consumedFat = convertToBigDecimal(fatValue);
        BigDecimal consumedCarbs = convertToBigDecimal(carbsValue);
        BigDecimal consumedProtein = convertToBigDecimal(proteinValue);

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
     * 
     * 修复说明：
     * - 处理 Object[] 嵌套情况（Hibernate 查询可能返回嵌套数组）
     * - 如果 value 是 Object[]，递归处理第一个元素
     * - 如果 value 是 List，取第一个元素
     */
    private BigDecimal convertToBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        
        // ✅ 修复：处理 Object[] 嵌套情况（递归处理）
        if (value instanceof Object[]) {
            Object[] array = (Object[]) value;
            if (array.length > 0) {
                // 递归处理第一个元素（可能还是 Object[]）
                return convertToBigDecimal(array[0]);
            } else {
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        }
        
        // 处理 List 类型（Hibernate 有时可能返回 List）
        if (value instanceof java.util.List) {
            java.util.List<?> list = (java.util.List<?>) value;
            if (!list.isEmpty()) {
                return convertToBigDecimal(list.get(0));
            } else {
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        }
        
        // 处理基本数值类型
        if (value instanceof BigDecimal) {
            return ((BigDecimal) value).setScale(2, RoundingMode.HALF_UP);
        } else if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue()).setScale(2, RoundingMode.HALF_UP);
        } else if (value instanceof String) {
            try {
                return new BigDecimal((String) value).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) {
                log.warn("无法将字符串转换为 BigDecimal: {}", value);
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        } else {
            // 如果类型不匹配，尝试转换为字符串再解析
            try {
                String strValue = value.toString().trim();
                if (strValue.isEmpty()) {
                    return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
                }
                return new BigDecimal(strValue).setScale(2, RoundingMode.HALF_UP);
            } catch (NumberFormatException e) {
                log.warn("无法将值转换为 BigDecimal: {}, 类型: {}", value, value.getClass().getName());
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
        }
    }
}
