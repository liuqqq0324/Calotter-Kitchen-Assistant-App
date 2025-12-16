# calotter-cooking 模块文档

> **模块职责**：烹饪推荐、烹饪会话管理、菜品管理、剩菜处理  
> **适用对象**：负责烹饪模块开发的团队成员  
> **最后更新**：2025-12-16

---

## 📋 目录

1. [模块概述](#模块概述)
2. [目录结构](#目录结构)
3. [核心实体](#核心实体)
4. [主要功能](#主要功能)
5. [API接口](#api接口)
6. [代码示例](#代码示例)
7. [与其他模块的交互](#与其他模块的交互)
8. [开发指南](#开发指南)

---

## 模块概述

`calotter-cooking` 模块负责整个系统的**烹饪相关功能**，包括：

- 🤖 **AI烹饪推荐**：基于库存、用户偏好、健康目标生成个性化烹饪建议
- 📝 **烹饪会话管理**：记录每次烹饪请求和AI响应
- 🍽️ **菜品管理**：管理菜品信息（Dish实体）
- 🍲 **剩菜处理**：处理烹饪后的剩菜

### 核心特点

- **AI上下文构建**：整合用户信息、库存信息、健康目标，构建完整的AI请求上下文
- **会话记录**：完整记录每次烹饪请求和AI响应，便于追溯和优化
- **事件驱动**：烹饪完成后发布事件，触发健康模块自动记录营养

### 模块位置

```
backend-calotter/
└── calotter-modules/
    └── calotter-cooking/        # 烹饪模块
        ├── pom.xml
        └── src/main/java/com/calotter/cooking/
```

---

## 目录结构

```
calotter-cooking/
├── pom.xml                                    # Maven配置文件
└── src/main/java/com/calotter/cooking/
    ├── controller/                           # 控制器层（API接口）
    │   ├── CookingController.java           # 烹饪相关API
    │   └── dto/                              # 请求/响应DTO
    │       ├── CookingGenerationRequest.java # 生成烹饪推荐请求
    │       ├── CookingCompletionRequest.java # 完成烹饪请求
    │       └── CookingCompletionResponse.java # 完成烹饪响应
    ├── service/                              # 业务逻辑层
    │   ├── CookingContextBuilderService.java # AI上下文构建服务（核心）
    │   ├── CookingSessionService.java       # 烹饪会话服务
    │   ├── DishService.java                 # 菜品服务
    │   ├── LeftoverDishService.java         # 剩菜服务
    │   ├── dto/                              # Service层DTO
    │   │   ├── AiCookingContext.java        # AI请求上下文
    │   │   ├── AiRecipeResponse.java        # AI响应
    │   │   ├── DinerProfile.java            # 食客画像
    │   │   ├── KitchenSnapshot.java         # 厨房快照（库存）
    │   │   └── ...                           # 其他DTO
    │   └── event/                            # 事件定义
    │       └── CookingSessionCompletedEvent.java # 烹饪完成事件
    ├── repository/                           # 数据访问层
    │   ├── CookingSessionRepository.java    # 烹饪会话数据访问
    │   └── DishRepository.java              # 菜品数据访问
    └── domain/                               # 实体层
        ├── entity/
        │   ├── CookingSession.java          # 烹饪会话实体
        │   └── Dish.java                    # 菜品实体
        └── enums/
            └── DifficultyLevel.java         # 难度等级枚举
```

### 各目录说明

- **controller/**：定义API接口，接收HTTP请求，返回响应
- **service/**：处理业务逻辑
  - `CookingContextBuilderService`：构建AI请求上下文（核心服务）
  - `CookingSessionService`：管理烹饪会话
  - `DishService`：管理菜品
  - `LeftoverDishService`：处理剩菜
- **repository/**：操作数据库，增删改查
- **domain/entity/**：定义数据库表结构
- **domain/enums/**：定义枚举类型

---

## 核心实体

### 1. CookingSession（烹饪会话）

**作用**：记录每次烹饪请求的完整信息，包括请求上下文和AI响应

**主要字段**：
- `id`：会话ID（主键）
- `householdId`：家庭ID
- `initiatorId`：发起请求的用户ID
- `requestContext`：请求上下文（JSON格式，存储 `AiCookingContext`）
- `aiResponse`：AI响应（JSON格式，存储 `AiRecipeResponse`）
- `finalDish`：最终选择的菜品（`@ManyToOne` → `Dish`）
- `status`：状态（PENDING、COMPLETED、COOKED、CANCELLED）
- `selectedDishName`：用户选择的菜品名称

**数据库表**：`cooking_sessions`

**特点**：
- 使用JSONB存储请求和响应，便于完整记录和调试
- 关联Dish实体，便于查询和统计

### 2. Dish（菜品）

**作用**：存储结构化的菜品信息，包括营养信息、食材清单等

**主要字段**：
- `id`：菜品ID（主键）
- `name`：菜品名称
- `household`：所属家庭（`@ManyToOne` → `Household`）
- `totalCalories`：总卡路里
- `totalProtein`：总蛋白质
- `totalFat`：总脂肪
- `totalCarb`：总碳水化合物
- `totalFiber`：总纤维
- `totalWeightGram`：总重量（克）
- `ingredients`：食材清单（JSON格式）
- `steps`：制作步骤（JSON格式）

**数据库表**：`dishes`

**特点**：
- 从AI响应中提取结构化数据
- 便于查询和统计
- 关联剩菜，便于营养记录

---

## 主要功能

### 1. AI烹饪推荐生成

**流程**：
1. 前端发送生成请求（包含家庭成员ID、客人信息、偏好等）
2. `CookingController.generateContext()` 接收请求
3. `CookingContextBuilderService.buildContext()` 构建AI上下文：
   - 获取家庭成员信息
   - 获取健康目标
   - 获取库存信息（食材、调料、厨具）
   - 处理偏好冲突
   - 计算营养目标
4. 返回 `AiCookingContext`（前端发送给AI）
5. AI返回 `AiRecipeResponse`（前端发送回后端）
6. 创建 `CookingSession` 记录

**API**：`POST /api/cooking/generate-context`

### 2. 烹饪会话完成

**流程**：
1. 前端发送完成请求（包含消费信息、剩菜处理方式）
2. `CookingController.completeSession()` 接收请求
3. `CookingSessionService.completeSession()` 处理：
   - 创建或获取Dish快照
   - 处理剩菜（如果需要）
   - 更新会话状态
   - 发布 `CookingSessionCompletedEvent` 事件
4. 健康模块监听事件，自动创建营养日志

**API**：`POST /api/cooking/complete`

### 3. 剩菜管理

**功能**：
- 烹饪完成后自动创建剩菜记录
- 支持从剩菜记录营养摄入
- 查询家庭的剩菜列表

---

## API接口

### 1. 生成烹饪上下文

```http
POST /api/cooking/generate-context
Content-Type: application/json

{
  "memberIds": [1, 2],
  "guests": [
    {
      "name": "客人A",
      "allergies": ["花生"],
      "preferences": {
        "DISLIKE": ["香菜"],
        "TASTE": ["清淡"]
      }
    }
  ],
  "dishCount": 3,
  "maxTimeMinutes": 60,
  "difficulty": "MEDIUM",
  "targetCuisines": ["川菜", "粤菜"]
}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "settings": {
      "dishCount": 3,
      "maxTimeMinutes": 60,
      "difficulty": "MEDIUM",
      "targetCuisines": ["川菜", "粤菜"]
    },
    "compositeGoal": {
      "minCalories": 1800,
      "maxCalories": 2200,
      "protein": 90,
      "fat": 60,
      "carb": 200
    },
    "dinerProfile": {
      "roster": [
        {
          "dinerId": "M-1",
          "displayName": "张三",
          "targetCalories": 600,
          "personalDislikes": ["香菜"]
        }
      ],
      "globalAvoidance": ["花生", "VEGAN"]
    },
    "kitchenInventory": {
      "ingredients": [
        {
          "name": "鸡蛋",
          "quantity": 500.0,
          "unit": "g"
        }
      ],
      "spices": [...],
      "utensils": [...]
    }
  }
}
```

### 2. 完成烹饪会话

```http
POST /api/cooking/complete
Content-Type: application/json

{
  "sessionId": 1,
  "diners": [
    {
      "memberId": 1,
      "portionPercentage": 0.4
    },
    {
      "memberId": 2,
      "portionPercentage": 0.3
    }
  ],
  "consumedAt": "2025-12-16T18:30:00",
  "leftoverHandling": {
    "action": "SAVE_TO_FRIDGE"
  }
}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "sessionId": 1,
    "leftoverCreated": true,
    "leftoverId": 5
  }
}
```

---

## 代码示例

### 示例1：构建AI上下文

```java
// Service层
public AiCookingContext buildContext(CookingGenerationRequest req) {
    // 1. 获取基础数据
    List<FamilyMember> members = memberRepo.findAllById(req.getMemberIds());
    Long householdId = members.get(0).getHousehold().getId();
    
    // 2. 处理食客与目标
    DinerProfileAndGoal combinedData = processDinersAndGoals(
        members, req.getGuests(), req.getTargetCuisines());
    
    // 3. 处理库存
    KitchenSnapshot inventory = processInventory(householdId);
    
    // 4. 处理任务设置
    TaskSettings task = TaskSettings.builder()
            .dishCount(req.getDishCount())
            .maxTimeMinutes(req.getMaxTimeMinutes())
            .difficulty(req.getDifficulty())
            .targetCuisines(req.getTargetCuisines())
            .build();
    
    // 5. 组装最终上下文
    return AiCookingContext.builder()
            .settings(task)
            .compositeGoal(combinedData.getCompositeGoal())
            .dinerProfile(combinedData.getDinerProfile())
            .kitchenInventory(inventory)
            .build();
}
```

### 示例2：处理食客偏好

```java
// Service层内部方法
private DinerProfileAndGoal processDinersAndGoals(
        List<FamilyMember> members,
        List<GuestInfo> guests,
        List<String> overrideCuisines) {
    
    List<DinerProfile.DinerSlot> roster = new ArrayList<>();
    Set<String> globalAvoidance = new HashSet<>();
    
    // 处理家庭成员
    for (FamilyMember m : members) {
        // 收集过敏原和饮食限制
        if (m.getAllergies() != null) {
            m.getAllergies().forEach(a -> globalAvoidance.add(a.getName()));
        }
        
        // 计算营养目标
        HealthGoal goal = healthGoalRepo.findByFamilyMemberAndStatus(m, 1);
        int targetCal = goal != null ? (int)(goal.getDailyCalories() * 0.35) : 600;
        
        // 加入花名册
        roster.add(DinerProfile.DinerSlot.builder()
                .dinerId("M-" + m.getId())
                .displayName(m.getName())
                .targetCalories(targetCal)
                .build());
    }
    
    // 处理客人...
    
    // 返回合并结果
    return DinerProfileAndGoal.builder()
            .dinerProfile(DinerProfile.builder().roster(roster).build())
            .compositeGoal(calculateCompositeGoal(members))
            .build();
}
```

### 示例3：完成烹饪会话

```java
// Service层
@Transactional
public CookingCompletionResponse completeSession(CookingCompletionRequest req) {
    // 1. 获取会话
    CookingSession session = sessionRepository.findById(req.getSessionId())
            .orElseThrow(() -> new IllegalArgumentException("会话不存在"));
    
    // 2. 创建Dish快照
    Dish dish = dishService.createDishFromAiResponse(session.getAiResponse(), household);
    
    // 3. 处理剩菜
    if (req.getLeftoverHandling().getAction() == LeftoverAction.SAVE_TO_FRIDGE) {
        LeftoverDish leftover = new LeftoverDish();
        leftover.setHousehold(household);
        leftover.setOriginalDishId(dish.getId());
        leftover.setCurrentQuantityGram(remainingGram);
        leftoverDishRepository.save(leftover);
    }
    
    // 4. 更新会话状态
    session.setStatus(CookingSession.SessionStatus.COOKED);
    sessionRepository.save(session);
    
    // 5. 发布事件（触发健康模块记录营养）
    CookingSessionCompletedEvent event = new CookingSessionCompletedEvent(
        session.getId(), dish, req.getDiners());
    eventPublisher.publishEvent(event);
    
    return CookingCompletionResponse.builder()
            .sessionId(session.getId())
            .leftoverCreated(leftoverCreated)
            .build();
}
```

---

## 与其他模块的交互

### 依赖哪些模块？

1. **calotter-common**
   - 使用 `Result`、`BaseEntity` 等基础类

2. **calotter-user**
   - 使用 `Household`、`FamilyMember`、`HealthGoal` 实体
   - 获取用户信息和健康目标

3. **calotter-inventory**
   - 使用 `Ingredient`、`HouseholdSpice`、`HouseholdUtensil` 实体
   - 获取库存信息构建厨房快照
   - 使用 `LeftoverDish` 实体处理剩菜

### 被哪些模块使用？

1. **calotter-health（健康模块）**
   - 监听 `CookingSessionCompletedEvent` 事件
   - 自动创建营养日志
   - 依赖关系：health模块依赖cooking模块

### 交互示例

**场景1**：健康模块监听烹饪完成事件

```java
// 在 health 模块中
@EventListener
public void handleCookingSessionCompleted(CookingSessionCompletedEvent event) {
    // 为每个用餐者创建营养日志
    for (DinerConsumption consumption : event.getDiners()) {
        NutritionLog log = new NutritionLog();
        log.setMemberId(consumption.getMemberId());
        log.setCalories(calculateCalories(consumption, event.getDish()));
        // ... 设置其他营养信息
        nutritionLogService.save(log);
    }
}
```

**场景2**：获取库存构建厨房快照

```java
// 在 cooking 模块中
private KitchenSnapshot processInventory(Long householdId) {
    // 获取可用食材
    List<Ingredient> ingredients = ingredientRepository
            .findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
    
    // 获取调料
    List<HouseholdSpice> spices = spiceRepository
            .findByHouseholdIdAndIsAvailableTrue(householdId);
    
    // 获取厨具
    List<HouseholdUtensil> utensils = utensilRepository
            .findByHouseholdIdAndIsAvailableTrue(householdId);
    
    // 构建快照
    return KitchenSnapshot.builder()
            .ingredients(convertToSnapshot(ingredients))
            .spices(convertToSnapshot(spices))
            .utensils(convertToSnapshot(utensils))
            .build();
}
```

---

## 开发指南

### 如何添加新功能？

#### 1. 添加新的偏好类型

在 `CookingContextBuilderService` 中添加处理逻辑：

```java
private static final String PREF_KEY_NEW_PREF = "NEW_PREF";

// 在处理偏好时添加
countPreferences(m.getPreferences(), PREF_KEY_NEW_PREF, newPrefCounter);
```

#### 2. 添加新的营养计算逻辑

在 `processDinersAndGoals` 方法中修改营养计算：

```java
// 添加新的营养指标
int totalVitaminC = 0;

// 在循环中累加
if (g != null) {
    totalVitaminC += (int)(g.getVitaminC() * ratio);
}

// 在CompositeNutritionalGoal中添加
compositeGoal.setVitaminC(totalVitaminC);
```

#### 3. 添加新的剩菜处理方式

在 `CookingSessionService` 中添加：

```java
if (req.getLeftoverHandling().getAction() == LeftoverAction.COMPOST) {
    // 处理堆肥逻辑
    handleCompost(leftover);
}
```

### 常见问题

#### Q1: 如何修改AI上下文的构建逻辑？

**A**: 修改 `CookingContextBuilderService` 中的方法：
- `processDinersAndGoals()`：处理食客和目标
- `processInventory()`：处理库存
- `buildContext()`：主入口

#### Q2: 如何添加新的烹饪难度等级？

**A**: 在 `DifficultyLevel` 枚举中添加：

```java
public enum DifficultyLevel {
    EASY, MEDIUM, HARD, EXPERT, NEW_LEVEL  // 添加新等级
}
```

#### Q3: 如何记录烹饪历史？

**A**: 使用 `CookingSession` 实体，所有会话都已记录。可以添加查询方法：

```java
// 在 CookingSessionRepository 中
List<CookingSession> findByHouseholdIdAndStatus(
    Long householdId, 
    CookingSession.SessionStatus status
);
```

---

## 测试

模块包含测试文件，位于 `src/test/java/com/calotter/cooking/`：

- `CookingSessionServiceTest.java`：烹饪会话服务测试
- `DishServiceTest.java`：菜品服务测试
- `LeftoverDishServiceTest.java`：剩菜服务测试

运行测试：
```bash
cd calotter-modules/calotter-cooking
mvn test
```

---

**文档结束** - 如有疑问，请查看[总览文档](./后端架构总览.md)或联系团队成员。

