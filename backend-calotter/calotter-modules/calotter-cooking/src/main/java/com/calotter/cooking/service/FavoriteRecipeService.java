package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriteRecipeService {

    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;

    /**
        收藏/取消收藏
     */
    @Transactional
    public Dish toggleFavorite(Long householdId, MenuDTO.RecipeDTO recipeDto) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 简化：按名称匹配已存在的 Dish
        Dish dish = dishRepository.findByHouseholdId(householdId).stream()
                .filter(d -> d.getName().equalsIgnoreCase(recipeDto.getTitle()))
                .findFirst()
                .orElse(null);
        if (dish == null) {
            dish = mapToDish(recipeDto, household);
        }
        dish.setFavorite(!dish.isFavorite());
        return dishRepository.save(dish);
    }

    /**
     * 确保菜谱存在（不切换收藏），用于开始烹饪
     */
    @Transactional
    public Dish ensureDish(Long householdId, MenuDTO.RecipeDTO recipeDto, boolean favoriteFlag) {
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        Dish dish = dishRepository.findByHouseholdId(householdId).stream()
                .filter(d -> d.getName().equalsIgnoreCase(recipeDto.getTitle()))
                .findFirst()
                .orElse(null);
        if (dish == null) {
            dish = mapToDish(recipeDto, household);
        }
        if (favoriteFlag) {
            dish.setFavorite(true);
        }
        return dishRepository.save(dish);
    }

    @Transactional(readOnly = true)
    public List<Dish> listFavorites(Long householdId) {
        // 先校验家庭是否存在
        householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        return dishRepository.findByHouseholdIdAndFavoriteTrueOrderByUpdateTimeDesc(householdId);
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
