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
import java.util.stream.Collectors;

/**
 * Gemini AI 菜单生成服务（优化版 - 简化 Prompt 减少 Token）
 */
@Slf4j
public class GeminiAiMenuGenerationService implements AiMenuGenerationService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${ai.api.gemini.api-key:}")
    private String apiKey;

    @Value("${ai.api.gemini.base-url:https://generativelanguage.googleapis.com}")
    private String baseUrl;

    @Value("${ai.api.gemini.model:gemini-2.5-pro}")
    private String model;

    public GeminiAiMenuGenerationService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Gemini API key 未配置");
        }

        try {
            // 优化：将复杂 JSON 转换为简洁的文本格式，大幅减少 Token
            String simplifiedPrompt = buildSimplifiedPrompt(filter);

            Map<String, Object> body = new HashMap<>();
            body.put("contents", List.of(
                    Map.of("parts", List.of(
                            Map.of("text", simplifiedPrompt)
                    ))
            ));
            body.put("generationConfig", Map.of(
                    "temperature", 0.7,
                    "responseMimeType", "application/json"
            ));

            String url = baseUrl + "/v1beta/models/" + model + ":generateContent?key=" + apiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<String> resp = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

            // 检查 429 错误
            if (resp.getStatusCode().value() == 429) {
                throw new IllegalStateException("Gemini API 配额已用完。请稍后再试，或检查您的 API 配额限制。");
            }

            if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
                throw new RuntimeException("Gemini API 调用失败: " + resp.getStatusCode() + " " + resp.getBody());
            }

            JsonNode root = objectMapper.readTree(resp.getBody());
            String content = root.at("/candidates/0/content/parts/0/text").asText();
            if (content == null || content.isBlank()) {
                throw new RuntimeException("Gemini API 返回为空");
            }
            content = stripMarkdown(content);

            JsonNode menuRoot = objectMapper.readTree(content);
            JsonNode menusNode = menuRoot.get("menus");
            if (menusNode == null || !menusNode.isArray()) {
                throw new RuntimeException("Gemini API 返回不包含 menus 数组");
            }
            return objectMapper.readerForListOf(MenuDTO.class).readValue(menusNode);
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("429")) {
                throw new IllegalStateException("Gemini API 配额已用完。请稍后再试，或检查您的 API 配额限制。");
            }
            throw new RuntimeException("使用 Gemini 生成菜单失败: " + e.getMessage(), e);
        }
    }

    /**
     * 构建简化的 Prompt（大幅减少 Token）
     * 将 JSON 格式转换为简洁的文本格式
     */
    private String buildSimplifiedPrompt(RecipeGenerationFilter filter) {
        StringBuilder prompt = new StringBuilder();
        
        // 获取 dishCount
        int dishCount = 1; // 默认值
        if (filter.getGenerationSettings() != null && 
            filter.getGenerationSettings().getDishCount() != null) {
            dishCount = filter.getGenerationSettings().getDishCount();
        }
        
        prompt.append("Generate 5 menu options. Each menu must contain EXACTLY ")
              .append(dishCount)
              .append(" recipe(s). Return JSON: {\"menus\":[...]}.\n\n");
        
        // 1. 食材（简化格式：只保留名称和数量）
        if (filter.getInventory() != null && !filter.getInventory().isEmpty()) {
            prompt.append("Ingredients: ");
            String ingredients = filter.getInventory().stream()
                    .filter(item -> !isBasicSeasoning(item.getName())) // 过滤基础调料
                    .map(item -> {
                        String name = item.getName();
                        String amount = formatAmount(item.getAmountValue(), item.getAmountUnit());
                        return name + " (" + amount + ")";
                    })
                    .collect(Collectors.joining(", "));
            prompt.append(ingredients).append("\n");
        }
        
        // 2. 卡路里目标
        if (filter.getCalorieTarget() != null) {
            Double target = filter.getCalorieTarget().getMaxTotalKcal();
            Integer servings = filter.getServings() != null ? filter.getServings() : 2;
            prompt.append("Calorie target: ").append(target).append(" kcal/person, ")
                  .append(servings).append(" servings\n");
        }
        
        // 3. 过敏和避免的食材（简化）
        if (filter.getDietPreferences() != null) {
            if (filter.getDietPreferences().getAllergies() != null && 
                !filter.getDietPreferences().getAllergies().isEmpty()) {
                prompt.append("Allergies: ")
                      .append(String.join(", ", filter.getDietPreferences().getAllergies()))
                      .append("\n");
            }
            if (filter.getDietPreferences().getAvoidIngredients() != null && 
                !filter.getDietPreferences().getAvoidIngredients().isEmpty()) {
                prompt.append("Avoid: ")
                      .append(String.join(", ", filter.getDietPreferences().getAvoidIngredients()))
                      .append("\n");
            }
        }
        
        // 4. 厨具（简化）
        if (filter.getCookers() != null && !filter.getCookers().isEmpty()) {
            prompt.append("Available cookers: ")
                  .append(String.join(", ", filter.getCookers()))
                  .append("\n");
        }
        
        // 5. 输出格式要求（简化）
        prompt.append("\nOutput format: Each menu has recipes with: title, shortDescription, ");
        prompt.append("servings, cookingTimeMin, difficulty, nutritionEstimate (calories, proteinG, fatG, carbsG), ");
        prompt.append("ingredients (name, amountValue, amountUnit, isOptional, sourceType: INVENTORY/MANUAL_ADD), ");
        prompt.append("steps (stepNumber, instruction, stepTimeMin).");
        
        return prompt.toString();
    }

    /**
     * 判断是否是基础调料（不需要发送给 AI）
     */
    private boolean isBasicSeasoning(String name) {
        if (name == null) return false;
        String lower = name.toLowerCase();
        return lower.contains("salt") || 
               lower.contains("sugar") || 
               lower.contains("oil") || 
               lower.contains("water") ||
               lower.contains("pepper") ||
               lower.contains("soy");
    }

    /**
     * 格式化数量显示
     */
    private String formatAmount(Double value, String unit) {
        if (value == null) return "";
        if (unit == null) unit = "";
        if (value.intValue() == value.doubleValue()) {
            return value.intValue() + unit;
        }
        return String.format("%.1f%s", value, unit);
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

