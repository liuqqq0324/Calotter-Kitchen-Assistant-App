package com.calotter.health.config;

import com.calotter.health.service.ai.GroqManualNutritionEstimator;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * AI 营养估算器配置
 * 仅使用 Groq（已移除 Gemini 实现）
 */
@Configuration
public class AiNutritionEstimatorConfig {

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
        return new GroqManualNutritionEstimator(objectMapper, baseUrl, apiKey, model);
    }
}

