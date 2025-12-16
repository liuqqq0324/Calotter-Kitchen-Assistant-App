# calotter-inventory 模块文档

> **模块职责**：库存管理（食材、调料、厨具、剩菜）  
> **适用对象**：负责库存模块开发的团队成员  
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

`calotter-inventory` 模块负责整个系统的**库存管理功能**，包括：

- 🥬 **食材管理**：添加、更新、查询、删除食材库存
- 🧂 **调料管理**：管理家庭拥有的调料
- 🍴 **厨具管理**：管理家庭拥有的厨具
- 🍲 **剩菜管理**：记录和管理剩菜

### 核心特点

- 所有库存都**属于某个家庭**（Household）
- 食材、调料、厨具都**关联标准库**（StandardIngredient、StandardSpice、StandardUtensil）
- 支持**库存扣减**功能（如烹饪后减少食材数量）
- 支持**标准库查询**（通过名称搜索标准食材、调料、厨具）

### 模块位置

```
backend-calotter/
└── calotter-modules/
    └── calotter-inventory/        # 库存模块
        ├── pom.xml
        └── src/main/java/com/calotter/inventory/
```

---

## 目录结构

```
calotter-inventory/
├── pom.xml                                    # Maven配置文件
└── src/main/java/com/calotter/inventory/
    ├── controller/                           # 控制器层（API接口）
    │   ├── InventoryController.java         # 库存相关API
    │   └── dto/                              # 请求/响应DTO
    │       ├── IngredientRequest.java        # 食材请求
    │       ├── IngredientResponse.java      # 食材响应
    │       ├── SpiceRequest.java             # 调料请求
    │       ├── SpiceResponse.java            # 调料响应
    │       ├── UtensilRequest.java           # 厨具请求
    │       ├── UtensilResponse.java          # 厨具响应
    │       ├── LeftoverRequest.java          # 剩菜请求
    │       └── LeftoverResponse.java         # 剩菜响应
    ├── service/                              # 业务逻辑层
    │   └── InventoryService.java            # 库存服务（所有库存操作的业务逻辑）
    ├── repository/                           # 数据访问层
    │   ├── IngredientRepository.java        # 食材数据访问
    │   ├── HouseholdSpiceRepository.java    # 调料数据访问
    │   ├── HouseholdUtensilRepository.java  # 厨具数据访问
    │   ├── LeftoverDishRepository.java      # 剩菜数据访问
    │   ├── StandardIngredientRepository.java # 标准食材库数据访问
    │   ├── StandardSpiceRepository.java     # 标准调料库数据访问
    │   └── StandardUtensilRepository.java    # 标准厨具库数据访问
    └── domain/                               # 实体层
        └── entity/
            ├── Ingredient.java              # 食材实体
            ├── HouseholdSpice.java           # 调料实体
            ├── HouseholdUtensil.java         # 厨具实体
            └── LeftoverDish.java             # 剩菜实体
```

### 各目录说明

- **controller/**：定义API接口，接收HTTP请求，返回响应
- **service/**：处理业务逻辑，验证数据，调用Repository
- **repository/**：操作数据库，增删改查
- **domain/entity/**：定义数据库表结构

---

## 核心实体

### 1. Ingredient（食材）

**作用**：存储家庭拥有的食材库存

**主要字段**：
- `id`：食材ID（主键）
- `household`：所属家庭（`@ManyToOne` → `Household`）
- `metadata`：标准食材信息（`@ManyToOne` → `StandardIngredient`）
- `quantity`：数量（如 500.0）
- `unit`：单位（如 "g"、"ml"、"pcs"）
- `expirationDate`：过期时间
- `location`：存放位置（"FRIDGE"、"FREEZER"、"PANTRY"）

**数据库表**：`household_ingredients`

**关系**：
- 属于某个家庭（Household）
- 关联标准食材库（StandardIngredient）

### 2. HouseholdSpice（调料）

**作用**：存储家庭拥有的调料

**主要字段**：
- `id`：调料ID（主键）
- `household`：所属家庭（`@ManyToOne` → `Household`）
- `metadata`：标准调料信息（`@ManyToOne` → `StandardSpice`）
- `isAvailable`：是否可用
- `remark`：备注

**数据库表**：`household_spices`

### 3. HouseholdUtensil（厨具）

**作用**：存储家庭拥有的厨具

**主要字段**：
- `id`：厨具ID（主键）
- `household`：所属家庭（`@ManyToOne` → `Household`）
- `metadata`：标准厨具信息（`@ManyToOne` → `StandardUtensil`）
- `isAvailable`：是否可用
- `remark`：备注

**数据库表**：`household_utensils`

### 4. LeftoverDish（剩菜）

**作用**：记录烹饪后剩余的菜品

**主要字段**：
- `id`：剩菜ID（主键）
- `household`：所属家庭（`@ManyToOne` → `Household`）
- `dishName`：菜品名称
- `quantity`：剩余数量
- `unit`：单位
- `cookedDate`：烹饪日期
- `expirationDate`：过期时间
- `nutritionInfo`：营养信息（JSON格式）

**数据库表**：`household_leftovers`

---

## 主要功能

### 1. 食材管理

**功能**：
- ✅ 创建食材：`POST /api/inventory/ingredients`
- ✅ 更新食材：`PUT /api/inventory/ingredients/{id}`
- ✅ 获取食材详情：`GET /api/inventory/ingredients/{id}`
- ✅ 获取家庭的所有食材：`GET /api/inventory/ingredients?householdId={householdId}`
- ✅ 删除食材：`DELETE /api/inventory/ingredients/{id}`
- ✅ 扣减食材库存：`POST /api/inventory/ingredients/{id}/deduct?amount={amount}`

**特点**：
- 必须关联标准食材库（StandardIngredient）
- 支持数量扣减（烹饪后减少库存）
- 可以设置过期时间和存放位置

### 2. 调料管理

**功能**：
- ✅ 创建调料：`POST /api/inventory/spices`
- ✅ 更新调料：`PUT /api/inventory/spices/{id}`
- ✅ 获取调料详情：`GET /api/inventory/spices/{id}`
- ✅ 获取家庭的所有调料：`GET /api/inventory/spices?householdId={householdId}`
- ✅ 删除调料：`DELETE /api/inventory/spices/{id}`

### 3. 厨具管理

**功能**：
- ✅ 创建厨具：`POST /api/inventory/utensils`
- ✅ 更新厨具：`PUT /api/inventory/utensils/{id}`
- ✅ 获取厨具详情：`GET /api/inventory/utensils/{id}`
- ✅ 获取家庭的所有厨具：`GET /api/inventory/utensils?householdId={householdId}`
- ✅ 删除厨具：`DELETE /api/inventory/utensils/{id}`

### 4. 剩菜管理

**功能**：
- ✅ 创建剩菜：`POST /api/inventory/leftovers`
- ✅ 更新剩菜：`PUT /api/inventory/leftovers/{id}`
- ✅ 获取剩菜详情：`GET /api/inventory/leftovers/{id}`
- ✅ 获取家庭的所有剩菜：`GET /api/inventory/leftovers?householdId={householdId}`
- ✅ 删除剩菜：`DELETE /api/inventory/leftovers/{id}`

### 5. 标准库查询

**功能**：
- ✅ 搜索标准食材：`GET /api/inventory/standard-ingredients/search?name={name}&fuzzy={fuzzy}`
  - `fuzzy=false`：精确匹配，返回单个结果
  - `fuzzy=true`：模糊匹配，返回列表

---

## API接口

### 食材相关API

#### 1. 创建食材

```http
POST /api/inventory/ingredients
Content-Type: application/json

{
  "householdId": 1,
  "standardIngredientId": 10,
  "quantity": 500.0,
  "unit": "g",
  "expirationDate": "2025-12-31",
  "location": "FRIDGE"
}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "householdId": 1,
    "standardIngredientId": 10,
    "name": "鸡蛋",
    "quantity": 500.0,
    "unit": "g",
    "expirationDate": "2025-12-31",
    "location": "FRIDGE"
  }
}
```

#### 2. 获取家庭的所有食材

```http
GET /api/inventory/ingredients?householdId=1
```

#### 3. 扣减食材库存

```http
POST /api/inventory/ingredients/1/deduct?amount=100.0
```

**说明**：将食材数量减少100.0，如果数量不足会报错。

### 调料相关API

#### 1. 创建调料

```http
POST /api/inventory/spices
Content-Type: application/json

{
  "householdId": 1,
  "standardSpiceId": 5,
  "isAvailable": true,
  "remark": "新买的"
}
```

### 厨具相关API

#### 1. 创建厨具

```http
POST /api/inventory/utensils
Content-Type: application/json

{
  "householdId": 1,
  "standardUtensilId": 3,
  "isAvailable": true,
  "remark": "平底锅"
}
```

### 剩菜相关API

#### 1. 创建剩菜

```http
POST /api/inventory/leftovers
Content-Type: application/json

{
  "householdId": 1,
  "dishName": "红烧肉",
  "quantity": 200.0,
  "unit": "g",
  "cookedDate": "2025-12-16",
  "expirationDate": "2025-12-18"
}
```

### 标准库查询API

#### 1. 搜索标准食材

```http
# 精确匹配
GET /api/inventory/standard-ingredients/search?name=鸡蛋&fuzzy=false

# 模糊匹配
GET /api/inventory/standard-ingredients/search?name=鸡&fuzzy=true
```

---

## 代码示例

### 示例1：创建食材

```java
// Controller层
@PostMapping("/ingredients")
public Result<IngredientResponse> createIngredient(@Valid @RequestBody IngredientRequest request) {
    try {
        IngredientResponse response = inventoryService.createIngredient(request);
        return Result.success(response);
    } catch (IllegalArgumentException e) {
        return Result.error(e.getMessage());
    }
}

// Service层
@Transactional
public IngredientResponse createIngredient(IngredientRequest request) {
    // 1. 验证家庭是否存在
    Household household = householdRepository.findById(request.getHouseholdId())
            .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
    
    // 2. 验证标准食材是否存在
    StandardIngredient standardIngredient = standardIngredientRepository
            .findById(request.getStandardIngredientId())
            .orElseThrow(() -> new IllegalArgumentException("标准食材不存在"));
    
    // 3. 创建食材
    Ingredient ingredient = new Ingredient();
    ingredient.setHousehold(household);
    ingredient.setMetadata(standardIngredient);
    ingredient.setQuantity(request.getQuantity());
    ingredient.setUnit(request.getUnit());
    ingredient.setExpirationDate(request.getExpirationDate());
    ingredient.setLocation(request.getLocation());
    
    // 4. 保存食材
    ingredient = ingredientRepository.save(ingredient);
    
    // 5. 返回响应
    return toIngredientResponse(ingredient);
}
```

### 示例2：扣减食材库存

```java
// Service层
@Transactional
public void deductIngredient(Long id, Double amount) {
    Ingredient ingredient = ingredientRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("食材不存在"));
    
    // 验证数量是否足够
    if (ingredient.getQuantity() < amount) {
        throw new IllegalArgumentException("食材数量不足");
    }
    
    // 扣减数量
    ingredient.setQuantity(ingredient.getQuantity() - amount);
    ingredientRepository.save(ingredient);
}
```

### 示例3：查询标准食材

```java
// Service层
public StandardIngredient findStandardIngredientByName(String name) {
    return standardIngredientRepository.findByName(name)
            .orElseThrow(() -> new IllegalArgumentException("标准食材不存在: " + name));
}

public List<StandardIngredient> searchStandardIngredientsByName(String name) {
    return standardIngredientRepository.findByNameContainingIgnoreCase(name);
}
```

---

## 与其他模块的交互

### 依赖哪些模块？

1. **calotter-common**
   - 使用 `Result`、`BaseEntity` 等基础类
   - 使用标准库实体（`StandardIngredient`、`StandardSpice`、`StandardUtensil`）

2. **calotter-user**
   - 使用 `Household` 实体：所有库存都属于某个家庭
   - 依赖关系：inventory模块依赖user模块

### 被哪些模块使用？

1. **calotter-cooking（烹饪模块）**
   - 使用库存信息来生成AI烹饪推荐
   - 使用 `Ingredient`、`HouseholdSpice`、`HouseholdUtensil` 来构建厨房快照
   - 依赖关系：cooking模块依赖inventory模块

2. **calotter-health（健康模块）**
   - 可以从剩菜（`LeftoverDish`）记录营养摄入
   - 依赖关系：health模块依赖inventory模块

### 交互示例

**场景1**：烹饪模块获取家庭库存来生成推荐

```java
// 在 cooking 模块中
List<Ingredient> ingredients = ingredientRepository
    .findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
// 使用这些食材信息构建AI上下文
```

**场景2**：健康模块从剩菜记录营养

```java
// 在 health 模块中
LeftoverDish leftover = leftoverRepository.findById(leftoverId)
    .orElseThrow(() -> new IllegalArgumentException("剩菜不存在"));
// 使用剩菜的营养信息创建营养日志
```

---

## 开发指南

### 如何添加新功能？

#### 1. 添加新的库存类型

假设要添加"饮料"管理：

1. **在 common 模块添加标准库实体**（如果还没有）：
```java
@Entity
@Table(name = "ref_standard_beverages")
public class StandardBeverage extends BaseEntity {
    // ... 字段定义
}
```

2. **在 inventory 模块添加实体**：
```java
@Entity
@Table(name = "household_beverages")
public class HouseholdBeverage extends BaseEntity {
    @ManyToOne
    @JoinColumn(name = "household_id")
    private Household household;
    
    @ManyToOne
    @JoinColumn(name = "standard_beverage_id")
    private StandardBeverage metadata;
    
    private Double quantity;
    private String unit;
    // ... 其他字段
}
```

3. **添加Repository**：
```java
public interface HouseholdBeverageRepository extends JpaRepository<HouseholdBeverage, Long> {
    List<HouseholdBeverage> findByHouseholdId(Long householdId);
}
```

4. **在Service中添加方法**：
```java
public BeverageResponse createBeverage(BeverageRequest request) {
    // 业务逻辑
}
```

5. **在Controller中添加API**：
```java
@PostMapping("/beverages")
public Result<BeverageResponse> createBeverage(@RequestBody BeverageRequest request) {
    BeverageResponse response = inventoryService.createBeverage(request);
    return Result.success(response);
}
```

#### 2. 添加库存预警功能

在 `InventoryService` 中添加方法：

```java
public List<IngredientResponse> getExpiringIngredients(Long householdId, int days) {
    LocalDate threshold = LocalDate.now().plusDays(days);
    List<Ingredient> ingredients = ingredientRepository
            .findByHouseholdIdAndExpirationDateBefore(householdId, threshold);
    return ingredients.stream()
            .map(this::toIngredientResponse)
            .collect(Collectors.toList());
}
```

### 常见问题

#### Q1: 如何批量导入食材？

**A**: 可以添加批量创建方法：

```java
@Transactional
public List<IngredientResponse> createIngredientsBatch(List<IngredientRequest> requests) {
    List<IngredientResponse> responses = new ArrayList<>();
    for (IngredientRequest request : requests) {
        IngredientResponse response = createIngredient(request);
        responses.add(response);
    }
    return responses;
}
```

#### Q2: 如何实现库存自动扣减？

**A**: 可以在烹饪完成时自动扣减。在 `CookingSessionService` 中调用：

```java
// 烹饪完成后，根据使用的食材自动扣减库存
for (IngredientUsage usage : recipe.getIngredientUsages()) {
    inventoryService.deductIngredient(usage.getIngredientId(), usage.getAmount());
}
```

#### Q3: 如何查询即将过期的食材？

**A**: 在 `IngredientRepository` 中添加方法：

```java
@Query("SELECT i FROM Ingredient i WHERE i.household.id = :householdId " +
       "AND i.expirationDate BETWEEN :startDate AND :endDate")
List<Ingredient> findExpiringIngredients(
    @Param("householdId") Long householdId,
    @Param("startDate") LocalDate startDate,
    @Param("endDate") LocalDate endDate
);
```

---

## 测试

模块包含测试文件，位于 `src/test/java/com/calotter/inventory/`：

- `InventoryServiceTest.java`：库存服务测试

运行测试：
```bash
cd calotter-modules/calotter-inventory
mvn test
```

---

**文档结束** - 如有疑问，请查看[总览文档](./后端架构总览.md)或联系团队成员。

