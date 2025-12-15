package com.calotter.health.service;

import com.calotter.cooking.service.LeftoverDishService;
import com.calotter.cooking.service.dto.NutritionInfo;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.domain.enums.MealType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.event.NutritionLogCreatedEvent;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.repository.FamilyMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 营养日志服务
 * 负责创建营养日志记录
 */
@Service
@RequiredArgsConstructor
public class NutritionLogService {
    
    private final NutritionLogRepository nutritionLogRepository;
    private final FamilyMemberRepository familyMemberRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final LeftoverDishService leftoverDishService;
    private final ApplicationEventPublisher eventPublisher;
    
    /**
     * 从烹饪完成事件创建营养日志
     * 由事件监听器调用
     * 
     * @param event 烹饪完成事件
     * @return 创建的营养日志列表
     */
    @Transactional
    public List<NutritionLog> createFromEvent(CookingSessionCompletedEvent event) {
        List<NutritionLog> logs = new ArrayList<>();
        
        // 转换MealType字符串为枚举
        MealType mealType;
        try {
            mealType = MealType.valueOf(event.getMealType());
        } catch (IllegalArgumentException e) {
            mealType = MealType.SNACK; // 默认值
        }
        
        // 为每个用餐者创建日志
        for (CookingSessionCompletedEvent.DinerConsumptionData diner : event.getDiners()) {
            FamilyMember member = familyMemberRepository.findById(diner.getFamilyMemberId())
                    .orElseThrow(() -> new IllegalArgumentException("家庭成员不存在: " + diner.getFamilyMemberId()));
            
            NutritionLog log = new NutritionLog();
            log.setFamilyMember(member);
            log.setDishId(event.getDishId()); // ✅ 使用弱引用关联Dish
            log.setLogDate(event.getConsumedAt().toLocalDate());
            log.setSourceType(LogSourceType.APP_COOKING);
            log.setFoodName(event.getDishName()); // ✅ 存储快照（从事件获取）
            log.setEatenAt(event.getConsumedAt());
            log.setMealType(mealType);
            
            // ✅ 基于事件中的Dish营养快照计算并存储快照值
            double ratio = diner.getPortionPercentage();
            CookingSessionCompletedEvent.DishNutritionSnapshot nutrition = event.getDishNutrition();
            
            log.setCalories(nutrition.getTotalCalories() != null ? 
                    (int) (nutrition.getTotalCalories() * ratio) : null);
            log.setProtein(nutrition.getTotalProtein() != null ? 
                    nutrition.getTotalProtein() * ratio : null);
            log.setFat(nutrition.getTotalFat() != null ? 
                    nutrition.getTotalFat() * ratio : null);
            log.setCarb(nutrition.getTotalCarb() != null ? 
                    nutrition.getTotalCarb() * ratio : null);
            log.setFiber(nutrition.getTotalFiber() != null ? 
                    nutrition.getTotalFiber() * ratio : null);
            log.setQuantity(nutrition.getTotalWeightGram() != null ? 
                    (double)(nutrition.getTotalWeightGram() * ratio) : null);
            log.setUnit("g");
            
            logs.add(log);
        }
        
        // 保存所有日志
        List<NutritionLog> savedLogs = nutritionLogRepository.saveAll(logs);
        
        // 发布事件，触发聚合表更新
        eventPublisher.publishEvent(new NutritionLogCreatedEvent(this, savedLogs));
        
        return savedLogs;
    }
    
    /**
     * 从剩菜创建营养日志
     * 
     * @param leftoverId 剩菜ID
     * @param memberId 家庭成员ID
     * @param consumedGram 食用重量（克）
     * @param eatenAt 进食时间
     * @return 创建的营养日志
     */
    @Transactional
    public NutritionLog createFromLeftover(Long leftoverId, Long memberId, 
                                           Integer consumedGram, LocalDateTime eatenAt) {
        // 1. 查询LeftoverDish
        LeftoverDish leftover = leftoverDishRepository.findById(leftoverId)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在: " + leftoverId));
        
        // 2. 先验证食用重量（早验证早失败，避免不必要的服务调用）
        if (consumedGram == null || consumedGram <= 0) {
            throw new IllegalArgumentException("食用重量必须大于0");
        }
        if (consumedGram > leftover.getCurrentQuantityGram()) {
            throw new IllegalArgumentException(
                    String.format("食用重量(%d克)超过剩余重量(%d克)", 
                            consumedGram, leftover.getCurrentQuantityGram()));
        }
        
        // 3. 查询家庭成员
        FamilyMember member = familyMemberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("家庭成员不存在: " + memberId));
        
        // 4. 使用LeftoverDishService计算营养（该Service在cooking模块）
        // 注意：calculateNutritionForConsumption内部也会验证重量，但这里已经提前验证了
        NutritionInfo nutritionInfo = leftoverDishService
                .calculateNutritionForConsumption(leftoverId, consumedGram);
        
        // 5. 获取剩菜详情（包含Dish信息）
        com.calotter.cooking.service.dto.LeftoverDishDetailDTO leftoverDetail = 
                leftoverDishService.getLeftoverDishDetail(leftoverId);
        
        // 6. 创建NutritionLog
        NutritionLog log = new NutritionLog();
        log.setFamilyMember(member);
        log.setDishId(leftover.getOriginalDishId()); // ✅ 使用弱引用存储Dish ID
        log.setSourceType(LogSourceType.LEFTOVER);
        log.setFoodName(leftoverDetail.getName()); // ✅ 从LeftoverDishService获取
        log.setEatenAt(eatenAt);
        log.setMealType(determineMealType(eatenAt));
        log.setQuantity((double)consumedGram);
        log.setUnit("g");
        log.setLogDate(eatenAt.toLocalDate());
        
        // 7. 设置营养数据（从NutritionInfo，这些是计算后的实际摄入量）
        log.setCalories(nutritionInfo.getCalories());
        log.setProtein(nutritionInfo.getProtein());
        log.setFat(nutritionInfo.getFat());
        log.setCarb(nutritionInfo.getCarb());
        log.setFiber(nutritionInfo.getFiber());
        
        // 8. 保存日志
        NutritionLog savedLog = nutritionLogRepository.save(log);
        
        // 9. 更新LeftoverDish的剩余重量
        leftover.setCurrentQuantityGram(leftover.getCurrentQuantityGram() - consumedGram);
        leftoverDishRepository.save(leftover);
        
        // 10. 发布事件，触发聚合表更新
        eventPublisher.publishEvent(new NutritionLogCreatedEvent(this, List.of(savedLog)));
        
        return savedLog;
    }
    
    /**
     * 手动创建营养日志
     * 
     * @param request 手动记录请求
     * @return 创建的营养日志
     */
    @Transactional
    public NutritionLog createManual(ManualNutritionLogRequest request) {
        FamilyMember member = familyMemberRepository.findById(request.getFamilyMemberId())
                .orElseThrow(() -> new IllegalArgumentException("家庭成员不存在: " + request.getFamilyMemberId()));
        
        NutritionLog log = new NutritionLog();
        log.setFamilyMember(member);
        log.setDishId(null); // 手动记录没有Dish关联
        log.setSourceType(LogSourceType.MANUAL);
        log.setFoodName(request.getFoodName());
        log.setEatenAt(request.getEatenAt());
        log.setMealType(request.getMealType() != null ? request.getMealType() : determineMealType(request.getEatenAt()));
        log.setQuantity(request.getQuantity());
        log.setUnit(request.getUnit() != null ? request.getUnit() : "g");
        log.setLogDate(request.getEatenAt().toLocalDate());
        
        // 设置营养数据
        log.setCalories(request.getCalories());
        log.setProtein(request.getProtein());
        log.setFat(request.getFat());
        log.setCarb(request.getCarb());
        log.setFiber(request.getFiber());
        
        NutritionLog savedLog = nutritionLogRepository.save(log);
        
        // 发布事件，触发聚合表更新
        eventPublisher.publishEvent(new NutritionLogCreatedEvent(this, List.of(savedLog)));
        
        return savedLog;
    }
    
    /**
     * 根据时间判断餐次类型
     */
    private MealType determineMealType(LocalDateTime dateTime) {
        int hour = dateTime.getHour();
        if (hour >= 5 && hour < 10) return MealType.BREAKFAST;
        if (hour >= 10 && hour < 15) return MealType.LUNCH;
        if (hour >= 15 && hour < 21) return MealType.DINNER;
        return MealType.SNACK;
    }
}

