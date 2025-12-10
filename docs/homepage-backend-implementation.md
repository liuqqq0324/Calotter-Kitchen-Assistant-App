# Homepage Backend Implementation Summary

## 概述

本文档总结了根据 `homepage-api.md` 需求实现的数据库结构和后端代码。

## 数据库设计

### Schema: `sous_chef_hp`

创建了新的schema用于存储Homepage相关的数据。

### 表结构

#### 1. `hp_nutrition_target` - 营养目标表
存储用户的周营养目标。

**主要字段：**
- `id`: 主键
- `user_id`: 用户ID（外键）
- `week_start`, `week_end`: 周的开始和结束日期
- `weekly_target_energy/fat/carbohydrates/protein`: 周目标值
- `bmi`: BMI值
- `goal_type`: 目标类型（fat_loss, muscle_gain, maintain等）
- `calculation_model`: 计算模型（mifflin_st_jeor等）

**索引：**
- `idx_nutrition_target_user_week`: 基于user_id和week_start的索引

#### 2. `hp_intake_record` - 摄入记录表
存储用户的摄入记录（来自菜谱或手动输入）。

**主要字段：**
- `id`: 主键
- `user_id`: 用户ID（外键）
- `date`: 摄入日期
- `source_type`: 来源类型（'recipe' 或 'manual'）
- `recipe_id`, `recipe_title`: 菜谱相关（如果source_type='recipe'）
- `manual_food_name`, `portion_description`: 手动输入相关（如果source_type='manual'）
- `consumed_percentage`: 消费百分比（0-100）
- `base_energy/fat/carbohydrates/protein`: 基础营养成分
- `effective_energy/fat/carbohydrates/protein`: 有效营养成分（基础值 × 消费百分比）

**索引：**
- `idx_intake_record_user_date`: 基于user_id和date的索引
- `idx_intake_record_user_week`: 用于周汇总查询的索引

#### 3. `hp_recipe_nutrition` - 菜谱营养成分表
存储菜谱的详细营养成分。

**主要字段：**
- `id`: 主键
- `recipe_id`: 菜谱ID（外键，唯一）
- `energy/fat/carbohydrates/protein`: 每份的营养成分

**索引：**
- `idx_recipe_nutrition_recipe_id`: 基于recipe_id的索引

## 后端代码结构

### Entity实体类

1. **NutritionTarget.java** - 营养目标实体
2. **IntakeRecord.java** - 摄入记录实体（包含自动计算有效营养成分的方法）
3. **RecipeNutrition.java** - 菜谱营养成分实体

### Repository接口

1. **NutritionTargetRepository.java**
   - `findByUserIdAndDate()`: 根据用户和日期查找营养目标
   - `findByUserIdAndWeekStart()`: 根据用户和周开始日期查找

2. **IntakeRecordRepository.java**
   - `findByUserIdAndDate()`: 根据用户和日期查找摄入记录
   - `findByUserIdAndDateAndSourceType()`: 根据用户、日期和来源类型查找
   - `findByUserIdAndDateRange()`: 根据用户和日期范围查找
   - `sumEffectiveNutritionByDateRange()`: 汇总指定日期范围内的有效营养成分

3. **RecipeNutritionRepository.java**
   - `findByRecipeId()`: 根据菜谱ID查找营养成分

### Service服务类

1. **NutritionService.java**
   - `getWeeklyNutritionTargets()`: 获取周营养目标（如果不存在则自动计算创建）
   - `getWeeklyNutritionSummary()`: 获取周营养摘要（已消费和剩余）
   - `calculateAndCreateNutritionTarget()`: 计算并创建营养目标
   - 使用Mifflin-St Jeor方程计算BMR
   - 根据BMI和目标类型调整卡路里

2. **IntakeService.java**
   - `getTodayIntakes()`: 获取今日摄入记录
   - `updateIntakePercentage()`: 更新摄入百分比
   - `addManualIntake()`: 添加手动摄入记录
   - `createIntakeFromRecipe()`: 从菜谱创建摄入记录

### Controller控制器

1. **NutritionController.java**
   - `GET /api/nutrition/targets/weekly`: 获取周营养目标
   - `GET /api/nutrition/summary?period=week`: 获取周营养摘要

2. **IntakeController.java**
   - `GET /api/intake/today?source=recipe|manual`: 获取今日摄入
   - `PATCH /api/intake/{intake_id}`: 更新摄入百分比
   - `POST /api/intake/manual`: 添加手动摄入

### DTO类

#### Nutrition DTOs
- `WeeklyNutritionTargetsResponse.java`: 周营养目标响应
- `WeeklyNutritionSummaryResponse.java`: 周营养摘要响应

#### Intake DTOs
- `TodayIntakesResponse.java`: 今日摄入响应
- `UpdateIntakeRequest.java`: 更新摄入请求
- `UpdateIntakeResponse.java`: 更新摄入响应
- `AddManualIntakeRequest.java`: 添加手动摄入请求
- `AddManualIntakeResponse.java`: 添加手动摄入响应

## API端点总结

### 1. 获取周营养目标
```
GET /api/nutrition/targets/weekly
Authorization: Bearer <accessToken>
```

### 2. 获取周营养摘要
```
GET /api/nutrition/summary?period=week
Authorization: Bearer <accessToken>
```

### 3. 获取今日摄入
```
GET /api/intake/today?source=recipe|manual
Authorization: Bearer <accessToken>
```

### 4. 更新摄入百分比
```
PATCH /api/intake/{intake_id}
Authorization: Bearer <accessToken>
Content-Type: application/json
Body: { "consumed_percentage": 80 }
```

### 5. 添加手动摄入
```
POST /api/intake/manual
Authorization: Bearer <accessToken>
Content-Type: application/json
Body: {
  "date": "2025-11-29",
  "food_name": "fried rice with egg",
  "portion_description": "1 bowl"
}
```

## 营养计算逻辑

### BMR计算（Mifflin-St Jeor方程）
- 男性: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
- 女性: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161

### 每日卡路里计算
- 基础代谢率 × 活动系数（默认1.55，中等活动水平）
- 周卡路里 = 日卡路里 × 7

### 目标调整
- BMI > 25: 减脂目标，卡路里减少15%
- BMI < 18.5: 增肌目标，卡路里增加15%
- 其他: 维持目标

### 宏量营养素分配
- 蛋白质: 1.0g/kg体重/天 × 7天
- 脂肪: 25%的卡路里 ÷ 9 kcal/g
- 碳水化合物: 剩余卡路里 ÷ 4 kcal/g

## 注意事项

1. **手动摄入的营养估算**: 当前实现使用简化的食物名称匹配来估算营养成分。生产环境应使用专业的食物数据库API（如USDA FoodData Central）。

2. **菜谱营养成分**: 如果`hp_recipe_nutrition`表中没有数据，系统会从`rms_recipe.calories_per_serving`估算，或使用默认值。

3. **周的开始和结束**: 周从周一开始，到周日结束。

4. **数据一致性**: 摄入记录的`effective_nutrition`值会在保存时自动计算，确保与`consumed_percentage`一致。

## 后续改进建议

1. 集成专业的食物营养成分数据库API
2. 支持更多营养计算模型（Harris-Benedict等）
3. 支持用户自定义目标类型和宏量营养素比例
4. 添加营养目标历史记录
5. 支持每日营养摘要（不仅仅是周）
6. 添加营养成分验证和异常检测
