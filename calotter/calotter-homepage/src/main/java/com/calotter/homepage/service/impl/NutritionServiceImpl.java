package com.calotter.homepage.service.impl;

import com.calotter.common.core.utils.MapstructUtils;
import com.calotter.homepage.domain.NutritionTarget;
import com.calotter.homepage.domain.User;
import com.calotter.homepage.domain.vo.NutritionTargetVo;
import com.calotter.homepage.mapper.IntakeRecordMapper;
import com.calotter.homepage.mapper.NutritionTargetMapper;
import com.calotter.homepage.mapper.UserMapper;
import com.calotter.homepage.service.INutritionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Map;

/**
 * Nutrition Service Implementation
 * 营养服务实现类
 *
 * @author Auto Generated
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class NutritionServiceImpl implements INutritionService {

    private final NutritionTargetMapper nutritionTargetMapper;
    private final IntakeRecordMapper intakeRecordMapper;
    private final UserMapper userMapper;

    @Override
    public WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        NutritionTargetVo targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(userId, weekStart);
        NutritionTarget target;

        if (targetVo != null) {
            target = MapstructUtils.convert(targetVo, NutritionTarget.class);
        } else {
            // Calculate and create new target
            // 直接从数据库获取用户信息来计算营养目标
            target = calculateAndCreateNutritionTarget(userId, weekStart, weekEnd);
        }

        WeeklyNutritionTargetsResponse response = new WeeklyNutritionTargetsResponse();

        // Set weekly target
        WeeklyNutritionTargetsResponse.WeeklyTarget weeklyTarget = new WeeklyNutritionTargetsResponse.WeeklyTarget();
        weeklyTarget.energy = target.getWeeklyTargetEnergy();
        weeklyTarget.fat = target.getWeeklyTargetFat();
        weeklyTarget.carbohydrates = target.getWeeklyTargetCarbohydrates();
        weeklyTarget.protein = target.getWeeklyTargetProtein();
        response.weeklyTarget = weeklyTarget;

        // Set basis
        WeeklyNutritionTargetsResponse.Basis basis = new WeeklyNutritionTargetsResponse.Basis();
        basis.bmi = target.getBmi();
        basis.goalType = target.getGoalType();
        basis.calculationModel = target.getCalculationModel();
        basis.weekStart = target.getWeekStart();
        basis.weekEnd = target.getWeekEnd();
        response.basis = basis;

        return response;
    }

    @Override
    public WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        // Get target
        NutritionTargetVo targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(userId, weekStart);
        if (targetVo == null) {
            // Create target if not exists
            calculateAndCreateNutritionTarget(userId, weekStart, weekEnd);
            targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(userId, weekStart);
        }

        NutritionTarget target = MapstructUtils.convert(targetVo, NutritionTarget.class);

        // Get consumed values
        Map<String, Object> consumedMap = intakeRecordMapper.sumEffectiveNutritionByDateRange(userId, weekStart, weekEnd);

        // Handle null values safely - if map is null or values are null, use zero
        Object energyObj = consumedMap != null ? consumedMap.get("consumedEnergy") : null;
        Object fatObj = consumedMap != null ? consumedMap.get("consumedFat") : null;
        Object carbsObj = consumedMap != null ? consumedMap.get("consumedCarbohydrates") : null;
        Object proteinObj = consumedMap != null ? consumedMap.get("consumedProtein") : null;

        BigDecimal consumedEnergy = (energyObj instanceof BigDecimal) 
            ? ((BigDecimal) energyObj).setScale(2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedFat = (fatObj instanceof BigDecimal)
            ? ((BigDecimal) fatObj).setScale(2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedCarbs = (carbsObj instanceof BigDecimal)
            ? ((BigDecimal) carbsObj).setScale(2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedProtein = (proteinObj instanceof BigDecimal)
            ? ((BigDecimal) proteinObj).setScale(2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

        // Calculate remaining
        BigDecimal remainingEnergy = target.getWeeklyTargetEnergy().subtract(consumedEnergy).max(BigDecimal.ZERO);
        BigDecimal remainingFat = target.getWeeklyTargetFat().subtract(consumedFat).max(BigDecimal.ZERO);
        BigDecimal remainingCarbs = target.getWeeklyTargetCarbohydrates().subtract(consumedCarbs).max(BigDecimal.ZERO);
        BigDecimal remainingProtein = target.getWeeklyTargetProtein().subtract(consumedProtein).max(BigDecimal.ZERO);

        WeeklyNutritionSummaryResponse response = new WeeklyNutritionSummaryResponse();
        response.period = "week";
        response.weekStart = weekStart;
        response.weekEnd = weekEnd;

        WeeklyNutritionSummaryResponse.NutritionValues consumed = new WeeklyNutritionSummaryResponse.NutritionValues();
        consumed.energy = consumedEnergy;
        consumed.fat = consumedFat;
        consumed.carbohydrates = consumedCarbs;
        consumed.protein = consumedProtein;
        response.consumed = consumed;

        WeeklyNutritionSummaryResponse.NutritionValues remaining = new WeeklyNutritionSummaryResponse.NutritionValues();
        remaining.energy = remainingEnergy;
        remaining.fat = remainingFat;
        remaining.carbohydrates = remainingCarbs;
        remaining.protein = remainingProtein;
        response.remaining = remaining;

        return response;
    }

    /**
     * Calculate and create nutrition target for a user
     * 直接从数据库查询用户信息
     */
    private NutritionTarget calculateAndCreateNutritionTarget(Long userId, LocalDate weekStart, LocalDate weekEnd) {
        Integer age = null;
        String gender = null;
        Integer height = null;
        Integer weight = null;

        // 直接从数据库查询用户信息（sous_chef_ums.ums_user表）
        try {
            User user = userMapper.selectById(userId);
            if (user != null) {
                age = user.getAge();
                gender = user.getGender();
                height = user.getHeight();
                weight = user.getWeight();
                log.info("Retrieved user info from database: userId={}, age={}, gender={}, height={}, weight={}",
                        userId, age, gender, height, weight);
            } else {
                log.warn("User not found in database for userId={}, using default values", userId);
            }
        } catch (Exception e) {
            log.error("Failed to fetch user info from database for userId={}: {}", userId, e.getMessage(), e);
            log.warn("Using default values for nutrition calculation");
        }

        // 如果用户信息为空，使用默认值
        if (age == null) age = 30;
        if (height == null) height = 170;
        if (weight == null) weight = 70;
        if (gender == null) gender = "male";

        // Calculate BMI
        BigDecimal bmi = calculateBMI(height, weight);

        // Calculate BMR using Mifflin-St Jeor equation
        BigDecimal bmr = calculateBMR(age, gender, height, weight);

        // Calculate daily calories (assuming moderate activity level, multiplier = 1.55)
        BigDecimal dailyCalories = bmr.multiply(BigDecimal.valueOf(1.55));

        // Weekly calories
        BigDecimal weeklyCalories = dailyCalories.multiply(BigDecimal.valueOf(7));

        // Adjust based on goal type (default: maintain)
        String goalType = "maintain";
        if (bmi != null && bmi.compareTo(BigDecimal.valueOf(25)) > 0) {
            goalType = "fat_loss";
            weeklyCalories = weeklyCalories.multiply(BigDecimal.valueOf(0.85)); // 15% deficit
        } else if (bmi != null && bmi.compareTo(BigDecimal.valueOf(18.5)) < 0) {
            goalType = "muscle_gain";
            weeklyCalories = weeklyCalories.multiply(BigDecimal.valueOf(1.15)); // 15% surplus
        }

        // Calculate macronutrients
        BigDecimal weeklyProtein = BigDecimal.valueOf(weight).multiply(BigDecimal.valueOf(7)); // grams per week
        BigDecimal weeklyFat = weeklyCalories.multiply(BigDecimal.valueOf(0.25))
                .divide(BigDecimal.valueOf(9), 2, RoundingMode.HALF_UP); // 9 kcal per gram
        BigDecimal proteinCalories = weeklyProtein.multiply(BigDecimal.valueOf(4));
        BigDecimal fatCalories = weeklyFat.multiply(BigDecimal.valueOf(9));
        BigDecimal carbCalories = weeklyCalories.subtract(proteinCalories).subtract(fatCalories);
        BigDecimal weeklyCarbs = carbCalories.divide(BigDecimal.valueOf(4), 2, RoundingMode.HALF_UP);

        NutritionTarget target = new NutritionTarget();
        target.setUserId(userId);
        target.setWeekStart(weekStart);
        target.setWeekEnd(weekEnd);
        target.setWeeklyTargetEnergy(weeklyCalories.setScale(2, RoundingMode.HALF_UP));
        target.setWeeklyTargetFat(weeklyFat.setScale(2, RoundingMode.HALF_UP));
        target.setWeeklyTargetCarbohydrates(weeklyCarbs.setScale(2, RoundingMode.HALF_UP));
        target.setWeeklyTargetProtein(weeklyProtein.setScale(2, RoundingMode.HALF_UP));
        target.setBmi(bmi);
        target.setGoalType(goalType);
        target.setCalculationModel("mifflin_st_jeor");

        nutritionTargetMapper.insert(target);
        return target;
    }

    private BigDecimal calculateBMI(Integer height, Integer weight) {
        if (height == null || weight == null || height == 0) {
            return null;
        }
        BigDecimal heightM = BigDecimal.valueOf(height).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal heightSquared = heightM.multiply(heightM);
        return BigDecimal.valueOf(weight).divide(heightSquared, 2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateBMR(Integer age, String gender, Integer height, Integer weight) {
        BigDecimal base = BigDecimal.valueOf(10).multiply(BigDecimal.valueOf(weight))
                .add(BigDecimal.valueOf(6.25).multiply(BigDecimal.valueOf(height)))
                .subtract(BigDecimal.valueOf(5).multiply(BigDecimal.valueOf(age)));

        if ("male".equalsIgnoreCase(gender) || "m".equalsIgnoreCase(gender)) {
            base = base.add(BigDecimal.valueOf(5));
        } else {
            base = base.subtract(BigDecimal.valueOf(161));
        }

        return base;
    }

    private LocalDate getWeekStart(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToSubtract = dayOfWeek.getValue() - 1;
        return date.minusDays(daysToSubtract);
    }

    private LocalDate getWeekEnd(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToAdd = 7 - dayOfWeek.getValue();
        return date.plusDays(daysToAdd);
    }
}
