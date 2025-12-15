# 前端页面结构分析

## 一级页面（共 7 个）

一级页面是指直接通过应用入口、底部导航栏或主要路由访问的页面。

### 1. **LandingPage** (`pages/ums/auth/landing_page.dart`)
- **位置**: 应用入口（MaterialApp 的 home）
- **功能**: 登录/注册入口页面
- **导航**: 
  - → LoginPage
  - → RegistrationPage

### 2. **LoginPage** (`pages/ums/auth/login_page.dart`)
- **位置**: 从 LandingPage 进入
- **功能**: 用户登录
- **导航**: 
  - → MainScaffold (登录成功后)
  - ← LandingPage (Back 按钮)

### 3. **RegistrationPage** (`pages/ums/auth/registration_page.dart`)
- **位置**: 从 LandingPage 进入
- **功能**: 用户注册
- **导航**: 
  - ← LandingPage (Back 按钮)

### 4. **HomePage** (`pages/home/home_page.dart`)
- **位置**: MainScaffold 底部导航栏 "Home" (index 0)
- **功能**: 首页，显示营养信息和今日食谱
- **导航**: 无次级页面（使用 Dialog）

### 5. **RecipesHomePage** (`pages/recipes/recipes_home_page.dart`)
- **位置**: MainScaffold 底部导航栏 "Recipes" (index 1)
- **功能**: 食谱列表和生成
- **导航**: 
  - → RecipeFilterPage
  - → RecipeGeneratePage
  - → RecipeInstructionPage

### 6. **InventoryPage** (`pages/inventory/inventory_page.dart`)
- **位置**: MainScaffold 底部导航栏 "Kitchen" (index 3)
- **功能**: 库存管理（食材、调料、厨具）
- **导航**: 
  - → EditIngredientPage
  - → AddItemPage
  - → ReviewIngredientsPage

### 7. **ProfileViewPage** (`pages/ums/profile/profile_view_page.dart`)
- **位置**: MainScaffold 底部导航栏 "Me" (index 4)
- **功能**: 用户资料查看
- **导航**: 
  - → ProfileEditPage
  - → PreferencesListPage
  - → TaboosListPage
  - → AllergiesListPage
  - → SettingsPage

---

## 次级页面（共 12 个）

次级页面是指通过 `Navigator.push` 从一级页面进入的页面。

### 从 RecipesHomePage 进入：

#### 8. **RecipeFilterPage** (`pages/recipes/recipe_filter_page.dart`)
- **来源**: RecipesHomePage
- **功能**: 食谱筛选条件设置
- **导航**: ← RecipesHomePage

#### 9. **RecipeGeneratePage** (`pages/recipes/recipe_generate_page.dart`)
- **来源**: RecipesHomePage
- **功能**: 生成食谱菜单
- **导航**: 
  - → RecipeFilterPage (右上角 Filter)
  - → RecipeInstructionPage (查看生成的食谱)
  - ← RecipesHomePage

#### 10. **RecipeInstructionPage** (`pages/recipes/recipe_instruction_page.dart`)
- **来源**: RecipesHomePage 或 RecipeGeneratePage
- **功能**: 食谱制作步骤指导
- **导航**: 
  - → RecipeMealSummaryPage (完成所有食谱后)
  - ← RecipesHomePage / RecipeGeneratePage

#### 11. **RecipeMealSummaryPage** (`pages/recipes/recipe_meal_summary_page.dart`)
- **来源**: RecipeInstructionPage
- **功能**: 完成一餐后的总结页面
- **导航**: ← RecipeInstructionPage

### 从 InventoryPage 进入：

#### 12. **EditIngredientPage** (`pages/inventory/edit_ingredient_page.dart`)
- **来源**: InventoryPage
- **功能**: 编辑/添加食材
- **导航**: ← InventoryPage

#### 13. **AddItemPage** (`pages/add_item/add_item_page.dart`)
- **来源**: InventoryPage 或 MainScaffold 底部导航栏 "Add" (index 2)
- **功能**: 添加新物品（通过扫描或手动输入）
- **导航**: 
  - → ReviewIngredientsPage
  - ← InventoryPage / MainScaffold

#### 14. **ReviewIngredientsPage** (`pages/add_item/review_ingredients_page.dart`)
- **来源**: AddItemPage
- **功能**: 审核识别出的食材
- **导航**: 
  - → EditIngredientPage (编辑单个食材)
  - ← AddItemPage

### 从 ProfileViewPage 进入：

#### 15. **ProfileEditPage** (`pages/ums/profile/profile_edit_page.dart`)
- **来源**: ProfileViewPage
- **功能**: 编辑用户资料
- **导航**: ← ProfileViewPage

#### 16. **PreferencesListPage** (`pages/ums/preferences/preferences_list_page.dart`)
- **来源**: ProfileViewPage
- **功能**: 管理用户偏好
- **导航**: ← ProfileViewPage

#### 17. **TaboosListPage** (`pages/ums/preferences/taboos_list_page.dart`)
- **来源**: ProfileViewPage
- **功能**: 管理用户禁忌
- **导航**: ← ProfileViewPage

#### 18. **AllergiesListPage** (`pages/ums/preferences/allergies_list_page.dart`)
- **来源**: ProfileViewPage
- **功能**: 管理用户过敏信息
- **导航**: ← ProfileViewPage

#### 19. **SettingsPage** (`pages/ums/profile/settings_page.dart`)
- **来源**: ProfileViewPage
- **功能**: 设置页面（修改密码、退出登录、删除账户）
- **导航**: 
  - → LandingPage (退出登录后)
  - ← ProfileViewPage

---

## 特殊说明

### MainScaffold
- **位置**: `lib/main.dart`
- **功能**: 主应用框架，包含底部导航栏
- **包含的一级页面**: HomePage, RecipesHomePage, InventoryPage, ProfileViewPage
- **特殊处理**: AddItemPage 虽然列在 _pages 中，但实际通过 Navigator.push 打开

### Dialog 页面（不算独立页面）
- **AddFoodDialog** (`pages/home/add_food_dialog.dart`)
- **TodaysRecipesDialog** (`pages/home/todays_recipes_dialog.dart`)

---

## 总结

- **一级页面总数**: 7 个
  1. LandingPage
  2. LoginPage
  3. RegistrationPage
  4. HomePage
  5. RecipesHomePage
  6. InventoryPage
  7. ProfileViewPage

- **次级页面总数**: 12 个
  1. RecipeFilterPage
  2. RecipeGeneratePage
  3. RecipeInstructionPage
  4. RecipeMealSummaryPage
  5. EditIngredientPage
  6. AddItemPage
  7. ReviewIngredientsPage
  8. ProfileEditPage
  9. PreferencesListPage
  10. TaboosListPage
  11. AllergiesListPage
  12. SettingsPage

- **总页面数**: 19 个（不含 Dialog）
