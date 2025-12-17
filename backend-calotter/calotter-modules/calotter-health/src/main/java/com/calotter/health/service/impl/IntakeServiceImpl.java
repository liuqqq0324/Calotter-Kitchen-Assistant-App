package com.calotter.health.service.impl;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.IIntakeService;
import com.calotter.health.service.IIntakeService.AddManualIntakeResponse;
import com.calotter.health.service.IIntakeService.DeleteIntakeResponse;
import com.calotter.health.service.IIntakeService.IntakeItem;
import com.calotter.health.service.IIntakeService.ManualFoodItem;
import com.calotter.health.service.IIntakeService.ManualIntakeItem;
import com.calotter.health.service.IIntakeService.Nutrition;
import com.calotter.health.service.IIntakeService.TodayIntakesResponse;
import com.calotter.health.service.IIntakeService.UpdateIntakeItem;
import com.calotter.health.service.IIntakeService.UpdateIntakeResponse;
import com.calotter.health.service.IIntakeService.WeeklySummary;
import com.calotter.health.service.INutritionService;
import com.calotter.health.service.NutritionLogService;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import com.calotter.health.service.ai.NutritionEstimate;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.FamilyMemberRepository;
import com.calotter.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Intake Service Implementation
 * 摄入记录管理服务实现类（使用 JPA）
 *
 * 注意：NutritionLog 实体存储的是实际摄入的绝对值，不包含 consumedPercentage。
 * 为了兼容旧版 API，我们假设所有记录都是 100% 摄入。
 * 如果需要支持百分比调整，后续可以在 NutritionLog 中添加 consumedPercentage 字段。
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class IntakeServiceImpl implements IIntakeService {

    private final NutritionLogRepository nutritionLogRepository;
    private final UserRepository userRepository;
    private final FamilyMemberRepository familyMemberRepository;
    private final CookingSessionRepository cookingSessionRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final DishRepository dishRepository;
    private final NutritionLogService nutritionLogService;
    private final INutritionService nutritionService;
    private final ObjectProvider<ManualNutritionEstimator> manualNutritionEstimatorProvider;

    @Override
    @Transactional(readOnly = true)
    public TodayIntakesResponse getTodayIntakes(Long userId, String source) {
        LocalDate today = LocalDate.now();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        List<IntakeItem> items;
        
        if ("recipe".equals(source)) {
            // 从 calotter-inventory 模块获取当天做好的菜信息
            items = getTodayRecipesFromInventory(user, today);
        } else if ("manual".equals(source)) {
            // 手动输入的食物，从 NutritionLog 查询
            List<NutritionLog> logs = nutritionLogRepository.findByUserAndLogDateAndSourceType(
                    user, today, LogSourceType.MANUAL);
            items = logs.stream()
                    .map(this::convertToIntakeItem)
                    .collect(Collectors.toList());
        } else {
            // 所有来源，从 NutritionLog 查询
            List<NutritionLog> logs = nutritionLogRepository.findByUserAndLogDate(user, today);
            items = logs.stream()
                    .map(this::convertToIntakeItem)
                    .collect(Collectors.toList());
        }

        TodayIntakesResponse response = new TodayIntakesResponse();
        response.setDate(today);
        response.setSource(source);
        response.setItems(items);
        return response;
    }
    
    /**
     * 从 calotter-inventory 模块获取当天做好的菜信息
     * 通过 LeftoverDish 的 producedTime 查询当天产生的剩菜，然后获取对应的 Dish 信息
     * 注意：这里从 inventory 模块获取，但实际上 LeftoverDish 是剩菜，不是完整的菜
     * 如果需要获取完整的菜，应该从 CookingSession 查询当天完成的烹饪会话
     */
    private List<IntakeItem> getTodayRecipesFromInventory(User user, LocalDate today) {
        // 1. 获取用户的 Household（通过 User -> FamilyMember -> Household）
        Optional<FamilyMember> familyMemberOpt = familyMemberRepository.findAll().stream()
                .filter(member -> member.getUser() != null && 
                        member.getUser().getId().equals(user.getId()))
                .findFirst();
        
        if (familyMemberOpt.isEmpty()) {
            log.warn("无法找到用户的家庭成员信息，用户 ID: {}", user.getId());
            return Collections.emptyList();
        }
        
        Household household = familyMemberOpt.get().getHousehold();
        if (household == null) {
            log.warn("家庭成员没有关联的家庭，用户 ID: {}", user.getId());
            return Collections.emptyList();
        }
        
        // 2. 查询当天完成的 CookingSession（status = COOKED，updateTime 是当天的）
        // 注意：CookingSession 在 calotter-cooking 模块，但用户要求从 inventory 模块获取
        // 这里我们通过 LeftoverDish 间接获取，因为 LeftoverDish 的 producedTime 记录了菜的制作时间
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();
        
        // 方案1：从 LeftoverDish 获取（inventory 模块）
        List<LeftoverDish> todayLeftovers = leftoverDishRepository
                .findByHouseholdIdAndProducedTimeBetween(household.getId(), startOfDay, endOfDay);
        
        // 方案2：从 CookingSession 获取（cooking 模块）- 更准确，因为这是完整的菜
        // 查询当天完成的烹饪会话
        List<CookingSession> todaySessions = cookingSessionRepository.findByHouseholdId(household.getId())
                .stream()
                .filter(session -> session.getStatus() == CookingSession.SessionStatus.COOKED)
                .filter(session -> {
                    LocalDateTime updateTime = session.getUpdateTime();
                    return updateTime != null && 
                           !updateTime.toLocalDate().isBefore(today) && 
                           !updateTime.toLocalDate().isAfter(today);
                })
                .filter(session -> session.getFinalDish() != null)
                .collect(Collectors.toList());
        
        if (todaySessions.isEmpty() && todayLeftovers.isEmpty()) {
            log.debug("当天没有完成的烹饪会话或产生的剩菜，用户 ID: {}, 日期: {}", user.getId(), today);
            return Collections.emptyList();
        }
        
        // 3. 优先使用 CookingSession（完整的菜），如果没有则使用 LeftoverDish（剩菜）
        List<IntakeItem> items = new java.util.ArrayList<>();
        
        if (!todaySessions.isEmpty()) {
            // 从 CookingSession 获取完整的菜信息
            Set<Long> dishIds = todaySessions.stream()
                    .map(session -> session.getFinalDish().getId())
                    .collect(Collectors.toSet());
            
            Map<Long, Dish> dishMap = dishRepository.findAllById(dishIds).stream()
                    .collect(Collectors.toMap(Dish::getId, dish -> dish));
            
            // 查找对应的 NutritionLog 以获取 consumedPercentage
            List<NutritionLog> todayLogs = nutritionLogRepository.findByUserAndLogDateAndSourceType(
                    user, today, LogSourceType.APP_COOKING);
            Map<Long, NutritionLog> logMap = todayLogs.stream()
                    .filter(log -> log.getDishId() != null)
                    .collect(Collectors.toMap(NutritionLog::getDishId, log -> log, (existing, replacement) -> existing));
            
            // 转换为 IntakeItem
            for (CookingSession session : todaySessions) {
                Dish dish = dishMap.get(session.getFinalDish().getId());
                if (dish != null) {
                    IntakeItem item = convertCookingSessionToIntakeItem(session, dish, logMap.get(dish.getId()));
                    items.add(item);
                }
            }
        } else if (!todayLeftovers.isEmpty()) {
            // 从 LeftoverDish 获取剩菜信息（作为备选方案）
            Set<Long> dishIds = todayLeftovers.stream()
                    .map(LeftoverDish::getOriginalDishId)
                    .collect(Collectors.toSet());
            
            Map<Long, Dish> dishMap = dishRepository.findAllById(dishIds).stream()
                    .collect(Collectors.toMap(Dish::getId, dish -> dish));
            
            // 转换为 IntakeItem（去重）
            Map<Long, IntakeItem> itemMap = todayLeftovers.stream()
                    .filter(leftover -> dishMap.containsKey(leftover.getOriginalDishId()))
                    .collect(Collectors.toMap(
                            LeftoverDish::getOriginalDishId,
                            leftover -> convertLeftoverToIntakeItem(leftover, dishMap.get(leftover.getOriginalDishId())),
                            (existing, replacement) -> existing
                    ));
            
            items.addAll(itemMap.values());
        }
        
        return items;
    }
    
    /**
     * 将 CookingSession 转换为 IntakeItem
     */
    private IntakeItem convertCookingSessionToIntakeItem(CookingSession session, Dish dish, NutritionLog nutritionLog) {
        IntakeItem item = new IntakeItem();
        
        // 如果有对应的 NutritionLog，使用其 intakeId 和 consumedPercentage
        if (nutritionLog != null) {
            item.setIntakeId(nutritionLog.getId());
            item.setConsumedPercentage(nutritionLog.getConsumedPercentage() != null ? 
                    nutritionLog.getConsumedPercentage() : BigDecimal.valueOf(100.0));
        } else {
            item.setIntakeId(null);
            item.setConsumedPercentage(BigDecimal.valueOf(100.0)); // 默认100%
        }
        
        item.setSourceType("recipe");
        item.setRecipeId(dish.getId());
        item.setRecipeTitle(dish.getName());
        
        // baseNutrition: Dish 的100%营养值
        Nutrition baseNutrition = new Nutrition();
        baseNutrition.setEnergy(BigDecimal.valueOf(dish.getTotalCalories() != null ? dish.getTotalCalories() : 0));
        baseNutrition.setFat(BigDecimal.valueOf(dish.getTotalFat() != null ? dish.getTotalFat() : 0.0));
        baseNutrition.setCarbohydrates(BigDecimal.valueOf(dish.getTotalCarb() != null ? dish.getTotalCarb() : 0.0));
        baseNutrition.setProtein(BigDecimal.valueOf(dish.getTotalProtein() != null ? dish.getTotalProtein() : 0.0));
        item.setBaseNutrition(baseNutrition);
        
        // effectiveNutrition: 基于 consumedPercentage 计算实际摄入值
        BigDecimal ratio = item.getConsumedPercentage().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        Nutrition effectiveNutrition = new Nutrition();
        effectiveNutrition.setEnergy(baseNutrition.getEnergy().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setFat(baseNutrition.getFat().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setCarbohydrates(baseNutrition.getCarbohydrates().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setProtein(baseNutrition.getProtein().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        item.setEffectiveNutrition(effectiveNutrition);
        
        return item;
    }
    
    /**
     * 将 LeftoverDish 转换为 IntakeItem（备选方案）
     */
    private IntakeItem convertLeftoverToIntakeItem(LeftoverDish leftover, Dish dish) {
        IntakeItem item = new IntakeItem();
        
        // 注意：LeftoverDish 没有对应的 NutritionLog，所以 intakeId 可能为 null
        item.setIntakeId(null);
        item.setSourceType("recipe");
        item.setRecipeId(leftover.getOriginalDishId());
        item.setRecipeTitle(dish.getName());
        
        // consumedPercentage: 基于 LeftoverDish 的 currentQuantityGram 和 Dish 的 totalWeightGram 计算
        // 假设 LeftoverDish 的 currentQuantityGram 是剩余部分，那么消费的部分 = totalWeightGram - currentQuantityGram
        BigDecimal consumedPercentage = BigDecimal.valueOf(100.0);
        if (dish.getTotalWeightGram() != null && dish.getTotalWeightGram() > 0) {
            int consumedGram = dish.getTotalWeightGram() - leftover.getCurrentQuantityGram();
            if (consumedGram > 0) {
                consumedPercentage = BigDecimal.valueOf(consumedGram * 100.0 / dish.getTotalWeightGram())
                        .setScale(2, RoundingMode.HALF_UP);
            }
        }
        item.setConsumedPercentage(consumedPercentage);
        
        // baseNutrition: Dish 的100%营养值
        Nutrition baseNutrition = new Nutrition();
        baseNutrition.setEnergy(BigDecimal.valueOf(dish.getTotalCalories() != null ? dish.getTotalCalories() : 0));
        baseNutrition.setFat(BigDecimal.valueOf(dish.getTotalFat() != null ? dish.getTotalFat() : 0.0));
        baseNutrition.setCarbohydrates(BigDecimal.valueOf(dish.getTotalCarb() != null ? dish.getTotalCarb() : 0.0));
        baseNutrition.setProtein(BigDecimal.valueOf(dish.getTotalProtein() != null ? dish.getTotalProtein() : 0.0));
        item.setBaseNutrition(baseNutrition);
        
        // effectiveNutrition: 基于 consumedPercentage 计算实际摄入值
        BigDecimal ratio = consumedPercentage.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        Nutrition effectiveNutrition = new Nutrition();
        effectiveNutrition.setEnergy(baseNutrition.getEnergy().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setFat(baseNutrition.getFat().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setCarbohydrates(baseNutrition.getCarbohydrates().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        effectiveNutrition.setProtein(baseNutrition.getProtein().multiply(ratio).setScale(2, RoundingMode.HALF_UP));
        item.setEffectiveNutrition(effectiveNutrition);
        
        return item;
    }

    @Override
    @Transactional
    public UpdateIntakeResponse updateIntakePercentage(Long userId, Long intakeId, BigDecimal consumedPercentage) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        NutritionLog nutritionLog = nutritionLogRepository.findByIdAndUser(intakeId, user)
                .orElseThrow(() -> new RuntimeException("Intake record not found"));

        // 更新消费百分比
        nutritionLog.setConsumedPercentage(consumedPercentage);
        
        // 重新计算实际摄入营养值（基于基础值和新的 consumedPercentage）
        BigDecimal ratio = consumedPercentage.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        
        // 从基础营养值计算实际摄入值
        if (nutritionLog.getBaseEnergy() != null) {
            nutritionLog.setEnergy((int)(nutritionLog.getBaseEnergy() * ratio.doubleValue()));
        }
        if (nutritionLog.getBaseProtein() != null) {
            nutritionLog.setProtein(nutritionLog.getBaseProtein() * ratio.doubleValue());
        }
        if (nutritionLog.getBaseFat() != null) {
            nutritionLog.setFat(nutritionLog.getBaseFat() * ratio.doubleValue());
        }
        if (nutritionLog.getBaseCarbohydrates() != null) {
            nutritionLog.setCarbohydrates(nutritionLog.getBaseCarbohydrates() * ratio.doubleValue());
        }
        if (nutritionLog.getBaseFiber() != null) {
            nutritionLog.setFiber(nutritionLog.getBaseFiber() * ratio.doubleValue());
        }
        
        // 更新数量（如果有基础数量）
        if (nutritionLog.getQuantity() != null && nutritionLog.getBaseEnergy() != null) {
            // 假设 quantity 也是基于基础值计算的，需要重新计算
            // 这里简化处理：如果 quantity 存在，按比例调整
            // 实际应用中，可能需要存储 baseQuantity
        }

        // 保存更新
        nutritionLogRepository.save(nutritionLog);

        UpdateIntakeResponse response = new UpdateIntakeResponse();
        response.setIntake(convertToUpdateIntakeItem(nutritionLog));

        // Get weekly summary
        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        WeeklySummary summary = new WeeklySummary();
        summary.setWeekStart(weeklySummary.getWeekStart());
        summary.setWeekEnd(weeklySummary.getWeekEnd());
        Nutrition consumed = new Nutrition();
        consumed.setEnergy(weeklySummary.getConsumed().getEnergy());
        consumed.setFat(weeklySummary.getConsumed().getFat());
        consumed.setCarbohydrates(weeklySummary.getConsumed().getCarbohydrates());
        consumed.setProtein(weeklySummary.getConsumed().getProtein());
        summary.setConsumed(consumed);
        response.setWeeklySummary(summary);

        return response;
    }

    @Override
    @Transactional
    public AddManualIntakeResponse addManualIntake(Long userId, LocalDate date, String foodName, String portionDescription) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        LocalDate targetDate = date != null ? date : LocalDate.now();

        // 使用 AI 估算营养值
        ManualNutritionEstimator estimator = manualNutritionEstimatorProvider.getIfAvailable();
        if (estimator == null) {
            throw new IllegalStateException("ManualNutritionEstimator bean not found. Ensure Groq estimator is configured.");
        }

        NutritionEstimate estimate = estimator.estimate(foodName, portionDescription);

        // 创建 NutritionLog（通过 NutritionLogService）
        com.calotter.health.controller.dto.ManualNutritionLogRequest request =
                new com.calotter.health.controller.dto.ManualNutritionLogRequest();
        request.setUserId(userId);
        request.setEatenAt(LocalDateTime.now());
        request.setFoodName(foodName);
        request.setQuantity(portionDescription != null ? parseQuantity(portionDescription) : null);
        request.setUnit(parseUnit(portionDescription));
        request.setEnergy(estimate.energy() != null ? estimate.energy().intValue() : null);
        request.setProtein(estimate.protein() != null ? estimate.protein().doubleValue() : null);
        request.setFat(estimate.fat() != null ? estimate.fat().doubleValue() : null);
        request.setCarbohydrates(estimate.carbohydrates() != null ? estimate.carbohydrates().doubleValue() : null);

        NutritionLog savedLog = nutritionLogService.createManual(request);

        AddManualIntakeResponse response = new AddManualIntakeResponse();
        ManualIntakeItem item = new ManualIntakeItem();
        item.setIntakeId(savedLog.getId());
        item.setSourceType(savedLog.getSourceType().name().toLowerCase());
        item.setDate(savedLog.getLogDate());
        item.setManualFoodName(savedLog.getFoodName());
        item.setPortionDescription(portionDescription);
        Nutrition nutrition = new Nutrition();
        nutrition.setEnergy(BigDecimal.valueOf(savedLog.getEnergy() != null ? savedLog.getEnergy() : 0));
        nutrition.setFat(BigDecimal.valueOf(savedLog.getFat() != null ? savedLog.getFat() : 0.0));
        nutrition.setCarbohydrates(BigDecimal.valueOf(savedLog.getCarbohydrates() != null ? savedLog.getCarbohydrates() : 0.0));
        nutrition.setProtein(BigDecimal.valueOf(savedLog.getProtein() != null ? savedLog.getProtein() : 0.0));
        item.setEffectiveNutrition(nutrition);
        response.setIntake(item);

        // 获取同一天的手动食物列表
        List<NutritionLog> todayManualLogs = nutritionLogRepository.findByUserAndLogDateAndSourceType(
                user, targetDate, LogSourceType.MANUAL);
        List<ManualFoodItem> todayManualFoods = todayManualLogs.stream()
                .map(this::convertToManualFoodItem)
                .collect(Collectors.toList());
        response.setTodayManualFoods(todayManualFoods);

        // Get weekly summary
        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        WeeklySummary summary = new WeeklySummary();
        summary.setWeekStart(weeklySummary.getWeekStart());
        summary.setWeekEnd(weeklySummary.getWeekEnd());
        Nutrition consumed = new Nutrition();
        consumed.setEnergy(weeklySummary.getConsumed().getEnergy());
        consumed.setFat(weeklySummary.getConsumed().getFat());
        consumed.setCarbohydrates(weeklySummary.getConsumed().getCarbohydrates());
        consumed.setProtein(weeklySummary.getConsumed().getProtein());
        summary.setConsumed(consumed);
        response.setWeeklySummary(summary);

        return response;
    }

    @Override
    @Transactional
    public DeleteIntakeResponse deleteIntake(Long userId, Long intakeId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        NutritionLog nutritionLog = nutritionLogRepository.findByIdAndUser(intakeId, user)
                .orElseThrow(() -> new RuntimeException("Intake record not found"));

        LocalDate date = nutritionLog.getLogDate();
        nutritionLogRepository.delete(nutritionLog);

        DeleteIntakeResponse response = new DeleteIntakeResponse();
        response.setDeletedIntakeId(intakeId);
        response.setDate(date);

        // 获取同一天的手动食物列表（用于 UI 刷新）
        List<NutritionLog> todayManualLogs = nutritionLogRepository.findByUserAndLogDateAndSourceType(
                user, date, LogSourceType.MANUAL);
        List<ManualFoodItem> todayManualFoods = todayManualLogs.stream()
                .map(this::convertToManualFoodItem)
                .collect(Collectors.toList());
        response.setTodayManualFoods(todayManualFoods);

        // Get weekly summary
        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        WeeklySummary summary = new WeeklySummary();
        summary.setWeekStart(weeklySummary.getWeekStart());
        summary.setWeekEnd(weeklySummary.getWeekEnd());
        Nutrition consumed = new Nutrition();
        consumed.setEnergy(weeklySummary.getConsumed().getEnergy());
        consumed.setFat(weeklySummary.getConsumed().getFat());
        consumed.setCarbohydrates(weeklySummary.getConsumed().getCarbohydrates());
        consumed.setProtein(weeklySummary.getConsumed().getProtein());
        summary.setConsumed(consumed);
        response.setWeeklySummary(summary);

        return response;
    }

    /**
     * Convert NutritionLog to IntakeItem
     */
    private IntakeItem convertToIntakeItem(NutritionLog log) {
        IntakeItem item = new IntakeItem();
        item.setIntakeId(log.getId());
        item.setSourceType(log.getSourceType().name().toLowerCase());
        
        if (log.getSourceType() == LogSourceType.APP_COOKING) {
            item.setRecipeId(log.getDishId());
            item.setRecipeTitle(log.getFoodName());
        } else {
            item.setManualFoodName(log.getFoodName());
        }
        
        // 使用实际的 consumedPercentage
        BigDecimal consumedPct = log.getConsumedPercentage() != null ? 
                log.getConsumedPercentage() : BigDecimal.valueOf(100);
        item.setConsumedPercentage(consumedPct);

        // baseNutrition: 使用基础营养值（100%时的值）
        BigDecimal baseEnergy = BigDecimal.valueOf(log.getBaseEnergy() != null ? log.getBaseEnergy() : 
                (log.getEnergy() != null ? log.getEnergy() : 0));
        BigDecimal baseFat = BigDecimal.valueOf(log.getBaseFat() != null ? log.getBaseFat() : 
                (log.getFat() != null ? log.getFat() : 0.0));
        BigDecimal baseCarbohydrates = BigDecimal.valueOf(log.getBaseCarbohydrates() != null ? log.getBaseCarbohydrates() : 
                (log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0));
        BigDecimal baseProtein = BigDecimal.valueOf(log.getBaseProtein() != null ? log.getBaseProtein() : 
                (log.getProtein() != null ? log.getProtein() : 0.0));

        Nutrition baseNutrition = new Nutrition();
        baseNutrition.setEnergy(baseEnergy);
        baseNutrition.setFat(baseFat);
        baseNutrition.setCarbohydrates(baseCarbohydrates);
        baseNutrition.setProtein(baseProtein);
        item.setBaseNutrition(baseNutrition);

        // effectiveNutrition: 使用实际摄入值（已经基于 consumedPercentage 计算好的）
        BigDecimal effectiveEnergy = BigDecimal.valueOf(log.getEnergy() != null ? log.getEnergy() : 0);
        BigDecimal effectiveFat = BigDecimal.valueOf(log.getFat() != null ? log.getFat() : 0.0);
        BigDecimal effectiveCarbohydrates = BigDecimal.valueOf(log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0);
        BigDecimal effectiveProtein = BigDecimal.valueOf(log.getProtein() != null ? log.getProtein() : 0.0);
        
        Nutrition effectiveNutrition = new Nutrition();
        effectiveNutrition.setEnergy(effectiveEnergy);
        effectiveNutrition.setFat(effectiveFat);
        effectiveNutrition.setCarbohydrates(effectiveCarbohydrates);
        effectiveNutrition.setProtein(effectiveProtein);
        item.setEffectiveNutrition(effectiveNutrition);

        return item;
    }

    /**
     * Convert NutritionLog to UpdateIntakeItem
     */
    private UpdateIntakeItem convertToUpdateIntakeItem(NutritionLog log) {
        UpdateIntakeItem item = new UpdateIntakeItem();
        item.setIntakeId(log.getId());
        item.setSourceType(log.getSourceType().name().toLowerCase());
        item.setRecipeId(log.getDishId());
        item.setRecipeTitle(log.getFoodName());
        item.setDate(log.getLogDate());
        // 使用实际的 consumedPercentage
        BigDecimal consumedPct = log.getConsumedPercentage() != null ? 
                log.getConsumedPercentage() : BigDecimal.valueOf(100);
        item.setConsumedPercentage(consumedPct);

        // baseNutrition: 使用基础营养值（100%时的值）
        BigDecimal baseEnergy = BigDecimal.valueOf(log.getBaseEnergy() != null ? log.getBaseEnergy() : 
                (log.getEnergy() != null ? log.getEnergy() : 0));
        BigDecimal baseFat = BigDecimal.valueOf(log.getBaseFat() != null ? log.getBaseFat() : 
                (log.getFat() != null ? log.getFat() : 0.0));
        BigDecimal baseCarbohydrates = BigDecimal.valueOf(log.getBaseCarbohydrates() != null ? log.getBaseCarbohydrates() : 
                (log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0));
        BigDecimal baseProtein = BigDecimal.valueOf(log.getBaseProtein() != null ? log.getBaseProtein() : 
                (log.getProtein() != null ? log.getProtein() : 0.0));

        Nutrition baseNutrition = new Nutrition();
        baseNutrition.setEnergy(baseEnergy);
        baseNutrition.setFat(baseFat);
        baseNutrition.setCarbohydrates(baseCarbohydrates);
        baseNutrition.setProtein(baseProtein);
        item.setBaseNutrition(baseNutrition);

        // effectiveNutrition: 使用实际摄入值（已经基于 consumedPercentage 计算好的）
        BigDecimal effectiveEnergy = BigDecimal.valueOf(log.getEnergy() != null ? log.getEnergy() : 0);
        BigDecimal effectiveFat = BigDecimal.valueOf(log.getFat() != null ? log.getFat() : 0.0);
        BigDecimal effectiveCarbohydrates = BigDecimal.valueOf(log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0);
        BigDecimal effectiveProtein = BigDecimal.valueOf(log.getProtein() != null ? log.getProtein() : 0.0);
        
        Nutrition effectiveNutrition = new Nutrition();
        effectiveNutrition.setEnergy(effectiveEnergy);
        effectiveNutrition.setFat(effectiveFat);
        effectiveNutrition.setCarbohydrates(effectiveCarbohydrates);
        effectiveNutrition.setProtein(effectiveProtein);
        item.setEffectiveNutrition(effectiveNutrition);

        return item;
    }

    /**
     * Convert NutritionLog to ManualFoodItem
     */
    private ManualFoodItem convertToManualFoodItem(NutritionLog log) {
        ManualFoodItem item = new ManualFoodItem();
        item.setIntakeId(log.getId());
        item.setDate(log.getLogDate());
        item.setManualFoodName(log.getFoodName());
        item.setPortionDescription(log.getQuantity() != null && log.getUnit() != null
                ? log.getQuantity() + log.getUnit() : null);

        Nutrition nutrition = new Nutrition();
        nutrition.setEnergy(BigDecimal.valueOf(log.getEnergy() != null ? log.getEnergy() : 0));
        nutrition.setFat(BigDecimal.valueOf(log.getFat() != null ? log.getFat() : 0.0));
        nutrition.setCarbohydrates(BigDecimal.valueOf(log.getCarbohydrates() != null ? log.getCarbohydrates() : 0.0));
        nutrition.setProtein(BigDecimal.valueOf(log.getProtein() != null ? log.getProtein() : 0.0));
        item.setEffectiveNutrition(nutrition);

        return item;
    }

    /**
     * 简单的数量解析（从 portionDescription 中提取数字）
     */
    private Double parseQuantity(String portionDescription) {
        if (portionDescription == null || portionDescription.isEmpty()) {
            return null;
        }
        try {
            // 尝试提取数字部分
            String numberPart = portionDescription.replaceAll("[^0-9.]", "");
            return numberPart.isEmpty() ? null : Double.parseDouble(numberPart);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 简单的单位解析（从 portionDescription 中提取单位）
     */
    private String parseUnit(String portionDescription) {
        if (portionDescription == null || portionDescription.isEmpty()) {
            return "g";
        }
        // 简单的单位提取逻辑
        if (portionDescription.toLowerCase().contains("g") || portionDescription.toLowerCase().contains("gram")) {
            return "g";
        } else if (portionDescription.toLowerCase().contains("ml")) {
            return "ml";
        } else if (portionDescription.toLowerCase().contains("bowl") || portionDescription.toLowerCase().contains("碗")) {
            return "bowl";
        } else if (portionDescription.toLowerCase().contains("serving")) {
            return "serving";
        }
        return "g"; // 默认
    }
}
