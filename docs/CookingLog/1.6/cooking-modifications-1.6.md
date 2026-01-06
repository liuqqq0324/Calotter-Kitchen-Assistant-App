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

