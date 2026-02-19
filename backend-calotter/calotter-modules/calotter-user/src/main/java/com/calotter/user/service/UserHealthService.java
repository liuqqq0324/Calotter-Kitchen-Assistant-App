package com.calotter.user.service;

import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HealthGoalRepository;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.service.ai.AiNutritionRecommendationService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.util.Map;
import java.util.Optional;

/**
 * 用户健康服务
 * 提供 BMI 和目标营养数据
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserHealthService {
    
    private final UserRepository userRepository;
    private final HealthGoalRepository healthGoalRepository;
    private final AiNutritionRecommendationService aiNutritionService;
    
    /**
     * 获取用户的健康信息（BMI 和目标营养）
     * 
     * @param userId 用户ID
     * @return 健康信息
     */
    @Transactional(readOnly = true)
    public UserHealthInfo getUserHealthInfo(Long userId) {
        // 1. 查找用户
        Optional<User> userOpt = userRepository.findById(userId);
        
        if (userOpt.isEmpty()) {
            return UserHealthInfo.empty();
        }
        
        User user = userOpt.get();
        
        // 2. 获取健康目标（使用 User 而不是 FamilyMember）
        HealthGoal goal = healthGoalRepository.findByUserAndStatus(user, 1); // 1=ACTIVE
        
        UserHealthInfo info = new UserHealthInfo();
        
        // 3. 计算 BMI（使用 User 的字段）
        // 优先使用User的当前数据，如果没有则使用健康目标的数据
        if (user.getCurrentHeight() != null && user.getCurrentWeight() != null) {
            BigDecimal bmi = calculateBMI(user.getCurrentHeight(), user.getCurrentWeight().intValue());
            info.setBmi(bmi);
        } else if (goal != null && goal.getHeight() != null && goal.getStartWeight() != null) {
            BigDecimal bmi = calculateBMI(goal.getHeight(), goal.getStartWeight().intValue());
            info.setBmi(bmi);
        }
        // 如果都没有，BMI保持为null（前端会显示"--"）
        
        // 4. 获取目标营养数据
        if (goal != null) {
            info.setGoalType(goal.getGoalType() != null ? goal.getGoalType().name() : "MAINTENANCE");
            info.setDailyEnergy(goal.getDailyCalories());
            info.setDailyProtein(goal.getProtein());
            info.setDailyFat(goal.getFat());
            info.setDailyCarbohydrates(goal.getCarb());
            info.setDailyFiber(goal.getFiber());
        } else {
            info.setGoalType("MAINTENANCE");
            // 使用默认值
            info.setDailyEnergy(2000);
            info.setDailyProtein(70);
            info.setDailyFat(50);
            info.setDailyCarbohydrates(150);
            info.setDailyFiber(25);
        }
        
        return info;
    }
    
    /**
     * 创建或更新用户的健康目标
     * 
     * @param userId 用户ID
     * @param goalType 目标类型
     * @param activityLevel 活动水平
     * @return 创建或更新的健康目标
     */
    @Transactional
    public HealthGoal createOrUpdateHealthGoal(Long userId, HealthGoal.GoalType goalType, Double activityLevel) {
        // activityLevel 可以为空，如果为空则使用默认值 1.55
        if (activityLevel == null) {
            activityLevel = 1.55;
        }
        // 1. 查找用户
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在: " + userId));
        
        // 2. 验证用户身体信息
        log.info("🔍 验证用户身体信息:");
        log.info("   User.currentHeight: {}", user.getCurrentHeight());
        log.info("   User.currentWeight: {}", user.getCurrentWeight());
        
        if (user.getCurrentHeight() == null || user.getCurrentWeight() == null) {
            log.warn("   ⚠️ User 实体字段为空，尝试从 settings.profile 同步数据");
            
            // 尝试从 settings.profile 中获取并同步
            Map<String, Object> settings = user.getSettings();
            if (settings != null) {
                log.info("   User.settings 存在，查找 profile 数据");
                @SuppressWarnings("unchecked")
                Map<String, Object> profile = (Map<String, Object>) settings.get("profile");
                if (profile != null) {
                    log.info("   User.settings.profile 存在，查找 height 和 weight");
                    Object heightObj = profile.get("height");
                    Object weightObj = profile.get("weight");
                    log.info("   从 settings.profile 获取: height={} (type: {}), weight={} (type: {})", 
                            heightObj, heightObj != null ? heightObj.getClass().getSimpleName() : "null",
                            weightObj, weightObj != null ? weightObj.getClass().getSimpleName() : "null");
                    
                    if (heightObj != null && weightObj != null) {
                        // 同步到 User 实体字段
                        try {
                            Integer height = Integer.parseInt(heightObj.toString());
                            BigDecimal weight = new BigDecimal(weightObj.toString());
                            user.setCurrentHeight(height);
                            user.setCurrentWeight(weight);
                            userRepository.save(user);
                            log.info("   ✅ 已同步 profile 数据到 User 实体字段: height={}cm, weight={}kg", height, weight);
                        } catch (Exception e) {
                            log.error("   ❌ 同步 profile 数据失败: {}", e.getMessage(), e);
                        }
                    } else {
                        log.warn("   ⚠️ settings.profile 中 height 或 weight 为 null");
                    }
                } else {
                    log.warn("   ⚠️ User.settings.profile 不存在");
                }
            } else {
                log.warn("   ⚠️ User.settings 为 null");
            }
            
            // 再次检查
            if (user.getCurrentHeight() == null || user.getCurrentWeight() == null) {
                log.error("   ❌ 用户身高或体重信息不完整，无法创建健康目标");
                log.error("   最终状态: currentHeight={}, currentWeight={}", 
                        user.getCurrentHeight(), user.getCurrentWeight());
                throw new IllegalArgumentException("用户身高或体重信息不完整，请先完善个人信息");
            }
        }
        
        log.info("   ✅ 用户身体信息验证通过: height={}cm, weight={}kg", 
                user.getCurrentHeight(), user.getCurrentWeight());
        
        // 3. 计算BMI（用于AI服务）
        BigDecimal bmi = calculateBMI(user.getCurrentHeight(), user.getCurrentWeight().intValue());
        
        // 4. 计算年龄
        Integer age = calculateAge(user.getBirthdate());
        
        // 5. 查找是否已有活跃的健康目标
        HealthGoal existingGoal = healthGoalRepository.findByUserAndStatus(user, 1); // 1=ACTIVE
        
        HealthGoal goal;
        if (existingGoal != null) {
            // 更新现有目标：先归档旧的
            existingGoal.setStatus(0); // 0=ARCHIVED
            healthGoalRepository.save(existingGoal);
            
            // 创建新的活跃目标
            goal = new HealthGoal();
        } else {
            // 创建新目标
            goal = new HealthGoal();
        }
        
        // 6. 设置基本信息
        goal.setUser(user);
        goal.setStatus(1); // 1=ACTIVE
        goal.setGoalType(goalType);
        goal.setActivityLevel(activityLevel);
        goal.setHeight(user.getCurrentHeight());
        goal.setStartWeight(user.getCurrentWeight());
        goal.setAge(age);
        
        // 7. 调用AI服务获取营养建议
        log.info("🤖 准备调用 AI 服务获取营养建议");
        log.info("   用户信息: 身高={}cm, 体重={}kg, 年龄={}, 性别={}, BMI={}, 目标类型={}, 活动水平={}", 
                user.getCurrentHeight(), user.getCurrentWeight(), age, user.getGender(), bmi, goalType, activityLevel);
        
        try {
            AiNutritionRecommendationService.NutritionRecommendation recommendation = 
                    aiNutritionService.getNutritionRecommendation(
                        user.getCurrentHeight(),
                        user.getCurrentWeight(),
                        age,
                        user.getGender(),
                        bmi,
                        goalType,
                        activityLevel
                    );
            
            if (recommendation != null) {
                log.info("✅ AI 服务返回营养建议:");
                log.info("   卡路里: {}, 蛋白质: {}g, 脂肪: {}g, 碳水: {}g, 纤维: {}g",
                        recommendation.getDailyCalories(),
                        recommendation.getProtein(),
                        recommendation.getFat(),
                        recommendation.getCarb(),
                        recommendation.getFiber());
                
                goal.setDailyCalories(recommendation.getDailyCalories());
                goal.setProtein(recommendation.getProtein());
                goal.setFat(recommendation.getFat());
                goal.setCarb(recommendation.getCarb());
                goal.setFiber(recommendation.getFiber());
            } else {
                // AI 返回 null，执行科学公式兜底
                calculateNutritionFallback(goal, user, age, activityLevel, goalType);
            }
        } catch (Exception e) {
            log.error("❌ 调用 AI 服务获取营养建议失败，执行科学公式兜底", e);
            log.error("   异常信息: {}", e.getMessage());
            calculateNutritionFallback(goal, user, age, activityLevel, goalType);
        }
        
        log.info("📊 最终保存的营养数据:");
        log.info("   卡路里: {}, 蛋白质: {}g, 脂肪: {}g, 碳水: {}g, 纤维: {}g",
                goal.getDailyCalories(), goal.getProtein(), goal.getFat(), 
                goal.getCarb(), goal.getFiber());
        
        // 8. 保存到数据库
        HealthGoal savedGoal = healthGoalRepository.save(goal);
        log.info("💾 健康目标已保存到数据库");
        log.info("   目标ID: {}", savedGoal.getId());
        log.info("   目标类型: {}", savedGoal.getGoalType());
        log.info("   保存后的营养数据: 卡路里={}, 蛋白质={}g, 脂肪={}g, 碳水={}g, 纤维={}g",
                savedGoal.getDailyCalories(), savedGoal.getProtein(), 
                savedGoal.getFat(), savedGoal.getCarb(), savedGoal.getFiber());
        return savedGoal;
    }
    
    /**
     * AI 失败时的科学公式兜底计算 (Mifflin-St Jeor 公式)
     */
    private void calculateNutritionFallback(HealthGoal goal, User user, Integer age, Double activityLevel, HealthGoal.GoalType goalType) {
        log.info("🧪 执行 Mifflin-St Jeor 公式计算营养目标...");
        
        double weight = user.getCurrentWeight().doubleValue();
        double height = user.getCurrentHeight().doubleValue();
        int ageVal = (age != null) ? age : 25;
        int gender = 1; // 默认男性
        if (user.getGender() != null) {
            gender = user.getGender();
        }

        // 1. 计算 BMR
        double bmr;
        if (gender == 2) { // Female
            bmr = (10 * weight) + (6.25 * height) - (5 * ageVal) - 161;
        } else { // Male
            bmr = (10 * weight) + (6.25 * height) - (5 * ageVal) + 5;
        }

        // 2. 计算 TDEE
        double tdee = bmr * activityLevel;
        
        // 3. 根据目标调整
        int dailyCalories;
        double proteinRatio; // 每公斤体重蛋白质克数
        double fatPercentage = 0.25; // 脂肪占总热量比例

        if (goalType == HealthGoal.GoalType.LOSE_FAT) {
            dailyCalories = (int) (tdee - 500);
            proteinRatio = 1.8; // 减脂期高蛋白
        } else if (goalType == HealthGoal.GoalType.MUSCLE_GAIN) {
            dailyCalories = (int) (tdee + 300);
            proteinRatio = 2.0; // 增肌期极高蛋白
        } else {
            dailyCalories = (int) tdee;
            proteinRatio = 1.2; // 维持期适中蛋白
        }

        // 限制最低热量，防止计算出过低数值
        dailyCalories = Math.max(dailyCalories, gender == 2 ? 1200 : 1500);

        // 4. 分配宏量营养素
        int protein = (int) (weight * proteinRatio);
        int fat = (int) (dailyCalories * fatPercentage / 9);
        int carb = (dailyCalories - (protein * 4) - (fat * 9)) / 4;
        int fiber = (int) (dailyCalories / 1000.0 * 14); // 每1000大卡14g纤维

        log.info("📊 公式计算结果: Cal={}, P={}g, F={}g, C={}g, Fiber={}g", 
                dailyCalories, protein, fat, carb, fiber);

        goal.setDailyCalories(dailyCalories);
        goal.setProtein(protein);
        goal.setFat(fat);
        goal.setCarb(carb);
        goal.setFiber(fiber);
    }

    /**
     * 计算 BMI
     * 
     * @param height 身高（厘米）
     * @param weight 体重（千克）
     * @return BMI 值
     */
    private BigDecimal calculateBMI(Integer height, Integer weight) {
        if (height == null || weight == null || height == 0) {
            return null;
        }
        BigDecimal heightM = BigDecimal.valueOf(height).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal heightSquared = heightM.multiply(heightM);
        return BigDecimal.valueOf(weight).divide(heightSquared, 2, RoundingMode.HALF_UP);
    }
    
    /**
     * 计算年龄
     * 
     * @param birthdate 生日
     * @return 年龄
     */
    private Integer calculateAge(LocalDate birthdate) {
        if (birthdate == null) {
            return null;
        }
        return Period.between(birthdate, LocalDate.now()).getYears();
    }
    
    /**
     * 用户健康信息
     */
    @Data
    public static class UserHealthInfo {
        private BigDecimal bmi;
        private String goalType;
        private Integer dailyEnergy;
        private Integer dailyProtein;
        private Integer dailyFat;
        private Integer dailyCarbohydrates;
        private Integer dailyFiber;
        
        public static UserHealthInfo empty() {
            UserHealthInfo info = new UserHealthInfo();
            info.setGoalType("MAINTENANCE");
            info.setDailyEnergy(2000);
            info.setDailyProtein(70);
            info.setDailyFat(50);
            info.setDailyCarbohydrates(150);
            info.setDailyFiber(25);
            return info;
        }
    }
}

