package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CookingWorkflowService {

    private final CookingSessionRepository sessionRepository;
    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final IngredientRepository ingredientRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final FavoriteRecipeService favoriteRecipeService;

    @Transactional
    public Long startCooking(StartCookingRequest req) {
        Household household = householdRepository.findById(req.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        Dish dish;
        if (req.getDishId() != null) {
            dish = dishRepository.findById(req.getDishId())
                    .orElseThrow(() -> new IllegalArgumentException("菜品不存在: " + req.getDishId()));
        } else if (req.getRecipe() != null) {
            dish = favoriteRecipeService.ensureDish(req.getHouseholdId(), req.getRecipe(), false);
        } else {
            throw new IllegalArgumentException("必须提供 dishId 或 recipe");
        }

        CookingSession session = new CookingSession();
        session.setHouseholdId(req.getHouseholdId());
        session.setInitiatorId(req.getInitiatorId());
        session.setFinalDish(dish);
        session.setStatus(CookingSession.SessionStatus.PENDING);
        session.setRemainingRatio(1.0);
        session = sessionRepository.save(session);
        return session.getId();
    }

    @Transactional
    public CookingSession finishCooking(FinishCookingRequest req) {
        CookingSession session = sessionRepository.findById(req.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("会话不存在: " + req.getSessionId()));
        if (session.getFinalDish() == null) {
            throw new IllegalStateException("会话未绑定菜品");
        }
        Dish dish = session.getFinalDish();

        // 保存快照
        session.setIngredientsSnapshot(req.getFinalIngredients());
        session.setTotalNutritionSnapshot(req.getTotalNutrition());
        session.setRemainingRatio(1.0);
        session.setStatus(CookingSession.SessionStatus.COOKED);
        sessionRepository.save(session);

        // 扣减库存（如果sourceType是INVENTORY）
        deductInventory(session.getHouseholdId(), req.getFinalIngredients());

        // 生成 Leftover (初始=100%)
        if (dish.getTotalWeightGram() != null && dish.getTotalWeightGram() > 0) {
            LeftoverDish leftover = new LeftoverDish();
            leftover.setHousehold(householdRepository.findById(session.getHouseholdId())
                    .orElseThrow(() -> new IllegalArgumentException("家庭不存在")));
            leftover.setOriginalDishId(dish.getId());
            leftover.setCurrentQuantityGram(dish.getTotalWeightGram());
            leftover.setProducedTime(LocalDateTime.now());
            leftoverDishRepository.save(leftover);
        }

        // 发布事件给健康模块
        CookingSessionCompletedEvent.DishNutritionSnapshot snapshot =
                CookingSessionCompletedEvent.DishNutritionSnapshot.builder()
                        .totalCalories(toInt(req.getTotalNutrition().getCalories()))
                        .totalProtein(req.getTotalNutrition().getProtein())
                        .totalFat(req.getTotalNutrition().getFat())
                        .totalCarb(req.getTotalNutrition().getCarbs())
                        .totalFiber(null) // FinishCookingRequest中没有fiber字段
                        .totalWeightGram(dish.getTotalWeightGram())
                        .build();
        CookingSessionCompletedEvent event = new CookingSessionCompletedEvent(
                this,
                dish.getId(),
                dish.getName(),
                snapshot,
                List.of(), // 此处未传个人分餐，保留兼容
                LocalDateTime.now(),
                "DINNER"
        );
        eventPublisher.publishEvent(event);

        return session;
    }

    /**
     * 扣减库存
     * 根据ingredient name匹配库存并扣减
     */
    private void deductInventory(Long householdId, List<FinishCookingRequest.FinalIngredient> ingredients) {
        List<Ingredient> householdIngredients = ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
        
        for (FinishCookingRequest.FinalIngredient reqIng : ingredients) {
            // 只处理INVENTORY类型的食材
            if (!"INVENTORY".equalsIgnoreCase(reqIng.getSourceType())) {
                continue;
            }
            
            String reqName = reqIng.getName().toLowerCase().trim();
            Double reqAmount = reqIng.getAmountValue();
            String reqUnit = reqIng.getAmountUnit();
            
            if (reqAmount == null || reqAmount <= 0) {
                continue;
            }
            
            // 查找匹配的库存食材（名称模糊匹配）
            Optional<Ingredient> matched = householdIngredients.stream()
                    .filter(ing -> {
                        String ingName = ing.getMetadata().getName().toLowerCase().trim();
                        // 简单匹配：包含关系或完全匹配
                        return ingName.equals(reqName) || 
                               ingName.contains(reqName) || 
                               reqName.contains(ingName);
                    })
                    .findFirst();
            
            if (matched.isPresent()) {
                Ingredient ingredient = matched.get();
                Double currentQuantity = ingredient.getQuantity();
                String currentUnit = ingredient.getUnit();
                
                // 单位转换和扣减
                Double amountToDeduct = convertUnit(reqAmount, reqUnit, currentUnit);
                
                if (amountToDeduct != null && currentQuantity >= amountToDeduct) {
                    ingredient.setQuantity(currentQuantity - amountToDeduct);
                    ingredientRepository.save(ingredient);
                    log.info("扣减库存: {} {} -> {} {}", 
                            ingredient.getMetadata().getName(), 
                            currentQuantity, 
                            ingredient.getQuantity(), 
                            currentUnit);
                } else {
                    log.warn("库存不足或单位转换失败: {} 需要 {} {}，当前 {} {}", 
                            reqName, reqAmount, reqUnit, currentQuantity, currentUnit);
                }
            } else {
                log.warn("未找到匹配的库存食材: {}", reqName);
            }
        }
    }
    
    /**
     * 单位转换
     * 简化实现：只处理相同单位的情况
     * 实际应用中可能需要更复杂的转换逻辑
     */
    private Double convertUnit(Double amount, String fromUnit, String toUnit) {
        if (fromUnit == null || toUnit == null) {
            return null;
        }
        
        // 相同单位直接返回
        if (fromUnit.equalsIgnoreCase(toUnit)) {
            return amount;
        }
        
        // 简化处理：g和ml视为相同（实际应用中需要更精确的转换）
        if (("g".equalsIgnoreCase(fromUnit) && "ml".equalsIgnoreCase(toUnit)) ||
            ("ml".equalsIgnoreCase(fromUnit) && "g".equalsIgnoreCase(toUnit))) {
            return amount; // 假设1g = 1ml（简化处理）
        }
        
        // 其他情况返回null，表示无法转换
        log.warn("单位转换不支持: {} {} -> {}", amount, fromUnit, toUnit);
        return null;
    }

    private Integer toInt(Double v) {
        return v == null ? null : v.intValue();
    }
}
