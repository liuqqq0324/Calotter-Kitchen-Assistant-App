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
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AWS Bedrock AI 菜单生成服务（short-term Bearer Token）
 *
 * <p>说明：
 * <ul>
 *   <li>该实现不使用 IAM SigV4，而是使用 Bedrock short-term API key (Bearer token)。</li>
 *   <li>token 过期后需要手动更新（建议通过环境变量注入）。</li>
 *   <li>Prompt 复用 Groq 的 SYSTEM_PROMPT + userJson 输入格式。</li>
 * </ul>
 */
@Slf4j
public class BedrockAiMenuGenerationService implements AiMenuGenerationService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${ai.api.bedrock.api-key:}")
    private String apiKey;

    @Value("${ai.api.bedrock.region:us-east-1}")
    private String region;

    @Value("${ai.api.bedrock.model-id:meta.llama3-1-8b-instruct-v1:0}")
    private String modelId;

    @Value("${ai.api.bedrock.max-tokens:4096}")
    private int maxTokens;

    @Value("${ai.api.bedrock.temperature:0.2}")
    private double temperature;

    @Value("${ai.api.bedrock.top-p:0.9}")
    private double topP;

    // 复用 Groq 的系统提示词（保持行为一致：严格 JSON 输出 + 规则约束）
    // 注意：这里复制一份，避免跨类访问 private 常量；后续如需统一可提取到公共类。
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
            "TABOO (DIETARY STYLE) RULES - STRICT:",
            "- The input may contain dietPreferences.taboos (and some systems may also copy them into avoidIngredients).",
            "- These are HARD constraints. You MUST obey them even if it makes the menu simpler.",
            "- Interpret them as follows:",
            "  * vegetarian: NO meat/poultry/fish/seafood (no chicken, beef, pork, shrimp, fish, etc). Eggs/dairy are allowed unless vegan is also specified.",
            "  * vegan: NO animal products at all (no meat/fish/seafood, no eggs, no dairy, no honey).",
            "  * halal: NO pork/alcohol; avoid non-halal meats.",
            "  * kosher: NO pork/shellfish; do not mix meat and dairy in the same dish.",
            "  * gluten_free: NO wheat/barley/rye; avoid soy sauce unless gluten-free.",
            "  * low_sugar: avoid added sugar and sweet sauces.",
            "  * low_fat: choose lean/low-oil cooking methods; avoid deep-frying.",
            "  * low_sodium: avoid salty sauces (soy, fish sauce) unless low-sodium; minimize added salt.",
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
            "- Each 'recipes' array MUST contain EXACTLY 'generationSettings.dishCount' recipe objects.",
            "  * If dishCount=4, recipes array length must be 4.",
            "  * If dishCount=1, recipes array length must be 1.",
            "- Return ONLY valid JSON, no markdown, no code blocks, no explanatory text.",
            "- The JSON must be parseable by standard JSON parsers."
    );

    public BedrockAiMenuGenerationService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Bedrock short-term API key 未配置（ai.api.bedrock.api-key / BEDROCK_API_KEY）");
        }

        final String encodedModelId = URLEncoder.encode(modelId, StandardCharsets.UTF_8);
        final String url = "https://bedrock-runtime." + region + ".amazonaws.com/model/" + encodedModelId + "/converse";

        try {
            String userJson = objectMapper.writeValueAsString(filter);
            String userContent = "Here is the user context in JSON format:\n\n" + userJson + "\n\nNow generate the menus.";

            Map<String, Object> payload = new HashMap<>();
            payload.put("system", List.of(Map.of("text", SYSTEM_PROMPT)));
            payload.put("messages", List.of(
                    Map.of(
                            "role", "user",
                            "content", List.of(Map.of("text", userContent))
                    )
            ));
            payload.put("inferenceConfig", Map.of(
                    "maxTokens", maxTokens,
                    "temperature", temperature,
                    "topP", topP
            ));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

            log.debug("调用 Bedrock Converse: region={}, modelId={}, url={}", region, modelId, url);
            ResponseEntity<String> resp = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

            if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
                throw new RuntimeException("Bedrock 调用失败: " + resp.getStatusCode() + " " + resp.getBody());
            }

            String content = extractModelText(resp.getBody());
            if (content == null || content.isBlank()) {
                throw new RuntimeException("Bedrock 返回的 content 为空");
            }

            content = stripMarkdown(content);
            return parseMenusFromJson(content);
        } catch (HttpClientErrorException e) {
            // token 过期/无权限通常是 401/403
            if (e.getStatusCode().value() == 401 || e.getStatusCode().value() == 403) {
                throw new IllegalStateException("Bedrock token 无效或已过期（请手动更新 short-term API key）: " + e.getStatusCode());
            }
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("使用 Bedrock 生成菜单失败: " + e.getMessage(), e);
        }
    }

    private String extractModelText(String responseBody) throws Exception {
        JsonNode root = objectMapper.readTree(responseBody);
        // Converse 标准路径：output.message.content[0].text
        JsonNode textNode = root.at("/output/message/content/0/text");
        if (textNode != null && textNode.isTextual()) {
            return textNode.asText();
        }
        // 兼容：有些返回会把文本放在 content[0].text 以外
        JsonNode alt = root.at("/output/message/content/0");
        if (alt != null && alt.isTextual()) {
            return alt.asText();
        }
        // fallback: 直接取整个 output/message 作为字符串（便于排查）
        JsonNode msg = root.at("/output/message");
        if (msg != null && !msg.isMissingNode()) {
            return msg.toString();
        }
        return null;
    }

    private List<MenuDTO> parseMenusFromJson(String content) throws Exception {
        JsonNode menuRoot = objectMapper.readTree(content);
        JsonNode menusNode = menuRoot.get("menus");

        if (menusNode == null || !menusNode.isArray()) {
            // 如果根节点就是数组，直接使用
            if (menuRoot.isArray()) {
                menusNode = menuRoot;
            } else {
                throw new RuntimeException("Bedrock 返回不包含 menus 数组字段");
            }
        }

        return objectMapper.readerForListOf(MenuDTO.class).readValue(menusNode);
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


