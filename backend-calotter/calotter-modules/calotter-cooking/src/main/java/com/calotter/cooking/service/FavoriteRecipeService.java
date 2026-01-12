package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.DishDTO;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.entity.HouseholdFavoriteDish;
import com.calotter.cooking.domain.entity.UserRecipe;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.repository.HouseholdFavoriteDishRepository;
import com.calotter.cooking.repository.UserRecipeRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 收藏菜谱服务
 * 
 * 设计原则：物理隔离
 * - UserRecipe: 收藏的菜谱（蓝图）
 * - Dish: 烹饪历史记录
 * - 不做 JOIN 查询，只通过字段复制交互
 */
@Service
@RequiredArgsConstructor
public class FavoriteRecipeService {

    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;
    private final HouseholdFavoriteDishRepository favoriteDishRepository;
    private final UserRecipeRepository userRecipeRepository;

    /**
     * 收藏/取消收藏
     * 从 RecipeDTO 创建或更新 UserRecipe，并管理收藏关系
     */
    @Transactional
    public DishDTO toggleFavorite(Long householdId, MenuDTO.RecipeDTO recipeDto) {
        householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 查找或创建 UserRecipe（按名称，忽略大小写）
        UserRecipe recipe = userRecipeRepository
                .findFirstByHouseholdIdAndNameIgnoreCase(householdId, recipeDto.getTitle())
                .orElseGet(() -> {
                    UserRecipe r = mapToUserRecipe(recipeDto, householdId);
                    return userRecipeRepository.save(r);
                });

        // 更新现有 recipe 的数据（如果传入的数据有更新）
        updateUserRecipeFromDto(recipe, recipeDto);
        recipe = userRecipeRepository.save(recipe);

        // 使用独立关系表保存收藏状态
        boolean exists = favoriteDishRepository.existsByHouseholdIdAndRecipeId(householdId, recipe.getId());
        if (exists) {
            favoriteDishRepository.deleteByHouseholdIdAndRecipeId(householdId, recipe.getId());
            return userRecipeToDto(recipe, false);
        } else {
            HouseholdFavoriteDish fav = new HouseholdFavoriteDish();
            fav.setHouseholdId(householdId);
            fav.setRecipeId(recipe.getId());
            favoriteDishRepository.save(fav);
            return userRecipeToDto(recipe, true);
        }
    }

    /**
     * 从收藏菜谱创建 Dish 快照（用于开始烹饪）
     * 不做 JOIN，只复制字段
     */
    @Transactional
    public Dish cookFromFavorite(Long householdId, Long recipeId) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        UserRecipe recipe = userRecipeRepository.findById(recipeId)
                .orElseThrow(() -> new IllegalArgumentException("菜谱不存在: " + recipeId));

        if (!recipe.getHouseholdId().equals(householdId)) {
            throw new IllegalArgumentException("菜谱不属于该家庭");
        }

        // 从 UserRecipe 复制字段创建新的 Dish（不复制 ID）
        Dish dish = new Dish();
        dish.setHousehold(household);
        dish.setName(recipe.getName());
        dish.setCoverImage(recipe.getCoverImage());
        dish.setDescription(recipe.getDescription());
        dish.setTotalWeightGram(recipe.getTotalWeightGram());
        dish.setTotalCalories(recipe.getTotalCalories());
        dish.setTotalProtein(recipe.getTotalProtein());
        dish.setTotalFat(recipe.getTotalFat());
        dish.setTotalCarb(recipe.getTotalCarb());
        dish.setTotalFiber(recipe.getTotalFiber());
        dish.setCookingTimeMinutes(recipe.getCookingTimeMinutes());
        dish.setDifficulty(recipe.getDifficulty());
        
        // 复制 JSONB 字段（深拷贝）
        dish.setSteps(recipe.getSteps() == null ? null : 
                copyStepsToDish(recipe.getSteps()));
        dish.setTags(recipe.getTags() == null ? null : new ArrayList<>(recipe.getTags()));
        dish.setIngredientSnapshots(recipe.getIngredientSnapshots() == null ? null :
                copyIngredientSnapshotsToDish(recipe.getIngredientSnapshots()));
        
        // 记录来源
        dish.setSourceRecipeId(recipe.getId());

        return dishRepository.save(dish);
    }

    /**
     * 从 RecipeDTO 创建 Dish 快照（AI 生成的临时菜谱直接烹饪）
     */
    @Transactional
    public Dish createDishSnapshot(Long householdId, MenuDTO.RecipeDTO recipeDto) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        Dish dish = mapToDish(recipeDto, household);
        dish.setSourceRecipeId(null); // 不是从收藏创建的
        return dishRepository.save(dish);
    }

    /**
     * 获取收藏列表
     */
    @Transactional(readOnly = true)
    public List<DishDTO> listFavorites(Long householdId) {
        householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        List<HouseholdFavoriteDish> rels = favoriteDishRepository.findByHouseholdId(householdId);
        if (rels.isEmpty()) {
            return List.of();
        }

        // 提取 recipeId
        List<Long> recipeIds = rels.stream()
                .map(HouseholdFavoriteDish::getRecipeId)
                .collect(Collectors.toList());

        // 批量查询 UserRecipe（不做 JOIN）
        List<UserRecipe> recipes = userRecipeRepository.findAllById(recipeIds);

        return recipes.stream()
                .map(r -> userRecipeToDto(r, true))
                .sorted((a, b) -> {
                    if (a.getId() == null && b.getId() == null) return 0;
                    if (a.getId() == null) return 1;
                    if (b.getId() == null) return -1;
                    return b.getId().compareTo(a.getId());
                })
                .toList();
    }

    // ========== 辅助方法 ==========

    /**
     * UserRecipe 转 DishDTO
     */
    private DishDTO userRecipeToDto(UserRecipe recipe, boolean favorite) {
        return DishDTO.builder()
                .id(recipe.getId())
                .name(recipe.getName())
                .coverImage(recipe.getCoverImage())
                .description(recipe.getDescription())
                .totalWeightGram(recipe.getTotalWeightGram())
                .totalCalories(recipe.getTotalCalories())
                .totalProtein(recipe.getTotalProtein())
                .totalFat(recipe.getTotalFat())
                .totalCarb(recipe.getTotalCarb())
                .totalFiber(recipe.getTotalFiber())
                .cookingTimeMinutes(recipe.getCookingTimeMinutes())
                .difficulty(recipe.getDifficulty())
                .steps(convertStepsToDish(recipe.getSteps()))
                .tags(recipe.getTags())
                .ingredientSnapshots(convertIngredientSnapshotsToDish(recipe.getIngredientSnapshots()))
                .favorite(favorite)
                .build();
    }

    /**
     * RecipeDTO 转 UserRecipe
     */
    private UserRecipe mapToUserRecipe(MenuDTO.RecipeDTO recipeDto, Long householdId) {
        UserRecipe recipe = new UserRecipe();
        recipe.setHouseholdId(householdId);
        recipe.setName(recipeDto.getTitle());
        recipe.setDescription(recipeDto.getShortDescription());
        recipe.setCookingTimeMinutes(recipeDto.getCookingTimeMin());
        recipe.setDifficulty(parseDifficulty(recipeDto.getDifficulty()));
        
        if (recipeDto.getNutritionEstimate() != null) {
            recipe.setTotalCalories(toInt(recipeDto.getNutritionEstimate().getCalories()));
            recipe.setTotalProtein(recipeDto.getNutritionEstimate().getProteinG());
            recipe.setTotalFat(recipeDto.getNutritionEstimate().getFatG());
            recipe.setTotalCarb(recipeDto.getNutritionEstimate().getCarbsG());
        }
        
        if (recipeDto.getIngredients() != null) {
            recipe.setIngredientSnapshots(
                    recipeDto.getIngredients().stream().map(ing -> {
                        UserRecipe.IngredientSnapshot snap = new UserRecipe.IngredientSnapshot();
                        snap.setName(ing.getName());
                        snap.setAmountValue(ing.getAmountValue() != null ? ing.getAmountValue() : 0.0);
                        snap.setAmountUnit(ing.getAmountUnit() != null ? ing.getAmountUnit() : "g");
                        return snap;
                    }).toList()
            );
        }
        
        if (recipeDto.getSteps() != null) {
            recipe.setSteps(
                    recipeDto.getSteps().stream().map(s -> {
                        UserRecipe.CookingStep cs = new UserRecipe.CookingStep();
                        cs.setStepNumber(s.getStepNumber());
                        cs.setInstruction(s.getInstruction());
                        cs.setTimeMin(s.getStepTimeMin());
                        return cs;
                    }).toList()
            );
        }
        
        int totalWeight = recipeDto.getIngredients() == null ? 0 :
                recipeDto.getIngredients().stream()
                        .filter(i -> "g".equalsIgnoreCase(i.getAmountUnit()) && i.getAmountValue() != null)
                        .mapToInt(i -> i.getAmountValue().intValue())
                        .sum();
        recipe.setTotalWeightGram(totalWeight > 0 ? totalWeight : 1000);
        
        return recipe;
    }

    /**
     * 更新 UserRecipe（从 RecipeDTO）
     */
    private void updateUserRecipeFromDto(UserRecipe recipe, MenuDTO.RecipeDTO recipeDto) {
        // 更新字段（允许用户重新收藏时更新数据）
        recipe.setDescription(recipeDto.getShortDescription());
        recipe.setCookingTimeMinutes(recipeDto.getCookingTimeMin());
        recipe.setDifficulty(parseDifficulty(recipeDto.getDifficulty()));
        
        if (recipeDto.getNutritionEstimate() != null) {
            recipe.setTotalCalories(toInt(recipeDto.getNutritionEstimate().getCalories()));
            recipe.setTotalProtein(recipeDto.getNutritionEstimate().getProteinG());
            recipe.setTotalFat(recipeDto.getNutritionEstimate().getFatG());
            recipe.setTotalCarb(recipeDto.getNutritionEstimate().getCarbsG());
        }
        
        if (recipeDto.getIngredients() != null) {
            recipe.setIngredientSnapshots(
                    recipeDto.getIngredients().stream().map(ing -> {
                        UserRecipe.IngredientSnapshot snap = new UserRecipe.IngredientSnapshot();
                        snap.setName(ing.getName());
                        snap.setAmountValue(ing.getAmountValue() != null ? ing.getAmountValue() : 0.0);
                        snap.setAmountUnit(ing.getAmountUnit() != null ? ing.getAmountUnit() : "g");
                        return snap;
                    }).toList()
            );
        }
        
        if (recipeDto.getSteps() != null) {
            recipe.setSteps(
                    recipeDto.getSteps().stream().map(s -> {
                        UserRecipe.CookingStep cs = new UserRecipe.CookingStep();
                        cs.setStepNumber(s.getStepNumber());
                        cs.setInstruction(s.getInstruction());
                        cs.setTimeMin(s.getStepTimeMin());
                        return cs;
                    }).toList()
            );
        }
        
        int totalWeight = recipeDto.getIngredients() == null ? 0 :
                recipeDto.getIngredients().stream()
                        .filter(i -> "g".equalsIgnoreCase(i.getAmountUnit()) && i.getAmountValue() != null)
                        .mapToInt(i -> i.getAmountValue().intValue())
                        .sum();
        if (totalWeight > 0) {
            recipe.setTotalWeightGram(totalWeight);
        }
    }

    /**
     * RecipeDTO 转 Dish（用于 AI 生成的临时菜谱）
     */
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

    // ========== 类型转换辅助方法 ==========

    /**
     * UserRecipe.CookingStep 转 Dish.CookingStep
     */
    private List<Dish.CookingStep> convertStepsToDish(List<UserRecipe.CookingStep> steps) {
        if (steps == null) return null;
        return steps.stream().map(s -> {
            Dish.CookingStep ds = new Dish.CookingStep();
            ds.setStepNumber(s.getStepNumber());
            ds.setInstruction(s.getInstruction());
            ds.setTimeMin(s.getTimeMin());
            return ds;
        }).toList();
    }

    /**
     * UserRecipe.CookingStep 转 Dish.CookingStep（深拷贝）
     */
    private List<Dish.CookingStep> copyStepsToDish(List<UserRecipe.CookingStep> steps) {
        if (steps == null) return null;
        return convertStepsToDish(steps);
    }

    /**
     * UserRecipe.IngredientSnapshot 转 Dish.IngredientSnapshot
     */
    private List<Dish.IngredientSnapshot> convertIngredientSnapshotsToDish(
            List<UserRecipe.IngredientSnapshot> snapshots) {
        if (snapshots == null) return null;
        return snapshots.stream().map(s -> {
            Dish.IngredientSnapshot ds = new Dish.IngredientSnapshot();
            ds.setName(s.getName());
            ds.setAmountValue(s.getAmountValue());
            ds.setAmountUnit(s.getAmountUnit());
            return ds;
        }).toList();
    }

    /**
     * UserRecipe.IngredientSnapshot 转 Dish.IngredientSnapshot（深拷贝）
     */
    private List<Dish.IngredientSnapshot> copyIngredientSnapshotsToDish(
            List<UserRecipe.IngredientSnapshot> snapshots) {
        if (snapshots == null) return null;
        return convertIngredientSnapshotsToDish(snapshots);
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
