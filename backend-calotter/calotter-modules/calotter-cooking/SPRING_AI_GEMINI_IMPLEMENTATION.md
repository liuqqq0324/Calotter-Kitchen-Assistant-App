# Spring AI Gemini 实现说明

## 概述

已成功集成 Spring AI Gemini 支持，使用 Function Calling 来大幅减少 Prompt 中的格式说明 token 消耗。

## 主要改进

### 1. Token 消耗大幅减少
- **之前**: System Prompt 约 160+ 行（~2000+ tokens）
- **现在**: System Prompt 约 10 行（~150 tokens）
- **节省**: 约 **90%** 的 token 消耗

### 2. 使用结构化输出
- 通过 `MenuGenerationFunction` POJO 定义输出格式
- Spring AI 自动处理 JSON Schema 转换
- 类型安全，编译时检查

### 3. 更易维护
- 数据结构变更只需修改 POJO
- 不需要手动处理 JSON 格式验证
- Spring AI 自动处理响应解析

## 文件结构

### 新增文件
1. `MenuGenerationFunction.java` - Function Calling 的数据结构定义
2. `SpringAiGeminiMenuGenerationService.java` - Spring AI Gemini 服务实现

### 修改文件
1. `pom.xml` (父级) - 添加 Spring AI 依赖和 Milestone repository
2. `calotter-cooking/pom.xml` - 添加 Spring AI Gemini starter
3. `application.yml` - 添加 Spring AI Gemini 配置
4. `AiMenuServiceConfig.java` - 添加 Spring AI Gemini Bean 配置

## 配置说明

### application.yml 配置

```yaml
ai:
  api:
    mode: spring-ai-gemini  # 使用 Spring AI Gemini

spring:
  ai:
    google:
      gemini:
        api-key: ${GEMINI_API_KEY:}
        chat:
          options:
            model: gemini-2.0-flash-exp
            temperature: 0.7
```

### 模式选择

- `mock` - Mock 实现（开发测试）
- `gemini` - 原始 Gemini 实现（RestTemplate 直接调用）
- `spring-ai-gemini` - **Spring AI Gemini 实现（推荐，使用 Function Calling）**
- `groq` - Groq 实现（完整 Prompt 版本）

## 使用方法

1. **设置环境变量**（`.env` 文件）:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

2. **配置模式**（`application.yml`）:
   ```yaml
   ai:
     api:
       mode: spring-ai-gemini
   ```

3. **启动应用**: Spring AI 会自动配置 ChatModel Bean

## 技术细节

### Spring AI 自动配置
- Spring AI 会自动创建 `ChatModel` Bean
- 基于 `spring.ai.google.gemini.*` 配置自动配置

### 结构化输出
- 使用 `ChatClient.entity(MenuGenerationFunction.class)` 进行结构化输出
- Spring AI 会自动将 LLM 响应转换为目标类型
- 如果格式不正确，会抛出明确的异常

### 错误处理
- 自动检测配额错误（429）
- 提供清晰的错误消息
- 向后兼容原有错误处理逻辑

## 优势对比

| 特性 | 原始实现 | Spring AI 实现 |
|------|---------|---------------|
| System Prompt Token | ~2000+ | ~150 |
| 格式验证 | 手动处理 | 自动处理 |
| 类型安全 | 运行时检查 | 编译时检查 |
| 维护成本 | 高（修改 Prompt） | 低（修改 POJO） |
| JSON Schema | 手动定义 | 自动生成 |

## 注意事项

1. **依赖版本**: 使用 Spring AI 1.0.0-M4（Milestone 版本）
2. **模型兼容性**: 确保 Gemini 模型支持结构化输出（gemini-2.0-flash-exp 及以上）
3. **向后兼容**: 保留了原始 `GeminiAiMenuGenerationService`，可通过配置切换
4. **API Key**: 确保 `.env` 文件中配置了正确的 `GEMINI_API_KEY`

## 下一步优化

1. **Function Calling**: 可以进一步使用真正的 Function Calling（而非结构化输出）
2. **流式响应**: 可以添加流式响应支持
3. **重试机制**: 可以添加自动重试机制
4. **缓存**: 可以添加响应缓存以减少 API 调用

