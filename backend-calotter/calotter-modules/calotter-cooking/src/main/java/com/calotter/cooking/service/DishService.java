package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.enums.CookingCategory;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.AiRecipeResponse;
import com.calotter.user.domain.entity.Household;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Dish服务
 * 负责从AiRecipeResponse创建Dish快照
 */
@Service
@RequiredArgsConstructor
public class DishService {
    
    private final DishRepository dishRepository;
    
    /**
     * 从AI响应创建Dish快照
     * 
     * @param aiResponse AI响应
     * @param household 所属家庭
     * @return 创建的Dish实体
     */
    @Transactional
    public Dish createDishFromAiResponse(AiRecipeResponse aiResponse, Household household) {
        if (aiResponse == null || aiResponse.getDishes() == null || aiResponse.getDishes().isEmpty()) {
            throw new IllegalArgumentException("AI响应数据不完整，无法创建Dish快照");
        }
        
        // 取第一个菜品作为主菜（通常AI返回的第一个是主菜）
        AiRecipeResponse.GeneratedDish mainDish = aiResponse.getDishes().get(0);
        
        Dish dish = new Dish();
        dish.setHousehold(household);
        
        // 基础信息
        dish.setName(mainDish.getDishName());
        dish.setDescription(mainDish.getDescription());
        dish.setCookingTimeMinutes(mainDish.getTotalTimeMin());
        
        // 难度转换
        if (mainDish.getDifficulty() != null) {
            try {
                dish.setDifficulty(DifficultyLevel.valueOf(mainDish.getDifficulty().toUpperCase()));
            } catch (IllegalArgumentException e) {
                // 如果无法转换，默认使用MEDIUM
                dish.setDifficulty(DifficultyLevel.MEDIUM);
            }
        }
        
        // 分类转换
        if (mainDish.getCategory() != null) {
            try {
                dish.setCategory(CookingCategory.valueOf(mainDish.getCategory().toUpperCase()));
            } catch (IllegalArgumentException e) {
                // 如果无法转换，设置为null（允许为空）
                dish.setCategory(null);
            }
        }
        
        // 营养信息（从totalNutrition获取）
        if (aiResponse.getTotalNutrition() != null) {
            AiRecipeResponse.NutritionSummary nutrition = aiResponse.getTotalNutrition();
            dish.setTotalCalories(nutrition.getCalories());
            dish.setTotalProtein(nutrition.getProtein() != null ? nutrition.getProtein().doubleValue() : null);
            dish.setTotalFat(nutrition.getFat() != null ? nutrition.getFat().doubleValue() : null);
            dish.setTotalCarb(nutrition.getCarb() != null ? nutrition.getCarb().doubleValue() : null);
            dish.setTotalFiber(nutrition.getFiber() != null ? nutrition.getFiber().doubleValue() : null);
        }
        
        // 计算总重量（通过累加所有食材的重量）
        Integer totalWeight = calculateTotalWeight(aiResponse);
        dish.setTotalWeightGram(totalWeight);
        
        // 烹饪步骤
        if (mainDish.getSteps() != null) {
            List<Dish.CookingStep> steps = mainDish.getSteps().stream()
                    .map(step -> {
                        Dish.CookingStep dishStep = new Dish.CookingStep();
                        dishStep.setStepNumber(step.getStepNumber());
                        dishStep.setInstruction(step.getInstruction());
                        dishStep.setTimeMin(step.getTimeMin());
                        return dishStep;
                    })
                    .collect(Collectors.toList());
            dish.setSteps(steps);
        }
        
        // 原料快照
        if (mainDish.getIngredients() != null) {
            List<Dish.IngredientSnapshot> snapshots = mainDish.getIngredients().stream()
                    .map(ing -> {
                        Dish.IngredientSnapshot snapshot = new Dish.IngredientSnapshot();
                        snapshot.setName(ing.getName());
                        snapshot.setAmountValue(ing.getAmountValue() != null ? ing.getAmountValue() : 0.0);
                        snapshot.setAmountUnit(ing.getAmountUnit() != null ? ing.getAmountUnit() : "g");
                        return snapshot;
                    })
                    .collect(Collectors.toList());
            dish.setIngredientSnapshots(snapshots);
        }
        
        // 标签（暂时为空，后续可以从AI响应中提取）
        dish.setTags(new ArrayList<>());
        
        return dishRepository.save(dish);
    }
    
    /**
     * 计算食谱总重量
     * 通过累加所有食材的重量（需要统一单位转换）
     * 
     * @param aiResponse AI响应
     * @return 总重量（克）
     */
    private Integer calculateTotalWeight(AiRecipeResponse aiResponse) {
        if (aiResponse.getDishes() == null) {
            return 0;
        }
        
        int totalWeight = 0;
        for (AiRecipeResponse.GeneratedDish dish : aiResponse.getDishes()) {
            if (dish.getIngredients() != null) {
                for (AiRecipeResponse.RequiredIngredient ing : dish.getIngredients()) {
                    // 简化实现：只累加单位为"g"的食材
                    // 实际应用中可能需要更复杂的单位转换逻辑
                    if ("g".equalsIgnoreCase(ing.getAmountUnit()) && ing.getAmountValue() != null) {
                        totalWeight += ing.getAmountValue().intValue();
                    }
                }
            }
        }
        
        // 如果总重量为0，设置一个默认值（避免除零错误）
        return totalWeight > 0 ? totalWeight : 1000; // 默认1kg
    }
}

