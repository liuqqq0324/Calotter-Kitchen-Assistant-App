package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

/**
 * Mock AI 菜单生成服务（开发测试阶段使用）
 * 返回固定的假数据，不调用真实 API
 */
@Slf4j
public class MockAiMenuGenerationService implements AiMenuGenerationService {

    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        log.info("使用 Mock 模式生成菜单（不调用真实 API）");
        
        List<MenuDTO> menus = new ArrayList<>();
        
        // 生成 5 个固定的菜单
        for (int i = 1; i <= 5; i++) {
            MenuDTO menu = createMockMenu(i, filter);
            menus.add(menu);
        }
        
        return menus;
    }

    private MenuDTO createMockMenu(int menuId, RecipeGenerationFilter filter) {
        MenuDTO menu = new MenuDTO();
        menu.setMenuId(menuId);
        
        List<MenuDTO.RecipeDTO> recipes = new ArrayList<>();
        
        // 根据 filter 中的信息调整菜单
        String mainDish = "Tomato and Egg Stir-fry";
        if (filter.getDietPreferences() != null && 
            filter.getDietPreferences().getCuisinePreferences() != null &&
            !filter.getDietPreferences().getCuisinePreferences().isEmpty()) {
            String cuisine = filter.getDietPreferences().getCuisinePreferences().get(0);
            if (cuisine.toLowerCase().contains("chinese")) {
                mainDish = "番茄炒蛋";
            }
        }
        
        MenuDTO.RecipeDTO recipe = new MenuDTO.RecipeDTO();
        recipe.setTitle(mainDish);
        recipe.setShortDescription("Classic home-style dish with tomatoes and eggs");
        recipe.setServings(filter.getServings() != null ? filter.getServings() : 2);
        recipe.setCookingTimeMin(15);
        recipe.setDifficulty("easy");
        
        // 营养估算
        MenuDTO.NutritionEstimate nutrition = new MenuDTO.NutritionEstimate();
        Double targetCalories = filter.getCalorieTarget() != null ? 
            filter.getCalorieTarget().getMaxTotalKcal() : 600.0;
        if (filter.getServings() != null && filter.getServings() > 0) {
            targetCalories = targetCalories * filter.getServings();
        }
        nutrition.setCalories(targetCalories);
        nutrition.setProteinG(targetCalories * 0.15); // 15% 蛋白质
        nutrition.setFatG(targetCalories * 0.25 / 9); // 25% 脂肪
        nutrition.setCarbsG(targetCalories * 0.60 / 4); // 60% 碳水
        recipe.setNutritionEstimate(nutrition);
        
        // 食材列表
        List<MenuDTO.IngredientDTO> ingredients = new ArrayList<>();
        
        MenuDTO.IngredientDTO tomato = new MenuDTO.IngredientDTO();
        tomato.setName("Tomato");
        tomato.setAmountValue(2.0);
        tomato.setAmountUnit("pieces");
        tomato.setIsOptional(false);
        tomato.setSourceType("INVENTORY");
        ingredients.add(tomato);
        
        MenuDTO.IngredientDTO egg = new MenuDTO.IngredientDTO();
        egg.setName("Egg");
        egg.setAmountValue(3.0);
        egg.setAmountUnit("pieces");
        egg.setIsOptional(false);
        egg.setSourceType("INVENTORY");
        ingredients.add(egg);
        
        MenuDTO.IngredientDTO oil = new MenuDTO.IngredientDTO();
        oil.setName("Cooking Oil");
        oil.setAmountValue(15.0);
        oil.setAmountUnit("ml");
        oil.setIsOptional(false);
        oil.setSourceType("MANUAL_ADD");
        ingredients.add(oil);
        
        recipe.setIngredients(ingredients);
        
        // 步骤
        List<MenuDTO.StepDTO> steps = new ArrayList<>();
        
        MenuDTO.StepDTO step1 = new MenuDTO.StepDTO();
        step1.setStepNumber(1);
        step1.setInstruction("Wash and cut tomatoes into wedges");
        step1.setStepTimeMin(3);
        steps.add(step1);
        
        MenuDTO.StepDTO step2 = new MenuDTO.StepDTO();
        step2.setStepNumber(2);
        step2.setInstruction("Beat eggs in a bowl");
        step2.setStepTimeMin(2);
        steps.add(step2);
        
        MenuDTO.StepDTO step3 = new MenuDTO.StepDTO();
        step3.setStepNumber(3);
        step3.setInstruction("Heat oil in a pan, scramble eggs, then add tomatoes");
        step3.setStepTimeMin(10);
        steps.add(step3);
        
        recipe.setSteps(steps);
        recipes.add(recipe);
        menu.setRecipes(recipes);
        
        return menu;
    }
}

