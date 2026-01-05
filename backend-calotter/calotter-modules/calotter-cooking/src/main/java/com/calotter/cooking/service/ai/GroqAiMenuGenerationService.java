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
            "CRITICAL RULES:",
            "- The root object MUST have a 'menus' field containing an array of exactly 5 menu objects.",
            "- Each menu object MUST have 'menuId' (1-5) and 'recipes' array.",
            "- Return ONLY valid JSON, no markdown, no code blocks, no explanatory text.",
            "- The JSON must be parseable by standard JSON parsers."
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
        
        try {
            String userJson = objectMapper.writeValueAsString(filter);
            log.debug("发送给 Groq 的请求数据: {}", userJson);

            Map<String, Object> payload = new HashMap<>();
            payload.put("model", model);
            payload.put("messages", List.of(
                    Map.of("role", "system", "content", SYSTEM_PROMPT),
                    Map.of("role", "user", "content", "Here is the user context in JSON format:\n\n" + userJson + "\n\nNow generate the menus.")
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
}

