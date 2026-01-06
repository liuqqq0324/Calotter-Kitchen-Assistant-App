# Cooking 模块代码修改总结 - 2026.01.06（1.6）

## 📋 修改概览（这次改动解决什么）

本次修改的核心目标是：**把 Cooking / Inventory / Health 之间“做饭记录数据”的数据契约彻底打稳**，并且让 filter（allergies / avoid / taboo）与 User 模块对齐，方便后续 Health 计算与 Inventory 展示。

主要完成了 5 大类改动：

1. **移除旧的 `/api/cooking/complete` 链路**：仓库里只保留 `/api/cooking/finish` 作为完成烹饪入口
2. **保证“每次做饭都有唯一 Dish 实例 ID”**：无论从 AI 菜单开始烹饪，还是从收藏/历史（dishId）开始烹饪，都会生成新的 Dish 快照
3. **收藏系统重构：收藏永远指向模板（TEMPLATE），做饭永远生成实例（INSTANCE）**
4. **Cooking filter 与 User 对齐 + 标准库强校验 + 模糊搜索接口**
5. **前端 Filter 页面改造：allergies/taboos/avoid 三类都只能从标准库选择（含模糊搜索）**

---

## 1) Cooking 完成接口：弃用/移除 `/complete`，统一到 `/finish`

### 1.1 背景
之前存在两套“完成做饭”的逻辑：
- `/api/cooking/finish`：前端实际使用的完成接口
- `/api/cooking/complete`：旧链路（后来路由已不存在，但 service/DTO/test 残留）

这会让工程师误以为仍然存在 `/complete`，并产生测试/接口契约混乱。

### 1.2 变更
- **确认全 repo 不存在** `@PostMapping("/complete")`
- 删除旧的 complete 链路残留代码/测试（见“文件清单”）
- 更新注释，明确 `/finish` 替代旧 `/complete`

### 1.3 影响
- 对前端无影响（前端已经使用 `/api/cooking/finish`）
- 后端代码更干净，避免未来 merge 时引入“死代码误用”

---

## 2) Dish 快照：每次做饭都生成新的 Dish 实例 ID（解决同名复用/营养归因错误）

### 2.1 目标
你明确要求：**每次吃的菜都有一个 id**，不能因为同名、同 household 而复用旧 Dish 记录，导致：
- 第二次做同一道菜仍然沿用旧 `dishId`
- 营养/步骤/食材变更后无法追溯
- leftover / health intake 关联混乱

### 2.2 关键逻辑（startCooking）
`StartCookingRequest` 有三种入口：
- `recipes`（Menu 多菜）
- `recipe`（单菜 DTO）
- `dishId`（从收藏/历史点进来）

本次做了以下保证：
- **recipes/recipe**：每个 recipe DTO 都会 `createDishSnapshot()` 生成新的 Dish（新 id）
- **dishId**：不再直接复用该 Dish，而是 `cloneDishSnapshot()` 克隆出一个新的 Dish（新 id）

这样无论从哪里开始 cooking，`CookingSession.dishes` 里永远是“本次实例 Dish”，每次都有独立 `dishId`。

---

## 3) Leftover 工作流确认（避免循环依赖 + 不再靠 title 反查）

### 3.1 目标
Cooking 结束后：
- 有一个 **Dish 实例快照（instance dishId）**
- Inventory 侧有一个 **LeftoverDish 自己的 id（leftoverId）**
- Leftover 里保存必要展示字段快照，避免 join/循环依赖

### 3.2 现状实现（finishCooking）
`/api/cooking/finish` 在完成时对每个完成的 Dish 实例创建 Leftover：
- `LeftoverDish.id`：数据库自增（leftoverId）
- `LeftoverDish.originalDishId`：指向本次 Dish 实例 `dishId`
- 快照字段：`dishName / coverImage / caloriesPer100g`
- 默认“100% 存入冰箱”的体现：`currentQuantityGram = dish.totalWeightGram`

> 注意：Leftover 当前没有显式 “percentage” 字段；百分比只能通过克数推导。

---

## 4) 收藏系统重构（最关键：收藏=模板，做饭=实例）

### 4.1 旧问题
历史实现里“收藏”是写在 `Dish.favorite` 布尔字段上，且 toggle 时按 title 去找 Dish：
- Dish 同名越来越多后，会随机命中某条（可能是某次烹饪快照）
- `Dish.favorite` 作为实体字段会与“收藏关系”语义冲突
- 无法支持后续扩展（收藏夹/标签/排序/多用户等）

### 4.2 新模型（核心语义）
- **模板 Dish（TEMPLATE）**：收藏永远指向模板；模板本身稳定
- **实例 Dish（INSTANCE）**：每次开始 cooking 生成实例（Copy-on-Write）
- **templateDishId**：实例记录其来源模板（用于追溯“这次做的这盘菜来自哪个收藏模板”）

### 4.3 数据结构变化
1) 新增收藏关系表（household 维度）：
- `household_favorite_dishes(household_id, dish_id)`，其中 `dish_id` 指向模板 Dish

2) Dish 增强字段：
- `dish_type`：`TEMPLATE` / `INSTANCE`
- `template_dish_id`：仅 INSTANCE 使用，指向 TEMPLATE dishId（模板自身为 null）

3) `Dish.favorite` 不再作为真相：
- 只用于兼容旧客户端/响应形态
- favorites 接口改为返回 DTO，favorite 由关系表派生

### 4.4 兼容与迁移策略（重要）
- **backfill**：如果历史数据中 `Dish.favorite=true`，会迁移到新关系表
  - 若历史 favorite 发生在 INSTANCE 上且没有 template 关联，会自动创建对应 TEMPLATE 再建立关系
- 这样保证旧数据不会“收藏突然消失”

---

## 5) Cooking filter 与 User 对齐（avoid vs taboo 分离 + 标准库 + 模糊搜索）

### 5.1 需求
你要求 Cooking 的 filter 与 User 模块一致：
- User 侧有 `allergies / avoidIngredients / taboos` 分离
- 三者都有标准库限制：用户只能输入标准库里存在的值
- 前端输入框支持模糊查询（如输入 `veg` → `vegetarian`）

### 5.2 后端对齐点

#### 5.2.1 Filter DTO 增强：DietPreferences 新增 `taboos`
- `RecipeGenerationFilter.DietPreferences` 新增字段：`taboos`
- 与原有字段分工：
  - `allergies`：过敏（RefAllergen 标准库）
  - `taboos`：硬性禁忌（PreferenceStandardLibrary.TABOO_OPTIONS）
  - `avoidIngredients`：软性避免食材（标准食材库 StandardIngredient）

#### 5.2.2 Default filter：从 User 默认值导入
`AiMenuService.getDefaultFilter(householdId)` 现在会分别导入：
- `User.allergies` → `dietPreferences.allergies`
- `User.dietaryStyles[TABOO]` → `dietPreferences.taboos`
- `User.dietaryStyles[AVOID_INGREDIENT]` → `dietPreferences.avoidIngredients`
- `User.preferences[TASTE/CUISINE]` → taste/cuisine preferences

#### 5.2.3 标准库严格校验（防止用户乱填导致 AI/后端数据污染）
新增 `RecipeFilterValidationService`，在 `AiMenuService.generateMenus()` 中强制校验：
- cuisine/taste 必须在 `PreferenceStandardLibrary` 里
- taboos 必须在 `PreferenceStandardLibrary.TABOO_OPTIONS`
- allergies 必须存在于 `ref_standard_allergens`
- avoidIngredients 必须存在于标准食材库（StandardIngredient）

校验失败会直接抛 `IllegalArgumentException`（返回 400），前端必须通过标准库选择来避免失败。

#### 5.2.4 AI Prompt 兼容策略
由于现有 AI prompt 明确处理的是 `allergies` + `avoidIngredients`：
- 发送给 AI 前，后端会把 `taboos` 合并进 `avoidIngredients`（仅用于 AI 输入兼容）
- 前端/UI 仍保持三类分开展示和提交

### 5.3 User 模块增强：标准库搜索接口（支持模糊查询）

为了前端输入框支持“模糊搜索”，新增/增强以下接口：

- **Allergens（标准过敏源）**
  - `GET /api/user/standard-allergens`
  - `GET /api/user/standard-allergens/search?name=pea&fuzzy=true`

- **Taboos（标准禁忌标签）**
  - `GET /api/user/standard-taboos`
  - `GET /api/user/standard-taboos/search?q=veg`

- **Avoid ingredients（标准避免食材）**
  - `GET /api/user/standard-avoid-ingredients/search?name=veg&fuzzy=true`
  - 注意：这里复用标准食材库（StandardIngredient），只提供“查找/选择”，不允许自由输入

同时收紧了 User 写接口校验：
- `PUT /api/user/taboos`：taboos 必须在标准库中，否则 400
- `PUT /api/user/allergies`：allergies 必须在标准过敏源库中，否则 400

---

## 6) 前端 Filter 页面改造（只能选标准值 + 模糊查询）

### 6.1 背景
原 Filter 页：
- allergies 已用标准库 Autocomplete（✅）
- taboo/avoid 使用一个 TextField 逗号分隔输入（❌ 用户可以乱填，后端会 400）

### 6.2 变更
`RecipeFilterPage` 现在拆成 3 块，并且都支持模糊查询 + Chip 列表：

1) **Allergies**
- 继续使用标准过敏源库 + Autocomplete + Chip

2) **Taboos（标准标签）**
- 使用标准 taboo 列表（前端 `StandardLibraryService.getStandardTaboos()`）
- 输入 `veg` 可提示 `vegetarian/vegan` 等

3) **Avoid ingredients（标准食材库）**
- 使用标准食材库（`StandardLibraryService.getStandardIngredients()`）
- 用户只能从标准食材名中选择

提交给后端时，payload 变为：
- `diet_preferences.allergies`
- `diet_preferences.taboos`
- `diet_preferences.avoid_ingredients`

并更新了 `RecipeApiService`：
- default-filter 解析增加 `taboos`
- generate-menus 请求体增加 `dietPreferences.taboos`

---

## 7) 文件改动清单（按模块，方便 merge）

### 7.1 后端（backend-calotter）

#### Cooking 模块
- **删除（弃用旧 complete 链路）**
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingSessionService.java`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/CookingCompletionRequest.java`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/CookingCompletionResponse.java`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/LeftoverAction.java`

- **修改**
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/CookingController.java`
    - 注释明确 `/finish` 取代旧 `/complete`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/FinishCookingRequest.java`
    - 注释明确取代旧 `CookingCompletionRequest`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/CookingWorkflowService.java`
    - startCooking：recipe(s) → 实例 Dish；dishId → clone 实例 Dish
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/Dish.java`
    - 新增 `dish_type` / `template_dish_id`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/repository/DishRepository.java`
    - 新增按模板查询方法
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/FavoriteController.java`
    - 返回 `DishDTO`（favorite 派生）
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/DishDTO.java`
    - 新增：用于 favorites 返回（避免 Dish.favorite 持久化漂移）
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/domain/entity/HouseholdFavoriteDish.java`
    - 新增：收藏关系表实体
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/repository/HouseholdFavoriteDishRepository.java`
    - 新增：收藏关系 repo
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/FavoriteRecipeService.java`
    - 收藏永远指向 TEMPLATE
    - cooking clone 生成 INSTANCE 并填 templateDishId
    - legacy favorite backfill
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/controller/dto/RecipeGenerationFilter.java`
    - dietPreferences 新增 `taboos`
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/RecipeFilterValidationService.java`
    - 新增：filter 标准库校验
  - `backend-calotter/calotter-modules/calotter-cooking/src/main/java/com/calotter/cooking/service/AiMenuService.java`
    - default filter 分离 taboos/avoid
    - generateMenus 入口做校验 + AI 输入兼容合并

#### User 模块
- `backend-calotter/calotter-modules/calotter-user/src/main/java/com/calotter/user/repository/RefAllergenRepository.java`
  - 新增 `findByNameContainingIgnoreCase`（模糊搜索）
- `backend-calotter/calotter-modules/calotter-user/src/main/java/com/calotter/user/repository/StandardIngredientRepository.java`
  - 新增：避免 user 模块依赖 inventory 模块（用于 avoid ingredients 搜索）
- `backend-calotter/calotter-modules/calotter-user/src/main/java/com/calotter/user/service/UserService.java`
  - taboos/allergies update 改为严格标准库校验
  - 新增标准库 search 方法（allergens/taboos/avoid ingredients）
- `backend-calotter/calotter-modules/calotter-user/src/main/java/com/calotter/user/controller/UserController.java`
  - 新增标准库搜索 API：
    - `/standard-allergens/search`
    - `/standard-taboos`, `/standard-taboos/search`
    - `/standard-avoid-ingredients/search`

#### Test 变更
- 删除旧 API test：
  - `backend-calotter/calotter-start/src/test/java/com/calotter/controller/CookingControllerApiTest.java`
- 删除旧 service test：
  - `backend-calotter/calotter-modules/calotter-cooking/src/test/java/com/calotter/cooking/service/CookingSessionServiceTest.java`
- 更新：
  - `backend-calotter/calotter-modules/calotter-cooking/src/test/java/com/calotter/cooking/service/CookingWorkflowServiceTest.java`
    - 适配 `createDishSnapshot/cloneDishSnapshot`

### 7.2 前端（frontend-app）
- `frontend-app/lib/pages/recipes/recipe_filter_page.dart`
  - taboos/avoid ingredients 改成标准库选择 + Autocomplete + Chip
  - payload 增加 `diet_preferences.taboos`
- `frontend-app/lib/services/recipe_api_service.dart`
  - default-filter 解析增加 `taboos`
  - generate-menus 请求体增加 `dietPreferences.taboos`

---

## 8) 数据库/迁移注意事项（给 merge 的人看）

### 8.1 新增表/字段（ddl-auto: update 会自动创建）
- 新表：`household_favorite_dishes`
- dishes 表新增列：`dish_type`, `template_dish_id`

### 8.2 旧数据兼容
- 若历史数据存在 `Dish.favorite=true`，favorites 列表会 backfill 到新关系表（必要时会生成 TEMPLATE）

---

## 9) 回归测试建议（快速验证）

1) **AI 默认 filter**
- 打开 Filter 页，确认能加载默认 allergies/taboos/avoid

2) **Filter 标准库选择**
- 输入 `veg`，taboos 自动提示 `vegetarian/vegan`
- 输入标准食材名片段，avoid ingredients 能提示并添加 Chip

3) **生成菜单**
- 使用 Filter 生成菜单，后端不应 400（若 400，通常是值不在标准库）

4) **收藏（模板）**
- 点击收藏，favorites 列表应可见
- 再次点击应取消收藏

5) **从收藏开始 cooking**
- 选择收藏菜谱开始做饭：startCooking 应生成新的 INSTANCE dishId（不复用模板 id）

6) **finish → leftovers**
- finish 后，inventory leftovers 应出现新记录：
  - `originalDishId` 对应本次 INSTANCE dishId
  - `currentQuantityGram` 默认等于 `Dish.totalWeightGram`

---

**文档创建时间**：2026.01.06  
**修改人员**：Emma  
**审核状态**：待审核


