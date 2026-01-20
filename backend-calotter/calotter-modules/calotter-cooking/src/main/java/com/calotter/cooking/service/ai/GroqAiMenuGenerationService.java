package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Groq AI 菜单生成服务（保留原有实现）
 */
@Slf4j
public class GroqAiMenuGenerationService implements AiMenuGenerationService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${ai.api.groq.api-key:}")
    private String apiKey;

    @Value("${ai.api.groq.url:https://api.groq.com/openai/v1/chat/completions}")
    private String apiUrl;

    @Value("${ai.api.groq.model:llama-3.3-70b-versatile}")
    private String model;

    private static final String SYSTEM_PROMPT = String.join("\n",
            "You are a diet-focused cooking assistant.",
            "INPUT SUMMARY: You receive fridge inventory, calorie targets (per person), servings, and preferences.",
            "YOUR TASK: Generate EXACTLY 5 menu options based on the input.",
            "",
            "**IMPORTANT**: Each menu should contain EXACTLY 'generationSettings.dishCount' recipes (dishes).",
            "- If dishCount=4, each menu must have 4 different recipes.",
            "- If dishCount=1, each menu has 1 recipe.",
            "- The recipes in a menu should be complementary (e.g., main dish + side dishes + soup).",
            "",
            "=== 1. CRITICAL DATA REQUIREMENTS (BACKEND RULES) ===",
            "1. NUTRITION ESTIMATE: Instead of just calories, you MUST estimate the full macro-nutrient breakdown for the WHOLE recipe (all servings combined).",
            "   - Provide: 'calories', 'proteinG', 'fatG', 'carbsG'.",
            "   - Base these estimates on the total ingredients used.",
            "2. INVENTORY SOURCE MATCHING:",
            "   - For every ingredient in the output list, check the input 'inventory'.",
            "   - If the name loosely matches an item in the fridge, set 'sourceType' to 'INVENTORY'.",
            "   - If it is a new item (or a seasoning not in the list), set 'sourceType' to 'MANUAL_ADD'.",
            "   - Prefer using ingredients from the inventory to reduce waste.",
            "",
            "=== 2. COOKING LOGIC & CONSTRAINTS (USER RULES) ===",
            "COOKWARE RULES:",
            "- If 'cookers' list is provided, ONLY use cooking methods compatible with them.",
            "- Example: If 'oven' is not listed, DO NOT generate recipes requiring baking.",
            "- If 'cookers' is empty, assume basic stove + pot/pan only.",
            "",
            "CALORIE LOGIC:",
            "- The input 'calorieTarget' is PER PERSON.",
            "- However, the output 'nutritionEstimate' must be for the WHOLE RECIPE.",
            "- Logic: Target Recipe Calories ≈ (Per-Person Target * Servings).",
            "- Keep recipes realistic. Do not force exact math if it ruins the food, but stay within range.",
            "",
            "DIFFICULTY DEFINITIONS:",
            "- Easy: Common ingredients, <= 30 mins, basic steps, simple equipment.",
            "- Medium: 30-60 mins, marinating/sauces, moderate attention needed.",
            "- Hard: > 60 mins, complex techniques (deep fry, dough), multiple stages.",
            "- Respect the 'difficultyTarget' if provided.",
            "",
            "DIETARY RESTRICTIONS (dietPreferences.dietHabits) - CRITICAL UNDERSTANDING:",
            "- ⚠️ IMPORTANT: The 'dietHabits' array contains the USER'S DIETARY LIFESTYLE/RESTRICTIONS, NOT things to avoid.",
            "- If 'dietHabits' contains 'vegetarian', it means THE USER IS A VEGETARIAN (they follow a vegetarian diet).",
            "- If 'dietHabits' contains 'vegetarian', you MUST generate ONLY vegetarian recipes (NO meat, NO poultry, NO fish, NO seafood).",
            "- ⚠️ DO NOT MISUNDERSTAND: 'vegetarian' in dietHabits = user is vegetarian = recipes must be vegetarian (no meat).",
            "- ⚠️ DO NOT MISUNDERSTAND: 'vegetarian' in dietHabits ≠ habit against vegetarian food ≠ must include meat.",
            "",
            "INTERPRETATION GUIDE (what each value in 'dietHabits' means):",
            "- 'vegetarian' in dietHabits = User follows vegetarian diet = Generate ONLY vegetarian recipes (NO chicken, beef, pork, lamb, fish, shrimp, crab, lobster, any meat, any seafood). Eggs and dairy are allowed unless 'vegan' is also present.",
            "- 'vegan' in dietHabits = User follows vegan diet = Generate ONLY vegan recipes (NO meat, fish, eggs, dairy, honey, any animal products).",
            "- 'halal' in dietHabits = User follows halal diet = Generate ONLY halal recipes (NO pork, NO alcohol).",
            "- 'kosher' in dietHabits = User follows kosher diet = Generate ONLY kosher recipes (NO pork, NO shellfish, do not mix meat and dairy).",
            "- 'gluten_free' in dietHabits = User requires gluten-free diet = Generate ONLY gluten-free recipes (NO wheat, barley, rye).",
            "- 'low_sugar' in dietHabits = User requires low-sugar diet = Generate recipes with minimal added sugar.",
            "- 'low_fat' in dietHabits = User requires low-fat diet = Generate recipes with lean cooking methods (avoid deep-frying).",
            "- 'low_sodium' in dietHabits = User requires low-sodium diet = Generate recipes with minimal salt and salty sauces.",
            "",
            "VALIDATION CHECKLIST (before including any ingredient):",
            "- If 'vegetarian' is in dietHabits: Ask 'Is this ingredient meat, poultry, fish, or seafood?' If YES, DO NOT use it.",
            "- If 'vegan' is in dietHabits: Ask 'Is this ingredient from an animal?' If YES, DO NOT use it.",
            "- These are ABSOLUTE HARD CONSTRAINTS. Violating them will result in recipe rejection.",
            "",
            "SEASONINGS & PREFERENCES:",
            "- Use the provided 'seasonings' list if possible. Assume basic (salt/oil/soy) if empty.",
            "- STRICTLY RESPECT 'allergies'. Never use allergic ingredients.",
            "- Avoid 'avoidIngredients'.",
            "",
            "=== 3. OUTPUT FORMAT (CRITICAL - MUST FOLLOW EXACTLY) ===",
            "You MUST return a JSON object with this EXACT structure:",
            "{",
            "  \"menus\": [",
            "    {",
            "      \"menuId\": 1,",
            "      \"recipes\": [",
            "        {",
            "          \"title\": \"Dish Name\",",
            "          \"shortDescription\": \"Brief description\",",
            "          \"servings\": 2,",
            "          \"cookingTimeMin\": 30,",
            "          \"difficulty\": \"easy\",",
            "          \"nutritionEstimate\": {",
            "            \"calories\": 600.0,",
            "            \"proteinG\": 30.0,",
            "            \"fatG\": 20.0,",
            "            \"carbsG\": 60.0",
            "          },",
            "          \"ingredients\": [",
            "            {",
            "              \"name\": \"Ingredient Name\",",
            "              \"amountValue\": 200.0,",
            "              \"amountUnit\": \"g\",",
            "              \"isOptional\": false,",
            "              \"sourceType\": \"INVENTORY\"",
            "            }",
            "          ],",
            "          \"steps\": [",
            "            {",
            "              \"stepNumber\": 1,",
            "              \"instruction\": \"Step description\",",
            "              \"stepTimeMin\": 5",
            "            }",
            "          ]",
            "        }",
            "      ]",
            "    }",
            "  ]",
            "}",
            "",
            "⚠️ CRITICAL JSON FORMAT RULES (MANDATORY - NO EXCEPTIONS):",
            "- The root object MUST have a 'menus' field containing an array of exactly 3 menu objects.",
            "- Each menu object MUST have 'menuId' (1-3) and 'recipes' array.",
            "- Each 'recipes' array MUST contain EXACTLY 'generationSettings.dishCount' recipe objects.",
            "  * If dishCount=4, recipes array length must be 4.",
            "  * If dishCount=1, recipes array length must be 1.",
            "- ⚠️ USE COLON (:) NOT EQUALS (=) for JSON key-value pairs.",
            "  * CORRECT: \"ingredients\": [",
            "  * WRONG: \"ingredients\"=[ or \"ingredients\"=[",
            "- ⚠️ All JSON keys MUST be enclosed in double quotes.",
            "- ⚠️ All string values MUST be enclosed in double quotes.",
            "- ⚠️ Use commas to separate array elements and object properties.",
            "- ⚠️ Do NOT use markdown code blocks (no ```json or ```).",
            "- ⚠️ Do NOT include any explanatory text before or after the JSON.",
            "- ⚠️ Return ONLY the raw JSON object, nothing else.",
            "- The JSON must be parseable by standard JSON parsers without any preprocessing.",
            "- Double-check your JSON syntax before returning it."
    );

    public GroqAiMenuGenerationService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        log.info("开始使用 Groq API 生成菜单，模型: {}", model);
        
        if (apiKey == null || apiKey.isBlank()) {
            log.error("Groq API key 未配置");
            throw new IllegalStateException("Groq API key 未配置");
        }
        
        // ✅ 添加重试机制
        int maxRetries = 3;
        Exception lastException = null;
        
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                log.info("尝试生成菜单 (第 {}/{} 次)", attempt, maxRetries);
                return generateMenusInternal(filter);
            } catch (Exception e) {
                lastException = e;
                log.warn("第 {} 次尝试失败: {}", attempt, e.getMessage());
                
                // 如果不是最后一次尝试，等待后重试
                if (attempt < maxRetries) {
                    try {
                        // 指数退避：等待时间随尝试次数增加
                        long waitMs = 1000L * attempt;
                        log.info("等待 {} ms 后重试...", waitMs);
                        Thread.sleep(waitMs);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("重试被中断", ie);
                    }
                } else {
                    log.error("所有 {} 次尝试均失败", maxRetries);
                }
            }
        }
        
        // 所有重试都失败，抛出最后一个异常
        throw new RuntimeException("使用 Groq 生成菜单失败，已重试 " + maxRetries + " 次: " + 
            (lastException != null ? lastException.getMessage() : "未知错误"), lastException);
    }
    
    private List<MenuDTO> generateMenusInternal(RecipeGenerationFilter filter) {
        try {
            String userJson = objectMapper.writeValueAsString(filter);
            log.debug("发送给 Groq 的请求数据: {}", userJson);

            // ✅ 构建明确的 user message，特别强调 dietHabits 的含义
            StringBuilder userMessage = new StringBuilder();
            userMessage.append("Here is the user context in JSON format:\n\n").append(userJson).append("\n\n");
            
            // ✅ 如果存在 dietHabits，明确说明其含义
            if (filter != null && filter.getDietPreferences() != null && 
                filter.getDietPreferences().getDietHabits() != null && 
                !filter.getDietPreferences().getDietHabits().isEmpty()) {
                List<String> dietHabits = filter.getDietPreferences().getDietHabits();
                userMessage.append("⚠️ CRITICAL CLARIFICATION ABOUT 'dietHabits' ARRAY:\n");
                userMessage.append("The 'dietHabits' array contains the USER'S DIETARY LIFESTYLE, not things to avoid.\n");
                userMessage.append("For example, if 'dietHabits' contains 'vegetarian', it means THE USER IS A VEGETARIAN.\n");
                userMessage.append("Therefore, you MUST generate ONLY vegetarian recipes (NO meat, NO poultry, NO fish, NO seafood).\n");
                userMessage.append("Current dietHabits (user's dietary lifestyle): ").append(String.join(", ", dietHabits)).append("\n");
                userMessage.append("Please generate recipes that match this dietary lifestyle.\n\n");
            }
            
            userMessage.append("Now generate the menus following ALL constraints.");
            userMessage.append("\n\n⚠️ REMINDER: Use COLON (:) not equals (=) for JSON key-value pairs. Return ONLY valid JSON.");

            Map<String, Object> payload = new HashMap<>();
            payload.put("model", model);
            payload.put("messages", List.of(
                    Map.of("role", "system", "content", SYSTEM_PROMPT),
                    Map.of("role", "user", "content", userMessage.toString())
            ));
            payload.put("response_format", Map.of("type", "json_object"));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            log.debug("调用 Groq API: {}", apiUrl);
            
            ResponseEntity<String> resp = restTemplate.exchange(apiUrl, HttpMethod.POST, entity, String.class);
            
            log.debug("Groq API 响应状态: {}", resp.getStatusCode());
            log.debug("Groq API 响应内容: {}", resp.getBody());
            
            if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
                log.error("Groq API 调用失败: status={}, body={}", resp.getStatusCode(), resp.getBody());
                throw new RuntimeException("Groq API 调用失败: " + resp.getStatusCode() + " " + resp.getBody());
            }

            JsonNode root = objectMapper.readTree(resp.getBody());
            String content = root.at("/choices/0/message/content").asText();
            
            if (content == null || content.isBlank()) {
                log.error("Groq API 返回的 content 为空，完整响应: {}", resp.getBody());
                throw new RuntimeException("Groq API 返回为空");
            }
            
            log.debug("Groq API 原始 content: {}", content);
            content = stripMarkdown(content);
            log.debug("Groq API 清理后的 content: {}", content);
            
            // ✅ 添加后处理修复逻辑
            content = fixJsonFormatErrors(content);
            log.debug("Groq API 修复后的 content: {}", content);

            JsonNode menuRoot = objectMapper.readTree(content);
            JsonNode menusNode = menuRoot.get("menus");
            
            // 添加详细的调试信息
            log.debug("menuRoot 类型: {}, menusNode 类型: {}", 
                menuRoot.getNodeType(), menusNode != null ? menusNode.getNodeType() : "null");
            if (menusNode != null) {
                log.debug("menusNode 是否为数组: {}, 是否为对象: {}", 
                    menusNode.isArray(), menusNode.isObject());
                if (menusNode.isObject()) {
                    log.debug("menusNode 对象的所有字段: {}", menusNode.fieldNames());
                }
            }
            
            // 如果找不到 "menus" 字段，尝试其他可能的字段名
            if (menusNode == null || !menusNode.isArray()) {
                log.warn("未找到 'menus' 数组字段，menusNode: {}, 尝试其他可能的字段名", menusNode);
                
                // 尝试常见的字段名（跳过已检查的 "menus"）
                String[] possibleFieldNames = {"menu_list", "results", "data", "items"};
                for (String fieldName : possibleFieldNames) {
                    JsonNode node = menuRoot.get(fieldName);
                    if (node != null && node.isArray()) {
                        log.info("找到数组字段: {}", fieldName);
                        menusNode = node;
                        break;
                    }
                }
                
                // 如果 menuRoot 本身就是数组，直接使用
                if ((menusNode == null || !menusNode.isArray()) && menuRoot.isArray()) {
                    log.info("根节点本身就是数组，直接使用");
                    menusNode = menuRoot;
                }
            }
            
            if (menusNode == null || !menusNode.isArray()) {
                log.error("Groq API 返回格式错误，期望包含 'menus' 数组");
                log.error("menuRoot 类型: {}, 是否为对象: {}, 是否为数组: {}", 
                    menuRoot.getNodeType(), menuRoot.isObject(), menuRoot.isArray());
                log.error("实际返回的 content: {}", content);
                if (menuRoot.isObject()) {
                    log.error("menuRoot 的所有字段: {}", menuRoot.fieldNames());
                }
                throw new RuntimeException("Groq API 返回不包含 menus 数组");
            }
            
            log.debug("解析到 {} 个菜单", menusNode.size());
            List<MenuDTO> menus = objectMapper.readerForListOf(MenuDTO.class).readValue(menusNode);
            
            // 验证解析结果
            if (menus == null || menus.isEmpty()) {
                log.error("Groq API 返回的 menus 数组为空或解析失败");
                throw new RuntimeException("Groq API 返回的 menus 数组为空");
            }
            
            // 检查每个菜单的数据完整性
            for (int i = 0; i < menus.size(); i++) {
                MenuDTO menu = menus.get(i);
                if (menu.getMenuId() == null) {
                    log.warn("菜单 {} 的 menuId 为 null，自动设置为 {}", i, i + 1);
                    menu.setMenuId(i + 1);
                }
                if (menu.getRecipes() == null || menu.getRecipes().isEmpty()) {
                    log.error("菜单 {} 的 recipes 为空或 null", i);
                } else {
                    log.debug("菜单 {} 包含 {} 个食谱", i, menu.getRecipes().size());
                }
            }
            
            log.info("成功生成 {} 个菜单", menus.size());
            return menus;
            
        } catch (Exception e) {
            log.error("使用 Groq 生成菜单失败", e);
            throw new RuntimeException("使用 Groq 生成菜单失败: " + e.getMessage(), e);
        }
    }

    private String stripMarkdown(String content) {
        String c = content.trim();
        if (c.startsWith("```json")) {
            c = c.substring(7);
        } else if (c.startsWith("```")) {
            c = c.substring(3);
        }
        if (c.endsWith("```")) {
            c = c.substring(0, c.length() - 3);
        }
        return c.trim();
    }
    
    /**
     * ✅ 修复常见的 JSON 格式错误
     * 主要修复问题：
     * 1. "key"=[ 应该改为 "key": [
     * 2. 其他可能的格式错误
     */
    private String fixJsonFormatErrors(String content) {
        if (content == null || content.isEmpty()) {
            return content;
        }
        
        String fixed = content;
        
        // 修复 "key"=[ 或 "key"= [ 的情况（将 = 替换为 :）
        // 使用正则表达式匹配，但要注意不要误替换字符串值中的 =
        // 匹配模式：引号后的 = 符号（后面可能跟着空格）
        fixed = fixed.replaceAll("\"([^\"]+)\"\\s*=\\s*\\[", "\"$1\": [");
        fixed = fixed.replaceAll("\"([^\"]+)\"\\s*=\\s*\\{", "\"$1\": {");
        fixed = fixed.replaceAll("\"([^\"]+)\"\\s*=\\s*\"", "\"$1\": \"");
        fixed = fixed.replaceAll("\"([^\"]+)\"\\s*=\\s*(-?\\d+(?:\\.\\d+)?)", "\"$1\": $2");
        fixed = fixed.replaceAll("\"([^\"]+)\"\\s*=\\s*(true|false|null)", "\"$1\": $2");
        
        // 修复其他可能的格式问题
        // 移除可能的尾随逗号（在 ] 或 } 之前）
        fixed = fixed.replaceAll(",\\s*([\\]\\}])", "$1");
        
        // 记录是否进行了修复
        if (!fixed.equals(content)) {
            log.info("检测到 JSON 格式错误，已自动修复");
            log.debug("修复前: {}", content.substring(0, Math.min(500, content.length())));
            log.debug("修复后: {}", fixed.substring(0, Math.min(500, fixed.length())));
        }
        
        return fixed;
    }
}

