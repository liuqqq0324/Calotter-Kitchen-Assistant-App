# Cooking 工作流修改总结

## ✅ 已完成的修改

### 1. 前端API路径统一
- ✅ 修改 `recipe_api_service.dart`：调用路径改为 `/api/ai/generate-menus`
- ✅ 修改 `favorite_recipes_api_service.dart`：调用路径改为 `/api/recipes/favorite` 和 `/api/recipes/favorites`
- ✅ 添加 `householdId` 参数支持
- ✅ 处理 `Result<T>` 响应格式

### 2. 后端库存扣减逻辑
- ✅ 在 `CookingWorkflowService.finishCooking()` 中添加库存扣减
- ✅ 实现 `deductInventory()` 方法：
  - 遍历 `finalIngredients`
  - 如果 `sourceType` 是 `INVENTORY`，匹配库存并扣减
  - 处理名称模糊匹配和单位转换

### 3. 后端自动填充功能
- ✅ 修改 `AiMenuController`：添加 `householdId` 参数
- ✅ 修改 `AiMenuService`：添加 `enrichFilterFromHousehold()` 方法
  - 自动填充 `inventory`（从 `IngredientRepository` 查询）
  - 自动填充 `cookers`（从 `HouseholdUtensilRepository` 查询）
  - 自动填充 `seasonings`（从 `HouseholdSpiceRepository` 查询）

### 4. 前端收藏功能更新
- ✅ 修改 `collected_recipes_store.dart`：添加 `householdId` 参数
- ✅ 修改 `FavoriteRecipesApiService`：
  - 添加 `toggleFavorite()` 方法
  - 添加 `_dishToRecipeModel()` 转换方法
  - 更新所有方法支持 `householdId`

## ⏳ 待完成的修改

### 1. 前端页面API调用
需要修改以下页面添加API调用：

#### `recipe_instruction_page.dart`
- [ ] 页面加载时调用 `/api/cooking/start` 创建session
- [ ] 保存 `sessionId` 用于后续完成烹饪
- [ ] 传递 `householdId` 和 `initiatorId`

#### `recipe_meal_summary_page.dart`
- [ ] 调用 `/api/cooking/finish` API
- [ ] 传递 `finalIngredients` 和 `totalNutrition`
- [ ] 处理响应并跳转

#### `recipes_home_page.dart`
- [ ] 调用收藏API时传递 `householdId`
- [ ] 从用户信息获取 `householdId`

#### `recipe_generate_page.dart`
- [ ] 调用生成API时传递 `householdId`

### 2. 后端Filter默认值API
- [ ] 新增 `GET /api/recipes/preferences/default?householdId={householdId}`
- [ ] 从 `FamilyMember` 和 `HealthGoal` 获取默认偏好
- [ ] 返回默认的filter配置

### 3. 前端Filter页面
- [ ] `recipe_filter_page.dart`：页面加载时调用API获取默认值
- [ ] 填充到表单中

### 4. 辅助功能
- [ ] 创建获取 `householdId` 的辅助函数（从userId获取）
- [ ] 或者修改后端API支持从userId自动获取householdId

## 📝 修改文件清单

### 前端文件（已修改）
- `lib/services/recipe_api_service.dart`
- `lib/services/favorite_recipes_api_service.dart`
- `lib/data/collected_recipes_store.dart`

### 后端文件（已修改）
- `controller/AiMenuController.java`
- `service/AiMenuService.java`
- `service/CookingWorkflowService.java`

### 前端文件（待修改）
- `lib/pages/recipes/recipe_instruction_page.dart`
- `lib/pages/recipes/recipe_meal_summary_page.dart`
- `lib/pages/recipes/recipes_home_page.dart`
- `lib/pages/recipes/recipe_generate_page.dart`
- `lib/pages/recipes/recipe_filter_page.dart`

### 后端文件（待创建/修改）
- `controller/FavoriteController.java`（可能需要调整）
- 新增 `controller/RecipePreferencesController.java`（Filter默认值API）

## 🔧 使用说明

### 前端调用示例

#### 生成菜单
```dart
final menus = await RecipeApiService.generateMenus(
  filter,
  householdId: householdId, // 需要传递householdId
);
```

#### 收藏/取消收藏
```dart
final result = await FavoriteRecipesApiService.toggleFavorite(
  recipe,
  householdId: householdId, // 需要传递householdId
);
```

#### 获取收藏列表
```dart
final favorites = await FavoriteRecipesApiService.fetchFavorites(
  householdId: householdId, // 需要传递householdId
);
```

### 后端API调用示例

#### 生成菜单（自动填充inventory）
```
POST /api/ai/generate-menus?householdId=1
Body: RecipeGenerationFilter (inventory/cookers/seasonings可为空，会自动填充)
```

#### 开始烹饪
```
POST /api/cooking/start
Body: {
  "householdId": 1,
  "initiatorId": 1,
  "recipe": {...} // 或 "dishId": 1
}
```

#### 完成烹饪
```
POST /api/cooking/finish
Body: {
  "sessionId": 1,
  "finalIngredients": [...],
  "totalNutrition": {...}
}
```

## ⚠️ 注意事项

1. **householdId获取**：前端需要从用户信息中获取householdId，可能需要：
   - 调用user API获取用户信息
   - 从FamilyMember中获取householdId
   - 或者后端API支持从userId自动获取

2. **单位转换**：库存扣减的单位转换逻辑是简化实现，实际应用中可能需要更精确的转换

3. **名称匹配**：库存扣减使用简单的字符串匹配，可能需要更智能的匹配算法

4. **错误处理**：所有API调用都需要添加错误处理

5. **数据一致性**：确保库存扣减和健康记录的数据一致性

