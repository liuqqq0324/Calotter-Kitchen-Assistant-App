package com.calotter.inventory.service;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.inventory.controller.dto.*;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.*;
import com.calotter.common.core.repository.StandardIngredientRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 库存服务
 */
@Service
@RequiredArgsConstructor
public class InventoryService {

    private final IngredientRepository ingredientRepository;
    private final HouseholdSpiceRepository spiceRepository;
    private final HouseholdUtensilRepository utensilRepository;
    private final LeftoverDishRepository leftoverRepository;
    private final StandardIngredientRepository standardIngredientRepository;
    private final StandardSpiceRepository standardSpiceRepository;
    private final StandardUtensilRepository standardUtensilRepository;
    private final HouseholdRepository householdRepository;
    private final UnitValidationService unitValidationService; // ✅ 新增：单位验证服务

    // ==================== 食材管理 ====================

    /**
     * 创建食材
     */
    @Transactional
    public IngredientResponse createIngredient(IngredientRequest request) {
        if (request.getStandardIngredientId() == null) {
            throw new IllegalArgumentException("标准食材ID不能为空");
        }
        
        // ✅ 验证单位是否合法
        if (request.getUnit() != null) {
            unitValidationService.validateUnit(request.getStandardIngredientId(), request.getUnit());
        }
        
        Household household = householdRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        
        StandardIngredient standardIngredient = standardIngredientRepository.findById(request.getStandardIngredientId())
                .orElseThrow(() -> new IllegalArgumentException("标准食材不存在"));

        Ingredient ingredient = new Ingredient();
        ingredient.setHousehold(household);
        ingredient.setMetadata(standardIngredient);
        ingredient.setQuantity(request.getQuantity());
        ingredient.setUnit(request.getUnit());
        ingredient.setExpirationDate(request.getExpirationDate());
        ingredient.setLocation(request.getLocation());

        ingredient = ingredientRepository.save(ingredient);
        return toIngredientResponse(ingredient);
    }

    /**
     * 更新食材
     */
    @Transactional
    public IngredientResponse updateIngredient(Long id, IngredientRequest request) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("食材不存在"));

        Long standardIngredientId = request.getStandardIngredientId() != null 
            ? request.getStandardIngredientId() 
            : ingredient.getMetadata().getId();

        if (request.getStandardIngredientId() != null) {
            StandardIngredient standardIngredient = standardIngredientRepository.findById(request.getStandardIngredientId())
                    .orElseThrow(() -> new IllegalArgumentException("标准食材不存在"));
            ingredient.setMetadata(standardIngredient);
        }

        // ✅ 如果更新了单位，验证单位是否合法（基于当前的标准食材）
        if (request.getUnit() != null) {
            unitValidationService.validateUnit(standardIngredientId, request.getUnit());
        }

        if (request.getQuantity() != null) {
            ingredient.setQuantity(request.getQuantity());
        }
        if (request.getUnit() != null) {
            ingredient.setUnit(request.getUnit());
        }
        if (request.getExpirationDate() != null) {
            ingredient.setExpirationDate(request.getExpirationDate());
        }
        if (request.getLocation() != null) {
            ingredient.setLocation(request.getLocation());
        }

        ingredient = ingredientRepository.save(ingredient);
        return toIngredientResponse(ingredient);
    }

    /**
     * 获取食材详情
     */
    public IngredientResponse getIngredient(Long id) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("食材不存在"));
        return toIngredientResponse(ingredient);
    }

    /**
     * 获取家庭的所有食材
     */
    public List<IngredientResponse> getIngredientsByHousehold(Long householdId) {
        List<Ingredient> ingredients = ingredientRepository.findByHouseholdId(householdId);
        return ingredients.stream()
                .map(this::toIngredientResponse)
                .collect(Collectors.toList());
    }

    /**
     * 删除食材
     */
    @Transactional
    public void deleteIngredient(Long id) {
        if (!ingredientRepository.existsById(id)) {
            throw new IllegalArgumentException("食材不存在");
        }
        ingredientRepository.deleteById(id);
    }

    /**
     * 扣减食材库存（用于烹饪模块）
     */
    @Transactional
    public void deductIngredient(Long id, Double amount) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("食材不存在"));
        
        if (ingredient.getQuantity() < amount) {
            throw new IllegalArgumentException("库存不足");
        }
        
        ingredient.setQuantity(ingredient.getQuantity() - amount);
        ingredientRepository.save(ingredient);
    }

    // ==================== 调料管理 ====================

    /**
     * 创建调料
     */
    @Transactional
    public SpiceResponse createSpice(SpiceRequest request) {
        Household household = householdRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        
        StandardSpice standardSpice = standardSpiceRepository.findById(request.getStandardSpiceId())
                .orElseThrow(() -> new IllegalArgumentException("标准调料不存在"));

        HouseholdSpice spice = new HouseholdSpice();
        spice.setHousehold(household);
        spice.setMetadata(standardSpice);
        spice.setIsAvailable(request.getIsAvailable());
        spice.setRemark(request.getRemark());

        spice = spiceRepository.save(spice);
        return toSpiceResponse(spice);
    }

    /**
     * 更新调料
     */
    @Transactional
    public SpiceResponse updateSpice(Long id, SpiceRequest request) {
        HouseholdSpice spice = spiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("调料不存在"));

        if (request.getStandardSpiceId() != null) {
            StandardSpice standardSpice = standardSpiceRepository.findById(request.getStandardSpiceId())
                    .orElseThrow(() -> new IllegalArgumentException("标准调料不存在"));
            spice.setMetadata(standardSpice);
        }

        if (request.getIsAvailable() != null) {
            spice.setIsAvailable(request.getIsAvailable());
        }
        if (request.getRemark() != null) {
            spice.setRemark(request.getRemark());
        }

        spice = spiceRepository.save(spice);
        return toSpiceResponse(spice);
    }

    /**
     * 获取调料详情
     */
    public SpiceResponse getSpice(Long id) {
        HouseholdSpice spice = spiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("调料不存在"));
        return toSpiceResponse(spice);
    }

    /**
     * 获取家庭的所有调料
     */
    public List<SpiceResponse> getSpicesByHousehold(Long householdId) {
        List<HouseholdSpice> spices = spiceRepository.findByHouseholdId(householdId);
        return spices.stream()
                .map(this::toSpiceResponse)
                .collect(Collectors.toList());
    }

    /**
     * 删除调料
     */
    @Transactional
    public void deleteSpice(Long id) {
        if (!spiceRepository.existsById(id)) {
            throw new IllegalArgumentException("调料不存在");
        }
        spiceRepository.deleteById(id);
    }

    /**
     * 切换调料可用性（toggle）
     */
    @Transactional
    public SpiceResponse toggleSpiceAvailability(Long id) {
        HouseholdSpice spice = spiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("调料不存在"));
        
        // 切换可用性：true变false，false变true
        Boolean currentAvailability = spice.getIsAvailable();
        spice.setIsAvailable(currentAvailability == null || !currentAvailability);
        
        spice = spiceRepository.save(spice);
        return toSpiceResponse(spice);
    }

    // ==================== 厨具管理 ====================

    /**
     * 创建厨具
     */
    @Transactional
    public UtensilResponse createUtensil(UtensilRequest request) {
        Household household = householdRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        
        StandardUtensil standardUtensil = standardUtensilRepository.findById(request.getStandardUtensilId())
                .orElseThrow(() -> new IllegalArgumentException("标准厨具不存在"));

        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setHousehold(household);
        utensil.setMetadata(standardUtensil);
        utensil.setIsAvailable(request.getIsAvailable());
        utensil.setRemark(request.getRemark());

        utensil = utensilRepository.save(utensil);
        return toUtensilResponse(utensil);
    }

    /**
     * 更新厨具
     */
    @Transactional
    public UtensilResponse updateUtensil(Long id, UtensilRequest request) {
        HouseholdUtensil utensil = utensilRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("厨具不存在"));

        if (request.getStandardUtensilId() != null) {
            StandardUtensil standardUtensil = standardUtensilRepository.findById(request.getStandardUtensilId())
                    .orElseThrow(() -> new IllegalArgumentException("标准厨具不存在"));
            utensil.setMetadata(standardUtensil);
        }

        if (request.getIsAvailable() != null) {
            utensil.setIsAvailable(request.getIsAvailable());
        }
        if (request.getRemark() != null) {
            utensil.setRemark(request.getRemark());
        }

        utensil = utensilRepository.save(utensil);
        return toUtensilResponse(utensil);
    }

    /**
     * 获取厨具详情
     */
    public UtensilResponse getUtensil(Long id) {
        HouseholdUtensil utensil = utensilRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("厨具不存在"));
        return toUtensilResponse(utensil);
    }

    /**
     * 获取家庭的所有厨具
     */
    public List<UtensilResponse> getUtensilsByHousehold(Long householdId) {
        List<HouseholdUtensil> utensils = utensilRepository.findByHouseholdId(householdId);
        return utensils.stream()
                .map(this::toUtensilResponse)
                .collect(Collectors.toList());
    }

    /**
     * 删除厨具
     */
    @Transactional
    public void deleteUtensil(Long id) {
        if (!utensilRepository.existsById(id)) {
            throw new IllegalArgumentException("厨具不存在");
        }
        utensilRepository.deleteById(id);
    }

    /**
     * 切换厨具可用性（toggle）
     */
    @Transactional
    public UtensilResponse toggleUtensilAvailability(Long id) {
        HouseholdUtensil utensil = utensilRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("厨具不存在"));
        
        // 切换可用性：true变false，false变true
        Boolean currentAvailability = utensil.getIsAvailable();
        utensil.setIsAvailable(currentAvailability == null || !currentAvailability);
        
        utensil = utensilRepository.save(utensil);
        return toUtensilResponse(utensil);
    }

    // ==================== 剩菜管理 ====================

    /**
     * 创建剩菜
     */
    @Transactional
    public LeftoverResponse createLeftover(LeftoverRequest request) {
        Household household = householdRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        LeftoverDish leftover = new LeftoverDish();
        leftover.setHousehold(household);
        leftover.setOriginalDishId(request.getOriginalDishId());
        leftover.setCurrentQuantityGram(request.getCurrentQuantityGram());
        // 设置初始重量（手动创建时，初始重量等于当前重量）
        leftover.setInitialQuantityGram(request.getCurrentQuantityGram());
        leftover.setProducedTime(request.getProducedTime());

        leftover = leftoverRepository.save(leftover);
        return toLeftoverResponse(leftover);
    }

    /**
     * 更新剩菜
     */
    @Transactional
    public LeftoverResponse updateLeftover(Long id, LeftoverRequest request) {
        LeftoverDish leftover = leftoverRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在"));

        if (request.getOriginalDishId() != null) {
            leftover.setOriginalDishId(request.getOriginalDishId());
        }
        if (request.getCurrentQuantityGram() != null) {
            leftover.setCurrentQuantityGram(request.getCurrentQuantityGram());
        }
        if (request.getProducedTime() != null) {
            leftover.setProducedTime(request.getProducedTime());
        }

        leftover = leftoverRepository.save(leftover);
        return toLeftoverResponse(leftover);
    }

    /**
     * 获取剩菜详情
     */
    public LeftoverResponse getLeftover(Long id) {
        LeftoverDish leftover = leftoverRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在"));
        
        return LeftoverResponse.builder()
                .id(leftover.getId())
                .householdId(leftover.getHousehold().getId())
                .originalDishId(leftover.getOriginalDishId())
                .dishName(leftover.getDishName()) // ✅ 从快照获取
                .coverImage(leftover.getCoverImage()) // ✅ 从快照获取
                .currentQuantityGram(leftover.getCurrentQuantityGram())
                .producedTime(leftover.getProducedTime())
                .caloriesPer100g(leftover.getCaloriesPer100g()) // ✅ 从快照获取
                .build();
    }

    /**
     * 获取家庭的所有剩菜
     */
    public List<LeftoverResponse> getLeftoversByHousehold(Long householdId) {
        List<LeftoverDish> leftovers = leftoverRepository.findByHouseholdId(householdId);
        return leftovers.stream()
                .map(leftover -> LeftoverResponse.builder()
                        .id(leftover.getId())
                        .householdId(leftover.getHousehold().getId())
                        .originalDishId(leftover.getOriginalDishId())
                        .dishName(leftover.getDishName()) // ✅ 从快照获取
                        .coverImage(leftover.getCoverImage()) // ✅ 从快照获取
                        .currentQuantityGram(leftover.getCurrentQuantityGram())
                        .producedTime(leftover.getProducedTime())
                        .caloriesPer100g(leftover.getCaloriesPer100g()) // ✅ 从快照获取
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * 删除剩菜
     */
    @Transactional
    public void deleteLeftover(Long id) {
        if (!leftoverRepository.existsById(id)) {
            throw new IllegalArgumentException("剩菜不存在");
        }
        leftoverRepository.deleteById(id);
    }

    /**
     * 部分更新剩菜（根据消费百分比更新数量）
     * 
     * @param id LeftoverDish ID
     * @param consumedPercentage 消费百分比（0-100），例如：30.0 表示消费了 30%
     * @return 更新后的 LeftoverResponse
     */
    @Transactional
    public LeftoverResponse patchLeftover(Long id, java.math.BigDecimal consumedPercentage) {
        LeftoverDish leftover = leftoverRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("剩菜不存在"));
        
        // 验证初始重量是否存在
        if (leftover.getInitialQuantityGram() == null || leftover.getInitialQuantityGram() <= 0) {
            throw new IllegalArgumentException("初始重量无效，无法计算消费量");
        }
        
        // 验证消费百分比范围
        if (consumedPercentage.compareTo(java.math.BigDecimal.ZERO) < 0 ||
                consumedPercentage.compareTo(java.math.BigDecimal.valueOf(100)) > 0) {
            throw new IllegalArgumentException("消费百分比必须在 0-100 之间");
        }
        
        Integer totalWeightGram = leftover.getInitialQuantityGram();
        
        // 计算消费的重量
        // consumedPercentage 是百分比（如 30.0 表示 30%）
        java.math.BigDecimal consumedGrams = java.math.BigDecimal.valueOf(totalWeightGram)
                .multiply(consumedPercentage)
                .divide(java.math.BigDecimal.valueOf(100), 2, java.math.RoundingMode.HALF_UP);
        
        // 更新剩余重量：currentQuantityGram = currentQuantityGram - 消费的重量
        int newQuantity = leftover.getCurrentQuantityGram() - consumedGrams.intValue();
        
        if (newQuantity < 0) {
            throw new IllegalArgumentException(
                String.format("消费后剩余重量不能小于0。当前剩余：%dg，尝试消费：%dg", 
                    leftover.getCurrentQuantityGram(), consumedGrams.intValue()));
        }
        
        leftover.setCurrentQuantityGram(newQuantity);
        leftover = leftoverRepository.save(leftover);
        
        return getLeftover(id);
    }

    // ==================== 转换方法 ====================

    private IngredientResponse toIngredientResponse(Ingredient ingredient) {
        return IngredientResponse.builder()
                .id(ingredient.getId())
                .householdId(ingredient.getHousehold().getId())
                .standardIngredientId(ingredient.getMetadata().getId())
                .standardIngredientName(ingredient.getMetadata().getName())
                .category(ingredient.getMetadata().getCategory())
                .quantity(ingredient.getQuantity())
                .unit(ingredient.getUnit())
                .expirationDate(ingredient.getExpirationDate())
                .location(ingredient.getLocation())
                .build();
    }

    private SpiceResponse toSpiceResponse(HouseholdSpice spice) {
        return SpiceResponse.builder()
                .id(spice.getId())
                .householdId(spice.getHousehold().getId())
                .standardSpiceId(spice.getMetadata().getId())
                .standardSpiceName(spice.getMetadata().getName())
                .isAvailable(spice.getIsAvailable())
                .remark(spice.getRemark())
                .build();
    }

    private UtensilResponse toUtensilResponse(HouseholdUtensil utensil) {
        return UtensilResponse.builder()
                .id(utensil.getId())
                .householdId(utensil.getHousehold().getId())
                .standardUtensilId(utensil.getMetadata().getId())
                .standardUtensilName(utensil.getMetadata().getName())
                .isAvailable(utensil.getIsAvailable())
                .remark(utensil.getRemark())
                .build();
    }

    /**
     * 转换 LeftoverDish 为 LeftoverResponse（已废弃，使用 getLeftover 或 getLeftoversByHousehold）
     * 
     * @deprecated 此方法不包含菜品信息，请使用通过 Service 层获取的方法
     */
    @Deprecated
    private LeftoverResponse toLeftoverResponse(LeftoverDish leftover) {
        return LeftoverResponse.builder()
                .id(leftover.getId())
                .householdId(leftover.getHousehold().getId())
                .originalDishId(leftover.getOriginalDishId())
                .dishName(null) // 需要通过 Service 获取
                .coverImage(null) // 需要通过 Service 获取
                .currentQuantityGram(leftover.getCurrentQuantityGram())
                .producedTime(leftover.getProducedTime())
                .caloriesPer100g(null) // 需要通过 Service 获取
                .build();
    }

    // ==================== 标准食材库查询 ====================

    /**
     * 通过名称查找标准食材（精确匹配）
     */
    public StandardIngredient findStandardIngredientByName(String name) {
        return standardIngredientRepository.findByName(name)
                .orElseThrow(() -> new IllegalArgumentException("标准食材不存在: " + name));
    }

    /**
     * 通过名称模糊查找标准食材（不区分大小写）
     */
    public List<StandardIngredient> searchStandardIngredientsByName(String name) {
        return standardIngredientRepository.findByNameContainingIgnoreCase(name);
    }

    /**
     * 获取所有标准食材列表
     */
    public List<StandardIngredient> getAllStandardIngredients() {
        return standardIngredientRepository.findAll();
    }

    /**
     * 获取所有标准厨具列表
     */
    public List<com.calotter.common.core.domain.entity.StandardUtensil> getAllStandardUtensils() {
        return standardUtensilRepository.findAll();
    }

    /**
     * 获取所有标准调料列表
     */
    public List<com.calotter.common.core.domain.entity.StandardSpice> getAllStandardSpices() {
        return standardSpiceRepository.findAll();
    }

    /**
     * ✅ 获取标准食材的允许单位列表
     * @param standardIngredientId 标准食材ID
     * @return 允许的单位列表
     */
    public List<String> getAllowedUnits(Long standardIngredientId) {
        return unitValidationService.getAllowedUnits(standardIngredientId);
    }
}
