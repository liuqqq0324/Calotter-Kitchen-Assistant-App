# Cooking 模块代码修改总结 - 2026.01.07（1.7）

## 📋 修改概览（这次改动解决什么）

本次修改的核心目标是：**修复 AI 菜单生成中 taboos（饮食习惯）传递和理解问题**，并重新集成 AWS Bedrock AI 服务支持。

主要完成了 5 大类改动：

1. **重新集成 AWS Bedrock AI 服务**：添加 Bedrock 支持，使用 short-term Bearer token 方式
2. **修复 taboos 字段传递问题**：移除将 taboos 合并到 avoidIngredients 的逻辑，保持 taboos 作为独立字段
3. **强化 Groq Prompt 对 taboos 的理解**：明确说明 taboos 是用户的饮食风格，不是禁忌，避免 AI 误解
4. **前端 UI 改名优化**：将 "taboo" 改为更友好的 "Diet Habit"，但后端字段名保持不变
5. **环境变量配置优化**：将敏感 API key 改为从环境变量读取，避免硬编码

---

## 1) 集成 AWS Bedrock AI 服务支持

### 1.1 背景

需要支持 AWS Bedrock 作为 AI 菜单生成服务，使用 short-term Bearer token 方式进行认证（不使用 IAM SigV4）。

### 1.2 新增文件

**Bedrock AI 服务实现（`BedrockAiMenuGenerationService.java`）**
- 创建新的服务类，实现 `AiMenuGenerationService` 接口
- 使用 `RestTemplate` 直接调用 Bedrock Converse API
- 复用 Groq 的 SYSTEM_PROMPT，保持行为一致
- 支持通过构造函数注入配置参数（apiKey, region, modelId, maxTokens, temperature, topP）
- 实现错误处理和日志记录

**关键特性：**
- 使用 Converse API endpoint：`https://bedrock-runtime.{region}.amazonaws.com/model/{modelId}/converse`
- Bearer token 认证：支持 token 已包含或未包含 "Bearer " 前缀
- 响应解析：从 `output.message.content[0].text` 提取模型输出
- 错误处理：401/403 错误提示 token 过期，其他错误提供详细日志

### 1.3 配置变更

**后端配置（`AiMenuServiceConfig.java`）**
- 添加 `BedrockAiMenuGenerationService` 的 import
- 新增 Bedrock Bean 配置方法，使用 `@ConditionalOnProperty(name = "ai.api.mode", havingValue = "bedrock")`
- 通过 `@Value` 注解从配置文件读取所有 Bedrock 配置参数
- 添加 `@Primary` 注解，确保在 bedrock 模式下优先使用
- 添加调试日志，记录配置值

**配置文件（`application.yml`）**
- 添加 Bedrock 配置部分：
  ```yaml
  bedrock:
    api-key: ${BEDROCK_API_KEY:}  # 从环境变量读取
    region: us-east-1
    model-id: us.meta.llama3-3-70b-instruct-v1:0  # Inference Profile ID
    max-tokens: 4096
    temperature: 0.2
    top-p: 0.9
  ```
- 将 Groq API key 也改为从环境变量读取：`api-key: ${GROQ_API_KEY:}`

**环境变量模板（`env.template`）**
- 添加 `BEDROCK_API_KEY` 配置说明
- 更新 Groq 配置说明，标注为从环境变量读取

**Git 配置（`.gitignore`）**
- 添加 `.env` 和 `.env.*` 到忽略列表，避免敏感信息提交到仓库

### 1.4 问题修复过程

**问题 1：Spring Bean 无法找到**
- **原因**：`@Value` 注解在通过 `new` 创建的对象中不会自动注入
- **解决**：改为通过构造函数注入所有配置参数，在 `@Bean` 方法中读取配置并传递给构造函数

**问题 2：Model identifier 无效**
- **原因**：使用了错误的 model identifier 格式
- **解决**：从 `meta.llama3-1-8b-instruct-v1:0` → `meta.llama3-3-70b-instruct-v1:0` → `us.meta.llama3-3-70b-instruct-v1:0`（Inference Profile ID）

**问题 3：URL 编码问题**
- **原因**：`URLEncoder.encode()` 将 `:` 编码为 `%3A`，导致 URL 格式错误
- **解决**：移除 URL 编码，直接使用 model identifier（`:` 在 URL 路径中是合法字符）

**问题 4：Bearer token 格式问题**
- **原因**：`setBearerAuth()` 会自动添加 "Bearer " 前缀，如果 token 已包含会导致重复
- **解决**：检查 token 是否已包含 "Bearer " 前缀，如果包含则直接设置，否则使用 `setBearerAuth()`

**问题 5：On-demand throughput 不支持**
- **原因**：某些模型不支持直接用 model ID 调用 Converse API
- **解决**：使用 Inference Profile ID（`us.meta.llama3-3-70b-instruct-v1:0`）而不是 model ID

### 1.5 影响

- ✅ 支持 AWS Bedrock 作为 AI 服务选项
- ✅ 使用环境变量管理敏感信息，提高安全性
- ✅ 代码结构清晰，易于维护和扩展
- ⚠️ 需要手动更新 short-term Bearer token（token 过期后）

---

## 2) 修复 taboos 字段传递问题

### 2.1 问题描述

用户反馈：在 Filter 页面手动输入 "vegetarian" 到 taboos，但生成的食谱仍然包含 shrimp 等非素食食材。

**根因分析：**
- 后端 `AiMenuService.generateMenus()` 中将 `taboos` 合并到 `avoidIngredients`，导致：
  - `taboos` 字段在 JSON 中可能丢失或被误解
  - AI 将 "vegetarian" 当作普通食材名称，而非饮食限制
  - 缺少明确的日志追踪数据流

### 2.2 解决方案

**移除合并逻辑（`AiMenuService.java`）**
- 移除了将 `taboos` 合并到 `avoidIngredients` 的代码（第56-66行）
- 保持 `taboos` 作为独立字段传递给 AI
- 添加了详细的日志来追踪 filter 数据：
  ```java
  log.info("=== Filter Data Before AI Call ===");
  log.info("Taboos: {}", dp.getTaboos());
  log.info("Avoid Ingredients: {}", dp.getAvoidIngredients());
  log.info("Allergies: {}", dp.getAllergies());
  ```

**添加调试日志（`GroqAiMenuGenerationService.java`）**
- 在调用 AI 前记录完整的 filter 数据
- 记录发送给 Groq 的完整 JSON 请求

### 2.3 影响

- ✅ `taboos` 字段现在独立传递给 AI，不会被合并
- ✅ 可以通过日志追踪数据流，便于调试
- ⚠️ 需要确保 AI prompt 能正确理解 `taboos` 字段（见第3节）

---

## 3) 强化 Groq Prompt 对 taboos 的理解

### 3.1 问题描述

即使 `taboos` 字段正确传递，AI 仍然可能误解：
- 字段名 "taboos"（禁忌）可能让 AI 认为这是"禁忌的东西"
- AI 可能误解：`taboos: ["vegetarian"]` = 禁忌素食 = 必须要有肉（完全相反！）

### 3.2 解决方案

**强化 System Prompt（`GroqAiMenuGenerationService.java`）**

将原来的：
```
"TABOO (DIETARY STYLE) RULES - STRICT:"
"- The input may contain dietPreferences.taboos..."
"- Interpret them as follows:"
"  * vegetarian: NO meat/poultry/fish/seafood..."
```

改为：
```
"DIETARY RESTRICTIONS (dietPreferences.taboos) - CRITICAL UNDERSTANDING:"
"- ⚠️ IMPORTANT: The 'taboos' array contains the USER'S DIETARY LIFESTYLE/RESTRICTIONS, NOT things to avoid."
"- If 'taboos' contains 'vegetarian', it means THE USER IS A VEGETARIAN (they follow a vegetarian diet)."
"- If 'taboos' contains 'vegetarian', you MUST generate ONLY vegetarian recipes (NO meat, NO poultry, NO fish, NO seafood)."
"- ⚠️ DO NOT MISUNDERSTAND: 'vegetarian' in taboos = user is vegetarian = recipes must be vegetarian (no meat)."
"- ⚠️ DO NOT MISUNDERSTAND: 'vegetarian' in taboos ≠ taboo against vegetarian food ≠ must include meat."
```

**添加 User Message 强调（`GroqAiMenuGenerationService.java`）**

如果存在 taboos，在 user message 中明确说明：
```java
if (taboos != null && !taboos.isEmpty()) {
    userMessage.append("⚠️ CRITICAL CLARIFICATION ABOUT 'taboos' ARRAY:\n");
    userMessage.append("The 'taboos' array contains the USER'S DIETARY LIFESTYLE, not things to avoid.\n");
    userMessage.append("For example, if 'taboos' contains 'vegetarian', it means THE USER IS A VEGETARIAN.\n");
    userMessage.append("Therefore, you MUST generate ONLY vegetarian recipes (NO meat, NO poultry, NO fish, NO seafood).\n");
    userMessage.append("Current taboos (user's dietary lifestyle): ").append(String.join(", ", taboos)).append("\n");
}
```

**添加验证检查清单**

在 prompt 中添加验证步骤：
```
"VALIDATION CHECKLIST (before including any ingredient):"
"- If 'vegetarian' is in taboos: Ask 'Is this ingredient meat, poultry, fish, or seafood?' If YES, DO NOT use it."
"- If 'vegan' is in taboos: Ask 'Is this ingredient from an animal?' If YES, DO NOT use it."
"- These are ABSOLUTE HARD CONSTRAINTS. Violating them will result in recipe rejection."
```

### 3.3 影响

- ✅ AI 现在能正确理解 `taboos` 的含义
- ✅ 明确的正反两面说明（是什么 + 不是什么）
- ✅ 在 system prompt 和 user message 中都强调，双重保险

---

## 4) 前端 UI 改名优化（taboo → Diet Habit）

### 4.1 背景

字段名 "taboo"（禁忌）对用户不够友好，容易产生误解。改为更友好的 "Diet Habit"（饮食习惯），但后端字段名保持不变。

### 4.2 变更

**Filter 页面（`recipe_filter_page.dart`）**
- 标题：`"Allergies, taboos & avoid ingredients"` → `"Allergies, diet habits & avoid ingredients"`
- 子标题：`"Taboos (standard tags, optional)"` → `"Diet habits (standard tags, optional)"`
- 输入框标签：`"Add taboo tag"` → `"Add diet habit"`
- 注释更新：说明发送给后端时字段名为 `taboos`

**Profile View 页面（`profile_view_page.dart`）**
- 导航文字：`"Taboos"` → `"Diet Habits"`

**Profile Edit 页面（`profile_edit_page.dart`）**
- 标题：`"Taboos"` → `"Diet Habits"`

**Taboos List 页面（`taboos_list_page.dart`）**
- 页面标题：已为 `"Dietary Restrictions"`（无需修改）
- 注释更新：更友好的说明

### 4.3 保持不变

- ✅ **后端字段名**：发送给后端时仍然是 `"taboos"`（`"taboos": _selectedTaboos.toList()`）
- ✅ **变量名**：`_selectedTaboos` 保持不变（仅内部使用）
- ✅ **API 调用**：所有 API 调用仍然使用 `taboos` 字段名

### 4.4 影响

- ✅ 用户体验更好：看到的是 "Diet Habits" 或 "Dietary Restrictions"，更容易理解
- ✅ 后端接口不变：不需要修改后端代码
- ✅ 向后兼容：API 契约保持不变

---

## 5) 文件改动清单

### 5.1 后端修改文件

#### AI 服务配置
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/config/AiMenuServiceConfig.java`
  - 添加 `BedrockAiMenuGenerationService` 的 import 和 Bean 配置
  - 添加 `@ConditionalOnProperty` 条件，支持通过配置切换 AI 服务
  - 添加调试日志，记录配置值
  - 将 Bedrock Bean 设为 `@Primary`（当 mode=bedrock 时）

#### Bedrock AI 服务实现（新增）
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/ai/BedrockAiMenuGenerationService.java`
  - 实现 `AiMenuGenerationService` 接口
  - 使用 RestTemplate 调用 Bedrock Converse API
  - 支持 Bearer token 认证（自动处理前缀）
  - 实现响应解析和错误处理

#### AI 菜单生成服务
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/AiMenuService.java`
  - 移除 taboos 合并到 avoidIngredients 的逻辑
  - 添加详细的 filter 数据日志

- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/ai/GroqAiMenuGenerationService.java`
  - 强化 System Prompt 中对 taboos 的理解说明
  - 添加 User Message 强调 taboos 的含义
  - 添加验证检查清单

#### 配置文件
- `backend-calotter/calotter-start/src/main/resources/application.yml`
  - 添加 Bedrock 配置部分（region, model-id, max-tokens, temperature, top-p）
  - Bedrock 和 Groq 的 API key 都改为从环境变量读取
  - `ai.api.mode` 可设置为 `bedrock` 或 `groq`

- `backend-calotter/env.template`（新增）
  - 创建环境变量模板文件
  - 包含 `BEDROCK_API_KEY` 和 `GROQ_API_KEY` 的配置说明
  - 提供使用说明和注意事项

- `.gitignore`
  - 添加 `.env` 和 `.env.*` 到忽略列表

### 5.2 前端修改文件

- `frontend-app/lib/pages/recipes/recipe_filter_page.dart`
  - UI 文字：taboo → diet habit
  - 注释更新

- `frontend-app/lib/pages/ums/profile/profile_view_page.dart`
  - 导航文字：Taboos → Diet Habits

- `frontend-app/lib/pages/ums/profile/profile_edit_page.dart`
  - 标题：Taboos → Diet Habits

- `frontend-app/lib/pages/ums/preferences/taboos_list_page.dart`
  - 注释更新（页面标题已为 "Dietary Restrictions"）

---

## 6) 技术知识点总结

### 6.1 AI Prompt 设计原则

**问题**：字段名可能误导 AI 理解

**解决方案**：
1. **明确说明字段含义**：在 prompt 中明确说明字段代表什么，不是什么
2. **正反两面说明**：既说明"是什么"，也说明"不是什么"
3. **双重强调**：在 system prompt 和 user message 中都强调
4. **验证步骤**：添加检查清单，让 AI 在生成前验证

**最佳实践**：
- 避免使用可能产生歧义的字段名（如 "taboos" 可能被误解为"禁忌的东西"）
- 如果必须使用，在 prompt 中明确说明其真实含义
- 在 user message 中再次强调，确保 AI 理解

### 6.2 数据传递追踪

**问题**：数据传递过程中可能丢失或误解

**解决方案**：
- 在关键节点添加日志：接收数据时、处理数据时、发送数据时
- 使用清晰的日志格式，便于调试
- 记录完整的数据结构，而不仅仅是摘要

### 6.3 Spring Bean 配置最佳实践

**问题**：`@Value` 注解在通过 `new` 创建的对象中不会自动注入

**解决方案**：
- 对于需要配置注入的类，使用构造函数注入而不是字段注入
- 在 `@Bean` 方法中通过 `@Value` 读取配置，然后传递给构造函数
- 这样可以确保配置值正确注入，避免运行时错误

**示例：**
```java
@Bean
@ConditionalOnProperty(name = "ai.api.mode", havingValue = "bedrock")
public AiMenuGenerationService bedrockAiMenuGenerationService(
        ObjectMapper objectMapper,
        @Value("${ai.api.bedrock.api-key:}") String apiKey,
        @Value("${ai.api.bedrock.region:us-east-1}") String region,
        // ... 其他参数
) {
    return new BedrockAiMenuGenerationService(objectMapper, apiKey, region, ...);
}
```

### 6.4 环境变量管理

**问题**：敏感信息（API key）不应该硬编码在代码中

**解决方案**：
- 使用环境变量存储敏感信息
- 在配置文件中使用 `${ENV_VAR:default}` 语法读取环境变量
- 创建 `.env.template` 文件作为配置模板
- 将 `.env` 文件添加到 `.gitignore`，避免提交到仓库

**最佳实践：**
- 所有 API key 都从环境变量读取
- 提供清晰的文档说明如何设置环境变量
- 在启动脚本或文档中说明环境变量的设置方法

### 6.5 AWS Bedrock API 使用注意事项

**Model Identifier 格式：**
- 某些模型需要使用 Inference Profile ID 而不是 Model ID
- Inference Profile ID 格式：`us.meta.llama3-3-70b-instruct-v1:0`
- Model ID 格式：`meta.llama3-3-70b-instruct-v1:0`
- URL 路径中的 model identifier 不需要 URL 编码

**Bearer Token 格式：**
- 检查 token 是否已包含 "Bearer " 前缀
- 如果包含，直接设置 Authorization header
- 如果不包含，使用 `setBearerAuth()` 方法

**错误处理：**
- 401/403 通常表示 token 无效或过期
- 400 可能表示 model identifier 无效或请求格式错误
- 提供详细的错误日志，便于调试

---

## 7) 回归测试建议（快速验证）

1. **AI 菜单生成 - vegetarian 测试**
   - 在 Filter 页面输入 "vegetarian" 到 diet habits
   - 生成菜单，验证是否不包含任何肉类/海鲜
   - 查看后端日志，确认 `Taboos: [vegetarian]` 出现在日志中

2. **数据传递验证**
   - 查看后端日志中的 `=== Filter Data Before AI Call ===` 部分
   - 查看 `=== Groq AI Service - Filter Data ===` 部分
   - 确认 `taboos` 字段正确传递

3. **前端 UI 验证**
   - 检查 Filter 页面显示为 "Diet habits" 而不是 "Taboos"
   - 检查 Profile 页面显示为 "Diet Habits"
   - 确认功能正常，可以添加/删除 diet habits

4. **API 兼容性验证**
   - 确认发送给后端的 JSON 中字段名仍然是 `"taboos"`
   - 确认后端能正确接收和处理

---

## 8) 已知问题与后续优化

### 8.1 当前限制

- AI 可能仍然偶尔生成违反 taboos 的食谱（需要进一步优化 prompt 或添加后端验证）
- 如果所有生成的菜单都违反 taboos，目前会返回错误（可以考虑自动重试）

### 8.2 后续优化建议

- [ ] 考虑添加后端验证，过滤掉违反 taboos 的食谱（已在代码中实现但被用户拒绝）
- [ ] 考虑在 prompt 中添加更多示例，帮助 AI 理解
- [ ] 考虑使用更明确的字段名（如 `dietaryLifestyle` 而不是 `taboos`），但这需要前后端都改
- [ ] 考虑实现 Bedrock token 自动刷新机制（目前需要手动更新）
- [ ] 考虑添加 Bedrock API 调用监控和重试机制
- [ ] 考虑支持更多 Bedrock 模型（如 Claude、Titan 等）

---

**文档创建时间**：2026.01.07  
**最后更新**：2026.01.07（添加 Bedrock 集成部分）  
**修改人员**：Emma  
**审核状态**：待审核

