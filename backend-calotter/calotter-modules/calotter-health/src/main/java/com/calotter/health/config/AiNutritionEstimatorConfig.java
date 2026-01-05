package com.calotter.health.config;

import com.calotter.health.service.ai.GeminiManualNutritionEstimator;
import com.calotter.health.service.ai.GroqManualNutritionEstimator;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * AI 营养估算器配置
 * 通过配置选择使用 Gemini 或 Groq
 */
@Configuration
public class AiNutritionEstimatorConfig {

    /**
     * Gemini 营养估算器（默认，测试阶段使用）
     */
    @Bean
    @Primary
    @ConditionalOnProperty(name = "ai.nutrition.provider", havingValue = "gemini", matchIfMissing = true)
    public ManualNutritionEstimator geminiManualNutritionEstimator(
            @Value("${ai.nutrition.gemini.base-url:https://generativelanguage.googleapis.com}") String baseUrl,
            @Value("${ai.nutrition.gemini.api-key:}") String apiKey,
            @Value("${ai.nutrition.gemini.model:gemini-2.5-pro}") String model,
            com.fasterxml.jackson.databind.ObjectMapper objectMapper) {
        return new GeminiManualNutritionEstimator(objectMapper, baseUrl, apiKey, model);
    }

    /**
     * Groq 营养估算器（保留，可通过配置切换）
     */
    @Bean
    @ConditionalOnProperty(name = "ai.nutrition.provider", havingValue = "groq")
    public ManualNutritionEstimator groqManualNutritionEstimator(
            @Value("${ai.nutrition.groq.base-url:https://api.groq.com}") String baseUrl,
            @Value("${ai.nutrition.groq.api-key:}") String apiKey,
            @Value("${ai.nutrition.groq.model:llama-3.3-70b-versatile}") String model,
            com.fasterxml.jackson.databind.ObjectMapper objectMapper) {
        return new GroqManualNutritionEstimator(objectMapper, baseUrl, apiKey, model);
    }
}

