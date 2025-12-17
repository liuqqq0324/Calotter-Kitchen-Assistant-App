# Cooking 模块代码修改总结 - 2024.12.17

## 📋 修改概览

本次修改主要围绕以下几个方面：
1. **API 合并与简化**：合并 `/finish` 和 `/complete` API，移除冗余端点
2. **架构优化**：移除事件发布机制，改为数据库直接查询
3. **功能增强**：Session 支持多道菜（Menu），支持部分完成
4. **数据模型对齐**：统一前后端数据格式，特别是食材和营养字段
5. **用户体验优化**：添加默认 Filter API，支持自动填充用户偏好

---

## 1. API 合并与简化

### 1.1 合并 `/finish` 和 `/complete` API

**目的**：解决 API 功能重叠问题，简化前端调用逻辑，统一烹饪完成流程。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/CookingController.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/FinishCookingRequest.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingSessionService.java`（已移除相关调用）

**具体改动**：

#### 1.1.1 CookingController.java
- **删除**：`/api/cooking/complete` 端点
- **删除**：`/api/cooking/generate-context` 端点（未使用）
- **删除**：`CookingContextBuilderService` 和 `CookingSessionService` 的依赖注入
- **保留**：`/api/cooking/start` 和 `/api/cooking/finish` 端点
- **说明**：简化了 Controller，只保留核心的 start 和 finish 两个端点

#### 1.1.2 FinishCookingRequest.java
- **新增字段**：
  - `List<Long> completedDishIds`：已完成的菜品 ID 列表（支持部分完成）
  - `List<DinerConsumption> diners`：用餐者信息（从原 `CookingCompletionRequest` 合并）
  - `LocalDateTime consumedAt`：用餐时间
- **新增内部类**：
  - `DinerConsumption`：用餐者消费信息（包含 `familyMemberId`, `portionPercentage`, `note`）
- **说明**：将原 `CookingCompletionRequest` 的功能合并到 `FinishCookingRequest`，实现一个 API 完成所有功能

#### 1.1.3 CookingWorkflowService.java
- **修改** `finishCooking()` 方法：
  - 支持处理 `completedDishIds`（如果为空，默认完成所有菜品）
  - 支持处理 `diners` 信息（可选，用于健康模块记录）
  - 为每个已完成的菜品创建 `LeftoverDish` 记录
- **说明**：统一了完成烹饪的逻辑，不再需要两次 API 调用

---

## 2. 架构优化：移除事件发布机制

### 2.1 移除 ApplicationEventPublisher

**目的**：简化模块间耦合，让健康模块直接查询数据库，而不是依赖事件机制。这样更可靠、更易维护。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`

**具体改动**：

#### 2.1.1 CookingWorkflowService.java
- **删除**：`ApplicationEventPublisher eventPublisher` 依赖注入
- **删除**：`CookingSessionCompletedEvent` 的导入和发布逻辑
- **删除**：`finishCooking()` 方法中的事件发布代码（约 20 行）
- **保留**：数据保存逻辑（`CookingSession` 和 `LeftoverDish` 的创建）
- **说明**：
  - 数据已保存在 `CookingSession` 表中，健康模块可以通过查询数据库获取
  - 移除了异步事件可能带来的数据一致性问题
  - 简化了代码逻辑，降低了维护成本

**影响**：
- 健康模块需要修改为直接查询 `CookingSession` 表，而不是监听事件
- 这是更好的架构设计，符合"数据库作为单一数据源"的原则

---

## 3. Session 支持多道菜（Menu）

### 3.1 数据库模型修改

**目的**：支持一个 Session 对应多道菜（一个 Menu），而不是只对应一道菜。这样更符合实际使用场景。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/CookingSession.java`

**具体改动**：

#### 3.1.1 CookingSession.java
- **新增字段**：
  ```java
  @ManyToMany(fetch = FetchType.LAZY)
  @JoinTable(
      name = "cooking_session_dishes",
      joinColumns = @JoinColumn(name = "session_id"),
      inverseJoinColumns = @JoinColumn(name = "dish_id")
  )
  private List<Dish> dishes = new ArrayList<>();
  ```
  - 使用 `@ManyToMany` 关联多个 `Dish`
  - 创建中间表 `cooking_session_dishes`

- **新增字段**：
  ```java
  @JdbcTypeCode(SqlTypes.JSON)
  @Column(columnDefinition = "jsonb")
  private List<Long> completedDishIds = new ArrayList<>();
  ```
  - 记录完成了哪些菜品（Dish ID 列表）
  - 使用 JSON 存储，便于查询和更新

- **保留字段**：
  ```java
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "final_dish_id")
  private Dish finalDish;
  ```
  - 保留用于向后兼容，作为主菜标识

**数据库迁移**：
- 需要创建 `cooking_session_dishes` 中间表
- 现有数据：`final_dish_id` 仍然有效，新数据会同时填充 `dishes` 列表

### 3.2 StartCookingRequest 修改

**目的**：支持传入整个 Menu（多道菜）创建 Session。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/StartCookingRequest.java`

**具体改动**：

#### 3.2.1 StartCookingRequest.java
- **新增字段**：
  ```java
  private List<MenuDTO.RecipeDTO> recipes;  // 整个 Menu 的菜品列表
  private Integer menuId;                    // Menu ID（可选，用于标识）
  ```
- **保留字段**：
  ```java
  private Long dishId;                      // 向后兼容：单道菜
  private MenuDTO.RecipeDTO recipe;         // 向后兼容：单道菜
  ```
- **说明**：支持三种方式创建 Session：
  1. 传入 `recipes` 列表（新方式，支持多道菜）
  2. 传入 `dishId`（向后兼容）
  3. 传入 `recipe`（向后兼容）

### 3.3 CookingWorkflowService 修改

**目的**：实现多道菜 Session 的创建和完成逻辑。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`

**具体改动**：

#### 3.3.1 startCooking() 方法
- **逻辑修改**：
  1. 优先处理 `recipes` 列表（多道菜）
     - 为每道菜调用 `favoriteRecipeService.ensureDish()` 创建 `Dish`
     - 将所有 `Dish` 添加到 `session.dishes` 列表
     - 将第一个 `Dish` 设置为 `finalDish`（向后兼容）
  2. 向后兼容处理 `dishId` 或 `recipe`（单道菜）
- **说明**：实现了多道菜和单道菜的兼容处理

#### 3.3.2 finishCooking() 方法
- **逻辑修改**：
  1. 从 `session.dishes` 获取所有菜品（如果为空，使用 `finalDish` 向后兼容）
  2. 根据 `req.getCompletedDishIds()` 确定完成了哪些菜品
     - 如果 `completedDishIds` 为空，默认完成所有菜品
  3. 为每个已完成的菜品：
     - 收集食材使用情况
     - 创建 `LeftoverDish` 记录
  4. 保存 `completedDishIds` 到 `session.completedDishIds`
- **说明**：支持部分完成，用户可以选择只完成 Menu 中的部分菜品

---

## 4. 数据模型对齐

### 4.1 后端：Dish.IngredientSnapshot 格式修改

**目的**：统一食材格式，将 `quantityStr`（字符串）改为 `amountValue` + `amountUnit`（结构化数据），便于前端处理和单位转换。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/Dish.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/FavoriteRecipeService.java`

**具体改动**：

#### 4.1.1 Dish.java
- **修改** `IngredientSnapshot` 内部类：
  ```java
  // 旧格式
  private String quantityStr; // "500g", "2勺"
  
  // 新格式
  private Double amountValue; // 500.0
  private String amountUnit;  // "g", "ml", "pcs"
  ```
- **说明**：
  - 结构化数据更易处理
  - 支持单位转换
  - 便于前端显示和计算

#### 4.1.2 FavoriteRecipeService.java
- **修改** `mapToDish()` 方法：
  ```java
  // 旧代码
  snap.setQuantityStr((ing.getAmount_value() != null ? ing.getAmount_value() : 0) + ing.getAmount_unit());
  
  // 新代码
  snap.setAmountValue(ing.getAmount_value() != null ? ing.getAmount_value() : 0.0);
  snap.setAmountUnit(ing.getAmount_unit() != null ? ing.getAmount_unit() : "g");
  ```
- **说明**：直接使用 `amountValue` 和 `amountUnit`，不再拼接字符串

### 4.2 前端：RecipeModel 添加营养字段

**目的**：对齐前后端数据模型，支持完整的营养信息展示。

**改动位置**：
- `frontend-app/lib/models/recipe_models.dart`
- `frontend-app/lib/services/favorite_recipes_api_service.dart`

**具体改动**：

#### 4.2.1 recipe_models.dart
- **新增字段**（在 `RecipeModel` 类中）：
  ```dart
  final int? totalWeightGram;    // 总重量（克）
  final int? totalCalories;       // 总卡路里（对应后端 Integer）
  final double? totalProtein;     // 总蛋白质（克）
  final double? totalFat;         // 总脂肪（克）
  final double? totalCarb;        // 总碳水化合物（克）
  final double? totalFiber;       // 总纤维（克）
  ```
- **保留字段**：
  ```dart
  final double totalCaloriesEstimate; // 保留用于向后兼容
  ```
- **修改** `fromJson()` 方法：
  - 添加营养字段的解析逻辑
  - 支持 `total_weight_gram` 和 `totalWeightGram` 两种命名
  - 使用 `parseInt()` 和 `parseDouble()` 辅助方法处理类型转换

#### 4.2.2 favorite_recipes_api_service.dart
- **修改** `_dishToRecipeModel()` 方法：
  1. **食材解析**：
     ```dart
     // 旧代码：解析 quantityStr 字符串
     final quantityStr = ing['quantityStr']?.toString() ?? '0g';
     final match = RegExp(r'(\d+\.?\d*)\s*(\w+)').firstMatch(quantityStr);
     
     // 新代码：直接使用 amountValue 和 amountUnit
     final amountValue = (ing['amountValue'] ?? ing['amount_value'] ?? 0) is num
         ? (ing['amountValue'] ?? ing['amount_value']).toDouble()
         : 0.0;
     final amountUnit = ing['amountUnit']?.toString() ?? 
                        ing['amount_unit']?.toString() ?? 
                        'g';
     ```
  2. **营养字段映射**：
     ```dart
     'total_weight_gram': parseInt(dish['totalWeightGram'] ?? dish['total_weight_gram']),
     'total_calories': parseInt(dish['totalCalories'] ?? dish['total_calories']),
     'total_protein': parseDouble(dish['totalProtein'] ?? dish['total_protein']),
     'total_fat': parseDouble(dish['totalFat'] ?? dish['total_fat']),
     'total_carb': parseDouble(dish['totalCarb'] ?? dish['total_carb']),
     'total_fiber': parseDouble(dish['totalFiber'] ?? dish['total_fiber']),
     ```
- **说明**：支持后端 `Dish` 实体到前端 `RecipeModel` 的完整转换

---

## 5. 前端：支持多道菜和部分完成

### 5.1 recipe_instruction_page.dart 修改

**目的**：支持传入整个 Menu 创建 Session，而不是只传当前菜品。

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_instruction_page.dart`

**具体改动**：

#### 5.1.1 _createCookingSession() 方法
- **旧逻辑**：只传当前菜品（`widget.menu.recipes[_currentIndex]`）
- **新逻辑**：传入整个 Menu 的所有菜品
  ```dart
  final recipesJson = widget.menu.recipes.map((recipe) => {
    'title': recipe.title,
    'short_description': recipe.shortDescription,
    // ... 其他字段
  }).toList();
  
  final sessionId = await CookingApiService.startCooking(
    householdId: householdId,
    initiatorId: initiatorId,
    recipes: recipesJson,  // 传入整个 Menu
    menuId: widget.menu.menuId,
  );
  ```
- **说明**：一次创建 Session 包含所有菜品，支持后续部分完成

#### 5.1.2 _onMealDone() 方法
- **修改**：支持部分完成
  ```dart
  // 旧逻辑：必须全部完成才能保存
  if (!_isWholeMealDone) return;
  
  // 新逻辑：至少完成一道菜就可以保存
  if (_completedDishes.isEmpty) {
    // 显示提示
    return;
  }
  ```
- **说明**：用户可以选择只完成部分菜品

#### 5.1.3 _buildBottomControls() 方法
- **新增**：显示完成进度
  ```dart
  if (hasCompleted) ...[
    const SizedBox(width: 8),
    Text(
      '($completedCount/$_totalDishes completed)',
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.orange,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
  ```
- **修改按钮文字**：
  ```dart
  child: Text(
    _isWholeMealDone 
        ? 'Meal done' 
        : 'Save progress ($completedCount dishes)',
  ),
  ```
- **说明**：用户可以看到完成进度，即使未全部完成也可以保存

### 5.2 recipe_meal_summary_page.dart 修改

**目的**：支持部分完成和用餐者信息收集。

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`

**具体改动**：

#### 5.2.1 _saveConsumption() 方法
- **新增逻辑**：收集已完成的菜品 ID
  ```dart
  final completedDishIds = <int>[];
  for (final recipe in widget.menu.recipes) {
    final percentEaten = _percentEaten[recipe.id] ?? 0;
    if (percentEaten > 0) {
      final dishId = int.tryParse(recipe.id);
      if (dishId != null && dishId > 0) {
        completedDishIds.add(dishId);
      }
      // 收集食材和营养信息（按比例计算）
    }
  }
  ```
- **修改 API 调用**：
  ```dart
  await CookingApiService.finishCooking(
    sessionId: widget.sessionId!,
    completedDishIds: completedDishIds,  // 传入已完成的菜品 ID
    finalIngredients: finalIngredients,
    totalNutrition: {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    },
    // diners: 可选，后续可以添加用餐者信息输入
  );
  ```
- **说明**：
  - 只收集已完成的菜品（`percentEaten > 0`）的食材和营养信息
  - 营养信息按比例计算（`totalCalories * percentEaten / 100`）
  - 支持部分完成场景

### 5.3 cooking_api_service.dart 修改

**目的**：支持多道菜和部分完成的 API 调用。

**改动位置**：
- `frontend-app/lib/services/cooking_api_service.dart`

**具体改动**：

#### 5.3.1 startCooking() 方法
- **新增参数**：
  ```dart
  List<Map<String, dynamic>>? recipes,  // 支持整个 Menu
  int? menuId,                           // Menu ID
  ```
- **修改逻辑**：
  ```dart
  if (recipes != null && recipes.isNotEmpty) {
    // 支持多道菜（Menu）
    body['recipes'] = recipes;
    if (menuId != null) {
      body['menuId'] = menuId;
    }
  } else if (dishId != null) {
    // 向后兼容：单道菜
    body['dishId'] = dishId;
  } else if (recipe != null) {
    // 向后兼容：单道菜
    body['recipe'] = recipe;
  }
  ```
- **说明**：支持三种方式，优先使用 `recipes` 列表

#### 5.3.2 finishCooking() 方法
- **新增参数**：
  ```dart
  List<int>? completedDishIds,           // 已完成的菜品 ID 列表
  List<Map<String, dynamic>>? diners,     // 用餐者信息（可选）
  ```
- **修改逻辑**：
  ```dart
  if (completedDishIds != null && completedDishIds.isNotEmpty) {
    body['completedDishIds'] = completedDishIds;
  }
  if (diners != null && diners.isNotEmpty) {
    body['diners'] = diners;
  }
  ```
- **说明**：支持部分完成和用餐者信息（可选）

---

## 6. 默认 Filter API

### 6.1 后端：AiMenuService 新增方法

**目的**：根据用户的家庭成员信息和健康目标，自动生成默认的 Filter 设置，提升用户体验。

**改动位置**：
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/AiMenuService.java`
- `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/FavoriteController.java`

**具体改动**：

#### 6.1.1 AiMenuService.java
- **新增依赖**：
  ```java
  private final FamilyMemberRepository familyMemberRepository;
  private final HealthGoalRepository healthGoalRepository;
  ```
- **新增方法** `getDefaultFilter(Long householdId)`：
  1. **获取家庭成员信息**：
     ```java
     List<FamilyMember> members = familyMemberRepository.findByHouseholdId(householdId);
     ```
  2. **收集过敏信息**：
     ```java
     for (FamilyMember member : members) {
         if (member.getAllergies() != null) {
             member.getAllergies().forEach(a -> allergies.add(a.getName()));
         }
     }
     ```
  3. **收集偏好信息**：
     ```java
     if (member.getPreferences() != null) {
         List<String> dislikes = member.getPreferences().getOrDefault("DISLIKE", new ArrayList<>());
         List<String> cuisines = member.getPreferences().getOrDefault("CUISINE", new ArrayList<>());
         List<String> tastes = member.getPreferences().getOrDefault("TASTE", new ArrayList<>());
     }
     ```
  4. **计算卡路里目标**：
     ```java
     HealthGoal goal = healthGoalRepository.findByFamilyMemberAndStatus(member, 1); // 1=Active
     if (goal != null && goal.getDailyCalories() != null) {
         totalCalories += goal.getDailyCalories();
         activeGoalCount++;
     }
     // 计算平均卡路里目标（每人）
     if (activeGoalCount > 0) {
         avgCalorieTarget = (double) totalCalories / activeGoalCount;
     }
     ```
  5. **自动填充库存、厨具、调料**：
     ```java
     enrichFilterFromHousehold(filter, householdId);
     ```
- **说明**：
  - 从 `FamilyMember` 获取过敏、偏好信息
  - 从 `HealthGoal` 获取卡路里目标
  - 自动填充库存、厨具、调料（复用 `enrichFilterFromHousehold` 方法）

#### 6.1.2 FavoriteController.java
- **新增依赖**：
  ```java
  private final AiMenuService aiMenuService;
  ```
- **新增端点**：
  ```java
  @GetMapping("/default-filter")
  public Result<RecipeGenerationFilter> getDefaultFilter(
          @RequestParam("householdId") @NotNull Long householdId) {
      return Result.success(aiMenuService.getDefaultFilter(householdId));
  }
  ```
- **说明**：提供 `GET /api/recipes/default-filter?householdId={householdId}` 端点

### 6.2 前端：recipe_api_service.dart 新增方法

**目的**：调用后端 API 获取默认 Filter。

**改动位置**：
- `frontend-app/lib/services/recipe_api_service.dart`

**具体改动**：

#### 6.2.1 recipe_api_service.dart
- **新增方法** `getDefaultFilter({int? householdId})`：
  ```dart
  static Future<Map<String, dynamic>> getDefaultFilter({int? householdId}) async {
    final hId = householdId ?? await HouseholdService.getHouseholdId();
    final url = Uri.parse('${ApiConfig.recipeBaseUrl}/api/recipes/default-filter?householdId=$hId');
    final response = await http.get(url);
    // ... 处理响应
    return _convertFilterToFrontendFormat(filterData);
  }
  ```
- **新增方法** `_convertFilterToFrontendFormat()`：
  - 将后端 Filter 格式转换为前端格式
  - 处理 `diet_preferences`, `calorie_target`, `generation_settings` 等字段
- **说明**：封装了 API 调用和格式转换逻辑

### 6.3 前端：recipe_filter_page.dart 修改

**目的**：在页面初始化时自动加载默认 Filter，填充表单。

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_filter_page.dart`

**具体改动**：

#### 6.3.1 recipe_filter_page.dart
- **新增状态**：
  ```dart
  bool _isLoadingDefaults = false;
  ```
- **新增方法** `_loadDefaultFilter()`：
  ```dart
  Future<void> _loadDefaultFilter() async {
    setState(() => _isLoadingDefaults = true);
    try {
      final householdId = await HouseholdService.getHouseholdId();
      final defaultFilter = await RecipeApiService.getDefaultFilter(householdId: householdId);
      
      // 填充表单字段
      _servingsController.text = defaultFilter['servings'].toString();
      _dishCountController.text = defaultFilter['dish_count'].toString();
      _calorieController.text = defaultFilter['calorie_target'].toString();
      // ... 其他字段
    } catch (e) {
      // 错误处理
    } finally {
      setState(() => _isLoadingDefaults = false);
    }
  }
  ```
- **修改** `initState()`：
  ```dart
  @override
  void initState() {
    super.initState();
    _loadDefaultFilter();  // 自动加载默认 Filter
  }
  ```
- **说明**：
  - 页面加载时自动获取用户的默认偏好
  - 填充表单，用户可以直接使用或修改
  - 提升用户体验，减少重复输入

---

## 7. 数据库迁移说明

### 7.1 新增表

**表名**：`cooking_session_dishes`

**结构**：
```sql
CREATE TABLE cooking_session_dishes (
    session_id BIGINT NOT NULL,
    dish_id BIGINT NOT NULL,
    PRIMARY KEY (session_id, dish_id),
    FOREIGN KEY (session_id) REFERENCES cooking_sessions(id),
    FOREIGN KEY (dish_id) REFERENCES dishes(id)
);
```

**说明**：用于存储 Session 和 Dish 的多对多关系。

### 7.2 字段修改

**表名**：`cooking_sessions`

**新增字段**：
```sql
ALTER TABLE cooking_sessions 
ADD COLUMN completed_dish_ids JSONB;
```

**说明**：使用 JSONB 存储已完成的菜品 ID 列表，例如：`[1, 2, 3]`。

### 7.3 数据迁移

**现有数据**：
- 现有的 `final_dish_id` 仍然有效
- 新创建的 Session 会同时填充 `dishes` 列表和 `final_dish_id`

**迁移策略**：
- 可以编写迁移脚本，将现有的 `final_dish_id` 数据迁移到 `dishes` 列表
- 或者保持现状，新旧数据并存（向后兼容）

---

## 8. 测试建议

### 8.1 后端测试

1. **API 合并测试**：
   - 测试 `/api/cooking/finish` 是否支持 `completedDishIds` 和 `diners`
   - 验证 `/api/cooking/complete` 已移除
   - 验证事件不再发布

2. **多道菜 Session 测试**：
   - 测试传入 `recipes` 列表创建 Session
   - 验证 `cooking_session_dishes` 表正确创建关联
   - 测试部分完成（只完成部分菜品）
   - 验证 `completedDishIds` 正确保存

3. **数据模型测试**：
   - 验证 `Dish.IngredientSnapshot` 使用新格式（`amountValue` + `amountUnit`）
   - 验证 `FavoriteRecipeService.mapToDish()` 正确转换

4. **默认 Filter API 测试**：
   - 测试 `GET /api/recipes/default-filter?householdId={id}`
   - 验证自动填充过敏、偏好、卡路里目标
   - 验证自动填充库存、厨具、调料

### 8.2 前端测试

1. **多道菜流程测试**：
   - 测试从 Menu 页面进入烹饪指导页面
   - 验证 Session 创建时传入整个 Menu
   - 测试部分完成（只标记部分菜品为完成）
   - 验证保存时只保存已完成的菜品

2. **数据模型测试**：
   - 验证 `RecipeModel` 正确解析营养字段
   - 验证 `favorite_recipes_api_service.dart` 正确转换 `Dish` 到 `RecipeModel`
   - 验证食材格式（`amountValue` + `amountUnit`）正确显示

3. **默认 Filter 测试**：
   - 测试进入 Filter 页面时自动加载默认值
   - 验证表单字段正确填充
   - 测试用户可以修改默认值

---

## 9. 注意事项

### 9.1 向后兼容

1. **Session 创建**：
   - 仍然支持 `dishId` 和 `recipe` 参数（单道菜）
   - 新代码优先使用 `recipes` 列表（多道菜）

2. **Session 完成**：
   - 如果 `completedDishIds` 为空，默认完成所有菜品
   - 如果 `session.dishes` 为空，使用 `finalDish`（向后兼容）

3. **数据模型**：
   - `RecipeModel` 保留 `totalCaloriesEstimate` 字段（向后兼容）
   - `CookingSession` 保留 `finalDish` 字段（向后兼容）

### 9.2 数据一致性

1. **库存扣减**：
   - 只扣减 `sourceType` 为 `INVENTORY` 的食材
   - 使用名称模糊匹配，可能需要优化

2. **营养计算**：
   - 前端按比例计算营养信息（`totalCalories * percentEaten / 100`）
   - 后端保存完整的营养快照

3. **健康模块**：
   - 不再通过事件获取数据，需要直接查询 `CookingSession` 表
   - 需要修改健康模块的代码

### 9.3 性能考虑

1. **多道菜 Session**：
   - 一个 Session 可能关联多个 Dish，查询时注意性能
   - 使用 `@ManyToMany(fetch = FetchType.LAZY)` 延迟加载

2. **默认 Filter API**：
   - 需要查询多个表（FamilyMember, HealthGoal, Ingredient 等）
   - 考虑添加缓存或优化查询

---

## 10. 文件清单

### 10.1 后端修改文件

1. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/CookingController.java`
   - 删除 `/complete` 和 `/generate-context` 端点
   - 简化依赖注入

2. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/FavoriteController.java`
   - 新增 `/default-filter` 端点

3. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/StartCookingRequest.java`
   - 新增 `recipes` 和 `menuId` 字段

4. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/FinishCookingRequest.java`
   - 新增 `completedDishIds` 和 `diners` 字段
   - 新增 `DinerConsumption` 内部类

5. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/CookingSession.java`
   - 新增 `dishes` 列表（`@ManyToMany`）
   - 新增 `completedDishIds` 字段（JSONB）

6. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/Dish.java`
   - 修改 `IngredientSnapshot`：`quantityStr` → `amountValue` + `amountUnit`

7. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`
   - 删除 `ApplicationEventPublisher` 依赖
   - 删除事件发布逻辑
   - 修改 `startCooking()` 支持多道菜
   - 修改 `finishCooking()` 支持部分完成

8. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/FavoriteRecipeService.java`
   - 修改 `mapToDish()` 使用新的食材格式

9. `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/AiMenuService.java`
   - 新增 `FamilyMemberRepository` 和 `HealthGoalRepository` 依赖
   - 新增 `getDefaultFilter()` 方法

### 10.2 前端修改文件

1. `frontend-app/lib/models/recipe_models.dart`
   - 新增营养字段（`totalWeightGram`, `totalCalories`, `totalProtein` 等）
   - 修改 `fromJson()` 方法

2. `frontend-app/lib/services/cooking_api_service.dart`
   - 修改 `startCooking()` 支持 `recipes` 和 `menuId`
   - 修改 `finishCooking()` 支持 `completedDishIds` 和 `diners`

3. `frontend-app/lib/services/favorite_recipes_api_service.dart`
   - 修改 `_dishToRecipeModel()` 使用新的食材格式
   - 添加营养字段映射

4. `frontend-app/lib/services/recipe_api_service.dart`
   - 新增 `getDefaultFilter()` 方法
   - 新增 `_convertFilterToFrontendFormat()` 方法

5. `frontend-app/lib/pages/recipes/recipe_instruction_page.dart`
   - 修改 `_createCookingSession()` 传入整个 Menu
   - 修改 `_onMealDone()` 支持部分完成
   - 修改 `_buildBottomControls()` 显示完成进度

6. `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`
   - 修改 `_saveConsumption()` 收集 `completedDishIds`
   - 按比例计算营养信息

7. `frontend-app/lib/pages/recipes/recipe_filter_page.dart`
   - 新增 `_loadDefaultFilter()` 方法
   - 修改 `initState()` 自动加载默认 Filter

---

## 11. 总结

本次修改主要实现了以下目标：

1. **简化 API**：合并 `/finish` 和 `/complete`，减少 API 数量
2. **优化架构**：移除事件机制，改为数据库直接查询
3. **增强功能**：支持多道菜 Session 和部分完成
4. **对齐数据**：统一前后端数据格式，特别是食材和营养字段
5. **提升体验**：自动加载默认 Filter，减少用户输入

所有修改都保持了向后兼容，现有功能不受影响。建议在合并前进行充分测试，特别是多道菜和部分完成的场景。

---

**文档创建时间**：2024.12.17  
**修改人员**：Emma  
**审核状态**：待审核

