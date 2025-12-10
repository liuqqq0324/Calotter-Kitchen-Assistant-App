package com.souschef.service;

import com.souschef.dto.nutrition.WeeklyNutritionSummaryResponse;
import com.souschef.dto.nutrition.WeeklyNutritionTargetsResponse;
import com.souschef.entity.NutritionTarget;
import com.souschef.entity.User;
import com.souschef.repository.IntakeRecordRepository;
import com.souschef.repository.NutritionTargetRepository;
import com.souschef.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Optional;

@Service
public class NutritionService {
    
    @Autowired
    private NutritionTargetRepository nutritionTargetRepository;
    
    @Autowired
    private IntakeRecordRepository intakeRecordRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Get weekly nutrition targets for a user
     * If no target exists for the current week, calculate and create one
     */
    public WeeklyNutritionTargetsResponse getWeeklyNutritionTargets(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);
        
        Optional<NutritionTarget> targetOpt = nutritionTargetRepository.findByUserIdAndWeekStart(userId, weekStart);
        NutritionTarget target;
        
        if (targetOpt.isPresent()) {
            target = targetOpt.get();
        } else {
            // Calculate and create new target
            target = calculateAndCreateNutritionTarget(userId, weekStart, weekEnd);
        }
        
        WeeklyNutritionTargetsResponse response = new WeeklyNutritionTargetsResponse();
        
        // Set weekly target
        WeeklyNutritionTargetsResponse.WeeklyTarget weeklyTarget = new WeeklyNutritionTargetsResponse.WeeklyTarget();
        weeklyTarget.setEnergy(target.getWeeklyTargetEnergy());
        weeklyTarget.setFat(target.getWeeklyTargetFat());
        weeklyTarget.setCarbohydrates(target.getWeeklyTargetCarbohydrates());
        weeklyTarget.setProtein(target.getWeeklyTargetProtein());
        response.setWeeklyTarget(weeklyTarget);
        
        // Set basis
        WeeklyNutritionTargetsResponse.Basis basis = new WeeklyNutritionTargetsResponse.Basis();
        basis.setBmi(target.getBmi());
        basis.setGoalType(target.getGoalType());
        basis.setCalculationModel(target.getCalculationModel());
        basis.setWeekStart(target.getWeekStart());
        basis.setWeekEnd(target.getWeekEnd());
        response.setBasis(basis);
        
        return response;
    }
    
    /**
     * Get weekly nutrition summary (consumed and remaining)
     */
    public WeeklyNutritionSummaryResponse getWeeklyNutritionSummary(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = getWeekStart(today);
        LocalDate weekEnd = getWeekEnd(today);
        
        // Get target
        Optional<NutritionTarget> targetOpt = nutritionTargetRepository.findByUserIdAndWeekStart(userId, weekStart);
        if (targetOpt.isEmpty()) {
            // Create target if not exists
            calculateAndCreateNutritionTarget(userId, weekStart, weekEnd);
            targetOpt = nutritionTargetRepository.findByUserIdAndWeekStart(userId, weekStart);
        }
        
        NutritionTarget target = targetOpt.get();
        
        // Get consumed values
        Object[] consumedArray = intakeRecordRepository.sumEffectiveNutritionByDateRange(userId, weekStart, weekEnd);
        
        BigDecimal consumedEnergy = ((BigDecimal) consumedArray[0]).setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedFat = ((BigDecimal) consumedArray[1]).setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedCarbs = ((BigDecimal) consumedArray[2]).setScale(2, RoundingMode.HALF_UP);
        BigDecimal consumedProtein = ((BigDecimal) consumedArray[3]).setScale(2, RoundingMode.HALF_UP);
        
        // Calculate remaining
        BigDecimal remainingEnergy = target.getWeeklyTargetEnergy().subtract(consumedEnergy).max(BigDecimal.ZERO);
        BigDecimal remainingFat = target.getWeeklyTargetFat().subtract(consumedFat).max(BigDecimal.ZERO);
        BigDecimal remainingCarbs = target.getWeeklyTargetCarbohydrates().subtract(consumedCarbs).max(BigDecimal.ZERO);
        BigDecimal remainingProtein = target.getWeeklyTargetProtein().subtract(consumedProtein).max(BigDecimal.ZERO);
        
        WeeklyNutritionSummaryResponse response = new WeeklyNutritionSummaryResponse();
        response.setPeriod("week");
        response.setWeekStart(weekStart);
        response.setWeekEnd(weekEnd);
        
        WeeklyNutritionSummaryResponse.NutritionValues consumed = new WeeklyNutritionSummaryResponse.NutritionValues();
        consumed.setEnergy(consumedEnergy);
        consumed.setFat(consumedFat);
        consumed.setCarbohydrates(consumedCarbs);
        consumed.setProtein(consumedProtein);
        response.setConsumed(consumed);
        
        WeeklyNutritionSummaryResponse.NutritionValues remaining = new WeeklyNutritionSummaryResponse.NutritionValues();
        remaining.setEnergy(remainingEnergy);
        remaining.setFat(remainingFat);
        remaining.setCarbohydrates(remainingCarbs);
        remaining.setProtein(remainingProtein);
        response.setRemaining(remaining);
        
        return response;
    }
    
    /**
     * Calculate and create nutrition target for a user
     */
    private NutritionTarget calculateAndCreateNutritionTarget(Long userId, LocalDate weekStart, LocalDate weekEnd) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        
        User user = userOpt.get();
        
        // Calculate BMI
        BigDecimal bmi = calculateBMI(user.getHeight(), user.getWeight());
        
        // Calculate BMR using Mifflin-St Jeor equation
        BigDecimal bmr = calculateBMR(user.getAge(), user.getGender(), user.getHeight(), user.getWeight());
        
        // Calculate daily calories (assuming moderate activity level, multiplier = 1.55)
        BigDecimal dailyCalories = bmr.multiply(BigDecimal.valueOf(1.55));
        
        // Weekly calories
        BigDecimal weeklyCalories = dailyCalories.multiply(BigDecimal.valueOf(7));
        
        // Adjust based on goal type (default: maintain)
        String goalType = "maintain"; // Default, can be configured per user
        if (bmi != null && bmi.compareTo(BigDecimal.valueOf(25)) > 0) {
            goalType = "fat_loss";
            weeklyCalories = weeklyCalories.multiply(BigDecimal.valueOf(0.85)); // 15% deficit
        } else if (bmi != null && bmi.compareTo(BigDecimal.valueOf(18.5)) < 0) {
            goalType = "muscle_gain";
            weeklyCalories = weeklyCalories.multiply(BigDecimal.valueOf(1.15)); // 15% surplus
        }
        
        // Calculate macronutrients
        // Protein: 0.8-1.2g per kg body weight (use 1.0g)
        BigDecimal weeklyProtein = BigDecimal.valueOf(user.getWeight() != null ? user.getWeight() : 70)
                .multiply(BigDecimal.valueOf(7)); // grams per week
        
        // Fat: 20-35% of calories (use 25%)
        BigDecimal weeklyFat = weeklyCalories.multiply(BigDecimal.valueOf(0.25))
                .divide(BigDecimal.valueOf(9), 2, RoundingMode.HALF_UP); // 9 kcal per gram
        
        // Carbohydrates: remaining calories
        BigDecimal proteinCalories = weeklyProtein.multiply(BigDecimal.valueOf(4)); // 4 kcal per gram
        BigDecimal fatCalories = weeklyFat.multiply(BigDecimal.valueOf(9)); // 9 kcal per gram
        BigDecimal carbCalories = weeklyCalories.subtract(proteinCalories).subtract(fatCalories);
        BigDecimal weeklyCarbs = carbCalories.divide(BigDecimal.valueOf(4), 2, RoundingMode.HALF_UP); // 4 kcal per gram
        
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
        
        return nutritionTargetRepository.save(target);
    }
    
    /**
     * Calculate BMI
     */
    private BigDecimal calculateBMI(Integer height, Integer weight) {
        if (height == null || weight == null || height == 0) {
            return null;
        }
        // BMI = weight (kg) / (height (m))^2
        BigDecimal heightM = BigDecimal.valueOf(height).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal heightSquared = heightM.multiply(heightM);
        return BigDecimal.valueOf(weight).divide(heightSquared, 2, RoundingMode.HALF_UP);
    }
    
    /**
     * Calculate BMR using Mifflin-St Jeor equation
     * Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
     * Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161
     */
    private BigDecimal calculateBMR(Integer age, String gender, Integer height, Integer weight) {
        if (age == null || height == null || weight == null) {
            // Default values if missing
            age = age != null ? age : 30;
            height = height != null ? height : 170;
            weight = weight != null ? weight : 70;
        }
        
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
    
    /**
     * Get the start of the week (Monday)
     */
    private LocalDate getWeekStart(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToSubtract = dayOfWeek.getValue() - 1; // Monday = 1
        return date.minusDays(daysToSubtract);
    }
    
    /**
     * Get the end of the week (Sunday)
     */
    private LocalDate getWeekEnd(LocalDate date) {
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToAdd = 7 - dayOfWeek.getValue(); // Sunday = 7
        return date.plusDays(daysToAdd);
    }
}
