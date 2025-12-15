package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.CookingCompletionRequest;
import com.calotter.cooking.controller.dto.CookingCompletionResponse;
import com.calotter.cooking.controller.dto.LeftoverAction;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 烹饪会话服务
 * 负责完成烹饪会话，处理剩菜，发布事件触发健康日志创建
 */
@Service
@RequiredArgsConstructor
public class CookingSessionService {
    
    private final CookingSessionRepository sessionRepository;
    private final DishService dishService;
    private final HouseholdRepository householdRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final ApplicationEventPublisher eventPublisher;
    
    /**
     * 完成烹饪会话
     * 
     * @param req 完成请求
     * @return 完成响应
     */
    @Transactional
    public CookingCompletionResponse completeSession(CookingCompletionRequest req) {
        // 1. 获取 Session 和 Household
        CookingSession session = sessionRepository.findById(req.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("烹饪会话不存在: " + req.getSessionId()));
        
        Household household = householdRepository.findById(session.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在: " + session.getHouseholdId()));
        
        // 2. 创建或获取Dish快照
        Dish dish = session.getFinalDish();
        if (dish == null) {
            if (session.getAiResponse() == null) {
                throw new IllegalArgumentException("AI响应数据不存在，无法创建Dish快照");
            }
            // 从AiRecipeResponse创建Dish快照
            dish = dishService.createDishFromAiResponse(session.getAiResponse(), household);
            session.setFinalDish(dish);
            sessionRepository.save(session);
        }
        
        // 3. 计算总消费比例
        double totalConsumedPercentage = req.getDiners().stream()
                .mapToDouble(CookingCompletionRequest.DinerConsumption::getPortionPercentage)
                .sum();
        
        // 4. 处理剩菜（基于Dish）
        double remainingPercentage = 1.0 - totalConsumedPercentage;
        boolean leftoverCreated = false;
        
        if (remainingPercentage > 0.05 && 
            req.getLeftoverHandling() != null &&
            req.getLeftoverHandling().getAction() == LeftoverAction.SAVE_TO_FRIDGE) {
            
            LeftoverDish leftover = new LeftoverDish();
            leftover.setHousehold(household);
            leftover.setOriginalDishId(dish.getId()); // ✅ 关联Dish（弱引用）
            leftover.setCurrentQuantityGram((int)(dish.getTotalWeightGram() * remainingPercentage));
            leftover.setProducedTime(req.getConsumedAt());
            // 无需存储name和coverImage，通过LeftoverDishService查询Dish获取
            
            leftoverDishRepository.save(leftover);
            leftoverCreated = true;
        }
        
        // 5. 更新 Session 状态
        session.setStatus(CookingSession.SessionStatus.COOKED);
        sessionRepository.save(session);
        
        // 6. ✅ 发布事件（触发health模块创建NutritionLog，避免循环依赖）
        // 构建事件数据，包含创建NutritionLog所需的所有信息
        CookingSessionCompletedEvent.DishNutritionSnapshot nutritionSnapshot = 
                new CookingSessionCompletedEvent.DishNutritionSnapshot(
                        dish.getTotalCalories(),
                        dish.getTotalProtein(),
                        dish.getTotalFat(),
                        dish.getTotalCarb(),
                        dish.getTotalFiber(),
                        dish.getTotalWeightGram());
        
        // 转换用餐者数据
        List<CookingSessionCompletedEvent.DinerConsumptionData> dinerData = req.getDiners().stream()
                .map(diner -> new CookingSessionCompletedEvent.DinerConsumptionData(
                        diner.getFamilyMemberId(),
                        diner.getPortionPercentage(),
                        diner.getNote()))
                .toList();
        
        CookingSessionCompletedEvent event = new CookingSessionCompletedEvent(
                this,
                dish.getId(),
                dish.getName(),
                nutritionSnapshot,
                dinerData,
                req.getConsumedAt(),
                determineMealType(req.getConsumedAt()));
        
        eventPublisher.publishEvent(event);
        
        // 7. 计算总卡路里
        int totalCaloriesConsumed = 0;
        if (dish.getTotalCalories() != null) {
            totalCaloriesConsumed = (int)(dish.getTotalCalories() * totalConsumedPercentage);
        }
        
        return CookingCompletionResponse.builder()
                .success(true)
                .logsCreated(req.getDiners().size())
                .leftoverCreated(leftoverCreated)
                .totalCaloriesConsumed(totalCaloriesConsumed)
                .message("烹饪结束！摄入已记录" + (leftoverCreated ? "，剩余菜品已存入冰箱。" : "。"))
                .build();
    }
    
    /**
     * 根据时间判断餐次类型
     * 
     * @param dateTime 时间
     * @return 餐次类型字符串（BREAKFAST, LUNCH, DINNER, SNACK）
     */
    private String determineMealType(LocalDateTime dateTime) {
        int hour = dateTime.getHour();
        if (hour >= 5 && hour < 10) return "BREAKFAST";
        if (hour >= 10 && hour < 15) return "LUNCH";
        if (hour >= 15 && hour < 21) return "DINNER";
        return "SNACK";
    }
}

