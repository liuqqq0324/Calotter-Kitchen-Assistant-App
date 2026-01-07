package com.calotter.cooking.config;

import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.ai.BedrockAiMenuGenerationService;
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
     * Groq 实现（保留原有逻辑）
     */
    @Bean
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "groq")
    public AiMenuGenerationService groqAiMenuGenerationService(ObjectMapper objectMapper) {
        return new GroqAiMenuGenerationService(objectMapper);
    }

    /**
     * AWS Bedrock 实现（使用 short-term Bearer Token，走 Groq 同款 prompt + userJson）
     * 注意：token 过期需手动更新环境变量/配置。
     */
    @Bean
    @Primary
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "bedrock", matchIfMissing = false)
    public AiMenuGenerationService bedrockAiMenuGenerationService(
            ObjectMapper objectMapper,
            @Value("${ai.api.bedrock.api-key:}") String apiKey,
            @Value("${ai.api.bedrock.region:us-east-1}") String region,
            @Value("${ai.api.bedrock.model-id:us.meta.llama3-3-70b-instruct-v1:0}") String modelId,
            @Value("${ai.api.bedrock.max-tokens:4096}") int maxTokens,
            @Value("${ai.api.bedrock.temperature:0.2}") double temperature,
            @Value("${ai.api.bedrock.top-p:0.9}") double topP) {
        log.info("创建 BedrockAiMenuGenerationService bean");
        return new BedrockAiMenuGenerationService(
                objectMapper,
                apiKey,
                region,
                modelId,
                maxTokens,
                temperature,
                topP);
    }
}

