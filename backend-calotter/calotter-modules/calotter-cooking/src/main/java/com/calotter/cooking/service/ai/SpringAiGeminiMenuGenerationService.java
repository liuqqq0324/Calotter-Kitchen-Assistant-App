package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.cooking.service.dto.MenuGenerationFunction;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Spring AI Gemini 菜单生成服务
 * 使用 Spring AI 的 Function Calling 和结构化输出来减少 token 消耗
 */
@Slf4j
@RequiredArgsConstructor
public class SpringAiGeminiMenuGenerationService implements AiMenuGenerationService {
    
    private final ChatModel chatModel;
    private final ObjectMapper objectMapper;

    // 极简 System Prompt (优化 token 消耗)
    private static final String MINIMAL_SYSTEM_PROMPT = """
        Role: Diet Chef. Task: Generate EXACTLY 3 MENUS.
        Input: Urgent items first.
        Rules:
        1. JSON output only.
        2. Use 'Urgent' inventory to prevent waste.
        3. Ensure variety between menus.
        """;
    
    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        try {
            log.info("Generating menus");
            return executeGeneration(filter);
        } catch (Exception e) {
            log.error("生成菜单失败: {}", e.getMessage(), e);
            throw new RuntimeException("生成菜单失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 执行实际的生成逻辑
     */
    private List<MenuDTO> executeGeneration(RecipeGenerationFilter filter) {
        // 使用极简输入构建（节省 Token）
        String userInput = buildMinimalInput(filter);
        log.debug("User input: {}", userInput);
        
        ChatClient chatClient = ChatClient.builder(chatModel).build();
        
        MenuGenerationFunction functionResult = chatClient
            .prompt()
            .system(MINIMAL_SYSTEM_PROMPT)
            .user(userInput)
            .call()
            .entity(MenuGenerationFunction.class);
            
        if (functionResult == null || functionResult.getMenus() == null || functionResult.getMenus().isEmpty()) {
            throw new RuntimeException("Empty result from AI");
        }
        
        log.info("Successfully generated {} menu(s)", functionResult.getMenus().size());
        
        return functionResult.getMenus().stream()
            .map(this::convertToMenuDTO)
            .collect(Collectors.toList());
    }

    /**
     * 构建输入 (包含完整信息)
     * 包含：库存（含数量单位）、菜品数量、卡路里、份数、烹饪时间、难度、厨具、调料、偏好等
     */
    private String buildMinimalInput(RecipeGenerationFilter filter) {
        StringBuilder sb = new StringBuilder();
        sb.append("Context:{");
        
        // 1. 急需库存 (包含名称、数量、单位)
        sb.append("Urgent:[");
        if (filter.getUrgentInventory() != null && !filter.getUrgentInventory().isEmpty()) {
            String urgentItems = filter.getUrgentInventory().stream()
                .filter(item -> item != null && item.getName() != null && !item.getName().isEmpty())
                .map(item -> {
                    String name = item.getName();
                    String amount = item.getAmountValue() != null ? item.getAmountValue().toString() : "";
                    String unit = item.getAmountUnit() != null ? item.getAmountUnit() : "";
                    if (!amount.isEmpty() && !unit.isEmpty()) {
                        return name + "(" + amount + unit + ")";
                    } else if (!amount.isEmpty()) {
                        return name + "(" + amount + ")";
                    }
                    return name;
                })
                .collect(Collectors.joining(","));
            sb.append(urgentItems);
        }
        sb.append("],");

        // 2. 常规库存 (截取前 15 个，包含名称、数量、单位)
        sb.append("Regular:[");
        if (filter.getRegularInventory() != null && !filter.getRegularInventory().isEmpty()) {
            String regularItems = filter.getRegularInventory().stream()
                .limit(15) // Limit to 15 items
                .filter(item -> item != null && item.getName() != null && !item.getName().isEmpty())
                .map(item -> {
                    String name = item.getName();
                    String amount = item.getAmountValue() != null ? item.getAmountValue().toString() : "";
                    String unit = item.getAmountUnit() != null ? item.getAmountUnit() : "";
                    if (!amount.isEmpty() && !unit.isEmpty()) {
                        return name + "(" + amount + unit + ")";
                    } else if (!amount.isEmpty()) {
                        return name + "(" + amount + ")";
                    }
                    return name;
                })
                .collect(Collectors.joining(","));
            sb.append(regularItems);
        }
        sb.append("],");
        
        // 3. 核心限制：菜品数量
        int dishCount = 1;
        if (filter.getGenerationSettings() != null && filter.getGenerationSettings().getDishCount() != null) {
            dishCount = filter.getGenerationSettings().getDishCount();
        }
        sb.append("DishCount:").append(dishCount);
        
        // 4. 份数
        if (filter.getServings() != null) {
            sb.append(",Servings:").append(filter.getServings());
        }
        
        // 5. 卡路里目标
        if (filter.getCalorieTarget() != null) {
            if (filter.getCalorieTarget().getMinTotalKcal() != null || filter.getCalorieTarget().getMaxTotalKcal() != null) {
                sb.append(",Calories:");
                if (filter.getCalorieTarget().getMinTotalKcal() != null && filter.getCalorieTarget().getMaxTotalKcal() != null) {
                    if (filter.getCalorieTarget().getMinTotalKcal().equals(filter.getCalorieTarget().getMaxTotalKcal())) {
                        sb.append(filter.getCalorieTarget().getMinTotalKcal().intValue());
                    } else {
                        sb.append(filter.getCalorieTarget().getMinTotalKcal().intValue())
                          .append("-")
                          .append(filter.getCalorieTarget().getMaxTotalKcal().intValue());
                    }
                } else if (filter.getCalorieTarget().getMinTotalKcal() != null) {
                    sb.append(">=").append(filter.getCalorieTarget().getMinTotalKcal().intValue());
                } else if (filter.getCalorieTarget().getMaxTotalKcal() != null) {
                    sb.append("<=").append(filter.getCalorieTarget().getMaxTotalKcal().intValue());
                }
            }
        }
        
        // 6. 最大烹饪时间
        if (filter.getGenerationSettings() != null && filter.getGenerationSettings().getMaxCookingTimeMin() != null) {
            sb.append(",MaxTime:").append(filter.getGenerationSettings().getMaxCookingTimeMin()).append("min");
        }
        
        // 7. 难度目标
        if (filter.getGenerationSettings() != null && filter.getGenerationSettings().getDifficultyTarget() != null) {
            sb.append(",Difficulty:").append(filter.getGenerationSettings().getDifficultyTarget());
        }
        
        // 8. 厨具列表
        if (filter.getCookers() != null && !filter.getCookers().isEmpty()) {
            sb.append(",Cookers:[");
            sb.append(String.join(",", filter.getCookers()));
            sb.append("]");
        }
        
        // 9. 调料列表
        if (filter.getSeasonings() != null && !filter.getSeasonings().isEmpty()) {
            sb.append(",Seasonings:[");
            sb.append(String.join(",", filter.getSeasonings()));
            sb.append("]");
        }
        
        // 10. 饮食限制和偏好
        if (filter.getDietPreferences() != null) {
            if (filter.getDietPreferences().getAllergies() != null && !filter.getDietPreferences().getAllergies().isEmpty()) {
                sb.append(",Allergies:[");
                sb.append(String.join(",", filter.getDietPreferences().getAllergies()));
                sb.append("]");
            }
            if (filter.getDietPreferences().getDietHabits() != null && !filter.getDietPreferences().getDietHabits().isEmpty()) {
                sb.append(",DietHabits:[");
                sb.append(String.join(",", filter.getDietPreferences().getDietHabits()));
                sb.append("]");
            }
            if (filter.getDietPreferences().getAvoidIngredients() != null && !filter.getDietPreferences().getAvoidIngredients().isEmpty()) {
                sb.append(",Avoid:[");
                sb.append(String.join(",", filter.getDietPreferences().getAvoidIngredients()));
                sb.append("]");
            }
            // 11. 菜系偏好
            if (filter.getDietPreferences().getCuisinePreferences() != null && !filter.getDietPreferences().getCuisinePreferences().isEmpty()) {
                sb.append(",Cuisines:[");
                sb.append(String.join(",", filter.getDietPreferences().getCuisinePreferences()));
                sb.append("]");
            }
            // 12. 口味偏好
            if (filter.getDietPreferences().getTastePreferences() != null && !filter.getDietPreferences().getTastePreferences().isEmpty()) {
                sb.append(",Tastes:[");
                sb.append(String.join(",", filter.getDietPreferences().getTastePreferences()));
                sb.append("]");
            }
        }
        
        sb.append("}");
        
        return sb.toString();
    }
    

    /**
     * Convert MenuGenerationFunction.MenuOption to MenuDTO
     */
    private MenuDTO convertToMenuDTO(MenuGenerationFunction.MenuOption menuOption) {
        MenuDTO menuDTO = new MenuDTO();
        menuDTO.setMenuId(menuOption.getMenuId());
        
        List<MenuDTO.RecipeDTO> recipes = menuOption.getRecipes().stream()
            .map(this::convertToRecipeDTO)
            .collect(Collectors.toList());
        menuDTO.setRecipes(recipes);
        
        return menuDTO;
    }
    
    /**
     * Convert MenuGenerationFunction.RecipeOption to MenuDTO.RecipeDTO
     */
    private MenuDTO.RecipeDTO convertToRecipeDTO(MenuGenerationFunction.RecipeOption recipeOption) {
        MenuDTO.RecipeDTO recipeDTO = new MenuDTO.RecipeDTO();
        recipeDTO.setTitle(recipeOption.getTitle());
        recipeDTO.setShortDescription(recipeOption.getShortDescription());
        recipeDTO.setServings(recipeOption.getServings());
        recipeDTO.setCookingTimeMin(recipeOption.getCookingTimeMin());
        recipeDTO.setDifficulty(recipeOption.getDifficulty());
        recipeDTO.setCategory(recipeOption.getCategory()); // 设置烹饪分类
        
        // Convert nutrition estimate
        if (recipeOption.getNutritionEstimate() != null) {
            MenuDTO.NutritionEstimate nutrition = new MenuDTO.NutritionEstimate();
            nutrition.setCalories(recipeOption.getNutritionEstimate().getCalories());
            nutrition.setProteinG(recipeOption.getNutritionEstimate().getProteinG());
            nutrition.setFatG(recipeOption.getNutritionEstimate().getFatG());
            nutrition.setCarbsG(recipeOption.getNutritionEstimate().getCarbsG());
            recipeDTO.setNutritionEstimate(nutrition);
        }
        
        // Convert ingredients
        if (recipeOption.getIngredients() != null) {
            List<MenuDTO.IngredientDTO> ingredients = recipeOption.getIngredients().stream()
                .map(ing -> {
                    MenuDTO.IngredientDTO dto = new MenuDTO.IngredientDTO();
                    dto.setName(ing.getName());
                    dto.setAmountValue(ing.getAmountValue());
                    dto.setAmountUnit(ing.getAmountUnit());
                    dto.setIsOptional(ing.getIsOptional());
                    return dto;
                })
                .collect(Collectors.toList());
            recipeDTO.setIngredients(ingredients);
        }
        
        // Convert steps
        if (recipeOption.getSteps() != null) {
            List<MenuDTO.StepDTO> steps = recipeOption.getSteps().stream()
                .map(step -> {
                    MenuDTO.StepDTO dto = new MenuDTO.StepDTO();
                    dto.setStepNumber(step.getStepNumber());
                    dto.setInstruction(step.getInstruction());
                    dto.setStepTimeMin(step.getStepTimeMin());
                    return dto;
                })
                .collect(Collectors.toList());
            recipeDTO.setSteps(steps);
        }
        
        return recipeDTO;
    }
}
