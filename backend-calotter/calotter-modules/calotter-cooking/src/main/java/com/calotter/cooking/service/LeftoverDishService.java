package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.LeftoverDishDetailDTO;
import com.calotter.cooking.service.dto.LeftoverDishSummaryDTO;
import com.calotter.cooking.service.dto.NutritionInfo;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 剩菜业务服务
 * 
 * 职责：
 * 1. 组合 LeftoverDish 和 Dish 的数据
 * 2. 提供剩菜查询、营养计算等业务方法
 * 3. 处理数据组合和转换逻辑
 * 
 * 注意：由于 LeftoverDish 使用弱引用 originalDishId 关联 Dish，
 * 需要通过 DishRepository 查询 Dish 信息。
 */
@Service
@RequiredArgsConstructor
public class LeftoverDishService {
    
    private final LeftoverDishRepository leftoverDishRepository;
    private final DishRepository dishRepository;
    
    /**
     * 根据ID查询剩菜详情
     * 
     * @param leftoverId 剩菜ID
     * @return 剩菜详情DTO
     * @throws IllegalArgumentException 如果剩菜不存在或关联的Dish不存在
     */
    @Transactional(readOnly = true)
    public LeftoverDishDetailDTO getLeftoverDishDetail(Long leftoverId) {
        // 1. 查询 LeftoverDish
        LeftoverDish leftover = leftoverDishRepository.findById(leftoverId)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在: " + leftoverId));
        
        // 2. 查询关联的 Dish
        Dish dish = dishRepository.findById(leftover.getOriginalDishId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "关联的菜品不存在，ID: " + leftover.getOriginalDishId()));
        
        // 3. 计算当前剩菜的营养信息
        NutritionInfo currentNutrition = calculateNutritionByRatio(
                dish, leftover.getCurrentQuantityGram());
        
        // 4. 构建并返回 DTO
        return LeftoverDishDetailDTO.builder()
                .id(leftover.getId())
                .originalDishId(leftover.getOriginalDishId())
                .name(dish.getName())
                .description(dish.getDescription())
                .coverImage(dish.getCoverImage())
                .currentQuantityGram(leftover.getCurrentQuantityGram())
                .producedTime(leftover.getProducedTime())
                .createTime(leftover.getCreateTime())
                .updateTime(leftover.getUpdateTime())
                .currentCalories(currentNutrition.getCalories())
                .caloriesPer100g(dish.getCaloriesPer100g())
                .currentNutrition(currentNutrition)
                .build();
    }
    
    /**
     * 根据家庭ID查询所有剩菜列表（批量优化版本）
     * 
     * @param householdId 家庭ID
     * @return 剩菜摘要DTO列表
     */
    @Transactional(readOnly = true)
    public List<LeftoverDishSummaryDTO> getLeftoverDishesByHousehold(Long householdId) {
        // 1. 批量查询 LeftoverDish
        List<LeftoverDish> leftovers = leftoverDishRepository.findByHouseholdId(householdId);
        
        if (leftovers.isEmpty()) {
            return Collections.emptyList();
        }
        
        // 2. 提取所有 originalDishId
        Set<Long> dishIds = leftovers.stream()
                .map(LeftoverDish::getOriginalDishId)
                .collect(Collectors.toSet());
        
        // 3. 批量查询 Dish（避免 N+1 问题）
        Map<Long, Dish> dishMap = getDishMap(dishIds);
        
        // 4. 组合数据到 DTO 列表
        return leftovers.stream()
                .map(leftover -> {
                    Dish dish = dishMap.get(leftover.getOriginalDishId());
                    // 如果 Dish 不存在，使用默认值（避免因数据不一致导致整个列表查询失败）
                    if (dish == null) {
                        return LeftoverDishSummaryDTO.builder()
                                .id(leftover.getId())
                                .name("未知菜品")
                                .coverImage(null)
                                .currentQuantityGram(leftover.getCurrentQuantityGram())
                                .producedTime(leftover.getProducedTime())
                                .caloriesPer100g(0)
                                .build();
                    }
                    
                    return LeftoverDishSummaryDTO.builder()
                            .id(leftover.getId())
                            .name(dish.getName())
                            .coverImage(dish.getCoverImage())
                            .currentQuantityGram(leftover.getCurrentQuantityGram())
                            .producedTime(leftover.getProducedTime())
                            .caloriesPer100g(dish.getCaloriesPer100g())
                            .build();
                })
                .collect(Collectors.toList());
    }
    
    /**
     * 计算指定重量的营养信息（用于食用剩菜）
     * 
     * @param leftoverId 剩菜ID
     * @param consumedGram 食用重量（克）
     * @return 营养信息
     * @throws IllegalArgumentException 如果剩菜不存在、Dish不存在或食用重量超出范围
     */
    @Transactional(readOnly = true)
    public NutritionInfo calculateNutritionForConsumption(Long leftoverId, Integer consumedGram) {
        // 1. 验证参数
        if (consumedGram == null || consumedGram <= 0) {
            throw new IllegalArgumentException("食用重量必须大于0");
        }
        
        // 2. 查询 LeftoverDish
        LeftoverDish leftover = leftoverDishRepository.findById(leftoverId)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在: " + leftoverId));
        
        // 3. 验证是否可以食用（食用重量不能超过剩余重量）
        if (consumedGram > leftover.getCurrentQuantityGram()) {
            throw new IllegalArgumentException(
                    String.format("食用重量(%d克)超过剩余重量(%d克)", 
                            consumedGram, leftover.getCurrentQuantityGram()));
        }
        
        // 4. 查询关联的 Dish
        Dish dish = dishRepository.findById(leftover.getOriginalDishId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "关联的菜品不存在，ID: " + leftover.getOriginalDishId()));
        
        // 5. 计算营养信息
        return calculateNutritionByRatio(dish, consumedGram);
    }
    
    /**
     * 验证是否可以食用指定重量的剩菜
     * 
     * @param leftoverId 剩菜ID
     * @param consumedGram 食用重量（克）
     * @return true 如果可以食用，false 否则
     */
    @Transactional(readOnly = true)
    public boolean canConsume(Long leftoverId, Integer consumedGram) {
        if (consumedGram == null || consumedGram <= 0) {
            return false;
        }
        
        return leftoverDishRepository.findById(leftoverId)
                .map(leftover -> consumedGram <= leftover.getCurrentQuantityGram())
                .orElse(false);
    }
    
    // ================= 内部辅助方法 =================
    
    /**
     * 批量查询 Dish 并构建 Map（用于批量查询优化）
     * 
     * @param dishIds Dish ID 集合
     * @return Dish ID 到 Dish 对象的映射
     */
    private Map<Long, Dish> getDishMap(Set<Long> dishIds) {
        if (dishIds.isEmpty()) {
            return Collections.emptyMap();
        }
        
        List<Dish> dishes = dishRepository.findAllById(dishIds);
        return dishes.stream()
                .collect(Collectors.toMap(Dish::getId, dish -> dish));
    }
    
    /**
     * 根据比例计算营养信息
     * 
     * 公式：营养 = (quantityGram / dish.totalWeightGram) * dish.totalNutrient
     * 
     * @param dish 菜品实体
     * @param quantityGram 重量（克）
     * @return 营养信息
     */
    private NutritionInfo calculateNutritionByRatio(Dish dish, Integer quantityGram) {
        if (dish.getTotalWeightGram() == null || dish.getTotalWeightGram() == 0) {
            // 如果总重量为0，返回0营养
            return NutritionInfo.builder()
                    .calories(0)
                    .protein(0.0)
                    .fat(0.0)
                    .carb(0.0)
                    .fiber(0.0)
                    .build();
        }
        
        // 计算比例
        double ratio = (double) quantityGram / dish.getTotalWeightGram();
        
        // 计算各项营养
        return NutritionInfo.builder()
                .calories(dish.getTotalCalories() != null ? 
                        (int) (dish.getTotalCalories() * ratio) : 0)
                .protein(dish.getTotalProtein() != null ? 
                        dish.getTotalProtein() * ratio : 0.0)
                .fat(dish.getTotalFat() != null ? 
                        dish.getTotalFat() * ratio : 0.0)
                .carb(dish.getTotalCarb() != null ? 
                        dish.getTotalCarb() * ratio : 0.0)
                .fiber(dish.getTotalFiber() != null ? 
                        dish.getTotalFiber() * ratio : 0.0)
                .build();
    }
}

