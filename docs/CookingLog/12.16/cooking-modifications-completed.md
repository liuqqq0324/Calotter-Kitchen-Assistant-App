# Cooking 工作流修改完成总结

## ✅ 已完成的修改

### 1. 前端API服务层
- ✅ **cooking_api_service.dart** (新建)
  - `startCooking()` - 创建烹饪session
  - `finishCooking()` - 完成烹饪并保存数据

- ✅ **household_service.dart** (新建)
  - `getHouseholdId()` - 从userId获取householdId
  - `getInitiatorId()` - 获取当前用户的initiatorId

- ✅ **recipe_api_service.dart** (修改)
  - 修改API路径为 `/api/ai/generate-menus`
  - 添加 `householdId` 参数支持
  - 处理 `Result<T>` 响应格式

- ✅ **favorite_recipes_api_service.dart** (修改)
  - 修改API路径为 `/api/recipes/favorite` 和 `/api/recipes/favorites`
  - 添加 `householdId` 参数支持
  - 添加 `toggleFavorite()` 方法
  - 添加 `_dishToRecipeModel()` 转换方法

- ✅ **collected_recipes_store.dart** (修改)
  - 所有方法添加 `householdId` 参数

### 2. 前端页面层
- ✅ **recipe_instruction_page.dart** (修改)
  - 添加 `_createCookingSession()` 方法
  - 在 `initState()` 中调用创建session
  - 保存 `sessionId` 用于后续完成烹饪
  - 修改 `_toggleCollectRecipe()` 使用 `householdId`
  - 修改 `_onMealDone()` 传递 `sessionId` 到summary页面

- ✅ **recipe_meal_summary_page.dart** (修改)
  - 添加 `sessionId` 参数
  - 修改 `_saveConsumption()` 调用 `finishCooking` API
  - 收集 `finalIngredients` 和 `totalNutrition` 数据

- ✅ **recipes_home_page.dart** (修改)
  - 修改 `_loadFavorites()` 使用 `householdId`

- ✅ **recipe_generate_page.dart** (修改)
  - 修改 `_fetchMenus()` 传递 `householdId`

### 3. 后端服务层
- ✅ **CookingWorkflowService.java** (修改)
  - 添加 `IngredientRepository` 依赖
  - 添加 `deductInventory()` 方法实现库存扣减
  - 添加 `convertUnit()` 方法处理单位转换
  - 在 `finishCooking()` 中调用库存扣减

- ✅ **AiMenuService.java** (修改)
  - 添加 `IngredientRepository`, `HouseholdSpiceRepository`, `HouseholdUtensilRepository` 依赖
  - 添加 `enrichFilterFromHousehold()` 方法
  - 自动填充 `inventory`, `cookers`, `seasonings`

- ✅ **AiMenuController.java** (修改)
  - 添加 `householdId` 可选参数

## 📋 修改文件清单

### 前端新建文件
- `lib/services/cooking_api_service.dart`
- `lib/services/household_service.dart`

### 前端修改文件
- `lib/services/recipe_api_service.dart`
- `lib/services/favorite_recipes_api_service.dart`
- `lib/data/collected_recipes_store.dart`
- `lib/pages/recipes/recipe_instruction_page.dart`
- `lib/pages/recipes/recipe_meal_summary_page.dart`
- `lib/pages/recipes/recipes_home_page.dart`
- `lib/pages/recipes/recipe_generate_page.dart`

### 后端修改文件
- `service/CookingWorkflowService.java`
- `service/AiMenuService.java`
- `controller/AiMenuController.java`

## ⏳ 待完成的工作

### 1. Filter默认值API（可选）
- [ ] 新增 `GET /api/recipes/preferences/default?householdId={householdId}`
- [ ] 从 `FamilyMember` 和 `HealthGoal` 获取默认偏好
- [ ] 前端 `recipe_filter_page.dart` 调用API获取默认值

### 2. CookingContextBuilderService优化（可选）
- [ ] 支持从 `RecipeGenerationFilter` 直接构建上下文
- [ ] 不再依赖 `memberIds`，改为从 `householdId` 获取所有成员

## 🔧 使用说明

### 前端调用流程

1. **生成菜单**
```dart
final householdId = await HouseholdService.getHouseholdId();
final menus = await RecipeApiService.generateMenus(filter, householdId: householdId);
```

2. **开始烹饪**
```dart
// 在recipe_instruction_page.dart的initState中自动调用
final sessionId = await CookingApiService.startCooking(
  householdId: householdId,
  initiatorId: initiatorId,
  recipe: recipeJson,
);
```

3. **完成烹饪**
```dart
// 在recipe_meal_summary_page.dart的_saveConsumption中调用
await CookingApiService.finishCooking(
  sessionId: sessionId,
  finalIngredients: finalIngredients,
  totalNutrition: totalNutrition,
);
```

4. **收藏/取消收藏**
```dart
final householdId = await HouseholdService.getHouseholdId();
final result = await FavoriteRecipesApiService.toggleFavorite(
  recipe,
  householdId: householdId,
);
```

### 后端API说明

1. **生成菜单** - `POST /api/ai/generate-menus?householdId={householdId}`
   - 如果提供了 `householdId`，会自动填充 `inventory`, `cookers`, `seasonings`
   - 如果filter中这些字段为空，会从household查询并填充

2. **开始烹饪** - `POST /api/cooking/start`
   - 创建 `CookingSession`
   - 返回 `sessionId`

3. **完成烹饪** - `POST /api/cooking/finish`
   - 保存快照
   - 扣减库存（如果 `sourceType` 是 `INVENTORY`）
   - 创建 `LeftoverDish`（初始100%）
   - 发布健康事件

## ⚠️ 注意事项

1. **householdId获取**：前端通过 `HouseholdService.getHouseholdId()` 获取，需要确保用户API返回householdId信息

2. **库存扣减**：
   - 只扣减 `sourceType` 为 `INVENTORY` 的食材
   - 使用名称模糊匹配
   - 单位转换是简化实现，可能需要优化

3. **错误处理**：所有API调用都添加了try-catch，失败时会显示错误提示

4. **数据一致性**：库存扣减和健康记录通过事件机制保持一致性

5. **Session管理**：前端在开始烹饪时创建session，完成时调用finish API

## 🎯 测试建议

1. 测试生成菜单时自动填充inventory/cookers/seasonings
2. 测试开始烹饪创建session
3. 测试完成烹饪时库存扣减
4. 测试收藏/取消收藏功能
5. 测试householdId获取逻辑

