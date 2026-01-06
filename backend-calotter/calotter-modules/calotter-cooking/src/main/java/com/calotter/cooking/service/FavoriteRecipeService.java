package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.DishDTO;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.entity.HouseholdFavoriteDish;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.repository.HouseholdFavoriteDishRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteRecipeService {

    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;
    private final HouseholdFavoriteDishRepository favoriteDishRepository;

    /**
        收藏/取消收藏
     */
    @Transactional
    public DishDTO toggleFavorite(Long householdId, MenuDTO.RecipeDTO recipeDto) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 收藏永远指向“模板 Dish”
        Dish dish = dishRepository
                .findFirstByHouseholdIdAndNameIgnoreCaseAndDishType(
                        householdId, recipeDto.getTitle(), Dish.DishType.TEMPLATE)
                .orElseGet(() -> {
                    Dish d = mapToDish(recipeDto, household);
                    d.setDishType(Dish.DishType.TEMPLATE);
                    d.setTemplateDishId(null);
                    return dishRepository.save(d);
                });

        // 使用独立关系表保存收藏状态
        boolean exists = favoriteDishRepository.existsByHouseholdIdAndDishId(householdId, dish.getId());
        if (exists) {
            favoriteDishRepository.deleteByHouseholdIdAndDishId(householdId, dish.getId());
            return toDto(dish, false);
        } else {
            HouseholdFavoriteDish fav = new HouseholdFavoriteDish();
            fav.setHouseholdId(householdId);
            fav.setDishId(dish.getId());
            favoriteDishRepository.save(fav);
            return toDto(dish, true);
        }
    }

    /**
     * 创建 Dish 快照（Copy-on-Write）
     *
     * 重要：烹饪场景必须“每次开始烹饪都生成新的 Dish 记录”，以保证：
     * - 每次做同一道菜也有独立的 dishId（用于 health / leftover 的精确归因）
     * - 允许同名菜品在不同时间有不同配方/营养值（AI 生成会变化）
     */
    @Transactional
    public Dish createDishSnapshot(Long householdId, MenuDTO.RecipeDTO recipeDto) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        Dish dish = mapToDish(recipeDto, household);
        dish.setDishType(Dish.DishType.INSTANCE);
        dish.setTemplateDishId(null);
        return dishRepository.save(dish);
    }

    /**
     * Clone an existing Dish (usually a favorited/template dish) into a new Dish snapshot.
     *
     * This is required to guarantee: "each cook has a unique dishId", even when cooking from favorites/history.
     */
    @Transactional
    public Dish cloneDishSnapshot(Long householdId, Long dishId) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        Dish base = dishRepository.findByIdAndHousehold(dishId, household)
                .orElseThrow(() -> new IllegalArgumentException("菜品不存在: " + dishId));

        Dish dish = new Dish();
        dish.setHousehold(household);
        dish.setName(base.getName());
        dish.setCoverImage(base.getCoverImage());
        dish.setDescription(base.getDescription());
        dish.setTotalWeightGram(base.getTotalWeightGram());
        dish.setTotalCalories(base.getTotalCalories());
        dish.setTotalProtein(base.getTotalProtein());
        dish.setTotalFat(base.getTotalFat());
        dish.setTotalCarb(base.getTotalCarb());
        dish.setTotalFiber(base.getTotalFiber());
        dish.setCookingTimeMinutes(base.getCookingTimeMinutes());
        dish.setDifficulty(base.getDifficulty());

        // Copy JSONB fields (shallow copy is fine; persisted as JSON)
        dish.setSteps(base.getSteps() == null ? null : new ArrayList<>(base.getSteps()));
        dish.setTags(base.getTags() == null ? null : new ArrayList<>(base.getTags()));
        dish.setIngredientSnapshots(base.getIngredientSnapshots() == null ? null : new ArrayList<>(base.getIngredientSnapshots()));

        // 标记为 INSTANCE，并记录来源模板（若 base 已是 INSTANCE，则沿用其 templateDishId；否则用 base.id）
        dish.setDishType(Dish.DishType.INSTANCE);
        if (base.getDishType() == Dish.DishType.TEMPLATE) {
            dish.setTemplateDishId(base.getId());
        } else {
            dish.setTemplateDishId(base.getTemplateDishId() != null ? base.getTemplateDishId() : base.getId());
        }

        return dishRepository.save(dish);
    }

    @Transactional(readOnly = true)
    public List<DishDTO> listFavorites(Long householdId) {
        // 先校验家庭是否存在
        householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 兼容历史数据：如果旧版本把 favorite 直接写在 Dish 上，这里做一次轻量 backfill
        backfillLegacyFavorites(householdId);

        List<HouseholdFavoriteDish> rels = favoriteDishRepository.findByHouseholdId(householdId);
        if (rels.isEmpty()) {
            return List.of();
        }

        Set<Long> dishIds = rels.stream().map(HouseholdFavoriteDish::getDishId).collect(Collectors.toSet());
        Map<Long, Dish> dishMap = dishRepository.findAllById(dishIds).stream()
                .collect(Collectors.toMap(Dish::getId, Function.identity()));

        // 返回 DTO 列表，favorite 永远从关系表派生
        return dishMap.values().stream()
                .map(d -> toDto(d, true))
                .sorted((a, b) -> {
                    if (a.getId() == null && b.getId() == null) return 0;
                    if (a.getId() == null) return 1;
                    if (b.getId() == null) return -1;
                    // keep deterministic ordering; frontend doesn't strictly depend on it
                    return b.getId().compareTo(a.getId());
                })
                .toList();
    }

    /**
     * Backfill legacy favorites from Dish.favorite=true into the new relation table.
     * This prevents existing dev/test data from "disappearing" after introducing the new table.
     */
    private void backfillLegacyFavorites(Long householdId) {
        List<Dish> legacyFavs = dishRepository.findByHouseholdIdAndFavoriteTrueOrderByUpdateTimeDesc(householdId);
        for (Dish d : legacyFavs) {
            if (d.getId() == null) continue;
            // Legacy versions may have favorite=true on INSTANCE rows; we must migrate favorites to TEMPLATE dishes.
            Long templateId;
            if (d.getDishType() == Dish.DishType.TEMPLATE) {
                templateId = d.getId();
            } else if (d.getTemplateDishId() != null) {
                templateId = d.getTemplateDishId();
            } else {
                // No template link available (very old data). Create a TEMPLATE dish by copying this row.
                Dish template = new Dish();
                template.setHousehold(d.getHousehold());
                template.setName(d.getName());
                template.setCoverImage(d.getCoverImage());
                template.setDescription(d.getDescription());
                template.setTotalWeightGram(d.getTotalWeightGram());
                template.setTotalCalories(d.getTotalCalories());
                template.setTotalProtein(d.getTotalProtein());
                template.setTotalFat(d.getTotalFat());
                template.setTotalCarb(d.getTotalCarb());
                template.setTotalFiber(d.getTotalFiber());
                template.setCookingTimeMinutes(d.getCookingTimeMinutes());
                template.setDifficulty(d.getDifficulty());
                template.setSteps(d.getSteps());
                template.setTags(d.getTags());
                template.setIngredientSnapshots(d.getIngredientSnapshots());
                template.setDishType(Dish.DishType.TEMPLATE);
                template.setTemplateDishId(null);
                template = dishRepository.save(template);
                templateId = template.getId();
            }

            if (!favoriteDishRepository.existsByHouseholdIdAndDishId(householdId, templateId)) {
                HouseholdFavoriteDish fav = new HouseholdFavoriteDish();
                fav.setHouseholdId(householdId);
                fav.setDishId(templateId);
                favoriteDishRepository.save(fav);
            }
        }
    }

    private DishDTO toDto(Dish dish, boolean favorite) {
        return DishDTO.builder()
                .id(dish.getId())
                .name(dish.getName())
                .coverImage(dish.getCoverImage())
                .description(dish.getDescription())
                .totalWeightGram(dish.getTotalWeightGram())
                .totalCalories(dish.getTotalCalories())
                .totalProtein(dish.getTotalProtein())
                .totalFat(dish.getTotalFat())
                .totalCarb(dish.getTotalCarb())
                .totalFiber(dish.getTotalFiber())
                .cookingTimeMinutes(dish.getCookingTimeMinutes())
                .difficulty(dish.getDifficulty())
                .steps(dish.getSteps())
                .tags(dish.getTags())
                .ingredientSnapshots(dish.getIngredientSnapshots())
                .favorite(favorite)
                .build();
    }

    private Dish mapToDish(MenuDTO.RecipeDTO recipeDto, Household household) {
        Dish dish = new Dish();
        dish.setHousehold(household);
        dish.setName(recipeDto.getTitle());
        dish.setDescription(recipeDto.getShortDescription());
        dish.setCookingTimeMinutes(recipeDto.getCookingTimeMin());
        dish.setDifficulty(parseDifficulty(recipeDto.getDifficulty()));
        if (recipeDto.getNutritionEstimate() != null) {
            dish.setTotalCalories(toInt(recipeDto.getNutritionEstimate().getCalories()));
            dish.setTotalProtein(recipeDto.getNutritionEstimate().getProteinG());
            dish.setTotalFat(recipeDto.getNutritionEstimate().getFatG());
            dish.setTotalCarb(recipeDto.getNutritionEstimate().getCarbsG());
        }
        if (recipeDto.getIngredients() != null) {
            dish.setIngredientSnapshots(
                    recipeDto.getIngredients().stream().map(ing -> {
                        Dish.IngredientSnapshot snap = new Dish.IngredientSnapshot();
                        snap.setName(ing.getName());
                        snap.setAmountValue(ing.getAmountValue() != null ? ing.getAmountValue() : 0.0);
                        snap.setAmountUnit(ing.getAmountUnit() != null ? ing.getAmountUnit() : "g");
                        return snap;
                    }).toList()
            );
        }
        if (recipeDto.getSteps() != null) {
            dish.setSteps(
                    recipeDto.getSteps().stream().map(s -> {
                        Dish.CookingStep cs = new Dish.CookingStep();
                        cs.setStepNumber(s.getStepNumber());
                        cs.setInstruction(s.getInstruction());
                        cs.setTimeMin(s.getStepTimeMin());
                        return cs;
                    }).toList()
            );
        }
        // 估算重量（简单累加 g 单位）
        int totalWeight = recipeDto.getIngredients() == null ? 0 :
                recipeDto.getIngredients().stream()
                        .filter(i -> "g".equalsIgnoreCase(i.getAmountUnit()) && i.getAmountValue() != null)
                        .mapToInt(i -> i.getAmountValue().intValue())
                        .sum();
        dish.setTotalWeightGram(totalWeight > 0 ? totalWeight : 1000);
        return dish;
    }

    private com.calotter.cooking.domain.enums.DifficultyLevel parseDifficulty(String d) {
        try {
            return d == null ? null : com.calotter.cooking.domain.enums.DifficultyLevel.valueOf(d.toUpperCase());
        } catch (Exception e) {
            return null;
        }
    }

    private Integer toInt(Double v) {
        return v == null ? null : v.intValue();
    }
}
