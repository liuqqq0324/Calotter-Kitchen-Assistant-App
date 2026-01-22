package com.calotter.health.config;

import com.calotter.health.service.ai.GroqManualNutritionEstimator;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;

/**
 * AI 营养估算器配置
 * 仅使用 Groq（已移除 Gemini 实现）
 */
@Configuration
public class AiNutritionEstimatorConfig {

    @Autowired
    private Environment environment;

    /**
     * Groq 营养估算器（默认启用）
     */
    @Bean
    @Primary
    @ConditionalOnProperty(name = "ai.nutrition.provider", havingValue = "groq", matchIfMissing = true)
    public ManualNutritionEstimator groqManualNutritionEstimator(
            @Value("${ai.nutrition.groq.base-url:https://api.groq.com}") String baseUrl,
            @Value("${ai.nutrition.groq.api-key:}") String apiKey,
            @Value("${ai.nutrition.groq.model:llama-3.3-70b-versatile}") String model,
            com.fasterxml.jackson.databind.ObjectMapper objectMapper) {
        
        // 🔥 调试日志：检查 Spring Environment 中的属性
        System.out.println("=== Groq Nutrition Estimator Config ===");
        System.out.println("Base URL: " + baseUrl);
        
        // 直接从 Environment 检查属性
        String groqKeyFromEnv = environment.getProperty("GROQ_API_KEY");
        String groqKeyFromConfig = environment.getProperty("ai.nutrition.groq.api-key");
        System.out.println("GROQ_API_KEY from Environment: " + (groqKeyFromEnv != null ? "YES (length: " + groqKeyFromEnv.length() + ")" : "NO"));
        System.out.println("ai.nutrition.groq.api-key from Environment: " + (groqKeyFromConfig != null ? "YES (length: " + groqKeyFromConfig.length() + ")" : "NO"));
        
        // 检查注入的值
        System.out.println("API Key from @Value injection: " + (apiKey != null && !apiKey.isEmpty() ? "YES" : "NO"));
        System.out.println("API Key length: " + (apiKey != null ? apiKey.length() : 0));
        
        // 🔥 如果注入为空，尝试从 Environment 直接获取
        if ((apiKey == null || apiKey.isEmpty()) && groqKeyFromEnv != null && !groqKeyFromEnv.isEmpty()) {
            System.out.println("⚠️  WARNING: @Value injection failed, but found in Environment. Using Environment value.");
            apiKey = groqKeyFromEnv;
        }
        
        if (apiKey != null && !apiKey.isEmpty()) {
            System.out.println("API Key prefix: " + apiKey.substring(0, Math.min(10, apiKey.length())) + "...");
            System.out.println("API Key suffix: ..." + apiKey.substring(Math.max(0, apiKey.length() - 10)));
        } else {
            System.out.println("⚠️  ERROR: API Key is empty! Check .env file and GROQ_API_KEY variable.");
        }
        System.out.println("Model: " + model);
        System.out.println("=======================================");
        
        return new GroqManualNutritionEstimator(objectMapper, baseUrl, apiKey, model);
    }
}

