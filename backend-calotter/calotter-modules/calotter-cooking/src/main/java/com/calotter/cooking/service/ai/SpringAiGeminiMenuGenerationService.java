package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.cooking.service.dto.MenuGenerationFunction;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import reactor.core.publisher.Flux;

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
    
    // ✅ 修复 1: 极简 Prompt，移除所有关于 JSON 格式、字段名的指令
    // Spring AI 会自动处理 Schema，多余的指令只会干扰模型
    private static final String MINIMAL_SYSTEM_PROMPT = """
        You are a professional Diet-focused cooking assistant. 
        Task: Generate EXACTLY 3 distinct menus based on the user's inventory and preferences.
        
        Rules:
        1. Prioritize 'urgentInventory' ingredients to prevent waste.
        2. Ensure nutritional balance for the whole recipe.
        3. Respect all dietary constraints and cooker compatibility.
        """;

    /** 流式模式：每次只请求 1 个菜单，降低 JSON 幻觉概率 */
    private static final String SINGLE_MENU_PROMPT = """
        You are a professional Diet-focused cooking assistant. 
        Task: Generate EXACTLY 1 menu based on the user's inventory and preferences.
        
        Rules:
        1. Prioritize 'urgentInventory' ingredients to prevent waste.
        2. Ensure nutritional balance for the whole recipe.
        3. Respect all dietary constraints and cooker compatibility.
        """;
    
    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        // ✅ 修复 2: 简单的手动重试机制
        int maxRetries = 3;
        int attempt = 0;
        Exception lastException = null;

        while (attempt < maxRetries) {
            try {
                attempt++;
                log.info("Generating menus with Gemini (Attempt {}/{})", attempt, maxRetries);
                return executeGeneration(filter);
            } catch (Exception e) {
                log.warn("Attempt {} failed: {}", attempt, e.getMessage());
                lastException = e;
                // 如果是配额不足(429)，直接抛出，不要重试
                String errorMsg = e.getMessage();
                if (errorMsg != null && (errorMsg.contains("429") || errorMsg.contains("quota"))) {
                    throw new IllegalStateException("Gemini API quota exceeded. Please try again later or check your API quota limits.");
                }
            }
        }
        throw new RuntimeException("Failed to generate menus after " + maxRetries + " attempts", lastException);
    }

    @Override
    public Flux<MenuDTO> generateMenuStream(RecipeGenerationFilter filter) {
        int totalMenus = 5;
        return Flux.range(1, totalMenus)
                .flatMap(i -> generateSingleMenuAsync(filter, i));
    }

    private Flux<MenuDTO> generateSingleMenuAsync(RecipeGenerationFilter filter, int index) {
        return Flux.defer(() -> {
            try {
                log.info("Generating menu #{}...", index);
                MenuDTO menu = executeSingleGeneration(filter);
                menu.setMenuId(index);
                return Flux.just(menu);
            } catch (Exception e) {
                log.warn("Failed to generate menu #{}: {}", index, e.getMessage());
                return Flux.empty();
            }
        });
    }

    private MenuDTO executeSingleGeneration(RecipeGenerationFilter filter) {
        String userInput = buildUserInputForStream(filter);
        log.debug("User input (stream): {}", userInput);
        ChatClient chatClient = ChatClient.builder(chatModel).build();
        MenuGenerationFunction functionResult = chatClient
                .prompt()
                .system(SINGLE_MENU_PROMPT)
                .user(userInput)
                .call()
                .entity(MenuGenerationFunction.class);
        if (functionResult == null || functionResult.getMenus() == null || functionResult.getMenus().isEmpty()) {
            throw new RuntimeException("Empty response from AI");
        }
        return convertToMenuDTO(functionResult.getMenus().get(0));
    }

    private String buildUserInputForStream(RecipeGenerationFilter filter) {
        try {
            String filterJson = objectMapper.writeValueAsString(filter);
            return String.format("Context Data: %s\nPlease generate 1 menu now.", filterJson);
        } catch (Exception e) {
            throw new RuntimeException("Failed to build user input", e);
        }
    }

    /**
     * 执行实际的菜单生成逻辑
     */
    private List<MenuDTO> executeGeneration(RecipeGenerationFilter filter) {
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
        
        if (functionResult == null || functionResult.getMenus() == null || functionResult.getMenus().isEmpty()) {
            throw new RuntimeException("Empty response from AI");
        }
        
        log.info("Successfully generated {} menu(s)", functionResult.getMenus().size());
        
        return functionResult.getMenus().stream()
            .map(this::convertToMenuDTO)
            .collect(Collectors.toList());
    }
    
    /**
     * Build user input (optimized for token reduction)
     * Dietary habits explanation is minimal since System Prompt already covers it
     */
    private String buildUserInput(RecipeGenerationFilter filter) {
        try {
            String filterJson = objectMapper.writeValueAsString(filter);
            // ✅ 修复 3: User Input 同样移除具体的字段名指导，只保留业务逻辑
            return String.format("Context Data: %s\nPlease generate the menus now.", filterJson);
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

