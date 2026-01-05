# Cooking 模块代码修改总结 - 2026.01.05（1.5）

## 📋 修改概览

本次修改主要集中在 **前端 cooking 流程的可用性与一致性**，解决了以下问题：

1. **Summary 保存逻辑错误**：已 “Dish done” 但 Summary 提示 “Please mark at least one dish…”
2. **Summary 页面体验优化**：只展示已完成菜品；移除“吃了多少百分比”滑条
3. **保存后错误跳转**：Save record 后被弹回登录入口页（LandingPage）
4. **AI 生成菜单请求体不匹配**：前端请求字段/类型与后端 `RecipeGenerationFilter` 不一致导致 400
5. **多菜谱 timer 串台**：点击某个 dish 的 Step 1 timer，会把其它 dish 的 Step 1 timer 一并启动

---

## 1. Summary 保存 “未完成” 的错误修复

### 1.1 问题描述

Instruction 页已显示完成（例如 1/1 completed），但在 Summary 页点击 Save record 时提示：
`Please mark at least one dish as completed.`

### 1.2 根因分析

Summary 页原逻辑依赖 `int.tryParse(recipe.id)` 来构造 `completedDishIds`：
- 当 `recipe.id` 是非数字（例如 AI/本地生成常见的 `m1_r1`），解析失败导致 `completedDishIds` 为空
- 前端错误地用 “解析出的 completedDishIds 是否为空” 来判断是否完成

### 1.3 解决方案

将校验逻辑改为：**只要存在至少一道“被标记完成/被纳入 summary 的菜”即可保存**，不再依赖 `dishId` 是否可解析。

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`

---

## 2. Summary 页面只展示已完成菜品 + 移除百分比滑条

### 2.1 需求

1. Summary 里只显示 “mark dish done” 的菜
2. Summary 不需要显示 “吃菜百分比进度条/滑条”

### 2.2 解决方案

1. 新增 `completedDishIndexes` → 计算 `completedRecipes`，UI 与保存逻辑只遍历 `completedRecipes`
2. 移除每道菜的 percent 文本与 Slider；保存时按 **100% eaten** 处理

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`

---

## 3. Save record 后跳转到登录页的问题修复（并改为跳转到 My Recipes）

### 3.1 问题描述

Save record 后直接回到初始登录入口页。

### 3.2 根因分析

Summary 页曾使用：
`Navigator.popUntil(context, (route) => route.isFirst);`

但项目 `MaterialApp.home` 是 `LandingPage`（登录入口），所以 `route.isFirst` 会把用户弹回 LandingPage。

### 3.3 解决方案

Save record 成功后 **直接跳转到 My Recipes（Recipes tab）**：
- 通过 `Navigator.pushAndRemoveUntil(...)` 重置栈，避免回到 LandingPage
- 给 `MainScaffold` 增加 `initialIndex`，支持指定默认 tab

**改动位置**：
- `frontend-app/lib/main.dart`
- `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`

---

## 4. AI 菜单生成：请求体字段/类型对齐后端

### 4.1 问题描述

AI 生成菜单返回 400，后端提示：
“请求体格式错误，请检查 JSON 格式”

### 4.2 根因分析（关键点）

后端 `RecipeGenerationFilter.GenerationSettings.difficultyTarget` 是 **String**，
但前端 Filter 页面会把 `difficulty_target` 作为 **List<String>**（多选）传入，导致 Jackson 反序列化失败（`HttpMessageNotReadableException`）。

此外，前端 filter 常见存储结构是“顶层 snake_case”，而请求体 builder 原本只从 `generationSettings` 读取，导致 `dishCount` 可能被默认成 1。

### 4.3 解决方案

在 `RecipeApiService._buildRequestBody()` 中做归一化：
- `dishCount`：强制转 int（优先 generationSettings，其次顶层）
- `difficultyTarget`：若为 List，取第一个元素转 String
- 同时兼容顶层与 `generationSettings` 两种输入结构

**改动位置**：
- `frontend-app/lib/services/recipe_api_service.dart`

---

## 5. 多菜谱 timer 串台问题修复

### 5.1 问题描述

点击 dish A 的 step 1 timer，会连带启动 dish B/C 的 step 1 timer。

### 5.2 根因分析

计时器状态使用 `stepNumber`（1/2/3）作为 key：
- 不同 dish 的 stepNumber 相同 → Map key 冲突 → 状态串台

### 5.3 解决方案

把 timer/暂停/完成状态改成 **dishIndex + stepNumber** 的复合 key：
- key 形如 `"$dishIndex:$stepNumber"`
- 所有读取/写入统一使用这个 key

**改动位置**：
- `frontend-app/lib/pages/recipes/recipe_instruction_page.dart`

---

## 6. 修改文件清单

### 6.1 前端修改文件

- `frontend-app/lib/services/recipe_api_service.dart`
  - 生成菜单请求体归一化（`dishCount`、`difficultyTarget`、顶层/嵌套兼容）
- `frontend-app/lib/pages/recipes/recipe_instruction_page.dart`
  - timer 状态按 dish 维度隔离（复合 key）
- `frontend-app/lib/pages/recipes/recipe_meal_summary_page.dart`
  - Summary 仅展示已完成 dish
  - 移除 percent slider
  - 保存校验逻辑修复
  - 保存后跳转到 My Recipes（Recipes tab）
- `frontend-app/lib/main.dart`
  - `MainScaffold` 支持 `initialIndex`，便于从其它页面跳转到指定 tab

### 6.2 后端修改文件

本次没有新增后端代码改动（主要是前端请求体与后端 DTO 对齐、以及 cooking 流程 UI/交互修复）。

---

## 7. 测试建议（快速回归）

1. **AI 生成菜单**：设置 dish_count=3/4，确认每个 menu recipes 数量正确；无 400
2. **Cooking instruction timers**：在多 dish 菜单中，启动 dish1 step1，不影响 dish2 step1
3. **Dish done → Summary**：Summary 只展示已完成 dish，且无 percent slider
4. **Save record**：保存后跳转到 **My Recipes**，不回到 LandingPage

---

**文档创建时间**：2026.01.05  
**修改人员**：Emma  
**审核状态**：待审核


