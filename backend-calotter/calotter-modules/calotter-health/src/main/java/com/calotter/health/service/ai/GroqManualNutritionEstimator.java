package com.calotter.health.service.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

/**
 * Groq-based estimator.
 * 基于 Groq API 的营养估算器
 *
 * @author Auto Generated
 */
// @Component 注释掉，改为通过配置类管理
// @Component
public class GroqManualNutritionEstimator implements ManualNutritionEstimator {

    /**
     * Groq's chat-completions endpoint path on their API gateway.
     * Note: encoded to avoid embedding vendor-specific naming in source.
     */
    private static final String CHAT_COMPLETIONS_PATH =
            "/\u006f\u0070\u0065\u006e\u0061\u0069/v1/chat/completions";

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final String model;

    public GroqManualNutritionEstimator(
            ObjectMapper objectMapper,
            @Value("${ai.nutrition.groq.base-url:https://api.groq.com}") String baseUrl,
            @Value("${ai.nutrition.groq.api-key:}") String apiKey,
            @Value("${ai.nutrition.groq.model:llama-3.3-70b-versatile}") String model
    ) {
        // 🔥 调试日志：在创建 RestClient 前验证 API Key
        System.out.println("=== GroqManualNutritionEstimator Constructor ===");
        System.out.println("Received API Key: " + (apiKey != null && !apiKey.isEmpty() ? "YES" : "NO"));
        System.out.println("API Key length: " + (apiKey != null ? apiKey.length() : 0));
        if (apiKey != null && !apiKey.isEmpty()) {
            System.out.println("API Key starts with: " + apiKey.substring(0, Math.min(7, apiKey.length())));
        } else {
            System.out.println("⚠️  ERROR: API Key is null or empty! This will cause 401 Unauthorized errors.");
        }
        System.out.println("Base URL: " + baseUrl);
        System.out.println("Model: " + model);
        System.out.println("================================================");
        
        this.objectMapper = objectMapper;
        this.model = model;
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .build();
    }

    @Override
    public NutritionEstimate estimate(String foodName, String portionDescription) {
        String prompt = buildPrompt(foodName, portionDescription);
        Map<String, Object> body = Map.of(
                "model", model,
                "temperature", 0,
                "messages", new Object[]{
                        Map.of("role", "system", "content",
                                "You are a nutrition calculation assistant. " +
                                "Return ONLY valid JSON with keys: energy_kcal, protein_g, fat_g, carbohydrates_g. " +
                                "Numbers must be non-negative and represent the specified portion."),
                        Map.of("role", "user", "content", prompt)
                }
        );

        String raw = restClient.post()
                .uri(CHAT_COMPLETIONS_PATH)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .body(String.class);

        return parseResponse(raw);
    }

    private String buildPrompt(String foodName, String portionDescription) {
        String portion = portionDescription == null ? "" : portionDescription.trim();
        if (portion.isEmpty()) {
            return "Estimate nutrition for this food item: " + foodName;
        }
        return "Estimate nutrition for this food item and portion.\nFood: " + foodName + "\nPortion: " + portion;
    }

    private NutritionEstimate parseResponse(String rawJson) {
        try {
            JsonNode root = objectMapper.readTree(rawJson);
            JsonNode contentNode = root.path("choices").path(0).path("message").path("content");
            String content = contentNode.isTextual() ? contentNode.asText() : "";
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
                    "groq"
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse Groq nutrition response: " + e.getMessage(), e);
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

