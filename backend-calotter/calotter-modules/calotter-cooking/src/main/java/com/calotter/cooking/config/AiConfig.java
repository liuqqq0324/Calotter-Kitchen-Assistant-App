package com.calotter.cooking.config;

import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.ai.SpringAiGeminiMenuGenerationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * AI 菜单生成服务统一配置类
 * 仅使用 Spring AI Gemini 实现（已废除 Mock、Groq 和 Bedrock）
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
}

