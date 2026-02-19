# Calotter Backend - Spring Boot JPA

基于 Spring Boot 3.2.0 和 JPA 的 Personal Sous Chef 后端项目。

## 📋 目录

- [项目架构](#项目架构)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
  - [前置要求](#前置要求)
  - [首次启动（干净环境）](#首次启动干净环境)
  - [日常开发（更新后重建）](#日常开发更新后重建)
- [前后端联通测试](#前后端联通测试)
- [项目结构详解](#项目结构详解)
- [数据库说明](#数据库说明)
- [API 端点](#api-端点)
- [开发建议](#开发建议)

---

## 🏗️ 项目架构

### 模块化设计

项目采用 Maven 多模块架构，遵循领域驱动设计（DDD）原则：

```
backend-calotter/
├── calotter-common/              # 通用模块（被所有模块依赖）
│   ├── 核心实体基类（BaseEntity）
│   ├── 统一响应格式（Result<T>）
│   ├── 异常处理（GlobalExceptionHandler）
│   ├── JPA 审计配置
│   └── 标准库实体（StandardIngredient, StandardSpice, etc.）
│
├── calotter-modules/             # 业务模块聚合层
│   ├── calotter-user/           # 用户模块
│   │   ├── User（用户，含健康数据与饮食偏好）
│   │   ├── Household（家庭组）
│   │   └── HealthGoal（健康目标）
│   │
│   ├── calotter-inventory/      # 库存模块
│   │   ├── Ingredient、HouseholdSpice、HouseholdUtensil、LeftoverDish
│   │   └── InventoryService、LeftoverDishService
│   │
│   ├── calotter-cooking/        # 烹饪模块
│   │   ├── CookingSession、Dish、UserRecipe、HouseholdFavoriteDish
│   │   └── AiMenuService、SpringAiGeminiMenuGenerationService、CookingWorkflowService、FavoriteRecipeService、DishService
│   │
│   └── calotter-health/         # 健康模块
│       ├── NutritionLog、DailyNutrientAggregate
│       └── IntakeController、NutritionController、GroqManualNutritionEstimator、NutritionLogService、NutritionAggregateService
│
└── calotter-start/              # 启动模块（唯一入口）
    ├── CalotterApplication.java
    └── application.yml、DotenvConfig
```

### 模块依赖关系

```
calotter-start
  ├── calotter-common
  ├── calotter-user        → calotter-common
  ├── calotter-inventory   → calotter-common, calotter-user
  ├── calotter-cooking     → calotter-common, calotter-user, calotter-inventory
  └── calotter-health      → calotter-common, calotter-user, calotter-inventory, calotter-cooking
```
（health 通过事件监听 CookingSessionCompletedEvent 与 NutritionLogCreatedEvent 解耦协作。）

### 核心设计模式

1. **分层架构**：Controller → Service → Repository → Entity
2. **统一响应格式**：所有 API 返回 `Result<T>` 格式
3. **JPA 审计**：自动记录创建/更新时间
4. **标准库模式**：所有业务数据关联标准库（如 StandardIngredient）

### 模块化单体：ER 图深度解析与事务一致性

本节对核心表的设计逻辑、第三范式（3NF）满足情况，以及多用户并发修改家庭库存时的事务与数据一致性做硬核拆解。

---

#### 一、核心表设计逻辑（ER 深度解析）

**1. `households`（家庭组）**

| 列名 | 类型 | 约束 | 设计说明 |
|------|------|------|----------|
| id | BIGSERIAL | PK | 代理主键 |
| name | VARCHAR | NOT NULL | 家庭显示名，可重复 |
| invite_code | VARCHAR | NOT NULL UNIQUE | 邀请码，用于加入家庭，全局唯一 |
| owner_id | BIGINT | NOT NULL | 户主用户 ID，逻辑上 FK→users.id，未建物理 FK 以减轻跨表耦合 |
| create_time, update_time, create_by, update_by | 审计 | 继承 BaseEntity | 创建/更新人与时间 |

**设计要点**：家庭是“多用户共享”的聚合根。`owner_id` 表示创建者；成员关系通过关联表维护，避免在 `households` 上存冗余列表。

**2. `users_households`（用户-家庭多对多关联表）**

由 JPA `@JoinTable` 在 `User.joinedHouseholds` 上声明生成：

| 列名 | 类型 | 约束 | 设计说明 |
|------|------|------|----------|
| user_id | BIGINT | NOT NULL, FK→users.id | 用户 ID |
| household_id | BIGINT | NOT NULL, FK→households.id | 家庭 ID |

- **语义**：用户可加入多个家庭，家庭可有多个成员；仅存关联，不存角色/昵称等属性（若未来需要“家庭内昵称”，可加列或拆成独立实体，仍满足 3NF）。
- **3NF**：表内无非主属性对主键的部分依赖或传递依赖；主键为 (user_id, household_id) 的联合主键（或等价唯一约束）。

**3. `users` 中与家庭相关的字段**

| 列名 | 类型 | 设计说明 |
|------|------|----------|
| current_household_id | BIGINT | 当前活跃家庭 ID，会话级上下文；可为空（未选家庭） |

- 不参与“用户属于哪些家庭”的规范存储，仅作为前端/API 的当前上下文，避免在 `users_households` 上重复存储“当前家庭”语义。

**4. `nutrition_logs`（营养日志 / 摄入流水）**

| 列名 | 类型 | 约束 | 设计说明 |
|------|------|------|----------|
| id | BIGSERIAL | PK | 代理主键 |
| user_id | BIGINT | NOT NULL, FK→users.id | 摄入归属用户 |
| log_date | DATE | NOT NULL | 记录日期（冗余，便于按日分区/查询） |
| eaten_at | TIMESTAMP | NOT NULL | 进食时间 |
| meal_type | VARCHAR | 枚举 | BREAKFAST/LUNCH/DINNER/SNACK |
| source_type | VARCHAR | NOT NULL | 来源：APP_COOKING / LEFTOVER / MANUAL / EXTERNAL |
| dish_id | BIGINT | 可空 | 弱引用：LEFTOVER 时为 LeftoverDish.id，APP_COOKING 时为 Dish.id，MANUAL/EXTERNAL 为空 |
| food_name | VARCHAR | NOT NULL | 食物名称快照（便于查询与展示，避免总是 JOIN） |
| quantity, unit | 数值/字符串 | 可空 | 摄入数量与单位 |
| base_energy, base_protein, base_fat, base_carbohydrates, base_fiber | 数值 | 可空 | 基础营养（100% 摄入时的值，来自 Dish/Leftover 快照） |
| energy, protein, fat, carbohydrates, fiber | 数值 | 可空 | 实际摄入营养 = base_* × consumed_percentage / 100 |
| consumed_percentage | DECIMAL(5,2) | NOT NULL, 默认 100 | 消费百分比（0–100），支持“吃了一部分”与后续剩菜转换 |

**设计要点**：

- **流水表**：每行代表一次原子摄入，不存“汇总”，汇总由 `daily_nutrient_aggregates` 承担。
- **弱引用 dish_id**：用单列 + source_type 区分来源，避免 health 模块强依赖 cooking/inventory 的实体表，满足模块边界。
- **快照字段**：`food_name` 与 base_* / energy 等为写入时快照，避免事后 Dish/Leftover 被修改或删除导致历史数据失真，符合审计与报表需求。

**5. `daily_nutrient_aggregates`（日营养聚合）**

| 列名 | 类型 | 约束 | 设计说明 |
|------|------|------|----------|
| id | BIGSERIAL | PK | 代理主键 |
| user_id | BIGINT | NOT NULL, FK→users.id | 用户 |
| date | DATE | NOT NULL | 日期 |
| total_energy, total_protein, total_fat, total_carbohydrates, total_fiber | 数值 | NOT NULL, 默认 0 | 当日汇总 |
| goal_*_snapshot | 数值 | 可空 | 当日目标快照（便于历史达标率回溯） |
| version | INT | NOT NULL, @Version | 乐观锁版本号，防止并发更新覆盖 |

- **唯一约束**：`(user_id, date)` 唯一，保证每人每天一条聚合。
- **数据来源**：由 `NutritionLog` 流水在事务提交后通过 `NutritionLogCreatedEvent` 异步更新，或由 `rebuildDailyAggregate` 按日重算覆盖写入。

**6. `household_ingredients`（家庭食材库存）**

| 列名 | 类型 | 约束 | 设计说明 |
|------|------|------|----------|
| id | BIGSERIAL | PK | 代理主键 |
| household_id | BIGINT | NOT NULL, FK→households.id ON DELETE CASCADE | 所属家庭，删家庭则级联删库存 |
| standard_ingredient_id | BIGINT | NOT NULL, FK→ref_standard_ingredients.id | 标准食材 ID |
| quantity, unit | 数值/VARCHAR | NOT NULL | 数量与单位 |
| expiration_date | DATE | 可空 | 过期日 |
| location | VARCHAR | 可空 | FRIDGE/FREEZER/PANTRY |

- **3NF**：除主键外，所有属性只依赖 household_id + standard_ingredient_id 的语义（同一家庭同一标准食材可有多条记录，若业务约束“每家庭每标准食材一条”可加唯一约束）。

**7. `household_leftovers`（剩菜）**

- `household_id`：FK→households.id ON DELETE CASCADE。
- `original_dish_id`：弱引用 cooking 模块的 Dish.id，避免 inventory 依赖 cooking。
- 其余为菜品与营养的**快照**（dish_name, calories_per_100g, protein_per_100g 等），写入后不再依赖 Dish 表，满足查询与历史一致性。

**8. `cooking_sessions` 与 `cooking_session_dishes`**

- **cooking_sessions**：存 household_id、initiator_id、menu_id、status、request_context（AiCookingContext JSONB）、ai_response（AiRecipeResponse JSONB）、ingredients_snapshot_json、total_nutrition_snapshot_json 等；不直接存“菜单内容”的重复结构化数据，菜单内容由关联的 Dish 与 JSON 快照承载。
- **cooking_session_dishes**：多对多中间表 (session_id, dish_id)，表示一次会话对应多道菜（Dish 为每次“开始烹饪”时生成的快照）。

---

#### 二、为什么能满足第三范式（3NF）

- **1NF**：所有表列均为原子类型（无多值、无重复组）；JSONB 列存整块文档，在“表结构”层面仍视为原子。
- **2NF**：所有表均有主键；`users_households` 等关联表主键为 (user_id, household_id)，无部分依赖。
- **3NF**：业务表不存在“非主属性传递依赖于候选键”的情况：
  - 如 `nutrition_logs`：food_name、base_energy 等依赖的是“本条记录”的写入时快照，不依赖其他非主键列推导；
  - 如 `daily_nutrient_aggregates`：total_* 由应用层从流水汇总计算后写入，不存对其它表的传递依赖；
  - 标准库表（ref_standard_*）与业务表通过 ID 引用，无冗余重复存储。

**刻意冗余**（为查询/一致性而保留）均以“快照”形式存在（如 log_date、food_name、base_energy、goal_*_snapshot），不参与“由其他非主键列推导”的更新，因此不违反 3NF 的语义。

---

#### 三、多用户并发修改家庭库存时的事务与数据一致性

- **事务边界**：所有写操作均在 Service 层方法上使用 `@Transactional`（只读查询为 `@Transactional(readOnly = true)`）。例如：
  - **库存**：`InventoryService.createIngredient`、`updateIngredient`、`deleteIngredient` 等均为单方法一个事务；同一请求内多次写在同一事务中提交。
  - **烹饪**：`CookingWorkflowService.startCooking`、`finishCooking` 各为一个事务；`finishCooking` 内会扣减库存、写 Leftover、更新 Session 等，保证要么全成功要么全回滚。
- **隔离级别**：未显式配置时使用数据库默认（PostgreSQL 为 Read Committed）。读到的都是已提交数据，避免脏读；同一事务内的多次更新对外仍以提交点为准。
- **并发控制**：
  - **库存表**（如 `household_ingredients`）：未使用 `@Version` 或 `SELECT ... FOR UPDATE`；高并发下若两请求同时更新同一条食材（如同时扣减），后提交会覆盖先提交（last-write-wins）。若需“扣减不超卖”，可在业务层对关键扣减使用悲观锁（如 `@Lock(LockModeType.PESSIMISTIC_WRITE)` 按行锁）或乐观锁（为 Ingredient 加 version 列）。
  - **日聚合表**：`DailyNutrientAggregate` 使用 `@Version` 乐观锁；`NutritionAggregateService.updateAggregate` 在提交时若 version 被其他事务更新则会触发乐观锁异常，由调用方（事件监听器）或上层决定重试，从而避免并发更新同一用户同一天的聚合导致汇总错误。
- **事件与异步**：营养流水写入后发布 `NutritionLogCreatedEvent`，监听器在 `@TransactionalEventListener(phase = AFTER_COMMIT)` 且 `@Async` 下异步更新聚合表，保证“先持久化流水，再更新聚合”，避免事务回滚与监听器执行顺序导致的不一致。

---

#### 四、时序图文字化：生成 AI 菜谱全流程（硬核步骤）

以下为 **“客户端请求生成 AI 菜谱”** 的端到端流程（本接口**不写数据库**，仅返回 DTO；落库发生在用户“开始烹饪”时）。

1. **客户端**  
   - Flutter 对 `POST /api/ai/generate-menus` 发起请求，Body 为 `RecipeGenerationFilter`（JSON），Query 可选 `householdId`。

2. **进入 Spring Boot**  
   - 请求先经 Servlet 容器进入 DispatcherServlet；当前未配置 JWT 过滤器，故无“拦截器校验 Token”步骤；若未来加上 JWT Filter，会在此处校验并解析 userId。

3. **Controller 层**  
   - `AiMenuController.generateMenus(@RequestBody RecipeGenerationFilter filter, @RequestParam Long householdId)` 接收请求。  
   - `@Valid` 触发对 `RecipeGenerationFilter` 的 JSR-303 校验（若有注解）；校验失败直接返回 400。  
   - 调用 `aiMenuService.generateMenus(filter, householdId)`，返回 `Result.success(List<MenuDTO>)`。

4. **AiMenuService（编排层）**  
   - 若 `householdId != null`：调用 `enrichFilterFromHousehold(filter, householdId)`：从 `HouseholdRepository`、`IngredientRepository`、`HouseholdSpiceRepository`、`HouseholdUtensilRepository`、`UserRepository`、`HealthGoalRepository` 查询该家庭的库存（紧急/常规）、调料、厨具、成员偏好与健康目标，将结果写入 filter 的 `urgentInventory`、`regularInventory`、`cookers`、`seasonings`、`dietPreferences`、`calorieTarget` 等。  
   - 对 `filter.dietPreferences.allergies` 做规范化：null→[]，["none"]→[]，并移除混合列表中的 "none"。  
   - 调用 `recipeFilterValidationService.validate(filter)`：校验 `cuisinePreferences`、`tastePreferences`、`dietHabits` 是否落在标准库枚举内；`allergies` 是否在 `ref_standard_allergens` 中存在；`avoidIngredients` 是否在标准食材库中存在；不通过则抛 `IllegalArgumentException`，由全局异常处理返回 400。  
   - 调用 `aiMenuGenerationService.generateMenus(filter)`（注入的实现为 `SpringAiGeminiMenuGenerationService`），得到 `List<MenuDTO>`，原样返回。

5. **SpringAiGeminiMenuGenerationService（AI 与映射层）**  
   - **构建 Prompt**：`buildMinimalInput(filter)` 将 filter 序列化为一段结构化文本（Context: Urgent/Regular 库存、DishCount、Servings、Calories、MaxTime、Difficulty、Cookers、Seasonings、Allergies、DietHabits、Avoid、Cuisines、Tastes），作为 user message；system prompt 为固定短文案（角色、规则、JSON only、饮食限制优先等）。  
   - **调用 Gemini**：`ChatClient.builder(chatModel).build().prompt().system(...).user(userInput).call().entity(MenuGenerationFunction.class)`。  
     - Spring AI 将 user + system 发给 Gemini API；  
     - 使用 **Function Calling / 结构化输出**：返回的 JSON 由 Spring AI 反序列化为 `MenuGenerationFunction`（含 `List<MenuOption>`，每个含 `menuId`、`List<RecipeOption>`；RecipeOption 含 title、shortDescription、servings、cookingTimeMin、difficulty、category、nutritionEstimate、ingredients、steps）。  
   - **Response Cleaner/Parser**：无单独组件；**精准映射**即 Spring AI 的 `.entity(MenuGenerationFunction.class)` + Jackson 根据 DTO 的 `@JsonProperty` 等完成反序列化；若模型返回缺字段或格式异常，此处会抛异常。  
   - **转为 DTO**：`functionResult.getMenus().stream().map(this::convertToMenuDTO).collect(toList())`：每个 `MenuOption` → `MenuDTO`（含 menuId、recipes）；每个 `RecipeOption` → `MenuDTO.RecipeDTO`（title、shortDescription、servings、cookingTimeMin、difficulty、category、nutritionEstimate、ingredients、steps），字段一一映射。  
   - 若 `functionResult == null` 或 menus 为空，抛 `RuntimeException("Empty result from AI")`。

6. **返回响应**  
   - Controller 将 `Result.success(List<MenuDTO>)` 序列化为 JSON，经 DispatcherServlet 写回客户端；**此路径不写入数据库**。

7. **后续落库流程（用户点击“开始烹饪”时）**  
   - 客户端再调 `POST /api/cooking/start`（或等价端点），Body 含 `householdId`、`initiatorId`、`menuId`、`recipes`（即上一步返回的 `MenuDTO.RecipeDTO` 列表）。  
   - `CookingWorkflowService.startCooking` 在一个事务内：创建 `CookingSession`（status=PENDING），对每个 `RecipeDTO` 调用 `FavoriteRecipeService.createDishSnapshot` 生成 `Dish` 并关联到 Session，最后 `sessionRepository.save(session)`；此时才写入 `cooking_sessions`、`dishes`、`cooking_session_dishes`。  
   - 之后用户“完成烹饪”时，`finishCooking` 会更新 Session 状态、写快照、扣减库存、创建 Leftover、并发布 `CookingSessionCompletedEvent`，由 health 模块监听并创建 `NutritionLog`，再触发日聚合更新。

以上即从“客户端发请求”到“Spring AI 构建 Prompt → 调用 Gemini → JSON 结构化映射 → 返回 DTO”的完整文字化时序；落库与事件链在“开始烹饪 / 完成烹饪”流程中完成。

#### 五、代码级实现细节（Flutter 手势与 TFLite 预处理）

以下为答辩/文档可引用的具体代码位置与公式，便于说明“如何从 Pose 拿右手腕坐标”“如何算 Δx/Δy 与速度”“Android 端如何做裁剪/缩放与 x/255 归一化”。

---

**（1）Flutter 端：手势识别算法（右手腕坐标、Δx/Δy、速度判定）**

- **依赖与入口**：`frontend-app/lib/services/cooking/cooking_gesture_service.dart`，使用 `google_mlkit_pose_detection` 的 `PoseDetector`（stream 模式、base 模型），相机帧经 `_processCameraImage` 转为 `InputImage` 后调用 `_poseDetector!.processImage(inputImage)` 得到 `List<Pose>`。

- **获取右手腕坐标**：取第一帧人体 `poses.first`，再通过枚举取右手腕关键点：
  ```dart
  final pose = poses.first;
  final wrist = pose.landmarks[PoseLandmarkType.rightWrist];
  if (wrist != null && wrist.likelihood > 0.5) {
    _analyzeTrend(wrist.x, wrist.y);  // x, y 为 ML Kit 返回的该关键点坐标
  }
  ```
  代码位置：`cooking_gesture_service.dart` 约 139–147 行。`wrist.x`、`wrist.y` 为 ML Kit 返回的该关键点坐标，`likelihood` 为置信度，仅当 > 0.5 才参与趋势分析。

- **滑动缓冲区与采样**：使用定长缓冲区 `_movementBuffer`（长度 `_bufferSize = 5`），每帧在满足节流（`_throttleMs = 100` ms）且通过置信度校验时，将当前时间戳与点坐标入队，超出长度则丢弃最旧一项：
  ```dart
  final now = DateTime.now().millisecondsSinceEpoch;
  _movementBuffer.add(MapEntry(now, Point(currentX, currentY)));
  if (_movementBuffer.length > _bufferSize) _movementBuffer.removeAt(0);
  ```
  代码位置：约 157–165 行。

- **Δx、Δy 与时间差**：用缓冲区首尾两点计算净位移与时间差（单位：毫秒）：
  - 设首项为 (startT, start)，尾项为 (endT, end)，则：
  - **公式**：  
    Δx = end.x − start.x  
    Δy = end.y − start.y  
    Δt = endT − startT（ms）
  - 代码：`diffX = end.x - start.x`，`diffY = end.y - start.y`，`timeDiff = endT - startT`（约 168–178 行）。

- **速度（Velocity）与方向判定**：速度取“位移绝对值 / 时间差”，用于过滤微小抖动；方向由 Δx、Δy 符号与主轴决定。
  - **水平速度**：v_x = |Δx| / Δt（当 Δt > 0，否则为 0），单位：坐标单位/ms。
  - **垂直速度**：v_y = |Δy| / Δt。
  - 代码：水平方向 `velocityX = timeDiff > 0 ? diffX.abs() / timeDiff : 0.0`（约 193 行）；垂直同理（约 209 行）。
  - **最小位移与最小速度**：`_minDistanceX = 20`，`_minDistanceY = 20`，`_minVelocity = 0.25`。水平手势触发条件：`diffX.abs() > _minDistanceX && velocityX > _minVelocity`；垂直同理。
  - **方向主导性**：防止斜向误判，要求主轴明显大于副轴，例如水平：`isHorizontal = diffX.abs() > diffY.abs() * 1.2`；垂直：`isVertical = diffY.abs() > diffX.abs() * 1.2`（约 187–189 行）。再根据 diffX / diffY 正负判定右/左/上/下，映射到 `GestureType.nextStep`、`previousStep`、`startTimer`、`markDone`（约 199–224 行）。

**伪代码汇总（手势判定核心）**：
```
FUNCTION analyzeTrend(currentX, currentY):
  APPEND (now_ms, (currentX, currentY)) to buffer
  IF buffer.length < 3 THEN RETURN
  (startT, start) := buffer.first
  (endT, end) := buffer.last
  Δx := end.x - start.x
  Δy := end.y - start.y
  Δt := endT - startT   // ms
  IF Δt <= 0 THEN velocity := 0 ELSE velocity := (used axis displacement) / Δt
  IF |Δx| > 20 AND |Δx| > |Δy|*1.2 AND velocity > 0.25:
    IF Δx > 0 THEN emit nextStep ELSE emit previousStep
  IF |Δy| > 20 AND |Δy| > |Δx|*1.2 AND velocity > 0.25:
    IF Δy < 0 THEN emit startTimer ELSE emit markDone
```

---

**（2）TFLite 预处理管道（Android 原生层：裁剪/缩放、x/255 归一化）**

- **调用链**：Flutter 通过 `flutter_vision` 调用 Android 的 `yoloOnFrame` / `yoloOnImage`，在 `FlutterVisionPlugin` 的 `DetectionTask.run()` 中（`packages/flutter_vision/android/.../FlutterVisionPlugin.java` 约 259–276 行）完成：① 将输入转为 Bitmap；② 取模型输入尺寸；③ 调用 `utils.feedInputTensor(..., 0, 255)` 得到 ByteBuffer；④ 送入 YOLO 推理。

- **步骤 1：原始图 → Bitmap（含旋转，无裁剪）**  
  - **相机流**：`bitmap = utils.feedInputToBitmap(context, frame, image_height, image_width, 90)`（约 266 行）。  
  - **feedInputToBitmap**（`utils.java` 约 323–344 行）：将 Flutter 传来的 YUV 三平面 `bytesList` 按 NV21 顺序拼接（Y + V + U），用 `RenderScriptHelper.getBitmapFromNV21` 转为 RGBA Bitmap；再用 `Matrix.postRotate(rotation)`（此处 90°）做旋正，**此处不做裁剪或缩放**，仅得到与相机分辨率一致的 Bitmap。  
  - **单张图**：`bitmap = BitmapFactory.decodeByteArray(image, 0, image.length)`，无旋转。

- **步骤 2：模型输入尺寸**  
  - `int[] shape = yolo.getInputTensor().shape()`，通常为 `[1, H, W, C]`；`input_height = shape[1]`，`input_width = shape[2]`（约 268–270 行）。

- **步骤 3：缩放/裁剪 + 归一化（feedInputTensor）**  
  - 调用：`utils.feedInputTensor(bitmap, shape[1], shape[2], src_width, src_height, 0, 255)`（约 272 行），即 `mean = 0`，`std = 255`。  
  - **utils.feedInputTensor**（`utils.java` 约 294–322 行）：根据源图与目标尺寸选择分支：
    - 若 `src_width > input_width || src_height > input_height` → **downsize**：双线性缩放至 `(input_height, input_width)`。  
    - 否则 → **upsize**：用中心裁剪或 pad 至 `(input_height, input_width)`。  
  - 实际缩放/裁剪与归一化在 `FeedInputTensorHelper.getBytebufferFromBitmap` 中完成（`FeedInputTensorHelper.java` 约 53–70 行）。

- **步骤 4：downsize 管道（双线性缩放 + x/255）**  
  - `FeedInputTensorHelper` 的 **downSizeImageProcessor**（约 25–33 行）由两条链组成：
    1. **ResizeOp(height, width, ResizeMethod.BILINEAR)**：将 Bitmap 双线性缩放到 `(height, width)`（即模型的 `shape[1]`、`shape[2]`），**不做中心裁剪**，整图缩放到目标尺寸。  
    2. **NormalizeOp(mean, std)**：逐像素做线性变换，公式为 **output = (input - mean) / std**；此处 mean=0、std=255，即 **output = input / 255**（x/255 归一化到 [0,1] 量级）。  
  - 代码：`tensorImage.load(bitmap)` 后 `downSizeImageProcessor.process(tensorImage)` 返回 `TensorImage`，再 `getBuffer()` 得到 ByteBuffer 送入 Interpreter。

- **步骤 5：upsize 管道（中心裁剪或 Pad + x/255）**  
  - **upSizeImageProcessor**（约 34–39 行）：
    1. **ResizeWithCropOrPadOp(height, width)**：若图小于目标则 pad（默认黑边），若大于则中心裁剪到 `(height, width)`，**不做缩放**，仅裁剪或填充到固定尺寸。  
    2. **NormalizeOp(0, 255)**：同样 **output = input / 255**。

- **小结（公式与顺序）**  
  - **downsize**：Bitmap → 双线性 Resize 到 (H, W) → 归一化 y = x/255 → ByteBuffer。  
  - **upsize**：Bitmap → 中心 CropOrPad 到 (H, W) → 归一化 y = x/255 → ByteBuffer。  
  - 归一化统一为 **y = (x − 0) / 255 = x/255**，与 YOLO 常见 [0,1] 输入一致。

---

## 🛠️ 技术栈

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**（Hibernate）
- **PostgreSQL 15**
- **Docker & Docker Compose**（数据库）
- **Maven 3.6+**
- **Lombok**
- **JWT**（用户认证）
- **Spring AI**（Gemini API）
- **Groq API**（AI 菜单生成）

---

## 🚀 快速开始

### 前置要求

- **Java 17+**（推荐使用 JDK 17）
- **Maven 3.6+**
- **Docker & Docker Compose**（用于启动 PostgreSQL）
- **Python 3.x**（可选，用于运行初始化脚本）

### 首次启动（干净环境）

#### 步骤 1: 启动 PostgreSQL 数据库

```bash
# 进入项目根目录
cd backend-calotter

# 启动 PostgreSQL 容器
docker-compose up -d

# 验证数据库是否启动成功
docker ps | grep calotter_postgres
```

数据库配置（已在 `docker-compose.yml` 中配置）：
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `calotter`
- **Username**: `postgres`
- **Password**: `123`

#### 步骤 2: 配置环境变量（可选）

如果需要使用 AI 功能（菜单生成、营养估算），需要配置 API Keys：
   
   ```bash
   # 复制环境变量模板
   cp env.template .env
   
   # 编辑 .env 文件，填入你的 API Keys
# 至少需要配置以下之一：
# - GEMINI_API_KEY（用于 Spring AI Gemini）
# - GROQ_API_KEY（用于 Groq API）
```

`.env` 文件示例：
```bash
GEMINI_API_KEY=your_gemini_api_key_here
GROQ_API_KEY=your_groq_api_key_here
```

> **注意**：Spring Boot 会自动加载 `.env` 文件，无需手动设置环境变量。

#### 步骤 3: 建表并填充标准库（首次启动 Spring Boot）

**重要**：删库后只需启动一次 Spring Boot 即可自动完成建表和标准库填充，无需单独运行初始化脚本。

- **JPA**（`ddl-auto: update`）：启动时自动创建/更新所有表结构。
- **DataSqlRunner**：在 Hibernate 建表完成后自动执行 `calotter-start/src/main/resources/data.sql`，插入标准库数据（过敏原、食材、调料、厨具）。

```bash
# 进入启动模块
cd calotter-start

# 启动 Spring Boot 应用（自动建表 + 自动执行 data.sql 填充标准库）
mvn spring-boot:run

# 等待看到 "Started CalotterApplication" 后，可按 Ctrl+C 停止，或保持运行
```

**标准库内容**（由 data.sql 填充）：
- 标准过敏原库（10 条）、标准食材库（154 条，YOLO 83 + 欧美扩展；别名如 Zucchini 已删，仅保留 Courgette）、标准调料库（40 条）、标准厨具库（34 条）

**若需在不启动应用时单独执行 data.sql**：`python run_init_sql.py` 或 `psql -h localhost -U postgres -d calotter -f calotter-start/src/main/resources/data.sql`（需先由 JPA 建表，否则会报错）。

#### 步骤 4: 编译项目

```bash
# 在项目根目录执行
mvn clean install

# 如果遇到依赖下载问题，可以跳过测试
mvn clean install -DskipTests
```

#### 步骤 5: 启动后端应用（若步骤 3 未停止可跳过）

```bash
# 进入启动模块
cd calotter-start

# 启动 Spring Boot 应用
mvn spring-boot:run

# 或者使用 IDE 直接运行 CalotterApplication.java
```

启动成功后，你应该看到：
```
Started CalotterApplication in X.XXX seconds
```

应用默认运行在：**http://localhost:8080**

#### 步骤 6: 验证启动成功

```bash
# 测试健康检查端点（如果存在）
curl http://localhost:8080/actuator/health

# 或者测试用户注册端点
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

### 日常开发（更新后重建）

每次代码更新后，建议执行以下步骤确保数据库和代码同步：

#### 快速重建流程

```bash
# 1. 停止后端应用（如果正在运行）
# 在运行应用的终端按 Ctrl+C

# 2. 删除并重建数据库（⚠️ 会删除所有数据）
docker-compose down -v          # 删除容器和数据卷
docker-compose up -d            # 重新创建容器

# 3. 等待数据库启动（约 5 秒）
# Windows PowerShell: Start-Sleep -Seconds 5
# Linux/Mac: sleep 5

# 4. 建表并填充标准库（启动一次 Spring Boot 即可，DataSqlRunner 会自动执行 data.sql）
cd calotter-start
mvn spring-boot:run
# 等待看到 "Started CalotterApplication" 后，按 Ctrl+C 停止（或保持运行）

# 5. 重新编译并启动（若步骤 4 已停止）
cd ..
mvn clean install
cd calotter-start
mvn spring-boot:run
```

#### 仅删除数据（保留表结构）

如果只想清空数据但保留表结构：

   ```sql
-- 连接到数据库
docker exec -it calotter_postgres psql -U postgres -d calotter

-- 执行清空脚本（在 psql 中，CASCADE 会处理外键依赖）
TRUNCATE TABLE nutrition_logs, daily_nutrient_aggregates, cooking_session_dishes, cooking_sessions, dishes, user_recipes, household_favorite_dishes, household_ingredients, household_spices, household_utensils, household_leftovers, health_goals, users_households, user_allergies, households, users CASCADE;

-- 退出 psql 后，在项目根目录重新初始化标准库（二选一）：
-- python run_init_sql.py
-- 或: psql -h localhost -U postgres -d calotter -f calotter-start/src/main/resources/data.sql
```

或使用 Python 脚本（在项目根目录）：

```python
# 创建临时脚本 clear_data.py
import psycopg2

conn = psycopg2.connect(
    host='localhost',
    port=5432,
    database='calotter',
    user='postgres',
    password='123'
)
conn.autocommit = True
cursor = conn.cursor()

# 清空所有业务数据表（顺序需满足外键依赖：先子表后父表）
tables = [
    'nutrition_logs',
    'daily_nutrient_aggregates',
    'cooking_session_dishes',
    'cooking_sessions',
    'dishes',
    'user_recipes',
    'household_favorite_dishes',
    'household_ingredients',
    'household_spices',
    'household_utensils',
    'household_leftovers',
    'health_goals',
    'users_households',
    'user_allergies',
    'households',
    'users'
]

for table in tables:
    cursor.execute(f'TRUNCATE TABLE {table} CASCADE;')
    print(f'✅ Cleared {table}')

cursor.close()
conn.close()
```

---

## 🔗 前后端联通测试

### 前置准备

1. **后端已启动**：确保后端运行在 `http://localhost:8080`
2. **前端已启动**：确保 Flutter 前端已运行
3. **配置前端 API 地址**：编辑 `frontend-app/lib/core/config/api_config.dart`

```dart
// 模拟器使用
static const String serverIp = "10.0.2.2";

// 真机使用（替换为你的电脑 IP）
static const String serverIp = "192.168.1.100";  // 你的局域网 IP
```

### 测试步骤

#### 1. 测试用户注册

**后端端点**：`POST /api/user/register`

**使用 curl**：
```bash
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "message": "Registration successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1,
    "householdId": 1
  }
}
```

**前端测试**：
- 打开 Flutter 应用
- 进入注册页面
- 填写注册信息并提交
- 检查是否成功跳转到主页

#### 2. 测试用户登录

**后端端点**：`POST /api/user/login`

```bash
curl -X POST http://localhost:8080/api/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

#### 3. 测试获取标准食材库

**后端端点**：`GET /api/inventory/standard-ingredients`

```bash
# 需要先获取 token（从注册/登录响应中）
TOKEN="your_jwt_token_here"

curl -X GET http://localhost:8080/api/inventory/standard-ingredients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**前端测试**：
- 登录后进入库存页面
- 点击添加食材
- 检查标准食材列表是否正常加载

#### 4. 测试添加食材

**后端端点**：`POST /api/inventory/ingredients`

```bash
curl -X POST http://localhost:8080/api/inventory/ingredients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardIngredientId": 1001,
    "quantity": 5.0,
    "unit": "pcs",
    "expirationDate": "2024-12-31",
    "location": "FRIDGE"
  }'
```

#### 5. 测试 AI 菜单生成

**后端端点**：`POST /api/ai/generate-menus?householdId=1`

```bash
curl -X POST "http://localhost:8080/api/ai/generate-menus?householdId=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "urgentInventory": [],
    "regularInventory": [],
    "servings": 2,
    "dietPreferences": { "allergies": [], "dietHabits": [], "avoidIngredients": [], "cuisinePreferences": [], "tastePreferences": [] },
    "generationSettings": { "dishCount": 1, "maxCookingTimeMin": 30, "difficultyTarget": "easy" }
  }'
```

> **注意**：需配置 GEMINI_API_KEY（Spring AI 菜单生成）或 GROQ_API_KEY（营养估算）

### 常见问题排查

#### 问题 1: 前端无法连接后端

**症状**：前端显示网络错误或超时

**排查步骤**：
1. 检查后端是否运行：`curl http://localhost:8080/actuator/health`
2. 检查前端 API 配置：`frontend-app/lib/core/config/api_config.dart`
3. 真机测试时，确保手机和电脑在同一局域网
4. 检查防火墙是否阻止了 8080 端口

#### 问题 2: 数据库连接失败

**症状**：后端启动时报错 `Connection refused` 或 `Authentication failed`

**排查步骤**：
1. 检查 PostgreSQL 容器是否运行：`docker ps | grep postgres`
2. 检查数据库配置：`calotter-start/src/main/resources/application.yml`
3. 验证数据库连接：
   ```bash
   docker exec -it calotter_postgres psql -U postgres -d calotter
   ```

#### 问题 3: 标准库数据缺失

**症状**：前端无法加载标准食材列表

**排查步骤**：
1. 检查标准库数据：
   ```sql
   SELECT COUNT(*) FROM ref_standard_ingredients;
   ```
2. 如果数据为空，重新运行初始化脚本：
   ```bash
   python run_init_sql.py
   ```

---

## 📁 项目结构详解

### calotter-common（通用模块）

**职责**：提供所有模块共享的基础功能

**核心组件**：
- `BaseEntity`：所有实体的基类，包含审计字段
- `Result<T>`：统一 API 响应格式
- `GlobalExceptionHandler`：全局异常处理
- `StandardIngredient`、`StandardSpice` 等标准库实体

### calotter-user（用户模块）

**职责**：用户、家庭、健康目标管理（User 直接代表个人，含健康数据与饮食偏好）

**核心实体**（代码路径 `calotter-modules/calotter-user/.../domain/entity/`）：
- `User`：用户账户（含 dietaryStyles、preferences JSONB，allergies 多对多）
- `Household`：家庭组（多用户通过 users_households 关联）
- `HealthGoal`：健康目标

**关键服务**：`UserController`、`HouseholdController`、`UserService`、`HouseholdService`、`JwtService`

### calotter-inventory（库存模块）

**职责**：食材、厨具、调料、剩菜管理

**核心实体**：
- `Ingredient`：食材库存（关联 StandardIngredient）
- `HouseholdUtensil`：厨具（关联 StandardUtensil）
- `HouseholdSpice`：调料（关联 StandardSpice）
- `LeftoverDish`：剩菜

**关键特性**：
- 单位验证（primary_unit, secondary_unit, conversion_factor）
- 过期提醒
- 库存扣减（烹饪时）

### calotter-cooking（烹饪模块）

**职责**：AI 菜单生成、烹饪会话与菜谱收藏

**核心实体**（`calotter-modules/calotter-cooking/.../domain/entity/`）：
- `CookingSession`：烹饪会话（含 requestContext、aiResponse JSONB，多对多 dishes）
- `Dish`：单次烹饪菜品快照
- `UserRecipe`：收藏菜谱
- `HouseholdFavoriteDish`：家庭收藏菜品关联

**关键服务**：`AiMenuController`（/api/ai）、`CookingController`（/api/cooking）、`FavoriteController`（/api/recipes）；`AiMenuService`、`SpringAiGeminiMenuGenerationService`、`CookingWorkflowService`、`FavoriteRecipeService`、`DishService`、`RecipeFilterValidationService`

### calotter-health（健康模块）

**职责**：营养摄入流水、日聚合、手动/剩菜摄入

**核心实体**（`calotter-modules/calotter-health/.../domain/entity/`）：
- `NutritionLog`：营养日志（来源 LEFTOVER/MANUAL/APP_COOKING/EXTERNAL）
- `DailyNutrientAggregate`：日营养聚合（@Version 乐观锁）

**关键服务**：`IntakeController`（/api/intake）、`NutritionController`（/api/nutrition）；`IntakeServiceImpl`、`NutritionLogService`、`NutritionAggregateService`、`GroqManualNutritionEstimator`；事件监听 `CookingSessionCompletedEventListener`、`NutritionLogEventListener`

### calotter-start（启动模块）

**职责**：应用入口、配置管理

**核心文件**：
- `CalotterApplication.java`：Spring Boot 启动类
- `application.yml`：应用配置
- `DotenvConfig.java`：.env 文件加载

---

## 🗄️ 数据库说明

### 数据库初始化（删库后可自动建表 + 自动填充）

- **JPA**（`ddl-auto: update`）：启动时自动创建/更新所有表结构  
- **DataSqlRunner**：在 Hibernate 建表完成后自动执行 `data.sql`，插入标准库数据  

因此**删库后只需启动一次 Spring Boot**，即可自动完成建表和标准库填充，无需单独运行初始化脚本。

**若需仅手动执行 data.sql**（不启动应用）：`python run_init_sql.py` 或 `psql -f calotter-start/src/main/resources/data.sql`。

### 主要表结构

#### 标准库表（只读，由 data.sql 初始化）
- `ref_standard_allergens`：标准过敏原库（10 条）
- `ref_standard_ingredients`：标准食材库（154 条，YOLO 83 + 欧美扩展；别名已删，仅保留一种称呼如 Courgette）
- `ref_standard_spices`：标准调料库（40 条）
- `ref_standard_utensils`：标准厨具库（34 条）

#### 业务表（由 JPA 自动创建）
- `users`、`user_allergies`、`users_households`：用户与家庭多对多
- `households`：家庭组
- `health_goals`：健康目标
- `household_ingredients`、`household_spices`、`household_utensils`、`household_leftovers`：库存与剩菜
- `cooking_sessions`、`cooking_session_dishes`、`dishes`、`user_recipes`、`household_favorite_dishes`：烹饪与收藏
- `nutrition_logs`、`daily_nutrient_aggregates`：营养流水与日聚合

### 单位系统

所有食材支持**双单位系统**：

- `primary_unit`：主单位（如 `pcs`, `g`, `ml`）
- `secondary_unit`：次单位（如 `g`, `kg`, `L`）
- `unit_conversion_factor`：转换系数（1 primary_unit = unit_conversion_factor secondary_unit）
- `standard_unit`：标准单位（`g` 或 `ml`），用于营养计算

**示例**：
- Apple: `primary_unit='pcs'`, `secondary_unit='g'`, `conversion_factor=150.0` (1 pcs = 150 g)
- Beef: `primary_unit='g'`, `secondary_unit='kg'`, `conversion_factor=0.001` (1 g = 0.001 kg)
- Milk: `primary_unit='ml'`, `secondary_unit='L'`, `conversion_factor=0.001` (1 ml = 0.001 L)

---

## 🔌 API 端点

（以下按当前代码中 Controller 的 `@RequestMapping` + 方法映射整理。）

### 用户模块 `/api/user`（兼 `/api/ums/user`）

- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `POST /api/user/logout` - 登出
- `GET /api/user` - 获取当前用户
- `PUT /api/user` - 更新用户
- `GET /api/user/preferences`、`PUT /api/user/preferences`
- `GET /api/user/diet-habits`、`PUT /api/user/diet-habits`
- `GET /api/user/allergies`、`PUT /api/user/allergies`
- `GET /api/user/standard-allergens`、`GET /api/user/standard-allergens/search`
- `GET /api/user/standard-diet-habits`、`GET /api/user/standard-diet-habits/search`
- `GET /api/user/standard-avoid-ingredients/search`
- `GET /api/user/preferences-map`、`PUT /api/user/preferences-map`
- `POST /api/user/health-goal` - 创建/更新健康目标
- `GET /api/user/health-info` - 获取健康信息

### 家庭模块 `/api/household`

- `POST /api/household`、`PUT /api/household/{id}`、`GET /api/household/{id}`、`DELETE /api/household/{id}`
- `GET /api/household/invite/{inviteCode}`、`GET /api/household/owner/{ownerId}`、`GET /api/household/current`
- `POST /api/household/{householdId}/invite`、`POST /api/household/join`、`DELETE /api/household/{householdId}/leave`
- `DELETE /api/household/{householdId}/members/{memberId}`、`PUT /api/household/{householdId}/switch`
- `GET /api/household/user/{userId}/joined`、`PUT /api/household/{householdId}/regenerate-invite-code`

### 库存模块 `/api/inventory`

- 食材：`POST /api/inventory/ingredients`、`PUT /api/inventory/ingredients/{id}`、`GET /api/inventory/ingredients/{id}`、`GET /api/inventory/ingredients`、`DELETE /api/inventory/ingredients/{id}`、`POST /api/inventory/ingredients/{id}/deduct`
- 标准库：`GET /api/inventory/standard-ingredients`、`GET /api/inventory/standard-utensils`、`GET /api/inventory/standard-spices`、`GET /api/inventory/standard-ingredients/search`、`GET /api/inventory/standard-ingredients/{id}/allowed-units`
- 调料：`POST /api/inventory/spices`、`PUT /api/inventory/spices/{id}`、`GET /api/inventory/spices/{id}`、`GET /api/inventory/spices`、`DELETE /api/inventory/spices/{id}`
- 厨具：`POST /api/inventory/utensils`、`PUT /api/inventory/utensils/{id}`、`GET /api/inventory/utensils/{id}`、`GET /api/inventory/utensils`、`DELETE /api/inventory/utensils/{id}`
- 剩菜：`POST /api/inventory/leftovers`、`PUT /api/inventory/leftovers/{id}`、`GET /api/inventory/leftovers/{id}`、`GET /api/inventory/leftovers`、`DELETE /api/inventory/leftovers/{id}`

### AI 与烹饪 `/api/ai`、`/api/cooking`、`/api/recipes`

- `POST /api/ai/generate-menus` - 生成 AI 菜单（Query: householdId 可选）
- `POST /api/cooking/start`、`POST /api/cooking/finish`
- `POST /api/recipes/favorite`、`GET /api/recipes/favorites`、`GET /api/recipes/default-filter`

### 营养与摄入 `/api/nutrition`、`/api/intake`

- `GET /api/nutrition/targets/weekly`、`GET /api/nutrition/summary`、`GET /api/nutrition/summary/daily`、`GET /api/nutrition/targets/daily`
- `POST /api/nutrition/log/manual`、`POST /api/nutrition/log/leftover`
- `GET /api/intake/today`、`POST /api/intake/manual`、`DELETE /api/intake/{intake_id}`
- `GET /api/intake/dish/options`、`POST /api/intake/dish`

---

## 💡 开发建议

### 1. 数据库管理

- **开发环境**：使用 `ddl-auto: update` 自动更新表结构
- **生产环境**：建议使用 Flyway 或 Liquibase 进行版本管理
- **数据迁移**：修改实体类后，JPA 会自动更新表结构

### 2. 模块开发

- **新增实体**：继承 `BaseEntity` 以自动获得审计字段
- **API 响应**：统一使用 `Result<T>` 格式
- **异常处理**：抛出业务异常，由 `GlobalExceptionHandler` 统一处理

### 3. 标准库更新

- **添加新食材**：编辑 `calotter-start/src/main/resources/data.sql`
- **对齐 YOLO 模型**：确保标准食材库与 `frontend-app/lib/core/config/yolo_labels_config.dart`、`ingredient_icon_config.dart` 中的标签/图标一致

### 4. 测试

- **单元测试**：每个模块都有对应的测试类
- **集成测试**：在 `calotter-start/src/test` 中
- **API 测试**：使用 curl 或 Postman

### 5. 代码规范

- 使用 Lombok 减少样板代码
- 遵循 RESTful API 设计规范
- 使用有意义的变量和方法名
- 添加必要的注释（特别是业务逻辑）

---

## 📝 注意事项

1. **JPA Auditing**：当前使用固定用户 ID（1L），后续需要集成 Spring Security
2. **JSONB 字段**：`User.settings`、`User.dietaryStyles`、`User.preferences` 等使用 PostgreSQL JSONB 类型
3. **级联删除**：`Household` 删除时会级联删除所有关联的库存数据
4. **模块依赖**：注意模块间的依赖关系，避免循环依赖
5. **环境变量**：`.env` 文件不要提交到 Git，使用 `env.template` 作为模板

---

## 🆘 故障排除

### 常见错误

1. **端口被占用**：修改 `application.yml` 中的 `server.port`
2. **数据库连接失败**：检查 Docker 容器是否运行，密码是否正确
3. **编译失败**：运行 `mvn clean install -U` 更新依赖
4. **AI API 调用失败**：检查 `.env` 文件中的 API Key 是否正确

### 获取帮助

- 查看日志：`calotter-start` 目录下的日志文件
- 检查数据库：`docker exec -it calotter_postgres psql -U postgres -d calotter`
- 查看 Spring Boot 启动日志中的错误信息

---

## 📚 相关文档

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Spring Data JPA 文档](https://spring.io/projects/spring-data-jpa)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)

---

**最后更新**：基于当前代码库（README 与 API/表结构以代码为准）
