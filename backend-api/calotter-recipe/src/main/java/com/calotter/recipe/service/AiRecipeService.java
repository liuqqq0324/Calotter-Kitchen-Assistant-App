package com.calotter.recipe.service;

import com.calotter.recipe.api.RecipeApiController;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.DefaultUriBuilderFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Call OpenAI-compatible chat completions to generate recipe menus.
 * Keeps the request/response shape identical to the existing API DTOs
 * so the controller can simply delegate here.
 */
@Service
public class AiRecipeService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${openai.api.key:}")
    private String apiKey;

    @Value("${openai.api.url:https://api.openai.com/v1/chat/completions}")
    private String apiUrl;

    @Value("${openai.model:gpt-4o-mini}")
    private String model;

    public AiRecipeService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.restTemplate = new RestTemplate();
        // Some OpenAI-compatible gateways are picky about trailing slashes; use UriBuilderFactory.
        this.restTemplate.setUriTemplateHandler(new DefaultUriBuilderFactory());
    }

    public RecipeApiController.GeneratedMenusResponse generateMenus(RecipeApiController.GenerateMenusRequest req) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("OPENAI_API_KEY is missing; set it before calling AI.");
        }

        try {
            String userJson = objectMapper.writeValueAsString(req);

            // Build OpenAI chat request payload
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", model);
            Map<String, Object> systemMsg = new HashMap<>();
            systemMsg.put("role", "system");
            systemMsg.put("content", SYSTEM_PROMPT);

            Map<String, Object> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", "Here is the user context in JSON format:\n\n" + userJson + "\n\nNow generate the menus according to the instructions in the system prompt.");

            payload.put("messages", List.of(systemMsg, userMsg));
            // Ask the model to return strict JSON only
            Map<String, Object> responseFormat = new HashMap<>();
            responseFormat.put("type", "json_object");
            payload.put("response_format", responseFormat);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            ResponseEntity<String> response = restTemplate.exchange(apiUrl, HttpMethod.POST, entity, String.class);

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new RuntimeException("AI call failed: " + response.getStatusCode() + " " + response.getBody());
            }

            // Extract the model content string
            JsonNode root = objectMapper.readTree(response.getBody());
            String content = root.at("/choices/0/message/content").asText();
            if (content == null || content.isBlank()) {
                throw new RuntimeException("AI response content is empty.");
            }

            // Some providers may wrap JSON in markdown fences; strip them defensively
            if (content.startsWith("```json")) {
                content = content.replaceFirst("```json", "");
            }
            if (content.startsWith("```")) {
                content = content.replaceFirst("```", "");
            }
            if (content.endsWith("```")) {
                content = content.substring(0, content.length() - 3);
            }
            content = content.trim();

            // Parse content JSON into our DTO
            return objectMapper.readValue(content, RecipeApiController.GeneratedMenusResponse.class);

        } catch (Exception e) {
            throw new RuntimeException("Failed to generate menus via AI: " + e.getMessage(), e);
        }
    }

    // private static final String SYSTEM_PROMPT = String.join("\n",
    //         "You are a diet-focused cooking assistant.",
    //         "",
    //         "You receive a single JSON object describing the user's fridge inventory, optional calorie target, servings, diet preferences, cookers, seasonings, and generation settings.",
    //         "",
    //         "INPUT SUMMARY:",
    //         "- inventory: current ingredients in the fridge, with amount and unit.",
    //         "- calorie_target (optional): per-person total calorie target range (min_total_kcal, max_total_kcal) that today's menu should roughly aim for.",
    //         "- servings: how many servings each recipe should make (usually equals the number of people).",
    //         "- diet_preferences: optional cuisine/taste preferences, optional avoid_ingredients, and allergies (may be empty if none).",
    //         "- generation_settings: dish_count (how many dishes the user wants to cook today), and optionally max_cooking_time_min and difficulty_target.",
    //         "- cookers (optional): list of cooking equipment and appliances the user currently has.",
    //         "- seasonings (optional): which seasonings the user currently has available in the kitchen.",
    //         "",
    //         "YOUR TASK:",
    //         "1. Always generate EXACTLY 5 menu options.",
    //         "2. Each menu must contain exactly generation_settings.dish_count recipes.",
    //         "3. For each recipe:",
    //         "   - Set servings equal to the input 'servings' value unless there is a strong reason not to.",
    //         "   - Provide total_calories_estimate (for the whole recipe, all servings combined).",
    //         "   - This is a rough estimate only; the backend will perform any further calculations, including menu-level totals and per-person totals.",
    //         "4. If calorie_target is provided:",
    //         "   - Treat calorie_target as a per-person total calorie range for the whole day (or for today's overall menu).",
    //         "   - When designing menus, consider the number of servings:",
    //         "     * If servings = 1: the menu should be reasonable for one person whose total daily calories fall within [min_total_kcal, max_total_kcal].",
    //         "     * If servings > 1: conceptually, the total calorie range for the whole menu (all people combined) becomes roughly [min_total_kcal * servings, max_total_kcal * servings].",
    //         "   - Use this as a guideline when choosing and combining recipes:",
    //         "     * Each recipe's total_calories_estimate should be realistic.",
    //         "     * The combined calories of all recipes in a menu should be reasonable relative to the implied total range above,",
    //         "       but you do NOT need to compute or output any explicit menu-level total calories.",
    //         "   - Only per-recipe total_calories_estimate is required; the backend will calculate menu-level and per-person totals more precisely.",
    //         "5. If calorie_target is missing:",
    //         "   - Do not match any specific calorie range.",
    //         "   - Still keep the menus reasonable for a normal adult (avoid clearly excessive or unrealistically low calorie designs).",
    //         "",
    //         "INGREDIENT & INVENTORY RULES:",
    //         "- Prefer using ingredients that already exist in the inventory (by name).",
    //         "- Minimise the number and amount of ingredients that are NOT in the inventory.",
    //         "- Any additional ingredients should be common and easy to find (e.g. noodles, rice, basic sauces),",
    //         "  and you should avoid rare, luxury or hard-to-find ingredients (e.g. sea cucumber, truffle, caviar).",
    //         "- The amount_unit for all ingredients MUST be one of: 'g', 'ml', 'piece'.",
    //         "- Use realistic amounts for home cooking.",
    //         "",
    //         "SEASONINGS RULES:",
    //         "- If the 'seasonings' array is present and non-empty:",
    //         "  * Treat it as the list of seasonings the user currently has available in the kitchen.",
    //         "  * Prefer to use only seasonings from this list.",
    //         "  * Avoid using seasonings that are not in this list, unless the list is empty.",
    //         "- If 'seasonings' is missing or empty, you may assume basic seasonings like salt, sugar, soy sauce, and oil are available.",
    //         "- Always list seasonings as separate ingredients in the 'ingredients' array with realistic small amount_value and correct amount_unit (usually 'g' or 'ml').",
    //         "",
    //         "COOKWARE & EQUIPMENT RULES:",
    //         "- If the 'cookers' field is present and non-empty:",
    //         "  * Only use cooking methods that are compatible with the given equipment.",
    //         "  * Avoid requiring equipment that is NOT listed in cookers (for example, if 'oven' is not in cookers, do NOT design recipes that require baking in an oven).",
    //         "  * If a typical recipe would normally use an unavailable cooker, adapt it to a method that uses the available equipment instead (e.g. pan-fry on a stove instead of baking in an oven when possible).",
    //         "- If 'cookers' is missing or empty:",
    //         "  * Assume the user has at least a basic stove with a pan and a pot.",
    //         "  * Prefer simple methods that rely on this basic setup, and avoid recipes that absolutely require special equipment like an oven, air_fryer, or pressure_cooker.",
    //         "",
    //         "PREFERENCES & RESTRICTIONS:",
    //         "- Never use any ingredient listed in diet_preferences.allergies (even if the array is empty, you must still respect it).",
    //         "- Strongly avoid ingredients listed in diet_preferences.avoid_ingredients.",
    //         "- If cuisine_preferences is present and non-empty, prefer those cuisines when designing the recipes.",
    //         "- If cuisine_preferences is empty or missing, do not treat cuisine as a hard constraint.",
    //         "- If taste_preferences is present and non-empty, reflect these tastes in the seasoning and style (e.g. 'spicy', 'light').",
    //         "- If taste_preferences is empty or missing, use a balanced, everyday home-cooking taste.",
    //         "",
    //         "COOKING TIME & DIFFICULTY:",
    //         "- If generation_settings.max_cooking_time_min is provided, try to keep each recipe's cooking_time_min at or below this value.",
    //         "- Otherwise choose a reasonable cooking_time_min based on the recipe.",
    //         "",
    //         "Define difficulty levels as follows:",
    //         "- easy:",
    //         "  * Uses very common ingredients that most households have.",
    //         "  * Usually no more than about 6–7 ingredients (excluding water, salt, oil).",
    //         "  * Total cooking_time_min typically ≤ 30 minutes.",
    //         "  * Steps are short and straightforward, using basic techniques only (boil, stir-fry, bake, mix).",
    //         "  * Requires only simple equipment (stove, pan/pot).",
    //         "- medium:",
    //         "  * Uses a moderate number of ingredients (around 7–12).",
    //         "  * Total cooking_time_min roughly between 30 and 60 minutes.",
    //         "  * May include extra steps such as marinating, preparing a separate sauce, or combining oven and stove.",
    //         "  * Techniques require some attention and timing but are still approachable for home cooks.",
    //         "- hard:",
    //         "  * Uses many ingredients and/or some special or less common ingredients.",
    //         "  * Total cooking_time_min often > 60 minutes or involves multiple stages (e.g. dough proofing, long simmering).",
    //         "  * Steps are more complex, possibly including advanced techniques (deep-frying, dough handling, precise temperature control).",
    //         "  * May require special equipment (e.g. steamer plus oven, pressure cooker, blender).",
    //         "",
    //         "- All difficulty levels must still respect the 'cookers' field: do not require equipment that the user does not have.",
    //         "- If generation_settings.difficulty_target is provided, choose recipes whose difficulty matches that target as closely as possible.",
    //         "- If difficulty_target is missing, choose the easy or medium level that best fits each recipe according to the above definitions.",
    //         "",
    //         "OUTPUT FORMAT:",
    //         "- You MUST return ONLY a single JSON object that matches the output_schema.",
    //         "- The top-level object must have a 'menus' array with exactly 5 menu objects.",
    //         "- Each menu must contain:",
    //         "  * menu_id (1–5),",
    //         "  * recipes: an array of recipes, length equal to generation_settings.dish_count.",
    //         "- Each recipe must contain:",
    //         "  * title, short_description, servings, cooking_time_min, difficulty, total_calories_estimate, ingredients, steps.",
    //         "- The 'ingredients' array must include both main ingredients and all seasonings used in the recipe.",
    //         "- Do NOT add any extra top-level fields or keys not defined in the output_schema.",
    //         "",
    //         "IMPORTANT:",
    //         "- The response must be valid JSON.",
    //         "- Do NOT include explanations, comments, markdown, or any text outside the JSON."
    // );
    private static final String SYSTEM_PROMPT = String.join("\n",
            "You are a professional diet-focused cooking assistant API.",
            "",
            "INPUT SUMMARY:",
            "- You will receive user's fridge inventory, preferences, and constraints in JSON.",
            "- inventory: available ingredients.",
            "- generation_settings: dish_count, max_cooking_time_min, difficulty_target.",
            "",
            "YOUR GOAL:",
            "Generate a structured recipe menu strictly adhering to the JSON schema.",
            "",
            "CRITICAL RULES FOR 'STEPS':",
            "1. 'steps' MUST be an ARRAY of objects, NOT a list of strings.",
            "2. Each step object MUST contain:",
            "   - 'step_number': integer (1, 2, 3...)",
            "   - 'instruction': string (the action to take)",
            "   - 'step_time_min': integer (estimated minutes for this specific step)",
            "3. Do NOT merge steps into one big paragraph. Split them logically.",
            "4. Estimate 'step_time_min' realistically (e.g., boiling water = 5, chopping = 3, simmering = 20).",
            "",
            "STRICT OUTPUT SCHEMA (JSON ONLY):",
            "You must return a single JSON object with this exact structure:",
            "{",
            "  \"menus\": [",
            "    {",
            "      \"menu_id\": 1,",
            "      \"recipes\": [",
            "        {",
            "          \"title\": \"Recipe Name\",",
            "          \"short_description\": \"Brief summary.\",",
            "          \"servings\": 2,",
            "          \"cooking_time_min\": 30,",
            "          \"difficulty\": \"easy\",",
            "          \"total_calories_estimate\": 500,",
            "          \"ingredients\": [",
            "             {\"name\": \"Chicken\", \"amount_value\": 200, \"amount_unit\": \"g\", \"is_optional\": false, \"category\": \"main\"}",
            "          ],",
            "          \"steps\": [",
            "            { \"step_number\": 1, \"instruction\": \"Heat the pan.\", \"step_time_min\": 2 },",
            "            { \"step_number\": 2, \"instruction\": \"Fry chicken until golden.\", \"step_time_min\": 8 }",
            "          ]",
            "        }",
            "      ]",
            "    }",
            "  ]",
            "}",
            "",
            "IMPORTANT:",
            "- Output JSON ONLY.",
            "- No markdown formatting (no ```json code blocks).",
            "- Ensure strictly valid JSON syntax."
    );
}
