# Personal Sous Chef — 项目说明文档

本文档记录仓库的技术栈、架构实现、主要功能、开发与部署流程，以及已知风险与技术债，便于新成员上手与对外汇报。

---

## 1. 项目定位

智能家庭烹饪助手：围绕家庭厨房提供用户与家庭协作、库存管理、AI 菜单生成、烹饪流程辅助、营养摄入追踪，并叠加语音、手势与视觉（本地 YOLO + 云端视觉）能力。

---

## 2. 仓库结构

| 路径 | 说明 |
|------|------|
| `frontend-app/` | Flutter 移动端应用 |
| `backend-calotter/` | Spring Boot 多模块后端 |
| `yolo-training/` | YOLOv8 训练 / 验证 / 推理脚本（Python） |
| `docker-compose.yml`（根目录） | PostgreSQL 等编排（与后端目录内 compose 可能并存，注意环境一致） |
| `backend-calotter/docker-compose.yml` | 后端配套数据库编排 |
| `.github/workflows/deploy.yml` | CI/CD：构建 JAR、上传、远程启动 |

---

## 3. 技术栈

### 3.1 前端（Flutter）

- **语言 / 框架**：Dart、Flutter（SDK 约束见 `frontend-app/pubspec.yaml`）
- **入口**：`lib/main.dart`，应用根：`lib/app/app.dart`
- **关键依赖（节选）**
  - 网络：`http`
  - 本地存储：`shared_preferences`
  - 相机与 ML：`camera`、`google_mlkit_pose_detection`
  - 语音：`speech_to_text`、`flutter_tts`、`permission_handler`
  - AI：`google_generative_ai`；本地视觉：`packages/flutter_vision`（path 依赖）
- **状态管理**：以 `StatefulWidget` + Service 封装为主，未见统一的全局状态管理框架（如 Riverpod/Bloc）
- **API**：路径常量 `lib/core/constants/api_endpoints.dart`；HTTP 在 `lib/services/api/`，业务封装在 `lib/services/business/`

### 3.2 后端（Spring Boot）

- **运行时**：Java 17，Spring Boot 3.x（父 POM：`backend-calotter/pom.xml`）
- **持久化**：Spring Data JPA + Hibernate；PostgreSQL（驱动版本见 POM）
- **安全**：Spring Security + JWT（`calotter-user` 模块）；详见下文「风险」
- **AI**
  - 菜单生成：Spring AI + Google Gemini
  - 营养估算：Groq API（HTTP 调用）
- **其它**：Lombok、JJWT；调度 `@EnableScheduling`；健康模块异步 `@EnableAsync`

### 3.3 模型训练（Python）

- Ultralytics YOLOv8：`train.py`、`inference.py`、`validate.py`
- 依赖见 `yolo-training` 及后端侧可能存在的 Python 辅助脚本

### 3.4 部署与 CI

- GitHub Actions：Maven 构建 → 产物上传 → SSH 远程 `java -jar` 等方式启动（以 `deploy.yml` 为准）

---

## 4. 架构与实现方法

### 4.1 后端分层与模块

- **分层**：`Controller → Service → Repository → Entity`
- **统一响应**：`calotter-common` 中的 `Result<T>`
- **全局异常**：`GlobalExceptionHandler` 统一 HTTP 与错误体
- **Maven 模块**
  - `calotter-common`：通用能力
  - `calotter-user`：用户、家庭、安全配置
  - `calotter-inventory`：库存与标准库
  - `calotter-cooking`：AI 菜单、烹饪流程
  - `calotter-health`：营养与摄入、异步聚合
  - `calotter-start`：启动与配置装配

### 4.2 典型数据流

1. 前端通过 `Authorization: Bearer ...`（及/或 query 中的 `userId`/`householdId`）调用 REST API。
2. Controller 进入对应模块 Service（多处 `@Transactional`）。
3. JPA 写入 PostgreSQL，返回 `Result<T>`。
4. 营养等场景：提交日志后通过事件 + 异步任务更新聚合统计（见 `NutritionLogEventListener` 等）。

### 4.3 API 风格

- REST，路径按领域划分，例如：`/api/user`、`/api/household`、`/api/inventory`、`/api/ai`、`/api/cooking`、`/api/nutrition`、`/api/intake`。
- 响应体一般为 `{ code, message, data }` 形式。

### 4.4 前端架构要点

- 主导航骨架：`lib/navigation/main_scaffold.dart`
- 认证状态：`lib/services/business/auth_service.dart`（SharedPreferences 存 token / userId / householdId）
- 后端地址：`lib/core/config/api_config.dart`（部署时需按环境修改）

### 4.5 AI 与视觉

- **服务端**：Gemini 生成菜单；Groq 估算营养。
- **客户端**：本地 YOLO（`lib/services/ai/yolo_service.dart`）；云端视觉兜底（`lib/services/ai/cloud_vision_service.dart`）。
- **训练**：`yolo-training/` 独立维护权重与数据集流程。

---

## 5. 主要功能与代码位置

### 5.1 用户与认证

- **后端**：`calotter-user/.../controller/UserController.java`
- **前端**：`lib/features/auth/pages/login_page.dart`、`registration_page.dart`；`lib/services/business/auth_service.dart`

### 5.2 家庭 / 厨房协作

- **后端**：`calotter-user/.../controller/HouseholdController.java`
- **前端**：`lib/features/household/pages/household_manage_page.dart`、`scan_join_household_page.dart`；`lib/services/api/household_api_service.dart`

### 5.3 库存（食材、厨具、调料、剩菜）

- **后端**：`calotter-inventory/.../controller/InventoryController.java`、`.../service/InventoryService.java`
- **前端**：`lib/features/inventory/pages/inventory_page.dart`；`lib/services/api/inventory_api_service.dart`

### 5.4 AI 菜谱与烹饪流程

- **后端**：`AiMenuController.java`、`CookingController.java`、`CookingWorkflowService.java`（均在 `calotter-cooking` 模块）
- **前端**：`lib/features/recipes/pages/recipe_generate_page.dart`、`recipe_instruction_page.dart`；`lib/services/api/recipe_api_service.dart`

### 5.5 营养与摄入

- **后端**：`NutritionController.java`、`IntakeController.java`（`calotter-health`）
- **前端**：`lib/services/api/homepage_api_service.dart` 等

### 5.6 智能交互（语音 / 手势 / 视觉）

- **手势**：`lib/services/cooking/cooking_gesture_service.dart`
- **语音**：`lib/services/cooking/cooking_voice_assistant.dart`
- **YOLO / 云视觉**：`lib/services/ai/yolo_service.dart`、`cloud_vision_service.dart`

---

## 6. 开发与部署流程

### 6.1 后端

- 使用 `backend-calotter/docker-compose.yml`（或根目录 compose）启动 PostgreSQL。
- 在 `calotter-start` 模块：`mvn spring-boot:run` 或整仓 `mvn clean install` 后运行 JAR。
- 主配置：`calotter-start/src/main/resources/application.yml`
- 若使用 `.env`：注意 `DotenvConfig` 等加载逻辑与本地路径。

### 6.2 前端

```bash
cd frontend-app
flutter pub get
flutter run
```

- 将 `api_config.dart` 中的服务地址改为本机或测试服务器 IP/域名。

### 6.3 YOLO 训练与推理

```bash
cd yolo-training
python train.py
python inference.py --source ... --weights ...
python validate.py --weights ...
```

### 6.4 CI/CD

- 分支与 Secrets（如 `DB_PASSWORD`、`GEMINI_API_KEY`、`GROQ_API_KEY`）以 `.github/workflows/deploy.yml` 为准。

---

## 7. 已知风险与技术债（摘要）

### 7.1 高优先级

- **敏感信息**：避免在仓库中保留明文 API Key、数据库密码、JWT 密钥；须迁移至环境变量或密钥管理服务，并轮换已泄露密钥。
- **认证策略**：`SecurityConfig` 若仍为 `permitAll`，则需在网关或过滤器层强制执行 JWT 与资源级授权；避免仅凭 query 传 `userId`/`householdId` 造成越权。
- **审计用户**：`JpaAuditingConfig` 若固定为某用户 ID，生产环境需改为从 SecurityContext 解析。

### 7.2 中优先级

- **多套 compose / 配置**：根目录与 `backend-calotter` 下数据库名、用户可能不一致，团队需约定「单一事实来源」。
- **测试**：后端 `spring-boot-starter-test` 已引入时，建议补齐核心路径的集成测试或切片测试。

### 7.3 低优先级

- **业务 TODO**：烹饪模块中偏好冲突、客人忌口等逻辑仍有待完善。
- **Android 发布配置**：`android/app/build.gradle.kts` 中 applicationId、签名等需按产品化要求填写。

---

## 8. 文档维护

- 重大架构变更（新模块、认证方案、部署环境）请同步更新本文件。
- 若对外演示，可单独拆「3 分钟版 / 10 分钟版」讲稿，本文件作为事实参考。

---

*最后更新：基于仓库当前结构的静态梳理；具体版本号以各 `pom.yaml` / `pubspec.yaml` 为准。*
