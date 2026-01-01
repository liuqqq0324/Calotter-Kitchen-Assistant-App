package com.calotter.user.service;

import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HealthGoalRepository;
import com.calotter.user.repository.UserRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Optional;

/**
 * 用户健康服务
 * 提供 BMI 和目标营养数据
 */
@Service
@RequiredArgsConstructor
public class UserHealthService {
    
    private final UserRepository userRepository;
    private final HealthGoalRepository healthGoalRepository;
    
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
        if (user.getCurrentHeight() != null && user.getCurrentWeight() != null) {
            info.setBmi(calculateBMI(user.getCurrentHeight(), user.getCurrentWeight().intValue()));
        } else if (goal != null && goal.getHeight() != null && goal.getStartWeight() != null) {
            info.setBmi(calculateBMI(goal.getHeight(), goal.getStartWeight().intValue()));
        }
        
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

