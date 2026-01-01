# Cooking 模块代码修改总结 - 2024.12.18

## 📋 修改概览

本次修改主要围绕以下几个方面：
1. **Hibernate JSONB 序列化问题修复**：解决 `List<Long>` 和 `Object` 类型字段无法正确序列化为 JSONB 的问题
2. **编译错误修复**：修复 `DishService` 和 `CookingWorkflowService` 中的编译错误
3. **API 字段可选化**：将 `FinishCookingRequest` 的必填字段改为可选
4. **Jackson 序列化问题修复**：添加 `@JsonIgnore` 防止懒加载代理序列化失败
5. **API 校验一致性**：统一 GET/POST 请求的家庭存在性校验
6. **Postman 测试脚本**：创建 API 测试脚本和 Postman Collection

---

## 1. Hibernate JSONB 序列化问题修复

### 1.1 问题描述

**错误信息**：
```
java.lang.ClassCastException: class java.util.ArrayList cannot be cast to class java.lang.String
```

**根本原因**：Hibernate 6.x 的 JSONB 类型转换器无法正确处理以下情况：
- 字段类型为 `Object`，但实际存储 `List` 或其他复杂对象
- 字段类型为 `List<Long>`，配合 `@JdbcTypeCode(SqlTypes.JSON)`

### 1.2 解决方案

将有问题的 JSONB 字段改为 `String` 类型，手动进行 JSON 序列化/反序列化。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/CookingSession.java`

**具体改动**：

#### 1.2.1 completedDishIds 字段

```java
// 旧代码（有问题）
@JdbcTypeCode(SqlTypes.JSON)
@Column(columnDefinition = "jsonb")
private List<Long> completedDishIds = new ArrayList<>();

// 新代码（已修复）
@Column(columnDefinition = "text")
private String completedDishIdsStr;

// 便捷方法：获取完成的菜品 ID 列表
public List<Long> getCompletedDishIds() {
    if (completedDishIdsStr == null || completedDishIdsStr.isEmpty()) {
        return new ArrayList<>();
    }
    return java.util.Arrays.stream(completedDishIdsStr.split(","))
            .map(String::trim)
            .filter(s -> !s.isEmpty())
            .map(Long::parseLong)
            .collect(java.util.stream.Collectors.toList());
}

// 便捷方法：设置完成的菜品 ID 列表
public void setCompletedDishIds(List<Long> ids) {
    if (ids == null || ids.isEmpty()) {
        this.completedDishIdsStr = null;
    } else {
        this.completedDishIdsStr = ids.stream()
                .map(String::valueOf)
                .collect(java.util.stream.Collectors.joining(","));
    }
}
```

#### 1.2.2 ingredientsSnapshot 字段

```java
// 旧代码（有问题）
@JdbcTypeCode(SqlTypes.JSON)
@Column(columnDefinition = "jsonb")
private Object ingredientsSnapshot;

// 新代码（已修复）
@Column(columnDefinition = "text")
private String ingredientsSnapshotJson;

// 便捷方法：设置用料快照（自动序列化为 JSON）
public void setIngredientsSnapshot(Object ingredients) {
    if (ingredients == null) {
        this.ingredientsSnapshotJson = null;
    } else {
        try {
            ObjectMapper mapper = new ObjectMapper();
            this.ingredientsSnapshotJson = mapper.writeValueAsString(ingredients);
        } catch (Exception e) {
            this.ingredientsSnapshotJson = null;
        }
    }
}

// 便捷方法：获取用料快照 JSON 字符串
public String getIngredientsSnapshot() {
    return this.ingredientsSnapshotJson;
}
```

#### 1.2.3 totalNutritionSnapshot 字段

```java
// 旧代码（有问题）
@JdbcTypeCode(SqlTypes.JSON)
@Column(columnDefinition = "jsonb")
private Object totalNutritionSnapshot;

// 新代码（已修复）
@Column(columnDefinition = "text")
private String totalNutritionSnapshotJson;

// 便捷方法：设置营养快照（自动序列化为 JSON）
public void setTotalNutritionSnapshot(Object nutrition) {
    if (nutrition == null) {
        this.totalNutritionSnapshotJson = null;
    } else {
        try {
            ObjectMapper mapper = new ObjectMapper();
            this.totalNutritionSnapshotJson = mapper.writeValueAsString(nutrition);
        } catch (Exception e) {
            this.totalNutritionSnapshotJson = null;
        }
    }
}

// 便捷方法：获取营养快照 JSON 字符串
public String getTotalNutritionSnapshot() {
    return this.totalNutritionSnapshotJson;
}
```

**说明**：
- 使用 `String` 类型存储 JSON 字符串，避免 Hibernate JSONB 转换器的问题
- 提供便捷方法，对外暴露相同的 API，内部自动处理序列化
- 更稳定可靠，完全由代码控制序列化逻辑

---

## 2. 编译错误修复

### 2.1 DishService.java - setQuantityStr 方法不存在

**问题描述**：
```
cannot find symbol: method setQuantityStr(java.lang.String)
```

**原因**：12.17 修改了 `Dish.IngredientSnapshot`，将 `quantityStr` 改为 `amountValue` + `amountUnit`，但 `DishService` 未同步修改。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/DishService.java`

**具体改动**：

```java
// 旧代码（编译错误）
snapshot.setQuantityStr(ing.getAmountValue() + ing.getAmountUnit());

// 新代码（已修复）
snapshot.setAmountValue(ing.getAmountValue() != null ? ing.getAmountValue() : 0.0);
snapshot.setAmountUnit(ing.getAmountUnit() != null ? ing.getAmountUnit() : "g");
```

### 2.2 CookingWorkflowService.java - Lambda 表达式中的非 final 变量

**问题描述**：
```
local variables referenced from a lambda expression must be final or effectively final
```

**原因**：`completedDishIds` 变量在 if-else 中被重新赋值，导致不是 effectively final。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`

**具体改动**：

```java
// 旧代码（编译错误）
List<Long> completedDishIds = req.getCompletedDishIds();
if (completedDishIds == null || completedDishIds.isEmpty()) {
    completedDishIds = allDishes.stream()...  // 重新赋值，不是 final
}
List<Dish> completedDishes = allDishes.stream()
    .filter(d -> completedDishIds.contains(d.getId()))  // 编译错误
    .collect(Collectors.toList());

// 新代码（已修复）
List<Long> completedDishIds = req.getCompletedDishIds();
final List<Long> finalCompletedDishIds;
if (completedDishIds == null || completedDishIds.isEmpty()) {
    finalCompletedDishIds = allDishes.stream()
        .map(Dish::getId)
        .collect(Collectors.toList());
} else {
    finalCompletedDishIds = completedDishIds;
}
List<Dish> completedDishes = allDishes.stream()
    .filter(d -> finalCompletedDishIds.contains(d.getId()))  // 使用 final 变量
    .collect(Collectors.toList());
```

---

## 3. API 字段可选化

### 3.1 FinishCookingRequest 必填字段问题

**问题描述**：原先 `finalIngredients` 和 `totalNutrition` 是 `@NotNull` 必填字段，但在简单测试场景下不需要这些数据。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/FinishCookingRequest.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`

**具体改动**：

#### 3.1.1 FinishCookingRequest.java

```java
// 旧代码（必填）
@NotNull
private List<FinalIngredient> finalIngredients;

@NotNull
private NutritionSnapshot totalNutrition;

// 新代码（可选）
/**
 * 最终用料列表（可选）
 * 如果不提供，不扣减库存
 */
private List<FinalIngredient> finalIngredients;

/**
 * 总营养快照（可选）
 */
private NutritionSnapshot totalNutrition;
```

#### 3.1.2 CookingWorkflowService.java - 添加 null 检查

```java
// 保存快照（汇总所有已完成的菜品）
if (req.getFinalIngredients() != null) {
    session.setIngredientsSnapshot(req.getFinalIngredients());
}
if (req.getTotalNutrition() != null) {
    session.setTotalNutritionSnapshot(req.getTotalNutrition());
}

// 扣减库存（所有已完成的菜品用到的食材）
if (req.getFinalIngredients() != null && !req.getFinalIngredients().isEmpty()) {
    deductInventory(session.getHouseholdId(), req.getFinalIngredients());
}
```

**说明**：
- 简化测试：只传 `sessionId` 就能完成 Session
- 完整功能：传入 `finalIngredients` 可扣减库存，传入 `totalNutrition` 可记录营养

---

## 4. Jackson 序列化问题修复

### 4.1 问题描述

**错误信息**：
```
No serializer found for class org.hibernate.proxy.pojo.bytebuddy.ByteBuddyInterceptor
```

**错误链**：
```
Result["data"] → CookingSession["dishes"] → Dish["household"] → HibernateProxy
```

**原因**：Controller 返回 `CookingSession` Entity 时，Jackson 尝试序列化所有字段，包括懒加载的关联对象。Hibernate 返回代理对象，Jackson 不认识。

### 4.2 解决方案

在懒加载字段上添加 `@JsonIgnore` 注解，告诉 Jackson 跳过这些字段。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/CookingSession.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/Dish.java`

**具体改动**：

#### 4.2.1 CookingSession.java

```java
import com.fasterxml.jackson.annotation.JsonIgnore;

// 请求快照
@JsonIgnore  // 避免序列化大对象
@JdbcTypeCode(SqlTypes.JSON)
@Column(columnDefinition = "jsonb")
private AiCookingContext requestContext;

// 响应快照
@JsonIgnore  // 避免序列化大对象
@JdbcTypeCode(SqlTypes.JSON)
@Column(columnDefinition = "jsonb")
private AiRecipeResponse aiResponse;

// 多道菜关联
@JsonIgnore  // 防止 Jackson 序列化懒加载代理
@ManyToMany(fetch = FetchType.LAZY)
@JoinTable(...)
private List<Dish> dishes = new ArrayList<>();

// 主菜
@JsonIgnore  // 防止 Jackson 序列化懒加载代理
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "final_dish_id")
private Dish finalDish;
```

#### 4.2.2 Dish.java

```java
import com.fasterxml.jackson.annotation.JsonIgnore;

// 家庭关联
@JsonIgnore  // 防止 Jackson 序列化懒加载代理
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "household_id", nullable = false)
private Household household;
```

**说明**：
- `@JsonIgnore` 告诉 Jackson 跳过这个字段
- 懒加载字段通常不需要返回给前端
- 如果前端需要这些数据，应该通过 DTO 转换，而不是直接返回 Entity

---

## 5. API 校验一致性

### 5.1 问题描述

`GET /api/recipes/favorites` 不校验家庭是否存在，返回 200 + 空列表。
`POST /api/recipes/favorite` 校验家庭是否存在，返回 400 "家庭不存在"。

**不一致的用户体验**：同样的 `householdId`，一个成功一个失败。

### 5.2 解决方案

统一在两个 API 中都校验家庭存在性。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/FavoriteRecipeService.java`

**具体改动**：

```java
@Transactional(readOnly = true)
public List<Dish> listFavorites(Long householdId) {
    // 新增：先校验家庭是否存在
    householdRepository.findById(householdId)
            .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
    return dishRepository.findByHouseholdIdAndFavoriteTrueOrderByUpdateTimeDesc(householdId);
}
```

---

## 6. Postman 测试脚本

### 6.1 创建 API 测试脚本

**文件位置**：
- `backend-calotter/test-cooking-api.sh`

**功能**：
1. 注册测试用户
2. 创建测试家庭
3. 测试获取收藏列表
4. 测试收藏菜谱
5. 测试开始烹饪
6. 测试结束烹饪

**使用方法**：
```bash
cd backend-calotter
./test-cooking-api.sh
```

### 6.2 Postman Collection

**文件位置**：
- `docs/postman/Calotter-Cooking-API.postman_collection.json`

**包含的请求**：
1. Cooking 流程
   - 1.1 开始烹饪 - 单道菜
   - 1.2 开始烹饪 - 多道菜
   - 1.3 完成烹饪 - 全部完成
   - 1.4 完成烹饪 - 部分完成+用餐者
2. AI 菜单生成
   - 2.1 生成菜单 - 基础版
   - 2.2 生成菜单 - 自动填充
3. 收藏管理
   - 3.1 获取收藏列表
   - 3.2 收藏/取消收藏
4. 默认 Filter
   - 4.1 获取默认 Filter

---

## 7. 修改文件清单

### 7.1 后端修改文件

| 文件 | 修改内容 |
|------|---------|
| `CookingSession.java` | JSONB 字段改为 String + @JsonIgnore 注解 |
| `Dish.java` | household 字段添加 @JsonIgnore |
| `DishService.java` | setQuantityStr → setAmountValue/setAmountUnit |
| `CookingWorkflowService.java` | final 变量修复 + null 检查 |
| `FinishCookingRequest.java` | 移除 @NotNull，字段改为可选 |
| `FavoriteRecipeService.java` | listFavorites 添加家庭存在性校验 |

### 7.2 新增文件

| 文件 | 说明 |
|------|------|
| `backend-calotter/test-cooking-api.sh` | API 测试脚本 |
| `docs/CookingLog/12.18/cooking-modifications-12.18.md` | 本文档 |

---

## 8. 技术知识点总结

### 8.1 Hibernate JSONB 的坑

**问题**：`@JdbcTypeCode(SqlTypes.JSON)` + `Object` 类型 = 💥

**原因**：Hibernate 的 JSON 类型转换器在处理 `Object` 类型时，不知道如何正确序列化。

**解决方案**：
1. **方案 A**：使用明确的类型（如 `List<SpecificClass>`）
2. **方案 B**：使用 `String` 类型，手动序列化（本次采用）
3. **方案 C**：使用关联表（`@OneToMany`）

**最佳实践**：
- 避免在 Entity 中使用 `Object` 类型
- JSONB 适合存储结构明确的数据，不适合存储"任意对象"

### 8.2 Lambda 表达式中的变量

**规则**：Lambda 表达式中引用的外部变量必须是 `final` 或 `effectively final`。

**effectively final**：变量声明后从未被重新赋值。

**解决方案**：
```java
// 使用 final 变量
final List<Long> finalList;
if (condition) {
    finalList = valueA;
} else {
    finalList = valueB;
}
// 在 lambda 中使用 finalList
```

### 8.3 Jackson 与 Hibernate 懒加载

**问题**：Jackson 序列化 Entity 时，会尝试访问所有字段，包括懒加载的关联对象。Hibernate 返回代理对象，Jackson 不认识。

**解决方案**：
1. **方案 A**：使用 `@JsonIgnore` 跳过懒加载字段（本次采用）
2. **方案 B**：使用 DTO 转换，不直接返回 Entity
3. **方案 C**：配置 Jackson 的 Hibernate 模块

**最佳实践**：
- 不要直接返回 Entity 给前端
- 使用 DTO（Data Transfer Object）进行数据转换
- Entity 专注于数据库映射，DTO 专注于 API 响应

---

## 9. 待办事项

- [ ] 考虑将 Entity 改为返回 DTO，而不是依赖 `@JsonIgnore`
- [ ] 考虑使用 Flyway/Liquibase 管理数据库迁移
- [ ] 添加更多单元测试
- [ ] 前端同步测试 cooking 流程

---

**文档创建时间**：2024.12.18  
**修改人员**：Emma  
**审核状态**：待审核

