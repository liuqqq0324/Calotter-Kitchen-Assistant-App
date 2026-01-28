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
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Spring AI Gemini 菜单生成服务
 * 使用 Spring AI 的 Function Calling 和结构化输出来减少 token 消耗
 * 
 * 修复：添加重试延迟机制，防止重试风暴导致 429 错误
 */
@Slf4j
@RequiredArgsConstructor
public class SpringAiGeminiMenuGenerationService implements AiMenuGenerationService {
    
    private final ChatModel chatModel;
    private final ObjectMapper objectMapper;
    
    // 提取等待时间的正则表达式
    private static final Pattern RETRY_AFTER_PATTERN = Pattern.compile("Please retry in (\\d+(?:\\.\\d+)?)s\\.");

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
        int maxRetries = 3;
        int attempt = 0;
        Exception lastException = null;

        while (attempt < maxRetries) {
            try {
                attempt++;
                log.info("Generating 3 menus (Attempt {}/{})", attempt, maxRetries);
                
                return executeGeneration(filter);

            } catch (Exception e) {
                lastException = e;
                log.warn("Attempt {} failed: {}", attempt, e.getMessage());

                // 🛑 关键修复：检查是否需要等待，并执行睡眠
                if (isQuotaExceededError(e)) {
                    long waitMs = parseWaitTime(e);
                    // 如果 API 没说等多久，默认指数退避: 2s, 4s, 8s
                    if (waitMs == 0) {
                        waitMs = (long) Math.pow(2, attempt) * 1000;
                    }

                    log.warn("⚠️ 429 Rate Limit detected. Sleeping for {} ms before retry...", waitMs);
                    
                    try {
                        // 强制睡眠！不睡就是自杀
                        Thread.sleep(waitMs + 1000); // 多睡1秒缓冲
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("Interrupted during rate limit backoff", ie);
                    }
                } else {
                    // 非 429 错误，稍微等一下再重试
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("Interrupted during retry backoff", ie);
                    }
                }
            }
        }
        
        // 所有重试都失败
        String errorMsg = lastException != null ? lastException.getMessage() : "Unknown error";
        throw new RuntimeException("Failed to generate menus after " + maxRetries + " attempts. Last error: " + errorMsg, lastException);
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
     * 极简输入构建 (节省 Token)
     * 只包含最核心的信息：急需库存、常规库存、菜品数量
     */
    private String buildMinimalInput(RecipeGenerationFilter filter) {
        StringBuilder sb = new StringBuilder();
        sb.append("Context:{");
        
        // 1. 急需库存 (最重要)
        sb.append("Urgent:[");
        if (filter.getUrgentInventory() != null && !filter.getUrgentInventory().isEmpty()) {
            String urgentNames = filter.getUrgentInventory().stream()
                .map(RecipeGenerationFilter.InventoryItem::getName)
                .filter(name -> name != null && !name.isEmpty())
                .collect(Collectors.joining(","));
            sb.append(urgentNames);
        }
        sb.append("],");

        // 2. 常规库存 (截取前 15 个，防止过长)
        sb.append("Regular:[");
        if (filter.getRegularInventory() != null && !filter.getRegularInventory().isEmpty()) {
            String regularNames = filter.getRegularInventory().stream()
                .limit(15) // Limit to 15 items
                .map(RecipeGenerationFilter.InventoryItem::getName)
                .filter(name -> name != null && !name.isEmpty())
                .collect(Collectors.joining(","));
            sb.append(regularNames);
        }
        sb.append("],");
        
        // 3. 核心限制：菜品数量
        int dishCount = 1;
        if (filter.getGenerationSettings() != null && filter.getGenerationSettings().getDishCount() != null) {
            dishCount = filter.getGenerationSettings().getDishCount();
        }
        sb.append("DishCount:").append(dishCount);
        
        // 4. 饮食限制（如果有）
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
        }
        
        sb.append("}");
        
        return sb.toString();
    }
    
    /**
     * 解析错误消息中的等待时间
     * 例如："Please retry in 41.188s." -> 41188 ms
     */
    private long parseWaitTime(Exception e) {
        String msg = e.getMessage();
        if (msg == null) {
            return 0;
        }
        
        Matcher matcher = RETRY_AFTER_PATTERN.matcher(msg);
        if (matcher.find()) {
            double seconds = Double.parseDouble(matcher.group(1));
            return (long) (seconds * 1000);
        }
        
        // 检查异常链中的消息
        Throwable cause = e.getCause();
        int depth = 0;
        while (cause != null && depth < 5) {
            String causeMsg = cause.getMessage();
            if (causeMsg != null) {
                matcher = RETRY_AFTER_PATTERN.matcher(causeMsg);
                if (matcher.find()) {
                    double seconds = Double.parseDouble(matcher.group(1));
                    return (long) (seconds * 1000);
                }
            }
            cause = cause.getCause();
            depth++;
        }
        
        return 0;
    }

    /**
     * 检查异常是否是配额超限错误（429）
     */
    private boolean isQuotaExceededError(Exception e) {
        String msg = e.getMessage();
        if (msg != null) {
            String lowerMsg = msg.toLowerCase();
            if (lowerMsg.contains("429") || 
                lowerMsg.contains("quota") || 
                lowerMsg.contains("quota exceeded") ||
                lowerMsg.contains("too many requests") ||
                lowerMsg.contains("rate limit")) {
                return true;
            }
        }
        
        // 检查异常链
        Throwable cause = e.getCause();
        int depth = 0;
        while (cause != null && depth < 5) {
            String causeMsg = cause.getMessage();
            if (causeMsg != null) {
                String lowerCauseMsg = causeMsg.toLowerCase();
                if (lowerCauseMsg.contains("429") || 
                    lowerCauseMsg.contains("quota") ||
                    lowerCauseMsg.contains("too many requests") ||
                    lowerCauseMsg.contains("rate limit")) {
                    return true;
                }
            }
            cause = cause.getCause();
            depth++;
        }
        
        return false;
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
