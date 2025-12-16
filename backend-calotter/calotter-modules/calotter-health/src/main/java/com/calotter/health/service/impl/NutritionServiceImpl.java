package com.calotter.health.service.impl;

import com.calotter.health.service.INutritionService;
import com.calotter.health.service.INutritionService.Basis;
import com.calotter.health.service.INutritionService.Nutrition;
import com.calotter.health.service.INutritionService.NutritionTarget;
import com.calotter.health.service.INutritionService.WeeklyNutritionSummaryResponse;
import com.calotter.health.service.INutritionService.WeeklyNutritionTargetsResponse;
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
 *
 * TODO: 此实现类依赖以下组件，需要先创建：
 * 1. NutritionTargetMapper - MyBatis Mapper 接口，用于营养目标数据库操作
 * 2. IntakeRecordMapper - MyBatis Mapper 接口，用于摄入记录数据库操作
 * 3. UserMapper / FamilyMemberRepository - 用于获取用户/家庭成员信息
 * 4. NutritionTarget 实体类 - 营养目标实体
 * 5. NutritionTargetVo - 视图对象，用于查询结果映射
 * 6. User / FamilyMember 实体类 - 用户/家庭成员实体
 *
 * 注意：当前模块使用 JPA，此实现基于旧版 MyBatis 结构。
 * 如需完全集成，需要：
 * - 创建对应的 MyBatis Mapper 和实体类，或
 * - 适配到当前 JPA 实体结构
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class NutritionServiceImpl implements INutritionService {

    // TODO: 需要创建 NutritionTargetMapper
    // private final NutritionTargetMapper nutritionTargetMapper;

    // TODO: 需要创建 IntakeRecordMapper
    // private final IntakeRecordMapper intakeRecordMapper;

    // TODO: 需要创建 UserMapper 或使用 FamilyMemberRepository
    // private final UserMapper userMapper;
    // 或者使用 JPA Repository:
    // private final FamilyMemberRepository familyMemberRepository;

    @Override
    public WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long familyMemberId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        // TODO: 实现数据库查询逻辑
        // NutritionTargetVo targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(familyMemberId, weekStart);
        // NutritionTargetEntity targetEntity;
        // if (targetVo != null) {
        //     targetEntity = convertVoToEntity(targetVo);
        // } else {
        //     // Calculate and create new target
        //     targetEntity = calculateAndCreateNutritionTarget(familyMemberId, weekStart, weekEnd);
        // }
        NutritionTargetEntity targetEntity = calculateAndCreateNutritionTarget(familyMemberId, weekStart, weekEnd);

        WeeklyNutritionTargetsResponse response = new WeeklyNutritionTargetsResponse();

        // Set weekly target
        NutritionTarget weeklyTarget = new NutritionTarget();
        weeklyTarget.setEnergy(targetEntity.getWeeklyTargetEnergy());
        weeklyTarget.setFat(targetEntity.getWeeklyTargetFat());
        weeklyTarget.setCarbohydrates(targetEntity.getWeeklyTargetCarbohydrates());
        weeklyTarget.setProtein(targetEntity.getWeeklyTargetProtein());
        response.setWeeklyTarget(weeklyTarget);

        // Set basis
        Basis basis = new Basis();
        basis.setBmi(targetEntity.getBmi());
        basis.setGoalType(targetEntity.getGoalType());
        basis.setCalculationModel(targetEntity.getCalculationModel());
        basis.setWeekStart(targetEntity.getWeekStart());
        basis.setWeekEnd(targetEntity.getWeekEnd());
        response.setBasis(basis);

        return response;
    }

    @Override
    public WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long familyMemberId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);

        // TODO: 实现数据库查询逻辑
        // Get target
        // NutritionTargetVo targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(familyMemberId, weekStart);
        // if (targetVo == null) {
        //     // Create target if not exists
        //     calculateAndCreateNutritionTarget(familyMemberId, weekStart, weekEnd);
        //     targetVo = nutritionTargetMapper.selectByUserIdAndWeekStart(familyMemberId, weekStart);
        // }
        // NutritionTargetEntity targetEntity = convertVoToEntity(targetVo);
        NutritionTargetEntity targetEntity = calculateAndCreateNutritionTarget(familyMemberId, weekStart, weekEnd);

        // Get consumed values
        // TODO: 实现数据库查询逻辑
        // Map<String, Object> consumedMap = intakeRecordMapper.sumEffectiveNutritionByDateRange(familyMemberId, weekStart, weekEnd);
        Map<String, Object> consumedMap = null; // 临时占位

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
        BigDecimal remainingEnergy = targetEntity.getWeeklyTargetEnergy().subtract(consumedEnergy).max(BigDecimal.ZERO);
        BigDecimal remainingFat = targetEntity.getWeeklyTargetFat().subtract(consumedFat).max(BigDecimal.ZERO);
        BigDecimal remainingCarbs = targetEntity.getWeeklyTargetCarbohydrates().subtract(consumedCarbs).max(BigDecimal.ZERO);
        BigDecimal remainingProtein = targetEntity.getWeeklyTargetProtein().subtract(consumedProtein).max(BigDecimal.ZERO);

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
     * Calculate and create nutrition target for a family member
     * 计算并创建营养目标
     */
    private NutritionTargetEntity calculateAndCreateNutritionTarget(Long familyMemberId, LocalDate weekStart, LocalDate weekEnd) {
        Integer age = null;
        String gender = null;
        Integer height = null;
        Integer weight = null;

        // TODO: 实现数据库查询逻辑
        // 从数据库查询用户/家庭成员信息
        // try {
        //     User user = userMapper.selectById(familyMemberId);
        //     // 或者使用 FamilyMember:
        //     // FamilyMember member = familyMemberRepository.findById(familyMemberId).orElse(null);
        //     if (user != null) {
        //         age = user.getAge();
        //         gender = user.getGender();
        //         height = user.getHeight();
        //         weight = user.getWeight();
        //         log.info("Retrieved user info from database: familyMemberId={}, age={}, gender={}, height={}, weight={}",
        //                 familyMemberId, age, gender, height, weight);
        //     } else {
        //         log.warn("User not found in database for familyMemberId={}, using default values", familyMemberId);
        //     }
        // } catch (Exception e) {
        //     log.error("Failed to fetch user info from database for familyMemberId={}: {}", familyMemberId, e.getMessage(), e);
        //     log.warn("Using default values for nutrition calculation");
        // }

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

        NutritionTargetEntity targetEntity = new NutritionTargetEntity();
        targetEntity.setUserId(familyMemberId);
        targetEntity.setWeekStart(weekStart);
        targetEntity.setWeekEnd(weekEnd);
        targetEntity.setWeeklyTargetEnergy(weeklyCalories.setScale(2, RoundingMode.HALF_UP));
        targetEntity.setWeeklyTargetFat(weeklyFat.setScale(2, RoundingMode.HALF_UP));
        targetEntity.setWeeklyTargetCarbohydrates(weeklyCarbs.setScale(2, RoundingMode.HALF_UP));
        targetEntity.setWeeklyTargetProtein(weeklyProtein.setScale(2, RoundingMode.HALF_UP));
        targetEntity.setBmi(bmi);
        targetEntity.setGoalType(goalType);
        targetEntity.setCalculationModel("mifflin_st_jeor");

        // TODO: 实现数据库插入逻辑
        // nutritionTargetMapper.insert(targetEntity);

        return targetEntity;
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

    // ========== 临时占位类，需要替换为实际的实体和 VO ==========

    /**
     * TODO: 需要创建实际的 NutritionTarget 实体类
     * 临时占位类，用于编译通过
     */
    private static class NutritionTargetEntity {
        private Long id;
        private Long userId;
        private LocalDate weekStart;
        private LocalDate weekEnd;
        private BigDecimal weeklyTargetEnergy;
        private BigDecimal weeklyTargetFat;
        private BigDecimal weeklyTargetCarbohydrates;
        private BigDecimal weeklyTargetProtein;
        private BigDecimal bmi;
        private String goalType;
        private String calculationModel;

        // Getters and setters
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        public LocalDate getWeekStart() { return weekStart; }
        public void setWeekStart(LocalDate weekStart) { this.weekStart = weekStart; }
        public LocalDate getWeekEnd() { return weekEnd; }
        public void setWeekEnd(LocalDate weekEnd) { this.weekEnd = weekEnd; }
        public BigDecimal getWeeklyTargetEnergy() { return weeklyTargetEnergy; }
        public void setWeeklyTargetEnergy(BigDecimal weeklyTargetEnergy) { this.weeklyTargetEnergy = weeklyTargetEnergy; }
        public BigDecimal getWeeklyTargetFat() { return weeklyTargetFat; }
        public void setWeeklyTargetFat(BigDecimal weeklyTargetFat) { this.weeklyTargetFat = weeklyTargetFat; }
        public BigDecimal getWeeklyTargetCarbohydrates() { return weeklyTargetCarbohydrates; }
        public void setWeeklyTargetCarbohydrates(BigDecimal weeklyTargetCarbohydrates) { this.weeklyTargetCarbohydrates = weeklyTargetCarbohydrates; }
        public BigDecimal getWeeklyTargetProtein() { return weeklyTargetProtein; }
        public void setWeeklyTargetProtein(BigDecimal weeklyTargetProtein) { this.weeklyTargetProtein = weeklyTargetProtein; }
        public BigDecimal getBmi() { return bmi; }
        public void setBmi(BigDecimal bmi) { this.bmi = bmi; }
        public String getGoalType() { return goalType; }
        public void setGoalType(String goalType) { this.goalType = goalType; }
        public String getCalculationModel() { return calculationModel; }
        public void setCalculationModel(String calculationModel) { this.calculationModel = calculationModel; }
    }
}

