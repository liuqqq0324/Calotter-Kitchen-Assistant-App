package com.calotter.health.service.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

/**
 * Gemini-based estimator.
 * 基于 Gemini API 的营养估算器
 *
 * @author Auto Generated
 */
// @Component 注释掉，改为通过配置类管理
// @Component
public class GeminiManualNutritionEstimator implements ManualNutritionEstimator {

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final String model;
    private final String apiKey;

    public GeminiManualNutritionEstimator(
            ObjectMapper objectMapper,
            @Value("${ai.nutrition.gemini.base-url:https://generativelanguage.googleapis.com}") String baseUrl,
            @Value("${ai.nutrition.gemini.api-key:}") String apiKey,
            @Value("${ai.nutrition.gemini.model:gemini-2.5-pro}") String model
    ) {
        this.objectMapper = objectMapper;
        this.model = model;
        this.apiKey = apiKey;
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
    }

    @Override
    public NutritionEstimate estimate(String foodName, String portionDescription) {
        String prompt = buildPrompt(foodName, portionDescription);
        
        // Gemini API 请求格式
        Map<String, Object> body = Map.of(
                "contents", new Object[]{
                        Map.of("parts", new Object[]{
                                Map.of("text", prompt)
                        })
                },
                "generationConfig", Map.of(
                        "temperature", 0,
                        "responseMimeType", "application/json"
                )
        );

        // Gemini API 使用查询参数传递 API Key
        String uri = String.format("/v1beta/models/%s:generateContent?key=%s", model, apiKey);

        String raw = restClient.post()
                .uri(uri)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .body(String.class);

        return parseResponse(raw);
    }

    private String buildPrompt(String foodName, String portionDescription) {
        String portion = portionDescription == null ? "" : portionDescription.trim();
        String prompt = "You are a nutrition calculation assistant. " +
                "Estimate the nutrition values for the following food item and portion. " +
                "Return ONLY valid JSON with keys: energy_kcal, protein_g, fat_g, carbohydrates_g. " +
                "Numbers must be non-negative and represent the specified portion.\n\n";
        
        if (portion.isEmpty()) {
            prompt += "Food: " + foodName;
        } else {
            prompt += "Food: " + foodName + "\nPortion: " + portion;
        }
        
        return prompt;
    }

    private NutritionEstimate parseResponse(String rawJson) {
        try {
            JsonNode root = objectMapper.readTree(rawJson);
            
            // Gemini API 响应格式：candidates[0].content.parts[0].text
            JsonNode textNode = root.path("candidates").path(0).path("content").path("parts").path(0).path("text");
            String content = textNode.isTextual() ? textNode.asText() : "";
            
            // 如果 content 为空，尝试从其他路径获取
            if (content.isEmpty()) {
                JsonNode candidates = root.path("candidates");
                if (candidates.isArray() && candidates.size() > 0) {
                    JsonNode firstCandidate = candidates.get(0);
                    JsonNode contentNode = firstCandidate.path("content");
                    JsonNode partsNode = contentNode.path("parts");
                    if (partsNode.isArray() && partsNode.size() > 0) {
                        JsonNode firstPart = partsNode.get(0);
                        content = firstPart.path("text").asText("");
                    }
                }
            }
            
            String json = extractJsonObject(content);
            JsonNode nutrition = objectMapper.readTree(json);

            BigDecimal energy = decimal(nutrition.path("energy_kcal"));
            BigDecimal protein = decimal(nutrition.path("protein_g"));
            BigDecimal fat = decimal(nutrition.path("fat_g"));
            BigDecimal carbs = decimal(nutrition.path("carbohydrates_g"));

            return new NutritionEstimate(
                    energy.setScale(2, RoundingMode.HALF_UP),
                    fat.setScale(2, RoundingMode.HALF_UP),
                    carbs.setScale(2, RoundingMode.HALF_UP),
                    protein.setScale(2, RoundingMode.HALF_UP),
                    "gemini"
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse Gemini nutrition response: " + e.getMessage(), e);
        }
    }

    private BigDecimal decimal(JsonNode node) {
        if (node == null || node.isMissingNode() || node.isNull()) return BigDecimal.ZERO;
        if (node.isNumber()) return node.decimalValue().max(BigDecimal.ZERO);
        if (node.isTextual()) {
            try {
                return new BigDecimal(node.asText().trim()).max(BigDecimal.ZERO);
            } catch (Exception ignored) {
                return BigDecimal.ZERO;
            }
        }
        return BigDecimal.ZERO;
    }

    private String extractJsonObject(String text) {
        if (text == null) return "{}";
        String t = text.trim();
        if (t.startsWith("```")) {
            int firstNewline = t.indexOf('\n');
            if (firstNewline > 0) {
                t = t.substring(firstNewline + 1).trim();
            }
            int lastFence = t.lastIndexOf("```");
            if (lastFence >= 0) {
                t = t.substring(0, lastFence).trim();
            }
        }
        int start = t.indexOf('{');
        int end = t.lastIndexOf('}');
        if (start >= 0 && end >= 0 && end > start) {
            return t.substring(start, end + 1);
        }
        return "{}";
    }
}

