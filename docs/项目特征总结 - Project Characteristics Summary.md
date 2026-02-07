# Personal Sous Chef — 项目特征总结（基于工程实现）

> **说明**：本文档完全基于当前仓库的**实际代码与配置**整理，按答辩结构分为 Part 3（技术架构）、Part 4（专业贡献）、Part 5（反思与展望）。所有结论均可在对应路径下核实。  
> 最后更新：2026-02-08

---

# Part 3：技术架构

## 3.1 后端整体架构

### 3.1.1 Maven 多模块结构

**代码依据**：`backend-calotter/pom.xml`、`backend-calotter/calotter-modules/pom.xml`

- **根 POM**：`calotter`（packaging: pom），定义 Java 17、Spring Boot 3.2.0、PostgreSQL、JWT、**Spring AI BOM 1.1.0-M4** 等依赖管理。
- **子模块**：
  - **calotter-common**：通用基础（无业务模块依赖）。
  - **calotter-modules**：聚合层，内含 **calotter-user**、**calotter-cooking**、**calotter-inventory**、**calotter-health** 四个业务模块。
  - **calotter-start**：唯一启动入口，依赖 common + 各业务模块。

**模块依赖关系**（README 与架构文档）：  
`calotter-start` → `calotter-user` / `calotter-inventory` / `calotter-cooking` / `calotter-health`；各业务模块依赖 `calotter-common`；cooking 依赖 user、inventory。

### 3.1.2 分层与 API 约定

- **分层**：Controller → Service → Repository → Entity（README 与 `docs/backend-architecture-docs/后端架构总览.md`）。
- **统一响应**：所有接口返回 `Result<T>`（`code`、`message`、`data`），定义于 `calotter-common/src/main/java/com/calotter/common/core/Result.java`。
- **全局异常**：`calotter-common/.../exception/GlobalExceptionHandler.java`，处理 `Exception`、`IllegalArgumentException`、`RuntimeException`、`MethodArgumentNotValidException`、`HttpMessageNotReadableException`，统一返回 `Result.error(...)` 与合适 HTTP 状态码。

---

## 3.2 数据库：PostgreSQL 混合模型

**代码依据**：实体类中的 `@JdbcTypeCode(SqlTypes.JSON)` 与 `columnDefinition = "jsonb"`。

- **关系型核心**：User、Household、Ingredient、LeftoverDish、CookingSession、Dish 等表，外键与 JPA 关联明确（如 `CookingSession` 与 `Dish` 的 `@ManyToMany`、`@ManyToOne finalDish`）。
- **JSONB 灵活字段**（仅列实现位置）：
  - **User**（`calotter-user/.../entity/User.java`）：`settings`、`dietaryStyles`、`preferences` 为 `Map` 存 jsonb。
  - **CookingSession**（`calotter-cooking/.../entity/CookingSession.java`）：`requestContext`（AiCookingContext）、`aiResponse`（AiRecipeResponse）存 jsonb，用于 AI 请求/响应快照。
  - **Dish / UserRecipe**（`calotter-cooking/.../entity/Dish.java`、`UserRecipe.java`）：`steps`、`tags`、`ingredientSnapshots` 等为 List 存 jsonb。

**设计意图**（注释与文档）：核心业务保证一致性与外键约束；AI 上下文与用户偏好等需要快速迭代的 schema 用 JSONB，避免频繁改表。

---

## 3.3 后端 AI：Spring AI + 结构化输出

**代码依据**：`calotter-cooking/.../service/ai/SpringAiGeminiMenuGenerationService.java`

- **技术栈**：Spring AI（ChatModel，Google GenAI），依赖在根 POM 中为 `spring-ai-starter-model-google-genai` 1.1.0-M4。
- **调用方式**：
  - 使用 `ChatClient.builder(chatModel).build()`，`.prompt().system(MINIMAL_SYSTEM_PROMPT).user(userInput).call().entity(MenuGenerationFunction.class)`。
  - **未使用** BeanOutputParser 或手写 JSON 解析；直接通过 `.entity(MenuGenerationFunction.class)` 得到类型安全 POJO。
- **输入**：`buildMinimalInput(filter)` 将库存（Urgent/Regular）、DishCount、Servings、Calories、MaxTime、Difficulty、Cookers、Seasonings、Allergies、DietHabits、Avoid、Cuisines、Tastes 等拼成一段结构化文本注入 user message。
- **输出**：`MenuGenerationFunction` 含 `menus` 列表，再通过 `convertToMenuDTO` 转为 `MenuDTO` 返回给前端。

**配置**：`application.yml` 中 Gemini 的 `api-key` 使用 `${GEMINI_API_KEY:}` 注入；`DotenvConfig` 在启动时加载 `.env` 到 Spring Environment（`calotter-start/.../config/DotenvConfig.java`）。

---

## 3.4 前端架构（两套独立能力）

### 3.4.1 边缘 AI：食材识别（独立 Feature）

**代码依据**：`frontend-app/lib/services/ai/yolo_service.dart`、使用处 `frontend-app/lib/features/add_item/pages/add_item_page.dart`

- **实现**：`YoloService` 使用 `flutter_vision` 加载本地 `assets/models/yolo.tflite`（YOLOv8），`labels` 来自 `assets/models/label.txt`；`analyzeImage(imagePath)` 在本地执行推理，返回 `List<Ingredient>`（name、quantity、unit 等）。
- **场景**：在「添加食材」流程中调用（如拍照识别食材），与烹饪中的手势/语音**无直接关系**。
- **隐私/离线**：图像不离设备，无需联网即可识别。

### 3.4.2 烹饪时交互：手势与语音（另一独立 Feature）

**代码依据**：`frontend-app/lib/services/cooking/cooking_gesture_service.dart`、`cooking_voice_assistant.dart`；使用处 `frontend-app/lib/features/recipes/pages/recipe_instruction_page.dart`

- **手势**：`CookingGestureService` 使用 `camera` + `google_mlkit_pose_detection` 做姿态检测，支持 `nextStep`、`previousStep`、`startTimer`、`markDone` 等；内部有 `_cooldownMs = 1200`、`_throttleMs = 100` 做节流与冷却。在 `RecipeInstructionPage` 中另有 **`_gestureCooldown = 1500ms`** 的 UI 层防抖，避免连续误触。
- **语音**：`CookingVoiceAssistant` 使用 `speech_to_text`、`flutter_tts`，支持下一步/上一步、重复、计时、完成步骤等语音指令；在 `RecipeInstructionPage` 中与手势模式可分别开启，用于烹饪过程中的「脏手」操作。
- **场景**：仅在**烹饪步骤页**（`RecipeInstructionPage`）使用，与 YOLO 食材识别是不同功能。

### 3.4.3 状态与路由

- **状态**：当前以 StatefulWidget + setState 为主；存在 `data/stores/`（如 `collected_recipes_store.dart`、`consumption_history_store.dart`）做部分数据持有。
- **路由**：`core/routing/app_router.dart`、`route_names.dart`；底部导航等见 `navigation/`。

---

# Part 4：专业贡献

## 4.1 工程严谨性：统一响应与异常处理

**代码依据**：

- `calotter-common/.../core/Result.java`：泛型 `Result<T>`，`success(data)`、`error(code, message)` 等静态方法，所有 Controller 返回 `Result<...>`。
- `calotter-common/.../exception/GlobalExceptionHandler.java`：`@RestControllerAdvice`，对参数校验失败、JSON 解析错误、非法参数、运行时异常等统一返回 `Result.error(...)`，并设置 `@ResponseStatus`（如 400/500），避免向客户端暴露未处理的 500 与堆栈。

**效果**：前端可依赖固定结构（`code`、`message`、`data`）处理成功与错误，无需在各处写 try-catch 解析不同错误形态。

---

## 4.2 安全：敏感信息不落库、不提交

**代码依据**：

- **API Key 注入**：`application.yml` 中 Gemini/Groq 的 `api-key` 均为 `${GEMINI_API_KEY:}`、`${GROQ_API_KEY:}`；`GroqAiNutritionRecommendationService` 使用 `@Value("${ai.api.groq.api-key:}")`，并在 `afterPropertiesSet` 中若为空则从 `System.getenv("GROQ_API_KEY")` 兜底。
- **.env 加载**：`DotenvConfig` 在应用启动早期查找并解析 `.env` 文件，将键值加入 Spring Environment，供 `@Value` 使用；README 明确写「`.env` 文件不要提交到 Git，使用 `env.template` 作为模板」。
- **env.template**：`backend-calotter/env.template` 提供占位说明，无真实密钥；项目根 `.gitignore` 未显式列出 `backend-calotter/.env`，但文档与约定要求不提交 .env。

**结论**：代码中无硬编码 API Key 或数据库密码；敏感配置通过环境变量与 .env 注入，符合「零信任写码」的实践。

---

## 4.3 API 稳定性：向后兼容（Cooking Flow）

**代码依据**：

- **实体**：`calotter-cooking/.../entity/CookingSession.java` 同时保留 `List<Dish> dishes`（多道菜）与 `Dish finalDish`（单道菜主菜），注释写明「保留用于向后兼容：作为主菜标识」。
- **请求 DTO**：`StartCookingRequest` 除新字段 `recipes`、`menuId` 外，保留 `dishId`、`recipe`（单道菜）以兼容旧前端。
- **业务逻辑**：`CookingWorkflowService.finishCooking` 中先取 `session.getDishes()`，若为 null 或空则回退到 `session.getFinalDish()` 组成单元素列表，注释为「向后兼容：如果没有 dishes，使用 finalDish」。

**结论**：演进 Cooking 能力时保留旧字段与旧行为，避免破坏已有前端调用。

---

## 4.4 输入校验：标准库与 Filter 校验

**代码依据**：`calotter-cooking/.../service/RecipeFilterValidationService.java`

- **职责**：对 `RecipeGenerationFilter`（尤其是 `dietPreferences`）做校验，要求 `cuisinePreferences`、`tastePreferences`、`dietHabits`、`avoidIngredients`、`allergies` 等均来自标准库（`PreferenceStandardLibrary`、`RefAllergen`、`StandardIngredient` 等）。
- **调用位置**：`AiMenuService.generateMenus` 在调用 AI 前执行 `recipeFilterValidationService.validate(filter)`，非法输入直接抛 `IllegalArgumentException`，由 `GlobalExceptionHandler` 转为 400。

**结论**：保证传给 AI 的过滤条件与系统标准数据一致，避免无效或越界值进入下游。

---

## 4.5 应对 AI 输出不确定性：清洗与校验

**代码依据**：

- **营养建议（Groq）**：`calotter-user/.../service/ai/GroqAiNutritionRecommendationService.java`  
  - 从 API 拿到 `content` 后先执行 **`stripMarkdown(content)`**：去掉首尾 ` ```json` / ` ``` `，再 `objectMapper.readTree(content)`。  
  - 解析 JSON 后对 `dailyCalories`、`protein`、`fat`、`carb`、`fiber` 用 **`getIntValue(node, fieldName)`** 取值：对 null、缺失、非整数或字符串数字做安全处理，无法解析则返回 null，不抛异常导致请求直接失败。
- **营养估算（Groq）**：`calotter-health/.../service/ai/GroqManualNutritionEstimator.java`  
  - **`extractJsonObject(text)`**：若文本以 \`\`\` 包裹则去掉围栏，再取第一个 `{` 到最后一个 `}` 的子串得到纯 JSON；否则返回 `"{}"`。  
  - **`decimal(JsonNode node)`**：对缺失、非数字、非法字符串统一返回 `BigDecimal.ZERO`，避免 NPE 或 NumberFormatException。

**结论**：Raw AI 输出 → 正则/字符串清洗（Markdown、围栏）→ JSON 解析 → 字段级校验/默认值，形成可表述的「漏斗」；异常最终由 `GlobalExceptionHandler` 转为结构化错误响应。

---

## 4.6 协作与文档：契约与可追溯

**代码依据**：

- **数据交换格式**：`docs/Personal Chef Data Exchange JSON Format UMS.md` 定义 F/B/A 之间请求与响应的 JSON 结构（含 UMS、IMS、CMS、RMS、HP 等），与当前后端 API 路径、DTO 对齐（已按实际实现更新过）。
- **开发进度与引用**：`docs/开发进度 - Development Progress.md` 将「数据交换格式」作为参考资料链接，体现契约先行。
- **Cooking 变更记录**：`docs/CookingLog/` 下按日期/版本存放 cooking 相关修改说明（如 12.17、12.18、1.5、1.6、1.7、1.12），便于追溯设计决策。
- **用户模块日志**：`calotter-user/user-log/` 下有工作日志与重构说明（如健康目标同步、偏好标准库统一、厨房邀请等），便于前后端对齐行为。

**结论**：通过统一数据格式文档与变更日志，支撑多人在前后端之间的契约优先协作与问题回溯。

---

# Part 5：反思与展望

## 5.1 当前实现的局限（来自代码与 README）

- **JPA 审计**：README 注明「当前使用固定用户 ID（1L），后续需要集成 Spring Security」；审计与多租户隔离仍可加强。
- **.env 与 Git**：README 明确要求不提交 .env、以 env.template 为模板；若部署使用 GitHub Actions 等，密钥应通过 Secrets 注入，与文档一致。
- **手势实现**：除 `CookingGestureService`（姿态检测）外，存在 `CookingGestureControl` 的 stub 实现（仅打印日志、不真正检测），若有多套方案需在文档中说明当前采用哪一套。
- **健康模块与 Cooking**：健康模块通过监听 `CookingSessionCompletedEvent` 或类似机制消费烹饪完成数据（见 `CookingSessionCompletedEventListener`、营养汇总等），模块间依赖与事件契约可在架构文档中更明确。

---

## 5.2 技术债务与可演进方向（基于架构的合理延伸）

以下为根据当前架构可自然延伸的方向，**非当前仓库中已实现的规划文档**：

- **基础设施**：当前为单机 PostgreSQL（如 docker-compose）；可考虑 RDS、只读副本、Redis 缓存等以支撑更大负载与高可用。
- **前端状态**：当前以 setState + 少量 store 为主；若语音/手势与多页状态同步冲突增多，可引入 Riverpod 等做全局状态与生命周期管理。
- **自动化质量**：当前以人工集成测试为主；可增加 CI 中的单元测试与接口测试，在合并或部署前做质量门禁。
- **安全与多租户**：集成 Spring Security、按 userId/householdId 做细粒度权限与数据隔离，替代固定用户 ID 的审计假设。

---

## 5.3 产品与业务延伸（概念层面）

当前代码与文档未显式书写「产品路线图」；从已有能力可归纳的延伸方向包括：

- **智能补货**：基于库存与菜谱需求计算缺口，对接外部采购或清单（需新产品与后端接口）。
- **社区与分享**：若引入用户生成内容、菜谱分享，需在权限、审核与数据模型上扩展；当前实现以家庭与个人为主。
- **零浪费与健康**：已有库存过期提醒、营养记录与目标、剩菜管理；可在此基础上强化「减少浪费」与「健康饮食」的报表与引导。

---

# 附录：关键文件索引

| 主题 | 路径 |
|------|------|
| 统一响应 | `backend-calotter/calotter-common/.../core/Result.java` |
| 全局异常 | `backend-calotter/calotter-common/.../exception/GlobalExceptionHandler.java` |
| JSONB 示例 | `User.java`（settings/dietaryStyles/preferences）、`CookingSession.java`（requestContext/aiResponse）、`Dish.java`（steps/tags/ingredientSnapshots） |
| Spring AI 菜单 | `calotter-cooking/.../service/ai/SpringAiGeminiMenuGenerationService.java` |
| 向后兼容 | `CookingSession.java`（dishes + finalDish）、`CookingWorkflowService.finishCooking`、`StartCookingRequest` |
| AI 清洗/校验 | `GroqAiNutritionRecommendationService`（stripMarkdown、getIntValue）、`GroqManualNutritionEstimator`（extractJsonObject、decimal） |
| 过滤校验 | `RecipeFilterValidationService.java`、`AiMenuService.generateMenus` |
| 环境与密钥 | `application.yml`（${GEMINI_API_KEY} 等）、`DotenvConfig.java`、`env.template`、README |
| 前端 YOLO | `frontend-app/lib/services/ai/yolo_service.dart`、`add_item_page.dart` |
| 烹饪手势/语音 | `cooking_gesture_service.dart`、`cooking_voice_assistant.dart`、`recipe_instruction_page.dart` |
| 数据契约与日志 | `docs/Personal Chef Data Exchange JSON Format UMS.md`、`docs/CookingLog/`、`calotter-user/user-log/` |

---

*本文档仅基于仓库内代码与文档整理，不依赖外部口头描述；答辩或汇报时可据此逐条对照实现。*
