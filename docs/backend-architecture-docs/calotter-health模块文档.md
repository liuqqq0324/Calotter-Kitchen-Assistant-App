# calotter-health 模块文档

> **模块职责**：营养记录、健康报告、营养聚合统计  
> **适用对象**：负责健康模块开发的团队成员  
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

`calotter-health` 模块负责整个系统的**健康管理功能**，包括：

- 📊 **营养记录**：记录家庭成员的营养摄入
- 📈 **营养聚合**：按日、周、月聚合营养数据
- 📋 **健康报告**：生成周报、月报等健康报告
- 🔔 **事件监听**：自动监听烹饪完成事件，创建营养日志

### 核心特点

- **事件驱动**：监听烹饪完成事件，自动记录营养
- **多种来源**：支持从烹饪、剩菜、手动输入等多种来源记录营养
- **自动聚合**：自动计算每日、每周的营养汇总
- **弱引用设计**：使用弱引用关联Dish，避免循环依赖

### 模块位置

```
backend-calotter/
└── calotter-modules/
    └── calotter-health/          # 健康模块
        ├── pom.xml
        └── src/main/java/com/calotter/health/
```

---

## 目录结构

```
calotter-health/
├── pom.xml                                    # Maven配置文件
└── src/main/java/com/calotter/health/
    ├── controller/                           # 控制器层（API接口）
    │   ├── NutritionController.java         # 营养相关API
    │   └── dto/                              # 请求/响应DTO
    │       ├── ManualNutritionLogRequest.java # 手动记录请求
    │       └── WeeklyReportVO.java           # 周报响应
    ├── service/                              # 业务逻辑层
    │   ├── NutritionLogService.java         # 营养日志服务
    │   ├── NutritionAggregateService.java   # 营养聚合服务
    │   ├── listener/                         # 事件监听器
    │   │   ├── CookingSessionCompletedEventListener.java # 烹饪完成监听器
    │   │   └── NutritionLogEventListener.java # 营养日志监听器
    │   └── event/                            # 事件定义
    │       └── NutritionLogCreatedEvent.java # 营养日志创建事件
    ├── repository/                           # 数据访问层
    │   ├── NutritionLogRepository.java      # 营养日志数据访问
    │   └── DailyNutrientAggregateRepository.java # 每日聚合数据访问
    ├── domain/                               # 实体层
    │   ├── entity/
    │   │   ├── NutritionLog.java             # 营养日志实体
    │   │   └── DailyNutrientAggregate.java  # 每日营养聚合实体
    │   └── enums/
    │       ├── MealType.java                 # 餐次类型（早餐、午餐、晚餐、零食）
    │       └── LogSourceType.java            # 日志来源类型
    └── config/                               # 配置类
        └── AsyncConfig.java                  # 异步配置（事件处理）
```

### 各目录说明

- **controller/**：定义API接口，接收HTTP请求，返回响应
- **service/**：处理业务逻辑
  - `NutritionLogService`：创建和管理营养日志
  - `NutritionAggregateService`：计算和查询营养聚合
  - `listener/`：事件监听器，自动处理事件
- **repository/**：操作数据库，增删改查
- **domain/entity/**：定义数据库表结构
- **domain/enums/**：定义枚举类型
- **config/**：配置类

---

## 核心实体

### 1. NutritionLog（营养日志）

**作用**：记录每一次进食的详细信息，是营养数据的原子记录

**主要字段**：
- `id`：日志ID（主键）
- `familyMember`：所属家庭成员（`@ManyToOne` → `FamilyMember`）
- `logDate`：记录日期（冗余字段，便于查询）
- `eatenAt`：具体进食时间
- `mealType`：餐次类型（BREAKFAST、LUNCH、DINNER、SNACK）
- `sourceType`：来源类型（APP_COOKING、LEFTOVER、MANUAL、EXTERNAL）
- `dishId`：关联的Dish ID（弱引用，可空）
- `foodName`：食物名称（快照）
- `quantity`：摄入数量
- `unit`：单位（g、ml、serving）
- `calories`：卡路里（快照）
- `protein`：蛋白质（快照）
- `fat`：脂肪（快照）
- `carb`：碳水化合物（快照）
- `fiber`：膳食纤维（快照）

**数据库表**：`nutrition_logs`

**特点**：
- 使用弱引用关联Dish（`dishId`），避免循环依赖
- 存储营养快照，不依赖Dish实体
- 支持多种来源（烹饪、剩菜、手动输入）

### 2. DailyNutrientAggregate（每日营养聚合）

**作用**：按日聚合家庭成员的营养数据，便于快速查询和统计

**主要字段**：
- `id`：聚合ID（主键）
- `familyMember`：所属家庭成员（`@ManyToOne` → `FamilyMember`）
- `aggregateDate`：聚合日期
- `totalCalories`：总卡路里
- `totalProtein`：总蛋白质
- `totalFat`：总脂肪
- `totalCarb`：总碳水化合物
- `totalFiber`：总纤维
- `mealCount`：餐次数量

**数据库表**：`daily_nutrient_aggregates`

**特点**：
- 自动更新：当创建营养日志时，自动更新聚合表
- 便于查询：避免每次都聚合大量日志数据

---

## 主要功能

### 1. 自动记录营养（事件驱动）

**流程**：
1. 烹饪模块完成烹饪会话，发布 `CookingSessionCompletedEvent` 事件
2. `CookingSessionCompletedEventListener` 监听事件
3. `NutritionLogService.createFromEvent()` 处理：
   - 为每个用餐者创建营养日志
   - 根据消费比例计算营养摄入
   - 保存营养日志
   - 发布 `NutritionLogCreatedEvent` 事件
4. `NutritionLogEventListener` 监听事件，更新每日聚合表

**特点**：
- 完全自动化，用户无需手动记录
- 基于实际消费比例计算营养

### 2. 从剩菜记录营养

**流程**：
1. 前端发送请求（剩菜ID、成员ID、消费重量）
2. `NutritionController.createFromLeftover()` 接收请求
3. `NutritionLogService.createFromLeftover()` 处理：
   - 获取剩菜信息
   - 计算营养摄入（基于消费重量）
   - 创建营养日志
   - 更新剩菜数量
   - 更新每日聚合表

**API**：`POST /api/nutrition/log/leftover`

### 3. 手动记录营养

**流程**：
1. 前端发送请求（成员ID、食物名称、营养信息等）
2. `NutritionController.createManualLog()` 接收请求
3. `NutritionLogService.createManual()` 处理：
   - 创建营养日志
   - 更新每日聚合表

**API**：`POST /api/nutrition/log/manual`

### 4. 生成健康报告

**流程**：
1. 前端发送请求（成员ID、周开始日期）
2. `NutritionController.getWeeklyReport()` 接收请求
3. `NutritionAggregateService.getWeeklyReport()` 处理：
   - 查询一周的每日聚合数据
   - 计算周汇总
   - 对比健康目标
   - 生成报告

**API**：`GET /api/nutrition/weekly?memberId={memberId}&weekStart={weekStart}`

---

## API接口

### 1. 获取周健康报告

```http
GET /api/nutrition/weekly?memberId=1&weekStart=2025-12-16
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "memberId": 1,
    "weekStart": "2025-12-16",
    "weekEnd": "2025-12-22",
    "dailyAggregates": [
      {
        "date": "2025-12-16",
        "totalCalories": 1800,
        "totalProtein": 90,
        "totalFat": 60,
        "totalCarb": 200,
        "totalFiber": 25
      }
    ],
    "weeklyTotal": {
      "totalCalories": 12600,
      "totalProtein": 630,
      "totalFat": 420,
      "totalCarb": 1400,
      "totalFiber": 175
    },
    "goalComparison": {
      "caloriesProgress": 0.9,
      "proteinProgress": 1.0,
      "fatProgress": 0.85
    }
  }
}
```

### 2. 手动记录营养

```http
POST /api/nutrition/log/manual
Content-Type: application/json

{
  "memberId": 1,
  "foodName": "苹果",
  "quantity": 200.0,
  "unit": "g",
  "calories": 100,
  "protein": 0.5,
  "fat": 0.3,
  "carb": 25.0,
  "fiber": 4.0,
  "mealType": "SNACK",
  "eatenAt": "2025-12-16T15:30:00"
}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 100,
    "memberId": 1,
    "foodName": "苹果",
    "calories": 100,
    "protein": 0.5,
    "fat": 0.3,
    "carb": 25.0,
    "fiber": 4.0
  }
}
```

### 3. 从剩菜记录营养

```http
POST /api/nutrition/log/leftover?leftoverId=5&memberId=1&consumedGram=150&eatenAt=2025-12-16T18:30:00
```

**响应**：同手动记录响应

---

## 代码示例

### 示例1：监听烹饪完成事件

```java
// 事件监听器
@Component
@RequiredArgsConstructor
public class CookingSessionCompletedEventListener {
    private final NutritionLogService nutritionLogService;
    
    @Async
    @EventListener
    public void handleCookingSessionCompleted(CookingSessionCompletedEvent event) {
        // 为每个用餐者创建营养日志
        List<NutritionLog> logs = nutritionLogService.createFromEvent(event);
        log.info("Created {} nutrition logs from cooking session {}", 
                logs.size(), event.getSessionId());
    }
}
```

### 示例2：从事件创建营养日志

```java
// Service层
@Transactional
public List<NutritionLog> createFromEvent(CookingSessionCompletedEvent event) {
    List<NutritionLog> logs = new ArrayList<>();
    
    // 为每个用餐者创建日志
    for (DinerConsumptionData diner : event.getDiners()) {
        FamilyMember member = familyMemberRepository.findById(diner.getFamilyMemberId())
                .orElseThrow(() -> new IllegalArgumentException("家庭成员不存在"));
        
        NutritionLog log = new NutritionLog();
        log.setFamilyMember(member);
        log.setDishId(event.getDishId()); // 弱引用
        log.setLogDate(event.getConsumedAt().toLocalDate());
        log.setSourceType(LogSourceType.APP_COOKING);
        log.setFoodName(event.getDishName());
        log.setEatenAt(event.getConsumedAt());
        log.setMealType(MealType.valueOf(event.getMealType()));
        
        // 基于消费比例计算营养
        double ratio = diner.getPortionPercentage();
        DishNutritionSnapshot nutrition = event.getDishNutrition();
        
        log.setCalories((int)(nutrition.getTotalCalories() * ratio));
        log.setProtein(nutrition.getTotalProtein() * ratio);
        log.setFat(nutrition.getTotalFat() * ratio);
        log.setCarb(nutrition.getTotalCarb() * ratio);
        log.setFiber(nutrition.getTotalFiber() * ratio);
        log.setQuantity(nutrition.getTotalWeightGram() * ratio);
        log.setUnit("g");
        
        logs.add(log);
    }
    
    // 保存日志
    List<NutritionLog> savedLogs = nutritionLogRepository.saveAll(logs);
    
    // 发布事件，触发聚合表更新
    eventPublisher.publishEvent(new NutritionLogCreatedEvent(this, savedLogs));
    
    return savedLogs;
}
```

### 示例3：更新每日聚合表

```java
// 事件监听器
@Component
@RequiredArgsConstructor
public class NutritionLogEventListener {
    private final NutritionAggregateService aggregateService;
    
    @Async
    @EventListener
    public void handleNutritionLogCreated(NutritionLogCreatedEvent event) {
        // 为每个日志更新聚合表
        for (NutritionLog log : event.getLogs()) {
            aggregateService.updateDailyAggregate(log);
        }
    }
}
```

### 示例4：生成周报告

```java
// Service层
public WeeklyReportVO getWeeklyReport(Long memberId, LocalDate weekStart) {
    LocalDate weekEnd = weekStart.plusDays(6);
    
    // 查询一周的每日聚合
    List<DailyNutrientAggregate> aggregates = aggregateRepository
            .findByFamilyMemberIdAndAggregateDateBetween(memberId, weekStart, weekEnd);
    
    // 计算周汇总
    WeeklyTotal weeklyTotal = calculateWeeklyTotal(aggregates);
    
    // 获取健康目标
    HealthGoal goal = healthGoalRepository.findByFamilyMemberIdAndStatus(memberId, 1);
    
    // 对比目标
    GoalComparison comparison = compareWithGoal(weeklyTotal, goal);
    
    // 构建报告
    return WeeklyReportVO.builder()
            .memberId(memberId)
            .weekStart(weekStart)
            .weekEnd(weekEnd)
            .dailyAggregates(convertToDailyVO(aggregates))
            .weeklyTotal(weeklyTotal)
            .goalComparison(comparison)
            .build();
}
```

---

## 与其他模块的交互

### 依赖哪些模块？

1. **calotter-common**
   - 使用 `Result`、`BaseEntity` 等基础类

2. **calotter-user**
   - 使用 `FamilyMember` 实体
   - 获取健康目标（`HealthGoal`）

3. **calotter-inventory**
   - 使用 `LeftoverDish` 实体
   - 从剩菜记录营养

4. **calotter-cooking**
   - 监听 `CookingSessionCompletedEvent` 事件
   - 使用 `LeftoverDishService` 获取剩菜信息

### 被哪些模块使用？

目前没有被其他模块直接使用，但通过事件机制与其他模块交互。

### 交互示例

**场景1**：烹饪完成后自动记录营养

```java
// 在 cooking 模块中
@Transactional
public CookingCompletionResponse completeSession(CookingCompletionRequest req) {
    // ... 处理烹饪完成逻辑
    
    // 发布事件
    CookingSessionCompletedEvent event = new CookingSessionCompletedEvent(
        session.getId(), dish, req.getDiners());
    eventPublisher.publishEvent(event);
    
    return response;
}

// 在 health 模块中（自动监听）
@EventListener
public void handleCookingSessionCompleted(CookingSessionCompletedEvent event) {
    nutritionLogService.createFromEvent(event);
}
```

**场景2**：从剩菜记录营养

```java
// 在 health 模块中
@Transactional
public NutritionLog createFromLeftover(Long leftoverId, Long memberId, 
                                       Integer consumedGram, LocalDateTime eatenAt) {
    // 获取剩菜
    LeftoverDish leftover = leftoverDishRepository.findById(leftoverId)
            .orElseThrow(() -> new IllegalArgumentException("剩菜不存在"));
    
    // 获取Dish信息（通过LeftoverDishService）
    Dish dish = leftoverDishService.getDishByLeftoverId(leftoverId);
    
    // 计算营养（基于消费重量）
    double ratio = (double)consumedGram / leftover.getCurrentQuantityGram();
    
    // 创建营养日志
    NutritionLog log = new NutritionLog();
    log.setFamilyMember(member);
    log.setSourceType(LogSourceType.LEFTOVER);
    log.setDishId(dish.getId());
    log.setFoodName(dish.getName());
    log.setCalories((int)(dish.getTotalCalories() * ratio));
    // ... 设置其他营养信息
    
    return nutritionLogRepository.save(log);
}
```

---

## 开发指南

### 如何添加新功能？

#### 1. 添加新的营养指标

1. **在 `NutritionLog` 实体中添加字段**：
```java
@Column(name = "vitamin_c")
private Double vitaminC; // 维生素C
```

2. **在 `DailyNutrientAggregate` 中添加字段**：
```java
@Column(name = "total_vitamin_c")
private Double totalVitaminC;
```

3. **在聚合服务中添加计算逻辑**：
```java
public void updateDailyAggregate(NutritionLog log) {
    DailyNutrientAggregate aggregate = getOrCreateAggregate(log);
    aggregate.setTotalVitaminC(
        aggregate.getTotalVitaminC() + (log.getVitaminC() != null ? log.getVitaminC() : 0)
    );
    aggregateRepository.save(aggregate);
}
```

#### 2. 添加新的报告类型

在 `NutritionAggregateService` 中添加方法：

```java
public MonthlyReportVO getMonthlyReport(Long memberId, LocalDate monthStart) {
    LocalDate monthEnd = monthStart.plusMonths(1).minusDays(1);
    
    // 查询一月的每日聚合
    List<DailyNutrientAggregate> aggregates = aggregateRepository
            .findByFamilyMemberIdAndAggregateDateBetween(memberId, monthStart, monthEnd);
    
    // 计算月汇总
    MonthlyTotal monthlyTotal = calculateMonthlyTotal(aggregates);
    
    // 构建报告
    return MonthlyReportVO.builder()
            .memberId(memberId)
            .monthStart(monthStart)
            .monthEnd(monthEnd)
            .monthlyTotal(monthlyTotal)
            .build();
}
```

#### 3. 添加新的日志来源

1. **在 `LogSourceType` 枚举中添加**：
```java
public enum LogSourceType {
    APP_COOKING, LEFTOVER, MANUAL, EXTERNAL, SCAN_CODE  // 添加扫码来源
}
```

2. **在Service中添加处理方法**：
```java
public NutritionLog createFromScanCode(ScanCodeRequest request) {
    // 处理扫码逻辑
    NutritionLog log = new NutritionLog();
    log.setSourceType(LogSourceType.SCAN_CODE);
    // ... 设置其他信息
    return nutritionLogRepository.save(log);
}
```

### 常见问题

#### Q1: 如何修改营养计算逻辑？

**A**: 修改 `NutritionLogService` 中的计算方法，或者在 `createFromEvent` 方法中调整计算比例。

#### Q2: 如何查询历史营养数据？

**A**: 使用 `NutritionLogRepository` 查询：

```java
// 查询某成员某日期的所有日志
List<NutritionLog> logs = nutritionLogRepository
    .findByFamilyMemberIdAndLogDate(memberId, date);

// 查询某成员某时间段的日志
List<NutritionLog> logs = nutritionLogRepository
    .findByFamilyMemberIdAndEatenAtBetween(memberId, startTime, endTime);
```

#### Q3: 如何实现营养预警？

**A**: 在 `NutritionAggregateService` 中添加方法：

```java
public NutritionAlert checkNutritionAlert(Long memberId, LocalDate date) {
    DailyNutrientAggregate aggregate = aggregateRepository
            .findByFamilyMemberIdAndAggregateDate(memberId, date)
            .orElse(null);
    
    HealthGoal goal = healthGoalRepository.findByFamilyMemberIdAndStatus(memberId, 1);
    
    if (aggregate == null || goal == null) {
        return null;
    }
    
    // 检查是否超标
    if (aggregate.getTotalCalories() > goal.getDailyCalories() * 1.2) {
        return NutritionAlert.builder()
                .type("CALORIE_OVER")
                .message("今日卡路里摄入超标")
                .build();
    }
    
    return null;
}
```

---

## 测试

模块包含测试文件，位于 `src/test/java/com/calotter/health/`：

- `NutritionLogServiceTest.java`：营养日志服务测试
- `NutritionAggregateServiceTest.java`：营养聚合服务测试

运行测试：
```bash
cd calotter-modules/calotter-health
mvn test
```

---

**文档结束** - 如有疑问，请查看[总览文档](./后端架构总览.md)或联系团队成员。

