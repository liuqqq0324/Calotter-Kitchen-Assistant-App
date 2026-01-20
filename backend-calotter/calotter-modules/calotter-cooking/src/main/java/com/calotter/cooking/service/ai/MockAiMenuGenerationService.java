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
        
        // 生成 3 个固定的菜单
        for (int i = 1; i <= 3; i++) {
            MenuDTO menu = createMockMenu(i, filter);
            menus.add(menu);
        }
        
        return menus;
    }

    private MenuDTO createMockMenu(int menuId, RecipeGenerationFilter filter) {
        MenuDTO menu = new MenuDTO();
        menu.setMenuId(menuId);
        
        List<MenuDTO.RecipeDTO> recipes = new ArrayList<>();
        
        // 获取 dishCount，默认为 1
        int dishCount = 1;
        if (filter.getGenerationSettings() != null && 
            filter.getGenerationSettings().getDishCount() != null) {
            dishCount = filter.getGenerationSettings().getDishCount();
        }
        
        // 根据 dishCount 生成多道菜
        String[] mockDishes = {
            "Tomato and Egg Stir-fry",
            "Steamed Fish with Ginger",
            "Bok Choy with Garlic",
            "Miso Soup",
            "White Rice"
        };
        
        // 根据 filter 中的信息调整菜单
        String mainDish = mockDishes[0];
        if (filter.getDietPreferences() != null && 
            filter.getDietPreferences().getCuisinePreferences() != null &&
            !filter.getDietPreferences().getCuisinePreferences().isEmpty()) {
            String cuisine = filter.getDietPreferences().getCuisinePreferences().get(0);
            if (cuisine.toLowerCase().contains("chinese")) {
                mainDish = "Scrambled Eggs with Tomatoes";
                mockDishes = new String[]{"Scrambled Eggs with Tomatoes", "Steamed Fish", "Garlic Bok Choy", "Seaweed Soup", "White Rice"};
            }
        }
        
        // 根据 dishCount 生成对应数量的菜品
        for (int i = 0; i < Math.min(dishCount, mockDishes.length); i++) {
            MenuDTO.RecipeDTO recipe = new MenuDTO.RecipeDTO();
            recipe.setTitle(mockDishes[i]);
            recipe.setShortDescription("A delicious " + mockDishes[i].toLowerCase());
            recipe.setServings(filter.getServings() != null ? filter.getServings() : 2);
            recipe.setCookingTimeMin(15 + i * 5);
            recipe.setDifficulty("easy");
            
            // 营养估算 - 按照 dishCount 平分总卡路里
            MenuDTO.NutritionEstimate nutrition = new MenuDTO.NutritionEstimate();
            Double targetCalories = filter.getCalorieTarget() != null ? 
                filter.getCalorieTarget().getMaxTotalKcal() : 600.0;
            if (filter.getServings() != null && filter.getServings() > 0) {
                targetCalories = targetCalories * filter.getServings();
            }
            // 将总卡路里分配给每道菜
            Double dishCalories = targetCalories / dishCount;
            nutrition.setCalories(dishCalories);
            nutrition.setProteinG(dishCalories * 0.15); // 15% 蛋白质
            nutrition.setFatG(dishCalories * 0.25 / 9); // 25% 脂肪
            nutrition.setCarbsG(dishCalories * 0.60 / 4); // 60% 碳水
            recipe.setNutritionEstimate(nutrition);
            
            // 食材列表（简化版）
            List<MenuDTO.IngredientDTO> ingredients = new ArrayList<>();
            
            MenuDTO.IngredientDTO mainIngredient = new MenuDTO.IngredientDTO();
            mainIngredient.setName(mockDishes[i].split(" ")[0]); // 取第一个词作为主食材
            mainIngredient.setAmountValue(200.0 + i * 50);
            mainIngredient.setAmountUnit("g");
            mainIngredient.setIsOptional(false);
            mainIngredient.setSourceType("INVENTORY");
            ingredients.add(mainIngredient);
            
            recipe.setIngredients(ingredients);
            
            // 步骤（简化版）
            List<MenuDTO.StepDTO> steps = new ArrayList<>();
            
            MenuDTO.StepDTO step = new MenuDTO.StepDTO();
            step.setStepNumber(1);
            step.setInstruction("Prepare and cook " + mockDishes[i].toLowerCase());
            step.setStepTimeMin(recipe.getCookingTimeMin());
            steps.add(step);
            
            recipe.setSteps(steps);
            recipes.add(recipe);
        }
        
        menu.setRecipes(recipes);
        
        return menu;
    }
}

