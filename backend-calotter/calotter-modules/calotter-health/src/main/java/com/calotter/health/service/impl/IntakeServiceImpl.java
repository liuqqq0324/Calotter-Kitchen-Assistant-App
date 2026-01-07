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
        log.info("[getDishOptions] 开始获取菜品选项，userId={}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));
        log.debug("[getDishOptions] 用户信息: id={}, username={}, currentHouseholdId={}", 
                user.getId(), user.getUsername(), user.getCurrentHouseholdId());

        Household household = resolveHousehold(user);
        log.info("[getDishOptions] resolveHousehold 结果: householdId={}, householdName={}", 
                household != null ? household.getId() : null, 
                household != null ? household.getName() : null);
        
        DishOptionsResponse resp = new DishOptionsResponse();
        if (household == null) {
            log.warn("[getDishOptions] 用户没有关联的 household，返回空列表。userId={}, currentHouseholdId={}, joinedHouseholds={}", 
                    userId, user.getCurrentHouseholdId(), 
                    user.getJoinedHouseholds() != null ? user.getJoinedHouseholds().size() : 0);
            resp.setOptions(List.of());
            return resp;
        }

        List<LeftoverDish> allLeftovers = leftoverDishRepository.findByHouseholdId(household.getId());
        log.info("[getDishOptions] 查询到 leftovers 总数: {}, householdId={}", allLeftovers.size(), household.getId());
        
        List<LeftoverDish> leftovers = allLeftovers.stream()
                .filter(l -> {
                    boolean isValid = l.getCurrentQuantityGram() != null && l.getCurrentQuantityGram() > 0;
                    if (!isValid) {
                        log.debug("[getDishOptions] 过滤掉 leftover: id={}, dishName={}, currentQuantityGram={}", 
                                l.getId(), l.getDishName(), l.getCurrentQuantityGram());
                    }
                    return isValid;
                })
                .collect(Collectors.toList());
        
        log.info("[getDishOptions] 过滤后可用 leftovers 数量: {}", leftovers.size());
        
        List<DishOption> options = leftovers.stream().map(l -> {
            DishOption opt = new DishOption();
            opt.setType("leftover");
            opt.setId(l.getId());
            opt.setTitle(l.getDishName() != null ? l.getDishName() : ("Leftover " + l.getId()));
            opt.setSubtitle(l.getCurrentQuantityGram() != null ? (l.getCurrentQuantityGram() + "g leftover") : "Leftover");
            opt.setMaxConsumablePercentage(computeCurrentRemainingPercentage(l));
            log.debug("[getDishOptions] 创建选项: id={}, title={}, subtitle={}", 
                    opt.getId(), opt.getTitle(), opt.getSubtitle());
            return opt;
        }).collect(Collectors.toList());

        resp.setOptions(options);
        log.info("[getDishOptions] 返回选项数量: {}, userId={}, householdId={}", 
                options.size(), userId, household.getId());
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

        // Semantics: consumedPercentage is 0-100 relative to the ORIGINAL leftover (initial quantity).
        // If not provided, default to "eat all remaining" (i.e. current remaining % vs initial).
        final BigDecimal requestedConsumedPct = request.getConsumedPercentage();
        if (requestedConsumedPct != null) {
            if (requestedConsumedPct.compareTo(BigDecimal.ZERO) < 0 ||
                    requestedConsumedPct.compareTo(BigDecimal.valueOf(100)) > 0) {
                throw new IllegalArgumentException("consumedPercentage must be between 0 and 100");
            }
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

            // 关键：对于 LEFTOVER，这里的 dishId 存 LeftoverDish.id（方便后续同步库存）
            log.setSourceType(LogSourceType.LEFTOVER);
            log.setDishId(leftover.getId());
            log.setFoodName(leftover.getDishName() != null ? leftover.getDishName() : ("Leftover " + leftover.getId()));
            log.setUnit("g");
            Integer grams = leftover.getCurrentQuantityGram() != null ? leftover.getCurrentQuantityGram() : 0;
            log.setQuantity((double) grams); // 记录"当时选择的剩菜重量"，用于后续百分比同步

            // Max consumable at creation time (0-100 vs initial)
            BigDecimal maxConsumablePctAtCreation = computeMaxConsumablePercentageAtIntakeCreation(log, leftover);

            BigDecimal consumedPctAbs = requestedConsumedPct != null
                    ? requestedConsumedPct
                    : maxConsumablePctAtCreation; // default: eat all remaining
            // Safety clamp: cannot exceed what was available at creation time.
            if (maxConsumablePctAtCreation != null && consumedPctAbs.compareTo(maxConsumablePctAtCreation) > 0) {
                consumedPctAbs = maxConsumablePctAtCreation;
            }
            if (consumedPctAbs.compareTo(BigDecimal.ZERO) < 0) {
                consumedPctAbs = BigDecimal.ZERO;
            }
            log.setConsumedPercentage(consumedPctAbs);

            // 从 LeftoverDish 快照字段获取每100g的营养素值
            int kcalPer100g = leftover.getCaloriesPer100g() != null ? leftover.getCaloriesPer100g() : 0;
            Double proteinPer100g = leftover.getProteinPer100g();
            Double fatPer100g = leftover.getFatPer100g();
            Double carbPer100g = leftover.getCarbPer100g();
            Double fiberPer100g = leftover.getFiberPer100g();

            // 计算基础营养值（100%时的值）
            int baseEnergy = grams > 0 ? (int) Math.round(kcalPer100g * grams / 100.0) : 0;
            Double baseProtein = (grams > 0 && proteinPer100g != null) ? proteinPer100g * grams / 100.0 : 0.0;
            Double baseFat = (grams > 0 && fatPer100g != null) ? fatPer100g * grams / 100.0 : 0.0;
            Double baseCarbohydrates = (grams > 0 && carbPer100g != null) ? carbPer100g * grams / 100.0 : 0.0;
            Double baseFiber = (grams > 0 && fiberPer100g != null) ? fiberPer100g * grams / 100.0 : 0.0;

            log.setBaseEnergy(baseEnergy);
            log.setBaseProtein(baseProtein);
            log.setBaseFat(baseFat);
            log.setBaseCarbohydrates(baseCarbohydrates);
            log.setBaseFiber(baseFiber);

            // 计算实际摄入值（effective）
            // Base nutrition is computed from the CURRENT grams at creation time (log.quantity).
            // Since consumedPctAbs is relative to INITIAL, convert to a ratio of "how much of the CURRENT grams was eaten":
            //   ratio = consumedPctAbs / maxConsumablePctAtCreation
            BigDecimal ratio = BigDecimal.ZERO;
            if (maxConsumablePctAtCreation != null && maxConsumablePctAtCreation.compareTo(BigDecimal.ZERO) > 0) {
                ratio = consumedPctAbs.divide(maxConsumablePctAtCreation, 4, RoundingMode.HALF_UP);
            }
            double ratioD = Math.max(0.0, Math.min(1.0, ratio.doubleValue()));
            log.setEnergy((int) Math.round((log.getBaseEnergy() != null ? log.getBaseEnergy() : 0) * ratioD));
            log.setProtein((log.getBaseProtein() != null ? log.getBaseProtein() : 0.0) * ratioD);
            log.setFat((log.getBaseFat() != null ? log.getBaseFat() : 0.0) * ratioD);
            log.setCarbohydrates((log.getBaseCarbohydrates() != null ? log.getBaseCarbohydrates() : 0.0) * ratioD);
            log.setFiber((log.getBaseFiber() != null ? log.getBaseFiber() : 0.0) * ratioD);

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
     * 语义：consumedPct 是相对“初始重量（initialQuantityGram）”的百分比（0-100）。
     * 逻辑：remaining = baseGrams - initialGrams * consumedPct / 100
     * baseGrams 使用 NutritionLog.quantity（创建 intake 时记录的剩菜重量）
     */
    private void syncLeftoverQuantityByConsumedPercentage(NutritionLog log, LeftoverDish leftover) {
        if (leftover == null) return;
        BigDecimal consumedPct = log.getConsumedPercentage() != null ? log.getConsumedPercentage() : BigDecimal.valueOf(0);
        double baseGramsDouble = log.getQuantity() != null ? log.getQuantity()
                : (leftover.getCurrentQuantityGram() != null ? leftover.getCurrentQuantityGram() : 0);
        int baseGrams = (int) Math.round(Math.max(0, baseGramsDouble));

        Integer initial = leftover.getInitialQuantityGram();
        if (initial == null || initial <= 0) {
            // Fallback if initial snapshot is missing: behave like "relative to baseGrams".
            BigDecimal remainingPct = BigDecimal.valueOf(100).subtract(consumedPct);
            int remainingGrams = remainingPct
                    .multiply(BigDecimal.valueOf(baseGrams))
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                    .intValue();
            leftover.setCurrentQuantityGram(Math.max(0, remainingGrams));
            leftoverDishRepository.save(leftover);
            return;
        }

        int consumedGrams = BigDecimal.valueOf(initial)
                .multiply(consumedPct)
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                .intValue();

        int remainingGrams = baseGrams - consumedGrams;
        remainingGrams = Math.max(0, Math.min(baseGrams, remainingGrams));
        leftover.setCurrentQuantityGram(remainingGrams);
        leftoverDishRepository.save(leftover);
    }

    private Household resolveHousehold(User user) {
        log.debug("[resolveHousehold] 开始解析用户的 household，userId={}, currentHouseholdId={}", 
                user.getId(), user.getCurrentHouseholdId());
        
        Household household = null;
        
        // 1. 优先使用 currentHouseholdId
        if (user.getCurrentHouseholdId() != null) {
            household = householdRepository.findById(user.getCurrentHouseholdId()).orElse(null);
            if (household != null) {
                log.debug("[resolveHousehold] 从 currentHouseholdId 获取到 household: id={}, name={}", 
                        household.getId(), household.getName());
            } else {
                log.warn("[resolveHousehold] currentHouseholdId={} 对应的 household 不存在", 
                        user.getCurrentHouseholdId());
            }
        } else {
            log.debug("[resolveHousehold] 用户没有设置 currentHouseholdId");
        }
        
        // 2. 如果没有，尝试从 joinedHouseholds 获取
        if (household == null) {
            User loadedUser = userRepository.findById(user.getId())
                    .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + user.getId()));
            
            if (loadedUser.getJoinedHouseholds() != null && !loadedUser.getJoinedHouseholds().isEmpty()) {
                household = loadedUser.getJoinedHouseholds().get(0);
                log.debug("[resolveHousehold] 从 joinedHouseholds 获取到第一个 household: id={}, name={}, totalJoined={}", 
                        household.getId(), household.getName(), loadedUser.getJoinedHouseholds().size());
            } else {
                log.debug("[resolveHousehold] 用户没有加入任何 household，尝试查找用户拥有的 household，userId={}", user.getId());
            }
        }
        
        // 3. 如果还没有，尝试查找用户作为 owner 的 household
        if (household == null) {
            List<Household> ownedHouseholds = householdRepository.findByOwnerId(user.getId());
            if (ownedHouseholds != null && !ownedHouseholds.isEmpty()) {
                household = ownedHouseholds.get(0);
                log.info("[resolveHousehold] 从 owner 关系获取到 household: id={}, name={}, totalOwned={}", 
                        household.getId(), household.getName(), ownedHouseholds.size());
            } else {
                log.warn("[resolveHousehold] 用户既没有 currentHouseholdId，也没有加入任何 household，也不是任何 household 的 owner，userId={}", user.getId());
            }
        }
        
        log.info("[resolveHousehold] 最终结果: userId={}, householdId={}, householdName={}", 
                user.getId(), 
                household != null ? household.getId() : null,
                household != null ? household.getName() : null);
        
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
        // Semantics:
        // - For leftover: consumedPercentage is relative to INITIAL (0-100), but base nutrition is for CURRENT grams at creation,
        //   so we convert to ratio-of-current via: ratio = consumedPct / maxConsumablePctAtCreation.
        // - For non-leftover: keep old ratio = consumedPct / 100.
        BigDecimal ratio = consumedPercentage.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        if (nutritionLog.getSourceType() == LogSourceType.LEFTOVER && nutritionLog.getDishId() != null) {
            LeftoverDish leftover = leftoverDishRepository.findById(nutritionLog.getDishId()).orElse(null);
            if (leftover != null) {
                BigDecimal maxConsumable = computeMaxConsumablePercentageAtIntakeCreation(nutritionLog, leftover);
                if (maxConsumable != null && maxConsumable.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal r = consumedPercentage.divide(maxConsumable, 4, RoundingMode.HALF_UP);
                    // Clamp 0..1
                    double rd = Math.max(0.0, Math.min(1.0, r.doubleValue()));
                    // Apply with base values
                    if (nutritionLog.getBaseEnergy() != null) {
                        nutritionLog.setEnergy((int) Math.round(nutritionLog.getBaseEnergy() * rd));
                    }
                    if (nutritionLog.getBaseProtein() != null) {
                        nutritionLog.setProtein(nutritionLog.getBaseProtein() * rd);
                    }
                    if (nutritionLog.getBaseFat() != null) {
                        nutritionLog.setFat(nutritionLog.getBaseFat() * rd);
                    }
                    if (nutritionLog.getBaseCarbohydrates() != null) {
                        nutritionLog.setCarbohydrates(nutritionLog.getBaseCarbohydrates() * rd);
                    }
                    if (nutritionLog.getBaseFiber() != null) {
                        nutritionLog.setFiber(nutritionLog.getBaseFiber() * rd);
                    }
                }
            }
        }
        
        // 从基础营养值计算实际摄入值（非 leftover 走这里；leftover 已在上面按“相对初始”语义重算）
        if (nutritionLog.getSourceType() != LogSourceType.LEFTOVER) {
            if (nutritionLog.getBaseEnergy() != null) {
                nutritionLog.setEnergy((int) (nutritionLog.getBaseEnergy() * ratio.doubleValue()));
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

        // For leftover intakes: expose the max consumable percentage (0-100) of the ORIGINAL leftover
        // at the time this intake was created.
        if (log.getSourceType() == LogSourceType.LEFTOVER && log.getDishId() != null) {
            leftoverDishRepository.findById(log.getDishId()).ifPresent(leftover -> {
                item.setMaxConsumablePercentage(computeMaxConsumablePercentageAtIntakeCreation(log, leftover));
            });
        }

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

        if (log.getSourceType() == LogSourceType.LEFTOVER && log.getDishId() != null) {
            leftoverDishRepository.findById(log.getDishId()).ifPresent(leftover -> {
                item.setMaxConsumablePercentage(computeMaxConsumablePercentageAtIntakeCreation(log, leftover));
            });
        }

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
     * Current remaining percentage vs initial (0-100).
     */
    private BigDecimal computeCurrentRemainingPercentage(LeftoverDish leftover) {
        if (leftover == null) return BigDecimal.valueOf(0);
        Integer initial = leftover.getInitialQuantityGram();
        Integer current = leftover.getCurrentQuantityGram();
        if (initial == null || initial <= 0) return BigDecimal.valueOf(0);
        int currentSafe = current != null ? Math.max(0, current) : 0;
        BigDecimal pct = BigDecimal.valueOf(currentSafe)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(initial), 2, RoundingMode.HALF_UP);
        return pct.max(BigDecimal.ZERO).min(BigDecimal.valueOf(100));
    }

    /**
     * Max consumable percentage (0-100) of the ORIGINAL leftover at intake creation time.
     *
     * At intake creation time we snapshot the leftover grams into NutritionLog.quantity (baseGrams).
     * We compute:
     *   maxPct = baseGrams / initialGrams * 100
     */
    private BigDecimal computeMaxConsumablePercentageAtIntakeCreation(NutritionLog log, LeftoverDish leftover) {
        if (leftover == null) return BigDecimal.valueOf(100);
        Integer initial = leftover.getInitialQuantityGram();
        if (initial == null || initial <= 0) return BigDecimal.valueOf(100);

        double baseGramsDouble = log.getQuantity() != null
                ? log.getQuantity()
                : (leftover.getCurrentQuantityGram() != null ? leftover.getCurrentQuantityGram() : 0);
        int baseGrams = (int) Math.round(Math.max(0, baseGramsDouble));

        BigDecimal pct = BigDecimal.valueOf(baseGrams)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(initial), 2, RoundingMode.HALF_UP);
        return pct.max(BigDecimal.ZERO).min(BigDecimal.valueOf(100));
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
