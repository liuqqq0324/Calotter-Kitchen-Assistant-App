package com.calotter.cooking.config;

import com.calotter.cooking.service.ai.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * AI 菜单生成服务统一配置类
 * 仅使用 Spring AI Gemini 实现（已废除 Mock 和 Groq）
 */
@Configuration
public class AiConfig {

    /**
     * Spring AI Gemini 实现（使用 Spring AI 和 Function Calling，减少 token 消耗）
     * 注意：这里需要 ChatModel，确保 application.yml 里配置了 spring.ai.google.genai
     * 默认使用此实现
     */
    @Bean
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "spring-ai-gemini", matchIfMissing = true)
    public AiMenuGenerationService springAiGeminiService(ChatModel chatModel, ObjectMapper objectMapper) {
        return new SpringAiGeminiMenuGenerationService(chatModel, objectMapper);
    }

    /**
     * AWS Bedrock 实现（可选，保留以备后用）
     */
    @Bean
    @ConditionalOnProperty(name = "ai.api.mode", havingValue = "bedrock")
    public AiMenuGenerationService bedrockService(
            ObjectMapper objectMapper,
            @Value("${ai.api.bedrock.api-key}") String apiKey,
            @Value("${ai.api.bedrock.region:us-east-1}") String region,
            @Value("${ai.api.bedrock.model:anthropic.claude-3-sonnet-20240229-v1:0}") String modelId) {
        // Bedrock 的其他参数可以硬编码或者继续从配置读取
        return new BedrockAiMenuGenerationService(objectMapper, apiKey, region, modelId, 4000, 0.7, 0.9);
    }
}

