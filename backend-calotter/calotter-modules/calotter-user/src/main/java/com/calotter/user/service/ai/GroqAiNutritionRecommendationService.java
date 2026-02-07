package com.calotter.user.service.ai;

import com.calotter.user.domain.entity.HealthGoal;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Groq AI 营养建议服务实现
 * API Key：优先读配置（含 application.yml 中的 ${GROQ_API_KEY}），为空时从环境变量 GROQ_API_KEY 兜底。
 */
@Slf4j
@Service
public class GroqAiNutritionRecommendationService implements AiNutritionRecommendationService, InitializingBean {
    
    @Value("${ai.api.groq.api-key:}")
    private String apiKey;
    
    @Value("${ai.api.groq.url:https://api.groq.com/openai/v1/chat/completions}")
    private String apiUrl;
    
    @Value("${ai.api.groq.model:llama-3.3-70b-versatile}")
    private String model;
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final RestTemplate restTemplate = new RestTemplate();

    /** 优先用配置/yml，为空时从环境变量 GROQ_API_KEY 兜底，兼容部署时 export 注入 */
    @Override
    public void afterPropertiesSet() {
        if (apiKey == null || apiKey.isBlank()) {
            String fromEnv = System.getenv("GROQ_API_KEY");
            if (fromEnv != null && !fromEnv.isBlank()) {
                apiKey = fromEnv;
                log.info("Groq API key loaded from environment GROQ_API_KEY");
            }
        }
    }
    
    private static final String SYSTEM_PROMPT = String.join("\n",
            "You are a professional nutritionist AI assistant.",
            "Your task is to provide personalized daily nutrition recommendations based on user's body information and health goals.",
            "",
            "**IMPORTANT**: You must return a JSON object with the following structure:",
            "{",
            "  \"dailyCalories\": <integer>,  // Daily calorie target",
            "  \"protein\": <integer>,        // Daily protein target in grams",
            "  \"fat\": <integer>,            // Daily fat target in grams",
            "  \"carb\": <integer>,          // Daily carbohydrate target in grams",
            "  \"fiber\": <integer>          // Daily fiber target in grams",
            "}",
            "",
            "Guidelines:",
            "- For weight loss (LOSE_FAT): Create a moderate calorie deficit (typically 300-500 kcal below maintenance)",
            "- For muscle gain (MUSCLE_GAIN): Provide sufficient calories and high protein (1.6-2.2g per kg body weight)",
            "- For maintenance (MAINTENANCE): Calculate maintenance calories based on BMR and activity level",
            "- Protein: 0.8-2.2g per kg body weight depending on goal",
            "- Fat: 20-35% of total calories",
            "- Carbohydrates: Remaining calories after protein and fat",
            "- Fiber: 25-35g per day"
    );
    
    @Override
    public NutritionRecommendation getNutritionRecommendation(
            Integer height,
            BigDecimal weight,
            Integer age,
            Integer gender,
            BigDecimal bmi,
            HealthGoal.GoalType goalType,
            Double activityLevel) {
        
        log.info("开始使用 Groq API 获取营养建议，模型: {}", model);
        
        if (apiKey == null || apiKey.isBlank()) {
            log.error("Groq API key 未配置");
            throw new IllegalStateException("Groq API key 未配置");
        }
        
        try {
            // 构建用户信息字符串
            String genderStr = (gender != null && gender == 1) ? "Male" : "Female";
            String goalTypeStr = goalType != null ? goalType.name() : "MAINTENANCE";
            String activityLevelStr = activityLevel != null ? String.format("%.2f", activityLevel) : "1.55";
            
            String userInfo = String.format(
                    "Height: %d cm\n" +
                    "Weight: %.1f kg\n" +
                    "Age: %d years\n" +
                    "Gender: %s\n" +
                    "BMI: %.1f\n" +
                    "Health Goal: %s\n" +
                    "Activity Level: %s",
                    height != null ? height : 0,
                    weight != null ? weight.doubleValue() : 0.0,
                    age != null ? age : 0,
                    genderStr,
                    bmi != null ? bmi.doubleValue() : 0.0,
                    goalTypeStr,
                    activityLevelStr
            );
            
            log.debug("用户信息: {}", userInfo);
            
            // 构建请求 payload
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", model);
            payload.put("messages", java.util.List.of(
                    Map.of("role", "system", "content", SYSTEM_PROMPT),
                    Map.of("role", "user", "content", "Please provide personalized daily nutrition recommendations for this user:\n\n" + userInfo)
            ));
            payload.put("response_format", Map.of("type", "json_object"));
            payload.put("temperature", 0.7);
            
            // 设置请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);
            
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            log.debug("调用 Groq API: {}", apiUrl);
            
            // 调用 API
            ResponseEntity<String> resp = restTemplate.exchange(apiUrl, HttpMethod.POST, entity, String.class);
            
            log.debug("Groq API 响应状态: {}", resp.getStatusCode());
            log.debug("Groq API 响应内容: {}", resp.getBody());
            
            if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
                log.error("Groq API 调用失败: status={}, body={}", resp.getStatusCode(), resp.getBody());
                throw new RuntimeException("Groq API 调用失败: " + resp.getStatusCode() + " " + resp.getBody());
            }
            
            // 解析响应
            JsonNode root = objectMapper.readTree(resp.getBody());
            String content = root.at("/choices/0/message/content").asText();
            
            if (content == null || content.isBlank()) {
                log.error("Groq API 返回的 content 为空，完整响应: {}", resp.getBody());
                throw new RuntimeException("Groq API 返回为空");
            }
            
            log.debug("Groq API 原始 content: {}", content);
            
            // 清理可能的 markdown 代码块
            content = stripMarkdown(content);
            log.debug("Groq API 清理后的 content: {}", content);
            
            // 解析 JSON
            JsonNode nutritionNode = objectMapper.readTree(content);
            
            // 创建营养建议对象
            NutritionRecommendation recommendation = new NutritionRecommendation();
            recommendation.setDailyCalories(getIntValue(nutritionNode, "dailyCalories"));
            recommendation.setProtein(getIntValue(nutritionNode, "protein"));
            recommendation.setFat(getIntValue(nutritionNode, "fat"));
            recommendation.setCarb(getIntValue(nutritionNode, "carb"));
            recommendation.setFiber(getIntValue(nutritionNode, "fiber"));
            
            log.info("成功获取营养建议: 卡路里={}, 蛋白质={}g, 脂肪={}g, 碳水={}g, 纤维={}g",
                    recommendation.getDailyCalories(),
                    recommendation.getProtein(),
                    recommendation.getFat(),
                    recommendation.getCarb(),
                    recommendation.getFiber());
            
            return recommendation;
            
        } catch (Exception e) {
            log.error("使用 Groq 获取营养建议失败", e);
            throw new RuntimeException("使用 Groq 获取营养建议失败: " + e.getMessage(), e);
        }
    }
    
    /**
     * 从 JSON 节点获取整数值
     */
    private Integer getIntValue(JsonNode node, String fieldName) {
        JsonNode fieldNode = node.get(fieldName);
        if (fieldNode == null || fieldNode.isNull()) {
            return null;
        }
        if (fieldNode.isInt()) {
            return fieldNode.asInt();
        }
        if (fieldNode.isTextual()) {
            try {
                return Integer.parseInt(fieldNode.asText());
            } catch (NumberFormatException e) {
                log.warn("无法解析 {} 字段为整数: {}", fieldName, fieldNode.asText());
                return null;
            }
        }
        return null;
    }
    
    /**
     * 清理 markdown 代码块标记
     */
    private String stripMarkdown(String content) {
        if (content == null) {
            return null;
        }
        // 移除可能的 ```json 或 ``` 标记
        content = content.trim();
        if (content.startsWith("```json")) {
            content = content.substring(7);
        } else if (content.startsWith("```")) {
            content = content.substring(3);
        }
        if (content.endsWith("```")) {
            content = content.substring(0, content.length() - 3);
        }
        return content.trim();
    }
}

