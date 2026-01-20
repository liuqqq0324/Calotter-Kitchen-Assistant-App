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
    
    // Minimal System Prompt (optimized for token reduction: ~30-50 tokens vs ~150 tokens)
    // JSON Schema is automatically handled by Spring AI via .entity() method, not in prompt
    private static final String MINIMAL_SYSTEM_PROMPT = """
        Diet-focused cooking assistant. Generate EXACTLY 3 menus.
        Rules: dishCount per menu, WHOLE recipe nutrition, inventory matching, dietary constraints, cooker compatibility.
        """;
    
    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        try {
            log.info("Starting menu generation with Spring AI Gemini");
            
            // Build user input
            String userInput = buildUserInput(filter);
            log.debug("User input: {}", userInput);
            
            // Use Spring AI ChatClient with structured output
            // JSON Schema is automatically generated from MenuGenerationFunction class annotations
            // and passed as API parameters (not in prompt), saving ~100-200 tokens compared to including Schema in prompt
            ChatClient chatClient = ChatClient.builder(chatModel).build();
            MenuGenerationFunction functionResult = chatClient
                .prompt()
                .system(MINIMAL_SYSTEM_PROMPT)
                .user(userInput)
                .call()
                .entity(MenuGenerationFunction.class); // Structured output with automatic JSON Schema
            
            log.info("Successfully generated {} menu(s)", functionResult.getMenus() != null ? functionResult.getMenus().size() : 0);
            
            // Convert to MenuDTO
            if (functionResult.getMenus() == null || functionResult.getMenus().isEmpty()) {
                throw new RuntimeException("Spring AI Gemini returned empty menu list");
            }
            
            return functionResult.getMenus().stream()
                .map(this::convertToMenuDTO)
                .collect(Collectors.toList());
                
        } catch (IllegalStateException e) {
            log.error("Spring AI Gemini API call failed (possibly quota issue): {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            log.error("Failed to generate menus with Spring AI Gemini", e);
            
            // Check if it's a quota error
            String errorMsg = e.getMessage();
            if (errorMsg != null && (errorMsg.contains("429") || errorMsg.contains("quota"))) {
                throw new IllegalStateException("Gemini API quota exceeded. Please try again later or check your API quota limits.");
            }
            
            throw new RuntimeException("Failed to generate menus with Spring AI Gemini: " + e.getMessage(), e);
        }
    }
    
    /**
     * Build user input (optimized for token reduction)
     * Dietary habits explanation is minimal since System Prompt already covers it
     */
    private String buildUserInput(RecipeGenerationFilter filter) {
        try {
            String filterJson = objectMapper.writeValueAsString(filter);
            // Simplified user input: remove redundant explanations since dietary habits are already in System Prompt
            // Saves ~50-80 tokens per request
            return String.format("Context: %s\nGenerate 3 menus following all constraints.", filterJson);
        } catch (Exception e) {
            throw new RuntimeException("Failed to build user input", e);
        }
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
                    dto.setSourceType(ing.getSourceType());
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

