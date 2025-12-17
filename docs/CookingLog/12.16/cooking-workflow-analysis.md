# Cooking 工作流检查与修改计划

## 一、当前代码结构分析

### 后端文件结构

#### Controller层
1. **CookingController.java** (`/api/cooking`)
   - `/generate-context` - 生成烹饪上下文（旧接口，可能不需要）
   - `/start` - 开始烹饪
   - `/finish` - 完成烹饪
   - `/complete` - 完成烹饪会话（带用餐者信息）

2. **AiMenuController.java** (`/api/ai`)
   - `/generate-menus` - 生成5套菜单（当前路径）

3. **FavoriteController.java** (`/api/recipes`)
   - `/favorite` - 收藏/取消收藏（POST，需要householdId参数）
   - `/favorites` - 获取收藏列表（GET，需要householdId参数）

#### Service层
1. **AiMenuService.java** - AI菜单生成服务
   - 调用Groq API生成菜单
   - 已有正确的prompt配置

2. **CookingWorkflowService.java** - 烹饪工作流服务
   - `startCooking()` - 创建CookingSession
   - `finishCooking()` - 完成烹饪，创建LeftoverDish，发布健康事件

3. **CookingSessionService.java** - 烹饪会话服务
   - `completeSession()` - 完成会话，处理剩菜和健康记录

4. **FavoriteRecipeService.java** - 收藏服务
   - `toggleFavorite()` - 切换收藏状态
   - `listFavorites()` - 获取收藏列表
   - `ensureDish()` - 确保Dish存在

5. **CookingContextBuilderService.java** - 上下文构建服务
   - `buildContext()` - 构建AI请求上下文（旧逻辑，基于memberIds）

6. **DishService.java** - Dish服务
   - `createDishFromAiResponse()` - 从AI响应创建Dish

#### Entity层
1. **Dish.java** - 菜谱实体
   - 包含完整的菜谱信息（营养、步骤、食材等）
   - 支持收藏标记（favorite字段）

2. **CookingSession.java** - 烹饪会话实体
   - 记录烹饪会话状态
   - 存储requestContext和aiResponse快照

#### DTO层
1. **RecipeGenerationFilter.java** - 食谱生成过滤器
   - 包含inventory, calorie_target, servings, diet_preferences等

2. **MenuDTO.java** - 菜单DTO
   - 包含menu_id和recipes列表
   - RecipeDTO包含完整的食谱信息

3. **StartCookingRequest.java** - 开始烹饪请求
   - householdId, initiatorId
   - dishId或recipe

4. **FinishCookingRequest.java** - 完成烹饪请求
   - sessionId
   - finalIngredients（最终用料）
   - totalNutrition（总营养）

5. **CookingCompletionRequest.java** - 完成会话请求
   - sessionId
   - diners（用餐者列表）
   - leftoverHandling（剩菜处理策略）

### 前端文件结构

#### Pages层
1. **recipes_home_page.dart** - 收藏食谱页
   - 展示收藏的食谱
   - Filter按钮
   - Start cooking按钮

2. **recipe_filter_page.dart** - Filter页面
   - 设置各种filter条件
   - 目前是纯前端逻辑，没有从后端获取默认值

3. **recipe_generate_page.dart** - 生成食谱页
   - 调用API生成5套菜单
   - 展示菜单列表
   - 选择菜单后Start cooking

4. **recipe_instruction_page.dart** - 烹饪指导页
   - 展示步骤和计时器
   - Mark done功能
   - 收藏/取消收藏单个菜单

5. **recipe_meal_summary_page.dart** - Meal summary页
   - 展示用掉的原材料
   - 目前只保存到本地，没有调用后端API

#### Services层
1. **recipe_api_service.dart** - 食谱API服务
   - `generateMenus()` - 调用 `/api/recipes/generate`（路径不匹配）

2. **favorite_recipes_api_service.dart** - 收藏API服务
   - 调用 `/api/users/me/favorite-recipes`（路径不匹配）

#### Data层
1. **collected_recipes_store.dart** - 收藏食谱存储
   - 管理收藏列表状态

## 二、发现的问题

### 1. API路径不匹配
- **问题1**: 前端调用 `/api/recipes/generate`，后端是 `/api/ai/generate-menus`
- **问题2**: 前端调用 `/api/users/me/favorite-recipes`，后端是 `/api/recipes/favorite` 和 `/api/recipes/favorites`
- **问题3**: 前端需要householdId，但API调用中没有传递

### 2. Filter功能不完整
- **问题1**: Filter页面没有从后端获取用户默认偏好数据
- **问题2**: Filter确认后没有保存为requestContext
- **问题3**: Filter需要支持household级别的数据获取

### 3. 生成食谱流程
- **问题1**: 前端调用路径错误
- **问题2**: 需要确保每次生成5套食谱（后端已实现）
- **问题3**: 需要根据household的ingredients生成（后端已有逻辑，但需要确认调用方式）

### 4. 开始烹饪流程
- **问题1**: 前端没有调用 `/api/cooking/start` API
- **问题2**: 前端直接跳转到instruction页面，没有创建session

### 5. 完成烹饪流程
- **问题1**: 前端meal summary页面没有调用后端API
- **问题2**: 需要保存leftover（生菜百分比100%）
- **问题3**: 需要保存营养数据到健康管理（后端已通过事件实现）
- **问题4**: 需要扣减库存（后端没有实现）

### 6. 库存管理
- **问题1**: 完成烹饪后需要根据ingredients的source_type扣减库存
- **问题2**: 如果source_type是INVENTORY，需要扣减；如果是MANUAL_ADD，只需要记录
- **问题3**: 需要区分库存已有和库存没有的情况

### 7. 收藏功能
- **问题1**: API路径不匹配
- **问题2**: 需要支持单个菜单的收藏/取消收藏（后端已支持）
- **问题3**: 收藏列表需要按householdId查询

## 三、修改计划

### 修改1: 统一API路径

#### 后端修改
1. **AiMenuController.java**
   - 将 `/api/ai/generate-menus` 改为 `/api/recipes/generate`
   - 或者保持原路径，前端改为调用 `/api/ai/generate-menus`

2. **FavoriteController.java**
   - 保持 `/api/recipes/favorite` 和 `/api/recipes/favorites`
   - 确保householdId通过RequestParam传递

#### 前端修改
1. **recipe_api_service.dart**
   - 修改 `generateMenus()` 调用路径为 `/api/ai/generate-menus` 或 `/api/recipes/generate`
   - 添加householdId参数

2. **favorite_recipes_api_service.dart**
   - 修改所有API调用路径为 `/api/recipes/favorite` 和 `/api/recipes/favorites`
   - 添加householdId参数

### 修改2: Filter功能完善

#### 后端新增
1. **新增API**: `GET /api/recipes/preferences/default?householdId={householdId}`
   - 从FamilyMember和HealthGoal获取默认偏好
   - 返回默认的filter配置

2. **修改CookingContextBuilderService.java**
   - 支持从RecipeGenerationFilter直接构建上下文
   - 不再依赖memberIds，改为从householdId获取所有成员

#### 前端修改
1. **recipe_filter_page.dart**
   - 页面加载时调用API获取默认值
   - 填充到表单中

2. **recipes_home_page.dart**
   - Filter确认后保存为requestContext（可以保存在state中）

### 修改3: 生成食谱流程

#### 后端修改
1. **AiMenuService.java**
   - 确保返回5套菜单（已实现）
   - 从RecipeGenerationFilter中获取inventory（需要从householdId查询）

2. **修改RecipeGenerationFilter处理**
   - 如果filter中没有inventory，根据householdId自动查询
   - 如果filter中没有cookers/seasonings，根据householdId自动查询

#### 前端修改
1. **recipe_api_service.dart**
   - 调用前确保inventory、cookers、seasonings已填充
   - 如果filter中没有，先调用inventory API获取

### 修改4: 开始烹饪流程

#### 后端修改
1. **CookingWorkflowService.java**
   - `startCooking()` 已实现，支持dishId或recipe

#### 前端修改
1. **recipe_instruction_page.dart**
   - 页面加载时调用 `/api/cooking/start` 创建session
   - 保存sessionId用于后续完成烹饪

2. **recipe_generate_page.dart**
   - Start cooking时传递recipe信息

### 修改5: 完成烹饪流程

#### 后端修改
1. **CookingWorkflowService.java**
   - `finishCooking()` 已实现创建leftover和发布健康事件
   - 需要添加库存扣减逻辑

2. **新增库存扣减服务**
   - 在finishCooking中，遍历finalIngredients
   - 如果source_type是INVENTORY，根据name匹配库存并扣减
   - 需要处理单位转换

#### 前端修改
1. **recipe_meal_summary_page.dart**
   - 调用 `/api/cooking/finish` API
   - 传递finalIngredients和totalNutrition
   - 处理响应并跳转

2. **recipe_instruction_page.dart**
   - Mark dish done时收集ingredients使用情况
   - 传递给meal summary页面

### 修改6: 库存扣减逻辑

#### 后端新增
1. **CookingWorkflowService.java**
   - 添加 `deductInventory()` 方法
   - 根据ingredient name匹配库存（模糊匹配）
   - 扣减对应数量
   - 处理单位转换（g, ml, piece）

2. **调用InventoryService**
   - 使用已有的 `deductIngredient()` 方法
   - 需要先根据name查找ingredient

### 修改7: Meal Summary数据展示

#### 后端修改
1. **新增API**: `GET /api/cooking/session/{sessionId}/summary`
   - 返回session的summary信息
   - 包括使用的ingredients（区分INVENTORY和MANUAL_ADD）

#### 前端修改
1. **recipe_meal_summary_page.dart**
   - 调用summary API获取数据
   - 展示库存已有和库存没有的区分

## 四、相关文件清单

### 后端文件

#### Controller
- `CookingController.java` - 烹饪控制器
- `AiMenuController.java` - AI菜单生成控制器
- `FavoriteController.java` - 收藏控制器

#### Service
- `AiMenuService.java` - AI菜单生成服务
- `CookingWorkflowService.java` - 烹饪工作流服务
- `CookingSessionService.java` - 烹饪会话服务
- `FavoriteRecipeService.java` - 收藏服务
- `CookingContextBuilderService.java` - 上下文构建服务
- `DishService.java` - Dish服务

#### Entity
- `Dish.java` - 菜谱实体
- `CookingSession.java` - 烹饪会话实体

#### DTO
- `RecipeGenerationFilter.java` - 食谱生成过滤器
- `MenuDTO.java` - 菜单DTO
- `StartCookingRequest.java` - 开始烹饪请求
- `FinishCookingRequest.java` - 完成烹饪请求
- `CookingCompletionRequest.java` - 完成会话请求

#### Repository
- `DishRepository.java` - Dish仓库
- `CookingSessionRepository.java` - CookingSession仓库

### 前端文件

#### Pages
- `recipes_home_page.dart` - 收藏食谱页
- `recipe_filter_page.dart` - Filter页面
- `recipe_generate_page.dart` - 生成食谱页
- `recipe_instruction_page.dart` - 烹饪指导页
- `recipe_meal_summary_page.dart` - Meal summary页

#### Services
- `recipe_api_service.dart` - 食谱API服务
- `favorite_recipes_api_service.dart` - 收藏API服务

#### Data
- `collected_recipes_store.dart` - 收藏食谱存储

#### Models
- `recipe_models.dart` - 食谱模型

## 五、优先级排序

### 高优先级（必须修改）
1. API路径统一（修改1）
2. 开始烹饪流程（修改4）
3. 完成烹饪流程（修改5）
4. 库存扣减逻辑（修改6）

### 中优先级（重要功能）
1. Filter功能完善（修改2）
2. 生成食谱流程（修改3）
3. Meal Summary数据展示（修改7）

### 低优先级（优化）
1. 收藏功能优化（已在修改1中涵盖）

## 六、注意事项

1. **尽量不动inventory/user/health代码**：只修改cooking部分
2. **不要随便改entity**：除非有必要添加字段
3. **Schema可以改**：但entity尽量保持稳定
4. **householdId传递**：所有API调用都需要传递householdId
5. **单位转换**：库存扣减时需要注意单位转换
6. **错误处理**：所有API调用都需要错误处理
7. **数据一致性**：确保库存扣减和健康记录的数据一致性

