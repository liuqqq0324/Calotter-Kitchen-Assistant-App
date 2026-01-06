package com.calotter.health.service.impl;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.IIntakeService;
import com.calotter.health.service.INutritionService;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.NutritionLogService;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import com.calotter.health.service.ai.NutritionEstimate;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
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
import java.util.List;
import java.util.Objects;
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
    private final HouseholdRepository householdRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final NutritionLogService nutritionLogService;
    private final NutritionAggregateService nutritionAggregateService;
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
            // “Today's Dish Intake”：以 NutritionLog 为准（仅 LEFTOVER），确保“新增选择 + 进度条调整”可持久化
            List<NutritionLog> logs = nutritionLogRepository.findByUserAndLogDateAndSourceTypeIn(
                    user,
                    today,
                    List.of(LogSourceType.LEFTOVER)
            );
            items = logs.stream().map(this::convertToIntakeItem).collect(Collectors.toList());
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

    @Override
    @Transactional(readOnly = true)
    public DishOptionsResponse getDishOptions(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        Household household = resolveHousehold(user);
        DishOptionsResponse resp = new DishOptionsResponse();
        if (household == null) {
            resp.setOptions(List.of());
            return resp;
        }

        List<LeftoverDish> leftovers = leftoverDishRepository.findByHouseholdId(household.getId())
                .stream()
                .filter(l -> l.getCurrentQuantityGram() != null && l.getCurrentQuantityGram() > 0)
                .collect(Collectors.toList());
        List<DishOption> options = leftovers.stream().map(l -> {
            DishOption opt = new DishOption();
            opt.setType("leftover");
            opt.setId(l.getId());
            opt.setTitle(l.getDishName() != null ? l.getDishName() : ("Leftover " + l.getId()));
            opt.setSubtitle(l.getCurrentQuantityGram() != null ? (l.getCurrentQuantityGram() + "g leftover") : "Leftover");
            return opt;
        }).collect(Collectors.toList());

        resp.setOptions(options);
        return resp;
    }

    @Override
    @Transactional
    public AddDishIntakeResponse addDishIntake(Long userId, AddDishIntakeRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));

        Household household = resolveHousehold(user);
        if (household == null) {
            throw new IllegalStateException("用户没有关联的家庭");
        }

        if (request.getType() != null && !request.getType().isBlank()
                && !"leftover".equalsIgnoreCase(request.getType())) {
            throw new IllegalArgumentException("Invalid type. Only 'leftover' is supported");
        }

        boolean hasSingleId = request.getId() != null;
        boolean hasIds = request.getIds() != null && !request.getIds().isEmpty();
        if (!hasSingleId && !hasIds) {
            throw new IllegalArgumentException("id or ids is required");
        }

        BigDecimal consumedPct = request.getConsumedPercentage() != null
                ? request.getConsumedPercentage()
                : BigDecimal.valueOf(100);
        if (consumedPct.compareTo(BigDecimal.ZERO) < 0 || consumedPct.compareTo(BigDecimal.valueOf(100)) > 0) {
            throw new IllegalArgumentException("consumedPercentage must be between 0 and 100");
        }

        LocalDate today = LocalDate.now();

        List<Long> targetIds = hasIds
                ? request.getIds().stream().filter(Objects::nonNull).distinct().toList()
                : List.of(request.getId());

        List<IntakeItem> createdItems = new java.util.ArrayList<>();
        IntakeItem firstCreated = null;

        for (Long leftoverId : targetIds) {
            LeftoverDish leftover = leftoverDishRepository.findById(leftoverId)
                    .orElseThrow(() -> new IllegalArgumentException("Leftover 不存在: " + leftoverId));
            if (leftover.getHousehold() != null
                    && leftover.getHousehold().getId() != null
                    && !leftover.getHousehold().getId().equals(household.getId())) {
                throw new IllegalArgumentException("Leftover 不属于当前家庭: " + leftoverId);
            }

            NutritionLog log = new NutritionLog();
            log.setUser(user);
            log.setLogDate(today);
            log.setEatenAt(LocalDateTime.now());
            log.setConsumedPercentage(consumedPct);

            // 关键：对于 LEFTOVER，这里的 dishId 存 LeftoverDish.id（方便后续同步库存）
            log.setSourceType(LogSourceType.LEFTOVER);
            log.setDishId(leftover.getId());
            log.setFoodName(leftover.getDishName() != null ? leftover.getDishName() : ("Leftover " + leftover.getId()));
            log.setUnit("g");
            Integer grams = leftover.getCurrentQuantityGram() != null ? leftover.getCurrentQuantityGram() : 0;
            log.setQuantity((double) grams); // 记录“当时选择的剩菜重量”，用于后续百分比同步

            int kcalPer100g = leftover.getCaloriesPer100g() != null ? leftover.getCaloriesPer100g() : 0;
            int baseEnergy = grams > 0 ? (int) Math.round(kcalPer100g * grams / 100.0) : 0;
            log.setBaseEnergy(baseEnergy);
            log.setBaseProtein(0.0);
            log.setBaseFat(0.0);
            log.setBaseCarbohydrates(0.0);
            log.setBaseFiber(0.0);

            // 计算实际摄入值（effective）
            BigDecimal ratio = consumedPct.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
            log.setEnergy((int) Math.round((log.getBaseEnergy() != null ? log.getBaseEnergy() : 0) * ratio.doubleValue()));
            log.setProtein((log.getBaseProtein() != null ? log.getBaseProtein() : 0.0) * ratio.doubleValue());
            log.setFat((log.getBaseFat() != null ? log.getBaseFat() : 0.0) * ratio.doubleValue());
            log.setCarbohydrates((log.getBaseCarbohydrates() != null ? log.getBaseCarbohydrates() : 0.0) * ratio.doubleValue());
            log.setFiber((log.getBaseFiber() != null ? log.getBaseFiber() : 0.0) * ratio.doubleValue());

            // 同步到 inventory：根据 consumedPercentage 更新剩菜当前重量
            syncLeftoverQuantityByConsumedPercentage(log, leftover);

            NutritionLog saved = nutritionLogRepository.save(log);
            createdItems.add(convertToIntakeItem(saved));
            if (firstCreated == null) {
                firstCreated = convertToIntakeItem(saved);
            }
        }

        // 聚合：对今天重建一次即可
        nutritionAggregateService.rebuildDailyAggregate(user, today);

        AddDishIntakeResponse resp = new AddDishIntakeResponse();
        resp.setAddedIntakes(createdItems);
        // backward compatible field
        resp.setIntake(firstCreated);

        List<NutritionLog> todayLogs = nutritionLogRepository.findByUserAndLogDateAndSourceTypeIn(
                user, today, List.of(LogSourceType.LEFTOVER));
        resp.setTodayDishIntakes(todayLogs.stream().map(this::convertToIntakeItem).collect(Collectors.toList()));

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
        resp.setWeeklySummary(summary);

        return resp;
    }

    /**
     * 将 intake 的 consumedPercentage 同步到 inventory 的 LeftoverDish.currentQuantityGram
     *
     * 逻辑：remaining = baseGrams * (100 - consumedPct) / 100
     * baseGrams 使用 NutritionLog.quantity（创建 intake 时记录的剩菜重量）
     */
    private void syncLeftoverQuantityByConsumedPercentage(NutritionLog log, LeftoverDish leftover) {
        if (leftover == null) return;
        BigDecimal consumedPct = log.getConsumedPercentage() != null ? log.getConsumedPercentage() : BigDecimal.valueOf(100);
        double baseGramsDouble = log.getQuantity() != null ? log.getQuantity()
                : (leftover.getCurrentQuantityGram() != null ? leftover.getCurrentQuantityGram() : 0);
        int baseGrams = (int) Math.round(Math.max(0, baseGramsDouble));
        BigDecimal remainingPct = BigDecimal.valueOf(100).subtract(consumedPct);
        int remainingGrams = remainingPct
                .multiply(BigDecimal.valueOf(baseGrams))
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                .intValue();
        leftover.setCurrentQuantityGram(Math.max(0, remainingGrams));
        leftoverDishRepository.save(leftover);
    }

    private Household resolveHousehold(User user) {
        Household household = null;
        if (user.getCurrentHouseholdId() != null) {
            household = householdRepository.findById(user.getCurrentHouseholdId()).orElse(null);
        }
        if (household == null) {
            User loadedUser = userRepository.findById(user.getId())
                    .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + user.getId()));
            if (loadedUser.getJoinedHouseholds() != null && !loadedUser.getJoinedHouseholds().isEmpty()) {
                household = loadedUser.getJoinedHouseholds().get(0);
            }
        }
        return household;
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

        // 如果是 leftover intake：同步 consumedPercentage 到 inventory 的剩菜重量
        if (nutritionLog.getSourceType() == LogSourceType.LEFTOVER && nutritionLog.getDishId() != null) {
            leftoverDishRepository.findById(nutritionLog.getDishId()).ifPresent(leftover -> {
                syncLeftoverQuantityByConsumedPercentage(nutritionLog, leftover);
            });
        }

        // ✅ 重建当天聚合，避免聚合表与真实流水不一致
        nutritionAggregateService.rebuildDailyAggregate(user, nutritionLog.getLogDate());

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

        // ✅ 重建当天聚合，避免聚合表与真实流水不一致
        nutritionAggregateService.rebuildDailyAggregate(user, date);

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
        
        if (log.getSourceType() == LogSourceType.APP_COOKING || log.getSourceType() == LogSourceType.LEFTOVER) {
            item.setLeftoverId(log.getDishId());
            item.setLeftoverTitle(log.getFoodName());
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
        item.setLeftoverId(log.getDishId());
        item.setLeftoverTitle(log.getFoodName());
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
