package com.calotter.cooking.config;

import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.ai.GeminiAiMenuGenerationService;
import com.calotter.cooking.service.ai.GroqAiMenuGenerationService;
import com.calotter.cooking.service.ai.MockAiMenuGenerationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * AI 菜单生成服务配置
 * 通过配置选择使用 Mock、Gemini 或 Groq
 */
@Configuration
public class AiMenuServiceConfig {

    /**
     * Mock 实现（开发测试阶段，默认使用）
     */
    @Bean
    @Primary
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "mock", matchIfMissing = true)
    public AiMenuGenerationService mockAiMenuGenerationService() {
        return new MockAiMenuGenerationService();
    }

    /**
     * Gemini 实现（优化版 - 简化 Prompt）
     */
    @Bean
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "gemini")
    public AiMenuGenerationService geminiAiMenuGenerationService(ObjectMapper objectMapper) {
        return new GeminiAiMenuGenerationService(objectMapper);
    }

    /**
     * Groq 实现（保留原有逻辑）
     */
    @Bean
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "groq")
    public AiMenuGenerationService groqAiMenuGenerationService(ObjectMapper objectMapper) {
        return new GroqAiMenuGenerationService(objectMapper);
    }
}

