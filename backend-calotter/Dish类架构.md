# Dish 实体类架构设计文档

## 📋 概述

采用 **Strategy A (快照模式)** 

**Dish（菜谱快照）** 将成为你系统中连接 AI 建议、实际烹饪、库存剩菜和历史摄入的核心锚点。它记录了"在那次特定的烹饪中，这道菜的客观物理属性"。

以下是基于需求（总质量、总热量、四大营养素、步骤、标签等）设计的 `Dish` 实体类，以及它在生态系统中的位置。

---

## 🔍 数据结构冲突分析与修正方案

### 1. 冲突分析结果

#### ✅ 无冲突的现有结构
- `BaseEntity` - 已存在，Dish 应该继承它
- `Household` 实体 - 已存在，可以使用 JPA 强引用关联
- `CookingSession` - 已存在，可以添加 Dish 引用同时保留 aiResponse 作为备份
- JSONB 存储方式 - 项目使用 `@JdbcTypeCode(SqlTypes.JSON)` 标准方式

#### ⚠️ 需要修改的地方

1. **Dish 实体类注解需要修正**
   - ❌ 架构文档中使用 `@Type(JsonType.class)` 和 `io.hypersistence.utils.hibernate.type.json.JsonType`
   - ✅ 应使用 `@JdbcTypeCode(SqlTypes.JSON)` 以符合现有项目规范（参考 CookingSession、FamilyMember 等实体）
   - ❌ 架构文档中使用 `Long householdId`
   - ✅ 应改为 `@ManyToOne Household household` 使用 JPA 强引用，符合项目规范

2. **DifficultyLevel 枚举不存在**
   - ❌ 架构文档中使用 `DifficultyLevel` 枚举，但现有代码中使用 `String difficulty`
   - ✅ 需要创建该枚举，或暂时使用 String（建议创建枚举以保持类型安全）

3. **CookingSession 需要添加 Dish 引用**
   - ❌ 现有 CookingSession 只有 `aiResponse` (JSONB) 和 `selectedDishName` (String)
   - ✅ 需要添加 `@ManyToOne Dish finalDish` 引用
   - ✅ 保留 `aiResponse` 作为原始备份（用于调试和审计）
   - 说明：Dish 是结构化数据，便于查询和关联；aiResponse 是原始 JSON，便于回溯

4. **LeftoverDish 需要重构**
   - ❌ 现有 LeftoverDish 包含：`name`, `coverImage`, `quantityGram`, `producedTime`, `household` 关联
   - ❌ 健康管理架构中提到需要 `caloriesPer100g` 字段
   - ✅ 引入 Dish 后，应该：
     - 添加 `@ManyToOne Dish originalDish` 强引用
     - 移除 `name` 和 `coverImage`（从 Dish 获取）
     - 保留 `quantityGram`（重命名为 `currentQuantityGram` 更清晰）
     - 保留 `producedTime`（记录制作时间）
     - 移除 `caloriesPer100g`（通过 Dish 计算）
     - 保留 `household` 关联（用于查询过滤）

5. **NutritionLog 的 referenceId 需要关联 Dish**
   - ❌ 健康管理架构中 `referenceId` 关联 `cooking_session_id` 或 `leftover_dish_id`
   - ✅ 引入 Dish 后，应该改为：
     - 将 `referenceId` 改为 `@ManyToOne Dish dish`（可空）
     - 当 `sourceType = APP_COOKING` 时，关联对应的 Dish
     - 当 `sourceType = LEFTOVER` 时，通过 LeftoverDish.originalDish 间接关联 Dish
     - 当 `sourceType = MANUAL` 或 `EXTERNAL` 时，dish 为 null

6. **内部类定义需要规范**
   - ❌ 架构文档中 CookingStep 和 IngredientSnapshot 定义为顶级类
   - ✅ 应该定义为静态内部类或独立的 DTO 类（参考 AiRecipeResponse 的结构）
   - ✅ 或者直接使用 AiRecipeResponse 中已定义的 CookingStep（需要统一）

7. **CookingStep 字段不一致**
   - ❌ 架构文档中 CookingStep 使用 `timerSeconds`
   - ✅ AiRecipeResponse.CookingStep 使用 `timeMin`（分钟）
   - 说明：需要在 Dish 中统一，建议使用 `timeMin` 与现有保持一致

### 2. 修正后的实体设计

#### Dish 实体类修正要点

```java
// ✅ 修正后的关键点：
// 1. 使用 @JdbcTypeCode(SqlTypes.JSON) 而不是 @Type(JsonType.class)
// 2. 使用 @ManyToOne Household 而不是 Long householdId
// 3. 继承 BaseEntity
// 4. CookingStep 和 IngredientSnapshot 定义为静态内部类
// 5. DifficultyLevel 需要创建枚举，或暂时使用 String
```

### 1. 核心实体类设计：Dish

这个类放在 `calotter-cooking` 模块中，因为它本质上是烹饪过程的产物。

**修正说明**：使用 JPA 强引用关联 `Household`，使用标准的 `@JdbcTypeCode` 注解，并继承 `BaseEntity`。

```java
package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

/**
 * Dish (菜谱快照/蓝图)
 * 代表一道已经生成的、具体的菜品配方。
 * 采用 Copy-on-Write 策略：每次配方微调都会生成新的 Dish 记录，
 * 以确保历史摄入记录和剩菜营养计算的绝对准确性。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "dishes")
public class Dish extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ✅ 修正：使用JPA强引用，而不是Long householdId
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    // --- 基础信息 ---
    @Column(nullable = false)
    private String name;      // 菜名 (e.g., "低脂版红烧肉")

    private String coverImage; // AI生成的图片或用户上传的图
    
    @Column(length = 1000)
    private String description; // 短描述

    // --- 核心物理属性 (Snapshot Metrics) ---
    /**
     * 总重量 (克)。
     * 极其重要：用于计算营养密度 (Density)。
     * Density = TotalCalories / TotalWeight
     */
    @Column(nullable = false)
    private Integer totalWeightGram; 

    // --- 总营养素 (Total Nutrients for the WHOLE dish) ---
    private Integer totalCalories; // kCal
    private Double totalProtein;   // g
    private Double totalFat;       // g
    private Double totalCarb;      // g
    private Double totalFiber;     // g

    // --- 烹饪元数据 ---
    private Integer cookingTimeMinutes;
    
    // ✅ 修正：需要创建DifficultyLevel枚举，或暂时使用String（建议创建枚举）
    @Enumerated(EnumType.STRING)
    private DifficultyLevel difficulty; // EASY, MEDIUM, HARD

    // --- 复杂结构 (使用 JSONB 存储) ---
    
    /**
     * 烹饪步骤
     * 结构: [{"stepNumber": 1, "instruction": "切肉...", "timeMin": 5}]
     */
    @JdbcTypeCode(SqlTypes.JSON) // ✅ 修正：使用标准注解
    @Column(columnDefinition = "jsonb")
    private List<CookingStep> steps;

    /**
     * 标签列表
     * 结构: ["Spicy", "Sichuan", "Keto-Friendly"]
     */
    @JdbcTypeCode(SqlTypes.JSON) // ✅ 修正：使用标准注解
    @Column(columnDefinition = "jsonb")
    private List<String> tags;

    /**
     * 原料清单的文本快照（快照模式，确保历史数据准确）
     * 结构: [{"name": "五花肉", "quantityStr": "500g"}, ...]
     */
    @JdbcTypeCode(SqlTypes.JSON) // ✅ 修正：使用标准注解
    @Column(columnDefinition = "jsonb")
    private List<IngredientSnapshot> ingredientSnapshots;

    // --- 辅助计算方法 (Domain Logic) ---
    
    /**
     * 计算每100克的卡路里 (用于剩菜估算)
     */
    public int getCaloriesPer100g() {
        if (totalWeightGram == null || totalWeightGram == 0 || totalCalories == null) {
            return 0;
        }
        return (int) ((totalCalories * 100.0) / totalWeightGram);
    }

    // ✅ 修正：定义为静态内部类
    @Data
    public static class CookingStep {
        private Integer stepNumber;
        private String instruction;
        private Integer timeMin; // ✅ 修正：与AiRecipeResponse.CookingStep保持一致，使用分钟
    }

    @Data
    public static class IngredientSnapshot {
        private String name;
        private String quantityStr; // "500g", "2勺"
    }
}

// ✅ 需要创建的枚举
enum DifficultyLevel {
    EASY, MEDIUM, HARD
}
```

---

###2. 关系重构：Dish 如何连接一切引入 `Dish` 后，你的数据模型变得非常清晰。这里是各实体的引用关系：

#### A. 烹饪会话 (CookingSession)

`Session` 现在只负责记录"谁、什么时候、发起了什么请求"，而具体的"结果"指向 `Dish`。

**修正说明**：添加 `finalDish` 引用，但保留 `aiResponse` (JSONB) 作为原始备份。

```java
public class CookingSession extends BaseEntity {
    // ... 其他字段保持不变
    
    // 保留 JSONB 作为原始备份（用于调试和审计）
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private AiRecipeResponse aiResponse;
    
    // ✅ 新增：核心业务逻辑指向 Dish（结构化数据，便于查询和关联）
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "final_dish_id")
    private Dish finalDish; 
    
    // selectedDishName 可以保留（用于快速显示），或从 finalDish.name 获取
    // private String selectedDishName; // 可选：保留用于快速查询
}
```

#### B. 剩菜 (LeftoverDish)

`LeftoverDish` 变得非常轻量，它不再需要存"这道菜原本有多少卡路里"，它只需要知道"我是哪道菜剩下的"以及"我还剩多重"。

**修正说明**：重构 LeftoverDish，关联 Dish 而不是直接存储营养信息。

```java
public class LeftoverDish extends BaseEntity { // ✅ 保留继承BaseEntity
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ✅ 保留：用于查询过滤
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    // ✅ 新增：强引用 Dish（核心变更）
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "original_dish_id", nullable = false)
    private Dish originalDish;

    // ✅ 重命名：quantityGram -> currentQuantityGram（更清晰）
    @Column(nullable = false)
    private Integer currentQuantityGram; // 剩了 300g

    // ✅ 保留：记录制作时间（用于判断新鲜度）
    @Column(nullable = false)
    private LocalDateTime producedTime;
    
    // ❌ 移除：name 和 coverImage（从 originalDish 获取）
    // ❌ 移除：caloriesPer100g（通过 originalDish 计算）
    
    // --- 辅助计算方法 ---
    
    /**
     * 获取剩菜名称（从原始Dish获取）
     */
    public String getName() {
        return originalDish != null ? originalDish.getName() : null;
    }
    
    /**
     * 获取剩菜封面图（从原始Dish获取）
     */
    public String getCoverImage() {
        return originalDish != null ? originalDish.getCoverImage() : null;
    }
    
    /**
     * 计算当前剩菜的总热量
     * 公式：currentQuantityGram * (originalDish.totalCalories / originalDish.totalWeightGram)
     */
    public Integer getCurrentCalories() {
        if (originalDish == null || originalDish.getTotalWeightGram() == null 
            || originalDish.getTotalCalories() == null || currentQuantityGram == null) {
            return 0;
        }
        double ratio = (double) currentQuantityGram / originalDish.getTotalWeightGram();
        return (int) (originalDish.getTotalCalories() * ratio);
    }
    
    /**
     * 计算每100克的卡路里（通过原始Dish计算）
     */
    public Integer getCaloriesPer100g() {
        return originalDish != null ? originalDish.getCaloriesPer100g() : 0;
    }
}
```

#### C. 营养日志 (NutritionLog) - ✅ 新增关联

引入 Dish 后，NutritionLog 应该关联 Dish 而不是 CookingSession 或 LeftoverDish。

**修正说明**：修改 NutritionLog 的 referenceId 为 Dish 引用。

```java
// 在 calotter-health 模块中
public class NutritionLog extends BaseEntity {
    // ... 其他字段
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "family_member_id", nullable = false)
    private FamilyMember familyMember;
    
    @Enumerated(EnumType.STRING)
    private LogSourceType sourceType; // APP_COOKING, LEFTOVER, MANUAL, EXTERNAL
    
    // ✅ 修正：关联 Dish 而不是 Long referenceId
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dish_id") // 可空：MANUAL和EXTERNAL类型可能没有Dish
    private Dish dish;
    
    // 说明：
    // - 当 sourceType = APP_COOKING 时，dish 指向烹饪产生的 Dish
    // - 当 sourceType = LEFTOVER 时，dish 指向 LeftoverDish.originalDish 对应的 Dish
    // - 当 sourceType = MANUAL 或 EXTERNAL 时，dish 为 null
}
```

#### D. 用户收藏 (UserFavorite / Cookbook) - 可选功能

收藏功能现在变得非常简单，直接关联 `Dish` 即可。

**说明**：这是可选功能，如果未来需要实现收藏，可以这样设计：

```java
// 可选：如果未来需要实现收藏功能
@Entity
@Table(name = "user_favorite_recipes")
public class UserFavoriteRecipe extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dish_id", nullable = false)
    private Dish dish; // 收藏了这个快照
    
    // 可以添加创建时间、备注等字段
}
```

---

###3. 业务逻辑流转 (The Workflow)现在，让我们看看引入 `Dish` 后，“烹饪完成”的逻辑变得多么顺畅：

1. **生成阶段**: AI 返回 JSON。
2. **创建快照**: 后端将 AI JSON 映射为 `Dish` 对象并 `save()`。
* *System*: `Dish id=501, Name="红烧肉", Weight=800g, Cals=2000...`


3. **计算摄入**:
* 用户 A 吃了 25% (200g)。
* `NutritionLog`: 引用 `Dish(501)`, Cal = 2000 * 0.25 = 500.


4. **处理剩菜**:
* 还剩 75% (600g)。
* 创建 `LeftoverDish`: 引用 `Dish(501)`, Quantity = 600g.


5. **次日食用剩菜**:
* 用户从冰箱拿出 `LeftoverDish`，吃了 300g。
* 后端计算：读取 `Dish(501)` 的数据。
* `Density` = 2000kcal / 800g = 2.5 kcal/g。
* 本次摄入 = 300g * 2.5 = 750 kcal。
* 创建 `NutritionLog`: Source=LEFTOVER, Ref=Dish(501).
* 更新 `LeftoverDish`: Quantity 变更为 300g。



---

## 📝 需要修改的文件清单

### 新建文件

1. **Dish 实体类**
   - `calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/Dish.java`
   - 包含内部类：`CookingStep`, `IngredientSnapshot`

2. **DifficultyLevel 枚举**
   - `calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/enums/DifficultyLevel.java`

3. **DishRepository**
   - `calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/repository/DishRepository.java`

### 修改现有文件

1. **CookingSession 实体**
   - `calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/CookingSession.java`
   - 添加字段：`@ManyToOne Dish finalDish`
   - 保留 `aiResponse` 和 `selectedDishName`（向后兼容）

2. **LeftoverDish 实体**
   - `calotter-modules/calotter-inventory/src/main/java/com/calotter/inventory/domain/entity/LeftoverDish.java`
   - 添加字段：`@ManyToOne Dish originalDish`
   - 移除字段：`name`, `coverImage`（从 Dish 获取）
   - 移除字段：`caloriesPer100g`（通过 Dish 计算）
   - 重命名字段：`quantityGram` -> `currentQuantityGram`
   - 添加辅助方法：`getName()`, `getCoverImage()`, `getCurrentCalories()`, `getCaloriesPer100g()`

3. **NutritionLog 实体**（在健康管理模块中）
   - `calotter-modules/calotter-health/src/main/java/com/calotter/health/domain/entity/NutritionLog.java`
   - 修改字段：`Long referenceId` -> `@ManyToOne Dish dish`（可空）

4. **健康管理架构文档中的业务逻辑**
   - 需要更新 `CookingSessionService.completeSession()` 方法：
     - 在创建 NutritionLog 时，设置 `dish` 而不是 `referenceId`
     - 在创建 LeftoverDish 时，设置 `originalDish` 而不是计算 `caloriesPer100g`

---

## ✅ 修正后的业务逻辑流程

### 烹饪完成流程（修正后）

1. **AI 生成阶段**: AI 返回 `AiRecipeResponse` JSON
2. **创建 Dish 快照**: 
   - 从 `AiRecipeResponse` 映射创建 `Dish` 对象
   - 保存 Dish 到数据库
   - 设置 `CookingSession.finalDish = dish`
   - 保留 `CookingSession.aiResponse` 作为原始备份

3. **计算摄入**:
   - 用户 A 吃了 25% (200g)
   - 创建 `NutritionLog`:
     - `dish = finalDish`
     - `sourceType = APP_COOKING`
     - `calories = dish.totalCalories * 0.25`

4. **处理剩菜**:
   - 还剩 75% (600g)
   - 创建 `LeftoverDish`:
     - `originalDish = finalDish`
     - `currentQuantityGram = 600`
     - `producedTime = 当前时间`
     - 无需存储 `caloriesPer100g`（通过 `originalDish.getCaloriesPer100g()` 计算）

5. **次日食用剩菜**:
   - 用户从冰箱拿出 `LeftoverDish`，吃了 300g
   - 后端计算：
     - 读取 `leftover.originalDish` 的数据
     - `density = originalDish.totalCalories / originalDish.totalWeightGram`
     - 本次摄入 = 300g * density
   - 创建 `NutritionLog`:
     - `dish = leftover.originalDish`
     - `sourceType = LEFTOVER`
   - 更新 `LeftoverDish`: `currentQuantityGram = 300g`

---

## 🎯 总结

引入 **Dish** 实体类并在其中包含 **TotalWeight** 和 **TotalNutrients** 是完美的解决方案。

* **解决了**: 剩菜营养计算困难的问题（通过密度计算，无需存储冗余数据）
* **解决了**: 收藏夹指向不明的问题（指向具体的 Dish 快照）
* **解决了**: 历史记录修改的问题（快照不可变，确保数据准确性）
* **解决了**: 数据冗余问题（LeftoverDish 不再需要存储 name、coverImage、caloriesPer100g）
* **统一了**: 营养数据来源（所有营养计算都基于 Dish 快照，保证一致性）

### 关键改进点

1. ✅ 使用 JPA 强引用替代弱引用（Household, Dish）
2. ✅ 使用标准 `@JdbcTypeCode` 注解替代第三方库
3. ✅ 保持数据一致性（Dish 作为唯一数据源）
4. ✅ 减少数据冗余（LeftoverDish 通过 Dish 计算属性）
5. ✅ 便于扩展（未来可以轻松添加收藏、分享等功能）

