package com.calotter.health.service.scheduler;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 剩菜转换定时任务
 * 每天凌晨执行，将前一天未完全消费的菜品转为剩菜存入 inventory
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LeftoverConversionScheduler {
    
    private final NutritionLogRepository nutritionLogRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final HouseholdRepository householdRepository;
    private final UserRepository userRepository;
    
    /**
     * 每天凌晨2点执行，处理前一天的未完全消费的菜品
     * cron表达式: 秒 分 时 日 月 周
     * "0 0 2 * * ?" 表示每天凌晨2点执行
     */
    @Scheduled(cron = "0 0 2 * * ?")
    @Transactional
    public void convertLeftoversFromPreviousDay() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        log.info("开始处理前一天的未完全消费菜品，日期: {}", yesterday);
        
        // 1. 查询前一天所有来自烹饪的 NutritionLog，且 consumedPercentage < 100%
        List<NutritionLog> incompleteLogs = nutritionLogRepository.findAll().stream()
                .filter(log -> log.getLogDate().equals(yesterday))
                .filter(log -> log.getSourceType() == LogSourceType.APP_COOKING)
                .filter(log -> log.getDishId() != null)
                .filter(log -> log.getConsumedPercentage() != null && 
                        log.getConsumedPercentage().compareTo(BigDecimal.valueOf(100)) < 0)
                .toList();
        
        if (incompleteLogs.isEmpty()) {
            log.info("前一天没有未完全消费的菜品");
            return;
        }
        
        log.info("找到 {} 条未完全消费的记录", incompleteLogs.size());
        
        // 2. 按 dishId 和 user 分组，计算剩余部分
        for (NutritionLog nutritionLog : incompleteLogs) {
            try {
                // 计算剩余百分比
                BigDecimal remainingPercentage = BigDecimal.valueOf(100)
                        .subtract(nutritionLog.getConsumedPercentage())
                        .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                
                // 计算剩余重量（基于基础营养值中的 quantity）
                // 注意：这里需要从 Dish 获取 totalWeightGram，但由于跨模块限制，暂时使用 quantity
                // 实际应用中，可能需要通过 DishService 获取 Dish 信息
                Double baseQuantity = nutritionLog.getQuantity() != null ? 
                        nutritionLog.getQuantity() / (nutritionLog.getConsumedPercentage().doubleValue() / 100.0) : null;
                
                if (baseQuantity == null || baseQuantity <= 0) {
                    log.warn("无法计算剩余重量，跳过记录 ID: {}", nutritionLog.getId());
                    continue;
                }
                
                Integer remainingGram = (int)(baseQuantity * remainingPercentage.doubleValue());
                
                if (remainingGram <= 0) {
                    log.debug("剩余重量为0，跳过记录 ID: {}", nutritionLog.getId());
                    continue;
                }
                
                // 3. 获取用户的 Household（优先使用 currentHouseholdId，否则使用第一个 joinedHousehold）
                User user = nutritionLog.getUser();
                Household household = null;
                
                // 优先使用 currentHouseholdId
                if (user.getCurrentHouseholdId() != null) {
                    household = householdRepository.findById(user.getCurrentHouseholdId()).orElse(null);
                }
                
                // 如果 currentHouseholdId 不存在或无效，尝试从 joinedHouseholds 获取第一个
                if (household == null) {
                    // 重新加载用户以获取 joinedHouseholds（避免懒加载问题）
                    User loadedUser = userRepository.findById(user.getId()).orElse(null);
                    if (loadedUser != null && loadedUser.getJoinedHouseholds() != null 
                            && !loadedUser.getJoinedHouseholds().isEmpty()) {
                        household = loadedUser.getJoinedHouseholds().get(0);
                    }
                }
                
                if (household == null) {
                    log.warn("用户没有关联的家庭，跳过记录 ID: {}, 用户 ID: {}", 
                            nutritionLog.getId(), user.getId());
                    continue;
                }
                
                // 4. 创建 LeftoverDish
                LeftoverDish leftover = new LeftoverDish();
                leftover.setHousehold(household);
                leftover.setOriginalDishId(nutritionLog.getDishId());
                leftover.setCurrentQuantityGram(remainingGram);
                leftover.setProducedTime(nutritionLog.getEatenAt());
                leftoverDishRepository.save(leftover);
                
                log.info("成功创建剩菜: Dish ID={}, 剩余重量={}g, 用户 ID={}, 家庭 ID={}", 
                        nutritionLog.getDishId(), remainingGram, nutritionLog.getUser().getId(), household.getId());
                
            } catch (Exception e) {
                log.error("处理记录失败，记录 ID: {}", nutritionLog.getId(), e);
            }
        }
        
        log.info("完成处理前一天的未完全消费菜品");
    }
}

