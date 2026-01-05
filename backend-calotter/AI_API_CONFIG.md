# AI API 配置说明

## 概述

项目支持三种 AI 菜单生成模式：
- **Mock**（默认，开发测试阶段）- 返回固定假数据，不调用真实 API，0 费用、0 延迟
- **Gemini**（优化版）- 简化 Prompt 格式，大幅减少 Token 消耗（50%-70%）
- **Groq**（完整版）- 保留原有完整 Prompt 逻辑

## 配置方式

### 1. 模式选择（重要）

编辑 `calotter-start/src/main/resources/application.yml`：

```yaml
ai:
  api:
    mode: mock  # mock（默认）/ gemini（优化版）/ groq（完整版）
```

**模式说明：**
- **`mock`**（默认）：开发测试阶段使用，返回固定假数据，不调用真实 API
  - ✅ 0 费用、0 延迟
  - ✅ 前端可以疯狂测试 UI，不用担心 API 限制
  - ✅ 演示时网络问题可以切回 Mock 模式
- **`gemini`**：使用 Gemini API，优化版（简化 Prompt）
  - ✅ Token 消耗降低 50%-70%
  - ✅ 适合免费版配额有限的情况
- **`groq`**：使用 Groq API，完整 Prompt 版本
  - ✅ 保留原有完整逻辑

### 2. API Key 配置

#### 环境变量配置（推荐）

**Windows PowerShell:**
```powershell
$env:GEMINI_API_KEY = "your_gemini_api_key_here"
$env:GROQ_API_KEY = "your_groq_api_key_here"
```

**macOS/Linux:**
```bash
export GEMINI_API_KEY="your_gemini_api_key_here"
export GROQ_API_KEY="your_groq_api_key_here"
```

#### 配置文件配置

编辑 `calotter-start/src/main/resources/application.yml`：

```yaml
ai:
  api:
    mode: mock  # mock / gemini / groq
    # Gemini 配置（优化版 - 简化 Prompt）
    gemini:
      api-key: ${GEMINI_API_KEY:}  # 从环境变量读取
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
    # Groq 配置（完整版）
    groq:
      api-key: ${GROQ_API_KEY:}  # 从环境变量读取
      url: https://api.groq.com/openai/v1/chat/completions
      model: llama-3.3-70b-versatile
  nutrition:
    provider: gemini  # gemini 或 groq
    gemini:
      api-key: ${GEMINI_API_KEY:}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
    groq:
      api-key: ${GROQ_API_KEY:}
      base-url: https://api.groq.com
      model: llama-3.3-70b-versatile
```

## 切换模式

### Mock 模式（开发测试，默认）

```yaml
ai:
  api:
    mode: mock
```

**特点：**
- 不需要 API Key
- 返回固定的假数据（5 个菜单）
- 适合前端 UI 开发和测试

### Gemini 模式（优化版）

```yaml
ai:
  api:
    mode: gemini
    gemini:
      api-key: ${GEMINI_API_KEY:}
```

**特点：**
- 简化 Prompt 格式，大幅减少 Token
- 过滤基础调料（盐、糖、油等）
- 使用简洁的文本格式而非 JSON
- Token 消耗降低 50%-70%

### Groq 模式（完整版）

```yaml
ai:
  api:
    mode: groq
    groq:
      api-key: ${GROQ_API_KEY:}
```

**特点：**
- 保留原有完整 Prompt 逻辑
- 使用 JSON 格式传递完整数据

## 获取 API Key

### Gemini API Key

1. 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 登录 Google 账号
3. 创建新的 API Key
4. 复制 API Key 并配置到环境变量或配置文件中

### Groq API Key

1. 访问 [Groq Console](https://console.groq.com/)
2. 注册/登录账号
3. 创建新的 API Key
4. 复制 API Key 并配置到环境变量或配置文件中

## 使用说明

### 菜单生成（AiMenuService）

- **API**: `/api/ai/generate-menus`
- **使用的配置**: `ai.api.mode`（mock/gemini/groq）
- **模式选择逻辑**：
  - `mode: mock` → 使用 `MockAiMenuGenerationService`（返回假数据）
  - `mode: gemini` → 使用 `GeminiAiMenuGenerationService`（优化版，简化 Prompt）
  - `mode: groq` → 使用 `GroqAiMenuGenerationService`（完整版）

### 营养估算（ManualNutritionEstimator）

- **API**: `/api/intake/manual`
- **使用的配置**: `ai.nutrition.provider` 和 `ai.nutrition.gemini.*` 或 `ai.nutrition.groq.*`
- **注意**：营养估算器独立配置，不受 `ai.api.mode` 影响

## 注意事项

1. **开发测试阶段推荐使用 Mock 模式**：
   - 默认配置为 `mode: mock`，不需要 API Key
   - 前端可以无限制测试 UI，不用担心 API 配额
   - 解决 RenderFlex overflow 等 UI 问题时，Mock 模式非常有用

2. **Gemini 优化版特点**：
   - 简化 Prompt 格式，将 JSON 转换为简洁文本
   - 自动过滤基础调料（盐、糖、油、水等）
   - Token 消耗降低 50%-70%，适合免费版配额

3. **API Key 安全**：
   - 不要将 API Key 提交到 Git 仓库
   - 使用环境变量或 `application-local.yml`（已添加到 `.gitignore`）

4. **配置优先级**：
   - 环境变量 > 配置文件
   - 如果环境变量未设置，将使用配置文件中的值

5. **错误处理**：
   - Mock 模式：不需要 API Key，不会出错
   - Gemini/Groq 模式：如果 API Key 未配置，会抛出 `IllegalStateException`
   - 429 错误（配额用完）：会显示友好的错误提示
   - 检查日志以获取详细的错误信息

## 测试配置

测试环境使用 mock 模式，配置在 `application-test.yml` 中：

```yaml
ai:
  api:
    mode: mock  # 测试时使用 mock 模式，不调用真实 API
    gemini:
      api-key: test-api-key
      base-url: http://localhost:9999
      model: test-model
    groq:
      api-key: test-api-key
      url: http://localhost:9999/mock-ai-api
      model: test-model
```

## 故障排查

### 问题：API Key 未配置错误

**解决方案**：
1. 检查环境变量是否设置：`echo $GEMINI_API_KEY`（Linux/macOS）或 `$env:GEMINI_API_KEY`（Windows）
2. 检查 `application.yml` 中的配置
3. 重启应用

### 问题：API 调用失败

**解决方案**：
1. 检查 API Key 是否有效
2. 检查网络连接
3. 查看应用日志获取详细错误信息
4. 确认 API 配额是否充足

### 问题：切换模式后不生效

**解决方案**：
1. 确认配置文件已保存
2. 重启应用
3. 检查日志确认使用的模式（Mock/Gemini/Groq）

### 问题：429 Too Many Requests（配额用完）

**解决方案**：
1. **立即切换到 Mock 模式**（推荐）：
   ```yaml
   ai:
     api:
       mode: mock
   ```
2. 等待配额重置（通常是按天或按月）
3. 考虑升级 API 计划
4. 使用 Gemini 优化版（`mode: gemini`）可以降低 Token 消耗

### 问题：前端 UI 溢出（RenderFlex overflow）

**解决方案**：
1. 切换到 Mock 模式进行 UI 测试：
   ```yaml
   ai:
     api:
       mode: mock
   ```
2. Mock 模式返回固定数据，可以无限制测试 UI
3. 修复 UI 溢出问题后再切换回真实 API

