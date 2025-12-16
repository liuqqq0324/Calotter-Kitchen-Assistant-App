# Cooking 模块服务重复功能分析报告

**分析时间**: 2025年12月16日  
**模块**: calotter-cooking

---

## 一、服务类概览

Cooking 模块包含以下 7 个服务类：

1. **CookingSessionService** - 烹饪会话完成服务
2. **CookingWorkflowService** - 烹饪工作流服务
3. **CookingContextBuilderService** - 烹饪上下文构建服务
4. **AiMenuService** - AI 菜单生成服务
5. **DishService** - 菜品服务
6. **LeftoverDishService** - 剩菜服务
7. **FavoriteRecipeService** - 收藏食谱服务

---

## 二、发现的重复功能

### 🔴 重复1：创建剩菜（LeftoverDish）逻辑重复

**问题描述**：
两个服务类都直接操作 `LeftoverDishRepository` 创建剩菜，违反了单一职责原则。

**重复位置**：

1. **CookingSessionService.completeSession()** (第76-84行)
```java
LeftoverDish leftover = new LeftoverDish();
leftover.setHousehold(household);
leftover.setOriginalDishId(dish.getId());
leftover.setCurrentQuantityGram((int)(dish.getTotalWeightGram() * remainingPercentage));
leftover.setProducedTime(req.getConsumedAt());
leftoverDishRepository.save(leftover);
```

2. **CookingWorkflowService.finishCooking()** (第85-93行)
```java
LeftoverDish leftover = new LeftoverDish();
leftover.setHousehold(householdRepository.findById(session.getHouseholdId())...);
leftover.setOriginalDishId(dish.getId());
leftover.setCurrentQuantityGram(dish.getTotalWeightGram());
leftover.setProducedTime(LocalDateTime.now());
leftoverDishRepository.save(leftover);
```

**问题分析**：
- ✅ `LeftoverDishService` 已经存在，专门负责剩菜相关业务
- ❌ 但两个服务都绕过了 `LeftoverDishService`，直接操作 Repository
- ❌ 创建逻辑略有不同（一个按比例，一个100%），但应该统一封装

**建议**：
- 在 `LeftoverDishService` 中添加 `createLeftoverDish()` 方法
- `CookingSessionService` 和 `CookingWorkflowService` 都调用该方法
- 统一剩菜创建逻辑，便于后续维护和扩展

---

### 🔴 重复2：发布 CookingSessionCompletedEvent 事件重复

**问题描述**：
两个服务都发布相同的事件，但数据来源和构建逻辑不同。

**重复位置**：

1. **CookingSessionService.completeSession()** (第91-119行)
   - 包含详细的用餐者消费数据（`DinerConsumptionData`）
   - 根据时间自动判断餐次类型
   - 营养数据来自 Dish 实体

2. **CookingWorkflowService.finishCooking()** (第95-114行)
   - 没有用餐者数据（空列表）
   - 固定餐次类型为 "DINNER"
   - 营养数据来自请求参数

**问题分析**：
- ⚠️ 两个方法都完成烹饪，但使用场景不同
- ⚠️ `CookingSessionService.completeSession()` 更完整（有用餐者数据）
- ⚠️ `CookingWorkflowService.finishCooking()` 可能是不完整的实现

**建议**：
- 统一事件发布逻辑，提取到公共方法
- 明确两个方法的职责边界：
  - `completeSession()` - 完整的烹饪完成流程（有分餐数据）
  - `finishCooking()` - 简化的完成流程（无分餐数据）
- 或者合并为一个方法，通过参数区分是否需要分餐数据

---

### 🟡 重复3：创建 Dish 实体的映射逻辑重复

**问题描述**：
三个服务类都有从不同来源创建 Dish 的逻辑，存在代码重复。

**重复位置**：

1. **DishService.createDishFromAiResponse()** (第34-105行)
   - 从 `AiRecipeResponse` 创建 Dish
   - 包含完整的营养信息、步骤、食材快照

2. **FavoriteRecipeService.mapToDish()** (第66-108行)
   - 从 `MenuDTO.RecipeDTO` 创建 Dish
   - 逻辑与 `DishService` 高度相似

3. **CookingSessionService.completeSession()** (第52-61行)
   - 调用 `DishService.createDishFromAiResponse()`，但逻辑间接重复

**问题分析**：
- ✅ `DishService` 是专门负责 Dish 的服务
- ⚠️ `FavoriteRecipeService.mapToDish()` 与 `DishService.createDishFromAiResponse()` 有大量重复代码
- ⚠️ 两者都处理：
  - 营养信息映射
  - 食材快照创建
  - 烹饪步骤转换
  - 重量计算

**建议**：
- 将 `FavoriteRecipeService.mapToDish()` 的逻辑提取到 `DishService`
- 创建统一的方法：`createDishFromRecipeDTO()` 或 `createDishFromMenuDTO()`
- `FavoriteRecipeService` 只负责收藏逻辑，调用 `DishService` 创建 Dish

---

### 🟡 重复4：库存查询逻辑重复

**问题描述**：
两个服务都查询库存数据（ingredients、spices、utensils），逻辑相似。

**重复位置**：

1. **CookingContextBuilderService.processInventory()** (第248-301行)
   - 查询 ingredients（按过期时间分类）
   - 查询 spices（可用状态）
   - 查询 utensils（可用状态）
   - 构建 `KitchenSnapshot`

2. **AiMenuService.enrichFilterFromHousehold()** (第117-156行)
   - 查询 ingredients（数量>0）
   - 查询 spices（可用状态）
   - 查询 utensils（可用状态）
   - 填充 `RecipeGenerationFilter`

**问题分析**：
- ⚠️ 两者查询条件略有不同（一个按过期时间分类，一个只查数量>0）
- ⚠️ 但都查询相同的数据源
- ⚠️ 可以提取公共的库存查询方法

**建议**：
- 在 `InventoryService` 中添加统一的库存查询方法
- 或者创建一个 `InventoryQueryService` 专门负责库存查询
- 两个服务都调用统一的查询方法，减少重复代码

---

### 🟢 重复5：扣减库存逻辑缺失

**问题描述**：
只有 `CookingWorkflowService` 有扣减库存的逻辑，`CookingSessionService` 没有。

**位置**：

1. **CookingWorkflowService.finishCooking()** (第82行)
   - 调用 `deductInventory()` 扣减库存
   - 包含单位转换逻辑

2. **CookingSessionService.completeSession()**
   - ❌ 没有扣减库存的逻辑

**问题分析**：
- ⚠️ 两个方法都完成烹饪，理论上都应该扣减库存
- ⚠️ `CookingSessionService` 可能遗漏了库存扣减逻辑
- ⚠️ 或者两个方法的使用场景不同，需要明确

**建议**：
- 明确两个方法的职责：
  - 如果都需要扣减库存，统一提取到公共方法
  - 如果使用场景不同，需要文档说明
- 将扣减库存逻辑提取到 `InventoryService`，统一管理

---

## 三、服务职责边界不清晰

### 问题1：CookingSessionService vs CookingWorkflowService

**当前状态**：
- `CookingSessionService.completeSession()` - 完成烹饪会话（有分餐数据）
- `CookingWorkflowService.finishCooking()` - 完成烹饪（无分餐数据）

**问题**：
- 两个方法都完成烹饪，职责重叠
- 不清楚什么场景用哪个方法
- Controller 中两个接口都存在（`/complete` 和 `/finish`）

**建议**：
- 明确两个方法的业务场景
- 如果功能重复，合并为一个方法
- 如果场景不同，重命名并添加文档说明

---

### 问题2：DishService vs FavoriteRecipeService

**当前状态**：
- `DishService` - 负责 Dish 相关业务
- `FavoriteRecipeService` - 负责收藏逻辑，但也创建 Dish

**问题**：
- `FavoriteRecipeService.mapToDish()` 与 `DishService.createDishFromAiResponse()` 重复
- 收藏服务不应该负责 Dish 的创建逻辑

**建议**：
- `FavoriteRecipeService` 只负责收藏/取消收藏逻辑
- Dish 创建统一由 `DishService` 负责

---

## 四、重构建议

### 优先级1：高优先级（必须修复）

1. **统一剩菜创建逻辑**
   - 在 `LeftoverDishService` 中添加 `createLeftoverDish()` 方法
   - 移除 `CookingSessionService` 和 `CookingWorkflowService` 中的直接创建逻辑

2. **明确 CookingSessionService 和 CookingWorkflowService 的职责**
   - 合并重复功能或明确使用场景
   - 统一事件发布逻辑

### 优先级2：中优先级（建议修复）

3. **统一 Dish 创建逻辑**
   - 将 `FavoriteRecipeService.mapToDish()` 提取到 `DishService`
   - 创建统一的 Dish 创建方法

4. **统一库存查询逻辑**
   - 在 `InventoryService` 中添加统一的查询方法
   - 减少重复的 Repository 查询

### 优先级3：低优先级（可选优化）

5. **提取扣减库存逻辑**
   - 将扣减库存逻辑提取到 `InventoryService`
   - 统一库存扣减的入口

---

## 五、代码重复统计

| 重复功能 | 涉及服务数 | 代码行数（重复） | 优先级 |
|---------|-----------|----------------|--------|
| 创建剩菜 | 2 | ~15行 | 高 |
| 发布事件 | 2 | ~30行 | 高 |
| 创建Dish | 2 | ~80行 | 中 |
| 查询库存 | 2 | ~50行 | 中 |
| 扣减库存 | 1（缺失） | N/A | 中 |

**总计重复代码行数**：约 175 行

---

## 六、总结

Cooking 模块确实存在**较多的服务功能重复**，主要体现在：

1. ✅ **剩菜创建逻辑重复** - 2个服务直接操作Repository
2. ✅ **事件发布逻辑重复** - 2个服务都发布相同事件
3. ✅ **Dish创建逻辑重复** - 2个服务都有映射逻辑
4. ✅ **库存查询逻辑重复** - 2个服务都查询相同数据
5. ⚠️ **扣减库存逻辑缺失** - 1个服务有，1个服务没有

**建议立即进行重构**，以提高代码可维护性和一致性。

---

**分析完成时间**: 2025年12月16日

