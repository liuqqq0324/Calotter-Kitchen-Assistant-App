package com.calotter.cooking.config;

import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.ai.GeminiAiMenuGenerationService;
import com.calotter.cooking.service.ai.GroqAiMenuGenerationService;
import com.calotter.cooking.service.ai.MockAiMenuGenerationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * AI 菜单生成服务配置
 * 通过配置选择使用 Mock、Gemini 或 Groq
 */
@Slf4j
@Configuration
public class AiMenuServiceConfig {

    @Value("${ai.api.mode:NOT_SET}")
    private String aiMode;

    @PostConstruct
    public void logConfig() {
        log.info("=== AI Menu Service Config ===");
        log.info("ai.api.mode = '{}' (length: {})", aiMode, aiMode != null ? aiMode.length() : 0);
        log.info("==============================");
    }

    /**
     * Mock 实现（开发测试阶段，默认使用）
     */
    @Bean
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
     * Groq 实现（主要使用，设为 Primary）
     */
    @Bean
    @Primary
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "groq", matchIfMissing = false)
    public AiMenuGenerationService groqAiMenuGenerationService(ObjectMapper objectMapper) {
        log.info("创建 GroqAiMenuGenerationService bean（Primary）");
        return new GroqAiMenuGenerationService(objectMapper);
    }
}

