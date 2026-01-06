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

        // 收藏场景：简化为按名称匹配已存在的 Dish（避免重复创建）
        Dish dish = dishRepository.findByHouseholdId(householdId).stream()
                .filter(d -> d.getName().equalsIgnoreCase(recipeDto.getTitle()))
                .findFirst()
                .orElse(null);
        if (dish == null) {
            dish = mapToDish(recipeDto, household);
            dish = dishRepository.save(dish);
        }

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

        // Favorites is a relationship table; snapshots are not favorited by default.
        dish.setFavorite(false);

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
            if (!favoriteDishRepository.existsByHouseholdIdAndDishId(householdId, d.getId())) {
                HouseholdFavoriteDish fav = new HouseholdFavoriteDish();
                fav.setHouseholdId(householdId);
                fav.setDishId(d.getId());
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
