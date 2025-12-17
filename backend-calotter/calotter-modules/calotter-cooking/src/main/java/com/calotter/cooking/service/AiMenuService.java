package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.FamilyMemberRepository;
import com.calotter.user.repository.HealthGoalRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AiMenuService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();
    private final IngredientRepository ingredientRepository;
    private final HouseholdSpiceRepository spiceRepository;
    private final HouseholdUtensilRepository utensilRepository;
    private final FamilyMemberRepository familyMemberRepository;
    private final HealthGoalRepository healthGoalRepository;

    @Value("${ai.api.key:}")
    private String apiKey;

    @Value("${ai.api.url:https://api.groq.com/openai/v1/chat/completions}")
    private String apiUrl;

    @Value("${ai.model:llama-3.3-70b-versatile}")
    private String model;

    /**
     * 调用 AI 生成 5 套菜单
     */
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter, Long householdId) {
        // 如果提供了householdId，自动填充inventory、cookers、seasonings
        if (householdId != null) {
            enrichFilterFromHousehold(filter, householdId);
        }
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("AI API key 未配置");
        }
        try {
            String userJson = objectMapper.writeValueAsString(filter);

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
            ResponseEntity<String> resp = restTemplate.exchange(apiUrl, HttpMethod.POST, entity, String.class);
            if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
                throw new RuntimeException("AI 调用失败: " + resp.getStatusCode() + " " + resp.getBody());
            }

            JsonNode root = objectMapper.readTree(resp.getBody());
            String content = root.at("/choices/0/message/content").asText();
            if (content == null || content.isBlank()) {
                throw new RuntimeException("AI 返回为空");
            }
            content = stripMarkdown(content);

            JsonNode menuRoot = objectMapper.readTree(content);
            JsonNode menusNode = menuRoot.get("menus");
            if (menusNode == null || !menusNode.isArray()) {
                throw new RuntimeException("AI 返回不包含 menus 数组");
            }
            return objectMapper.readerForListOf(MenuDTO.class).readValue(menusNode);
        } catch (Exception e) {
            throw new RuntimeException("生成菜单失败: " + e.getMessage(), e);
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
     * 获取默认 Filter（基于用户的偏好和健康目标）
     */
    public RecipeGenerationFilter getDefaultFilter(Long householdId) {
        RecipeGenerationFilter filter = new RecipeGenerationFilter();
        
        // 1. 获取家庭成员信息
        List<FamilyMember> members = familyMemberRepository.findByHouseholdId(householdId);
        
        // 2. 收集过敏信息
        List<String> allergies = new ArrayList<>();
        List<String> avoidIngredients = new ArrayList<>();
        List<String> cuisinePreferences = new ArrayList<>();
        List<String> tastePreferences = new ArrayList<>();
        
        // 3. 计算卡路里目标（从健康目标）
        Double avgCalorieTarget = null;
        int activeGoalCount = 0;
        int totalCalories = 0;
        
        for (FamilyMember member : members) {
            // 收集过敏
            if (member.getAllergies() != null) {
                member.getAllergies().forEach(a -> allergies.add(a.getName()));
            }
            
            // 收集偏好
            if (member.getPreferences() != null) {
                List<String> dislikes = member.getPreferences().getOrDefault("DISLIKE", new ArrayList<>());
                avoidIngredients.addAll(dislikes);
                
                List<String> cuisines = member.getPreferences().getOrDefault("CUISINE", new ArrayList<>());
                cuisinePreferences.addAll(cuisines);
                
                List<String> tastes = member.getPreferences().getOrDefault("TASTE", new ArrayList<>());
                tastePreferences.addAll(tastes);
            }
            
            // 计算卡路里目标
            HealthGoal goal = healthGoalRepository.findByFamilyMemberAndStatus(member, 1); // 1=Active
            if (goal != null && goal.getDailyCalories() != null) {
                totalCalories += goal.getDailyCalories();
                activeGoalCount++;
            }
        }
        
        // 计算平均卡路里目标（每人）
        if (activeGoalCount > 0) {
            avgCalorieTarget = (double) totalCalories / activeGoalCount;
        } else if (!members.isEmpty()) {
            // 如果没有健康目标，使用默认值（成年人平均）
            avgCalorieTarget = 600.0; // 默认每人600卡
        }
        
        // 4. 设置 diet_preferences
        RecipeGenerationFilter.DietPreferences dietPrefs = new RecipeGenerationFilter.DietPreferences();
        dietPrefs.setAllergies(allergies.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setAvoid_ingredients(avoidIngredients.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setCuisine_preferences(cuisinePreferences.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setTaste_preferences(tastePreferences.stream().distinct().collect(Collectors.toList()));
        filter.setDiet_preferences(dietPrefs);
        
        // 5. 设置卡路里目标
        if (avgCalorieTarget != null) {
            RecipeGenerationFilter.CalorieTarget calorieTarget = new RecipeGenerationFilter.CalorieTarget();
            calorieTarget.setMin_total_kcal(avgCalorieTarget);
            calorieTarget.setMax_total_kcal(avgCalorieTarget);
            filter.setCalorie_target(calorieTarget);
        }
        
        // 6. 设置默认值
        filter.setServings(members.isEmpty() ? 1 : members.size());
        filter.setGeneration_settings(new RecipeGenerationFilter.GenerationSettings());
        filter.getGeneration_settings().setDish_count(1);
        
        // 7. 自动填充库存、厨具、调料
        enrichFilterFromHousehold(filter, householdId);
        
        return filter;
    }

    /**
     * 从household自动填充filter的inventory、cookers、seasonings
     */
    private void enrichFilterFromHousehold(RecipeGenerationFilter filter, Long householdId) {
        // 填充inventory（如果为空）
        if (filter.getInventory() == null || filter.getInventory().isEmpty()) {
            List<Ingredient> ingredients = ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
            List<RecipeGenerationFilter.InventoryItem> inventoryItems = ingredients.stream()
                    .map(ing -> {
                        RecipeGenerationFilter.InventoryItem item = new RecipeGenerationFilter.InventoryItem();
                        item.setName(ing.getMetadata().getName());
                        item.setAmount_value(ing.getQuantity());
                        item.setAmount_unit(ing.getUnit());
                        if (ing.getExpirationDate() != null) {
                            item.setExpires_at(ing.getExpirationDate().format(DateTimeFormatter.ISO_LOCAL_DATE));
                        }
                        return item;
                    })
                    .collect(Collectors.toList());
            filter.setInventory(inventoryItems);
            log.info("自动填充inventory: {} 项", inventoryItems.size());
        }

        // 填充cookers（如果为空）
        if (filter.getCookers() == null || filter.getCookers().isEmpty()) {
            List<HouseholdUtensil> utensils = utensilRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
            List<String> cookerNames = utensils.stream()
                    .map(u -> u.getMetadata().getName())
                    .collect(Collectors.toList());
            filter.setCookers(cookerNames);
            log.info("自动填充cookers: {} 项", cookerNames.size());
        }

        // 填充seasonings（如果为空）
        if (filter.getSeasonings() == null || filter.getSeasonings().isEmpty()) {
            List<HouseholdSpice> spices = spiceRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
            List<String> spiceNames = spices.stream()
                    .map(s -> s.getMetadata().getName())
                    .collect(Collectors.toList());
            filter.setSeasonings(spiceNames);
            log.info("自动填充seasonings: {} 项", spiceNames.size());
        }
    }

    // 来自需求的 Prompt 配置（简化保存在常量）
    private static final String SYSTEM_PROMPT = String.join("\n",
            "You are a diet-focused cooking assistant.",
            "INPUT SUMMARY: You receive fridge inventory, calorie targets (per person), servings, and preferences.",
            "YOUR TASK: Generate EXACTLY 5 menu options based on the input.",
            "",
            "=== 1. CRITICAL DATA REQUIREMENTS (BACKEND RULES) ===",
            "1. NUTRITION ESTIMATE: Instead of just calories, you MUST estimate the full macro-nutrient breakdown for the WHOLE recipe (all servings combined).",
            "   - Provide: 'calories', 'protein_g', 'fat_g', 'carbs_g'.",
            "   - Base these estimates on the total ingredients used.",
            "2. INVENTORY SOURCE MATCHING:",
            "   - For every ingredient in the output list, check the input 'inventory'.",
            "   - If the name loosely matches an item in the fridge, set 'source_type' to 'INVENTORY'.",
            "   - If it is a new item (or a seasoning not in the list), set 'source_type' to 'MANUAL_ADD'.",
            "   - Prefer using ingredients from the inventory to reduce waste.",
            "",
            "=== 2. COOKING LOGIC & CONSTRAINTS (USER RULES) ===",
            "COOKWARE RULES:",
            "- If 'cookers' list is provided, ONLY use cooking methods compatible with them.",
            "- Example: If 'oven' is not listed, DO NOT generate recipes requiring baking.",
            "- If 'cookers' is empty, assume basic stove + pot/pan only.",
            "",
            "CALORIE LOGIC:",
            "- The input 'calorie_target' is PER PERSON.",
            "- However, the output 'nutrition_estimate' must be for the WHOLE RECIPE.",
            "- Logic: Target Recipe Calories ≈ (Per-Person Target * Servings).",
            "- Keep recipes realistic. Do not force exact math if it ruins the food, but stay within range.",
            "",
            "DIFFICULTY DEFINITIONS:",
            "- Easy: Common ingredients, <= 30 mins, basic steps, simple equipment.",
            "- Medium: 30-60 mins, marinating/sauces, moderate attention needed.",
            "- Hard: > 60 mins, complex techniques (deep fry, dough), multiple stages.",
            "- Respect the 'difficulty_target' if provided.",
            "",
            "SEASONINGS & PREFERENCES:",
            "- Use the provided 'seasonings' list if possible. Assume basic (salt/oil/soy) if empty.",
            "- STRICTLY RESPECT 'allergies'. Never use allergic ingredients.",
            "- Avoid 'avoid_ingredients'.",
            "",
            "=== 3. OUTPUT FORMAT ===",
            "- Return ONLY valid JSON matching the output_schema.",
            "- No markdown, no conversational text."
    );
}
