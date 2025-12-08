package com.souschef.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.souschef.dto.recipe.*;
import com.souschef.entity.Recipe;
import com.souschef.entity.RecipeIngredient;
import com.souschef.entity.RecipeKitchenware;
import com.souschef.repository.RecipeIngredientRepository;
import com.souschef.repository.RecipeKitchenwareRepository;
import com.souschef.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecipeService {
    
    @Autowired
    private RecipeRepository recipeRepository;
    
    @Autowired
    private RecipeIngredientRepository recipeIngredientRepository;
    
    @Autowired
    private RecipeKitchenwareRepository recipeKitchenwareRepository;
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * 根据筛选条件生成食谱菜单
     * 注意：这里目前是从数据库查询，实际应该调用AI引擎生成
     */
    public List<RecipeMenuResponse> generateRecipeMenus(RecipeGenerateRequest request) {
        // TODO: 这里应该调用AI引擎API生成食谱
        // 目前先返回空列表，或者从数据库查询符合条件的食谱
        
        // 临时实现：从数据库查询一些食谱作为示例
        List<Recipe> recipes = recipeRepository.findAll();
        
        // 根据条件筛选
        recipes = filterRecipes(recipes, request);
        
        // 如果筛选后没有足够的食谱，返回空列表
        if (recipes.isEmpty()) {
            return new ArrayList<>();
        }
        
        // 将食谱分组为菜单（每个菜单包含request.dishCount个食谱）
        int dishCount = request.getResolvedDishCount() != null ? request.getResolvedDishCount() : 1;
        int menuCount = Math.min(5, (recipes.size() + dishCount - 1) / dishCount); // 最多5个菜单
        
        List<RecipeMenuResponse> menus = new ArrayList<>();
        for (int i = 0; i < menuCount; i++) {
            int start = i * dishCount;
            int end = Math.min(start + dishCount, recipes.size());
            List<Recipe> menuRecipes = recipes.subList(start, end);
            
            RecipeMenuResponse menu = new RecipeMenuResponse();
            menu.setMenuId(i + 1);
            menu.setRecipes(menuRecipes.stream()
                    .map(this::convertToRecipeResponse)
                    .collect(Collectors.toList()));
            menus.add(menu);
        }
        
        return menus;
    }
    
    /**
     * 根据条件筛选食谱
     */
    private List<Recipe> filterRecipes(List<Recipe> recipes, RecipeGenerateRequest request) {
        return recipes.stream()
                .filter(recipe -> {
                    // 难度筛选
                    String difficultyTarget = request.getResolvedDifficultyTarget();
                    if (difficultyTarget != null && !difficultyTarget.isEmpty()) {
                        String difficulty = convertDifficultyLevel(recipe.getDifficultyLevel());
                        if (!difficultyTarget.equalsIgnoreCase(difficulty)) {
                            return false;
                        }
                    }
                    
                    // 时间筛选
                    Integer maxCookingTime = request.getResolvedMaxCookingTimeMin();
                    if (maxCookingTime != null) {
                        if (recipe.getTotalTimeMinutes() != null && 
                            recipe.getTotalTimeMinutes() > maxCookingTime) {
                            return false;
                        }
                    }
                    
                    // 卡路里筛选
                    Double maxCalorie = request.getResolvedMaxCalorie();
                    if (maxCalorie != null && recipe.getCaloriesPerServing() != null) {
                        if (recipe.getCaloriesPerServing() > maxCalorie) {
                            return false;
                        }
                    }
                    
                    // 菜系筛选
                    if (request.getDietPreferences() != null && 
                        request.getDietPreferences().getCuisinePreferences() != null &&
                        !request.getDietPreferences().getCuisinePreferences().isEmpty()) {
                        if (recipe.getCuisineType() == null || 
                            !request.getDietPreferences().getCuisinePreferences().contains(recipe.getCuisineType())) {
                            return false;
                        }
                    }
                    
                    // TODO: 过敏原和禁忌食材筛选（需要检查食材）
                    
                    return true;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * 将Recipe实体转换为RecipeResponse DTO
     */
    public RecipeResponse convertToRecipeResponse(Recipe recipe) {
        RecipeResponse response = new RecipeResponse();
        response.setRecipeId(String.valueOf(recipe.getId()));
        response.setTitle(recipe.getName());
        response.setShortDescription(recipe.getDescription() != null ? recipe.getDescription() : "");
        response.setServings(recipe.getServingSize() != null ? recipe.getServingSize() : 1);
        response.setCookingTimeMin(recipe.getTotalTimeMinutes() != null ? recipe.getTotalTimeMinutes() : 0);
        response.setDifficulty(convertDifficultyLevel(recipe.getDifficultyLevel()));
        response.setTotalCaloriesEstimate(recipe.getCaloriesPerServing() != null ? 
                recipe.getCaloriesPerServing().doubleValue() : 0.0);
        response.setEmoji("🍽️"); // 默认emoji
        
        // 转换食材
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByRecipeId(recipe.getId());
        response.setIngredients(ingredients.stream()
                .map(ri -> {
                    RecipeIngredientResponse ir = new RecipeIngredientResponse();
                    ir.setName(ri.getIngredient().getName());
                    ir.setAmountValue(ri.getQuantity().doubleValue());
                    ir.setAmountUnit(ri.getUnit());
                    ir.setIsOptional(ri.getOptional() != null ? ri.getOptional() : false);
                    return ir;
                })
                .collect(Collectors.toList()));
        
        // 转换步骤
        try {
            if (recipe.getInstructions() != null && !recipe.getInstructions().isEmpty()) {
                Map<String, Object> instructionsMap = objectMapper.readValue(
                        recipe.getInstructions(), 
                        new TypeReference<Map<String, Object>>() {});
                
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> stepsList = (List<Map<String, Object>>) instructionsMap.get("steps");
                
                if (stepsList != null) {
                    response.setSteps(stepsList.stream()
                            .map(step -> {
                                RecipeStepResponse sr = new RecipeStepResponse();
                                sr.setStepNumber(((Number) step.getOrDefault("step", 0)).intValue());
                                sr.setInstruction((String) step.getOrDefault("text", ""));
                                sr.setStepTimeMin(((Number) step.getOrDefault("timer_seconds", 0)).intValue() / 60);
                                return sr;
                            })
                            .collect(Collectors.toList()));
                } else {
                    response.setSteps(new ArrayList<>());
                }
            } else {
                response.setSteps(new ArrayList<>());
            }
        } catch (Exception e) {
            response.setSteps(new ArrayList<>());
        }
        
        return response;
    }
    
    /**
     * 根据ID获取食谱详情
     */
    public RecipeResponse getRecipeById(Integer id) {
        Optional<Recipe> recipeOpt = recipeRepository.findById(id);
        if (recipeOpt.isEmpty()) {
            return null;
        }
        return convertToRecipeResponse(recipeOpt.get());
    }
    
    /**
     * 将难度等级转换为字符串
     */
    private String convertDifficultyLevel(Integer level) {
        if (level == null) return "easy";
        switch (level) {
            case 1: return "easy";
            case 2: return "medium";
            case 3: return "hard";
            default: return "easy";
        }
    }
}
