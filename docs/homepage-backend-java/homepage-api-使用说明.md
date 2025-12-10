# Homepage API 使用说明文档

> ⚠️ **注意：本文档针对 backend-java 版本（旧版本）**
> 
> 如果你使用的是 calotter 项目，请查看：**`docs/calotter-homepage-使用说明.md`**
> 
> 当前项目推荐使用 calotter 版本，端口：10001

## 📋 目录
1. [概述](#概述)
2. [新建文件说明](#新建文件说明)
3. [数据库设置](#数据库设置)
4. [后端运行步骤](#后端运行步骤)
5. [API 接口说明](#api-接口说明)
6. [Postman 测试](#postman-测试)

---

## 概述

本文档说明如何运行和使用 Homepage 相关的营养追踪和摄入管理功能。该功能实现了以下核心能力：

- 📊 **周营养目标计算**：根据用户的身体数据（身高、体重、年龄、性别）自动计算周营养目标
- 📈 **营养摄入追踪**：记录用户每日的食物摄入（来自菜谱或手动输入）
- 📉 **营养摘要统计**：汇总周营养摄入情况，显示已消费和剩余目标

---

## 新建文件说明

### 📁 数据库文件（SQL脚本）

#### 1. `database/schema/hp/hp_schema_init.sql`
- **作用**：初始化 Homepage schema
- **说明**：创建 `sous_chef_hp` schema（如果不存在）

#### 2. `database/schema/hp/hp_nutrition_target.sql`
- **作用**：创建营养目标表
- **说明**：存储用户的周营养目标数据，包括能量、脂肪、碳水化合物、蛋白质的目标值

#### 3. `database/schema/hp/hp_intake_record.sql`
- **作用**：创建摄入记录表
- **说明**：存储用户的每日食物摄入记录，支持菜谱来源和手动输入两种方式

#### 4. `database/schema/hp/hp_recipe_nutrition.sql`
- **作用**：创建菜谱营养成分表
- **说明**：存储菜谱的详细营养成分信息（能量、脂肪、碳水化合物、蛋白质）

### 📁 后端实体类（Entity）

#### 1. `backend-java/src/main/java/com/souschef/entity/NutritionTarget.java`
- **作用**：营养目标实体类
- **说明**：对应数据库表 `hp_nutrition_target`，使用 JPA 注解映射

#### 2. `backend-java/src/main/java/com/souschef/entity/IntakeRecord.java`
- **作用**：摄入记录实体类
- **说明**：对应数据库表 `hp_intake_record`，包含自动计算有效营养成分的方法 `calculateEffectiveNutrition()`

#### 3. `backend-java/src/main/java/com/souschef/entity/RecipeNutrition.java`
- **作用**：菜谱营养成分实体类
- **说明**：对应数据库表 `hp_recipe_nutrition`，存储菜谱的营养信息

### 📁 数据访问层（Repository）

#### 1. `backend-java/src/main/java/com/souschef/repository/NutritionTargetRepository.java`
- **作用**：营养目标数据访问接口
- **主要方法**：
  - `findByUserIdAndDate()`：根据用户ID和日期查找营养目标
  - `findByUserIdAndWeekStart()`：根据用户ID和周开始日期查找

#### 2. `backend-java/src/main/java/com/souschef/repository/IntakeRecordRepository.java`
- **作用**：摄入记录数据访问接口
- **主要方法**：
  - `findByUserIdAndDate()`：查找用户某日的摄入记录
  - `findByUserIdAndDateAndSourceType()`：按来源类型筛选
  - `findByUserIdAndDateRange()`：查找日期范围内的记录
  - `sumEffectiveNutritionByDateRange()`：汇总日期范围内的有效营养成分

#### 3. `backend-java/src/main/java/com/souschef/repository/RecipeNutritionRepository.java`
- **作用**：菜谱营养成分数据访问接口
- **主要方法**：
  - `findByRecipeId()`：根据菜谱ID查找营养成分

### 📁 数据传输对象（DTO）

#### Nutrition 相关 DTO
1. **`dto/nutrition/WeeklyNutritionTargetsResponse.java`**
   - 周营养目标响应对象

2. **`dto/nutrition/WeeklyNutritionSummaryResponse.java`**
   - 周营养摘要响应对象

#### Intake 相关 DTO
3. **`dto/intake/TodayIntakesResponse.java`**
   - 今日摄入响应对象

4. **`dto/intake/UpdateIntakeRequest.java`**
   - 更新摄入百分比请求对象

5. **`dto/intake/UpdateIntakeResponse.java`**
   - 更新摄入响应对象

6. **`dto/intake/AddManualIntakeRequest.java`**
   - 添加手动摄入请求对象

7. **`dto/intake/AddManualIntakeResponse.java`**
   - 添加手动摄入响应对象

### 📁 业务逻辑层（Service）

#### 1. `backend-java/src/main/java/com/souschef/service/NutritionService.java`
- **作用**：营养相关业务逻辑
- **主要功能**：
  - `getWeeklyNutritionTargets()`：获取或计算周营养目标
  - `getWeeklyNutritionSummary()`：获取周营养摘要（已消费和剩余）
  - `calculateAndCreateNutritionTarget()`：根据用户数据计算营养目标
  - 使用 **Mifflin-St Jeor 方程**计算 BMR（基础代谢率）
  - 根据 BMI 自动调整目标类型（减脂/增肌/维持）

#### 2. `backend-java/src/main/java/com/souschef/service/IntakeService.java`
- **作用**：摄入记录管理业务逻辑
- **主要功能**：
  - `getTodayIntakes()`：获取今日摄入记录
  - `updateIntakePercentage()`：更新摄入百分比
  - `addManualIntake()`：添加手动摄入记录
  - `createIntakeFromRecipe()`：从菜谱创建摄入记录
  - 自动计算有效营养成分（基础值 × 消费百分比）

### 📁 控制器层（Controller）

#### 1. `backend-java/src/main/java/com/souschef/controller/NutritionController.java`
- **作用**：营养相关 API 控制器
- **路由前缀**：`/api/nutrition`
- **接口**：
  - `GET /api/nutrition/targets/weekly`：获取周营养目标
  - `GET /api/nutrition/summary?period=week`：获取周营养摘要

#### 2. `backend-java/src/main/java/com/souschef/controller/IntakeController.java`
- **作用**：摄入记录相关 API 控制器
- **路由前缀**：`/api/intake`
- **接口**：
  - `GET /api/intake/today?source=recipe|manual`：获取今日摄入
  - `PATCH /api/intake/{intake_id}`：更新摄入百分比
  - `POST /api/intake/manual`：添加手动摄入

---

## 数据库设置

### 步骤 1：创建 Schema 和表

在 PostgreSQL 数据库中执行以下 SQL 脚本（按顺序执行）：

```bash
# 1. 创建 schema
psql -U postgres -d souschef_db -f database/schema/hp/hp_schema_init.sql

# 2. 创建营养目标表
psql -U postgres -d souschef_db -f database/schema/hp/hp_nutrition_target.sql

# 3. 创建摄入记录表
psql -U postgres -d souschef_db -f database/schema/hp/hp_intake_record.sql

# 4. 创建菜谱营养成分表
psql -U postgres -d souschef_db -f database/schema/hp/hp_recipe_nutrition.sql
```

或者使用数据库客户端（如 pgAdmin、DBeaver）直接执行这些 SQL 文件。

### 步骤 2：验证表创建

执行以下 SQL 查询验证表是否创建成功：

```sql
-- 查看 schema
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'sous_chef_hp';

-- 查看表
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'sous_chef_hp' 
ORDER BY table_name;
```

应该看到以下三个表：
- `hp_nutrition_target`
- `hp_intake_record`
- `hp_recipe_nutrition`

---

## 后端运行步骤

### 前置条件

1. ✅ Java 17 或更高版本
2. ✅ Maven 3.6+
3. ✅ PostgreSQL 数据库已运行
4. ✅ 数据库连接配置正确（`application.yml`）

### 步骤 1：检查数据库配置

打开 `backend-java/src/main/resources/application.yml`，确认数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/souschef_db
    username: postgres
    password: mysecretpassword
```

### 步骤 2：编译项目

```bash
cd backend-java
mvn clean compile
```

### 步骤 3：运行应用

```bash
mvn spring-boot:run
```

或者使用 IDE（如 IntelliJ IDEA）直接运行 `SousChefBackendApplication.java`

### 步骤 4：验证服务启动

查看控制台输出，应该看到类似信息：

```
Started SousChefBackendApplication in X.XXX seconds
```

默认端口：**8080**（可在 `application.yml` 中修改）

### 步骤 5：测试健康检查

```bash
curl http://localhost:8080/hello
```

如果返回响应，说明服务已成功启动。

---

## API 接口说明

### 🔐 认证要求

所有 API 都需要在请求头中包含 JWT Token：

```
Authorization: Bearer <your_access_token>
```

获取 Token 的方法：先调用登录接口 `/api/ums/auth/login`

### 1. 获取周营养目标

**接口**：`GET /api/nutrition/targets/weekly`

**请求头**：
```
Authorization: Bearer <accessToken>
```

**响应示例**：
```json
{
  "weekly_target": {
    "energy": 12600,
    "fat": 350,
    "carbohydrates": 1400,
    "protein": 560
  },
  "basis": {
    "bmi": 22.3,
    "goal_type": "fat_loss",
    "calculation_model": "mifflin_st_jeor",
    "week_start": "2025-11-24",
    "week_end": "2025-11-30"
  }
}
```

**说明**：
- 如果用户当前周没有营养目标，系统会自动根据用户的身体数据计算并创建
- 计算基于用户的年龄、性别、身高、体重

### 2. 获取周营养摘要

**接口**：`GET /api/nutrition/summary?period=week`

**请求头**：
```
Authorization: Bearer <accessToken>
```

**查询参数**：
- `period`：固定为 `week`（目前只支持周）

**响应示例**：
```json
{
  "period": "week",
  "week_start": "2025-11-24",
  "week_end": "2025-11-30",
  "consumed": {
    "energy": 4200,
    "fat": 120,
    "carbohydrates": 480,
    "protein": 180
  },
  "remaining": {
    "energy": 8400,
    "fat": 230,
    "carbohydrates": 920,
    "protein": 380
  }
}
```

**说明**：
- `consumed`：本周已消费的营养成分
- `remaining`：剩余的营养目标（目标值 - 已消费）

### 3. 获取今日摄入

**接口**：`GET /api/intake/today?source=recipe|manual`

**请求头**：
```
Authorization: Bearer <accessToken>
```

**查询参数**：
- `source`：可选值
  - `recipe`：只返回菜谱来源的摄入
  - `manual`：只返回手动输入的摄入
  - `all` 或不传：返回所有来源的摄入

**响应示例（菜谱来源）**：
```json
{
  "date": "2025-11-29",
  "source": "recipe",
  "items": [
    {
      "intake_id": 101,
      "source_type": "recipe",
      "recipe_id": 1,
      "recipe_title": "Garlic Butter Chicken with Steamed Broccoli",
      "consumed_percentage": 50,
      "base_nutrition": {
        "energy": 650,
        "fat": 18,
        "carbohydrates": 50,
        "protein": 30
      },
      "effective_nutrition": {
        "energy": 325,
        "fat": 9,
        "carbohydrates": 25,
        "protein": 15
      }
    }
  ]
}
```

**响应示例（手动来源）**：
```json
{
  "date": "2025-11-29",
  "source": "manual",
  "items": [
    {
      "intake_id": 201,
      "source_type": "manual",
      "manual_food_name": "fried rice with egg",
      "effective_nutrition": {
        "energy": 650,
        "fat": 20,
        "carbohydrates": 80,
        "protein": 18
      }
    }
  ]
}
```

### 4. 更新摄入百分比

**接口**：`PATCH /api/intake/{intake_id}`

**请求头**：
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

**路径参数**：
- `intake_id`：摄入记录ID

**请求体**：
```json
{
  "consumed_percentage": 80
}
```

**响应示例**：
```json
{
  "intake": {
    "intake_id": 101,
    "source_type": "recipe",
    "recipe_id": 1,
    "recipe_title": "Garlic Butter Chicken with Steamed Broccoli",
    "date": "2025-11-29",
    "consumed_percentage": 80,
    "base_nutrition": {
      "energy": 650,
      "fat": 18,
      "carbohydrates": 50,
      "protein": 30
    },
    "effective_nutrition": {
      "energy": 520,
      "fat": 14.4,
      "carbohydrates": 40,
      "protein": 24
    }
  },
  "weekly_summary": {
    "week_start": "2025-11-24",
    "week_end": "2025-11-30",
    "consumed": {
      "energy": 4720,
      "fat": 134,
      "carbohydrates": 520,
      "protein": 204
    }
  }
}
```

**说明**：
- `consumed_percentage`：0-100 之间的数值
- 更新后会自动重新计算 `effective_nutrition`
- 响应中包含更新后的周营养摘要

### 5. 添加手动摄入

**接口**：`POST /api/intake/manual`

**请求头**：
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

**请求体**：
```json
{
  "date": "2025-11-29",
  "food_name": "fried rice with egg",
  "portion_description": "1 bowl"
}
```

**响应示例**：
```json
{
  "intake": {
    "intake_id": 201,
    "source_type": "manual",
    "date": "2025-11-29",
    "manual_food_name": "fried rice with egg",
    "portion_description": "1 bowl",
    "effective_nutrition": {
      "energy": 650,
      "fat": 20,
      "carbohydrates": 80,
      "protein": 18
    }
  },
  "weekly_summary": {
    "week_start": "2025-11-24",
    "week_end": "2025-11-30",
    "consumed": {
      "energy": 4850,
      "fat": 140,
      "carbohydrates": 560,
      "protein": 222
    }
  }
}
```

**说明**：
- `date`：可选，默认为今天
- `food_name`：必需，食物名称
- `portion_description`：可选，份量描述
- 系统会根据食物名称估算营养成分（当前为简化版本）

---

## Postman 测试

### 导入 Postman Collection

1. 打开 Postman
2. 点击左上角 **Import** 按钮
3. 选择文件：`docs/Homepage-API.postman_collection.json`
4. 点击 **Import** 完成导入

### 设置环境变量

在 Postman 中创建环境变量（可选，方便测试）：

1. 点击右上角环境选择器
2. 点击 **Add** 创建新环境
3. 添加以下变量：
   - `base_url`: `http://localhost:8080`
   - `access_token`: （登录后获取的 token）

### 测试流程

#### 步骤 1：登录获取 Token

1. 使用现有的登录接口（`/api/ums/auth/login`）登录
2. 复制返回的 `accessToken`
3. 在 Postman Collection 的变量中设置 `access_token`，或直接在请求头中设置

#### 步骤 2：测试营养目标接口

1. 打开 **"获取周营养目标"** 请求
2. 在 **Authorization** 标签页选择 **Bearer Token**
3. 输入你的 access token
4. 点击 **Send**
5. 应该返回当前周的营养目标

#### 步骤 3：测试营养摘要接口

1. 打开 **"获取周营养摘要"** 请求
2. 设置 Authorization（同上）
3. 点击 **Send**
4. 应该返回本周的已消费和剩余营养

#### 步骤 4：添加手动摄入

1. 打开 **"添加手动摄入"** 请求
2. 设置 Authorization
3. 在 Body 中修改食物名称（可选）
4. 点击 **Send**
5. 应该返回创建的摄入记录和更新后的周摘要

#### 步骤 5：查看今日摄入

1. 打开 **"获取今日摄入 (全部)"** 请求
2. 设置 Authorization
3. 点击 **Send**
4. 应该看到刚才添加的摄入记录

#### 步骤 6：更新摄入百分比

1. 先执行步骤 5，获取一个 `intake_id`
2. 打开 **"更新摄入百分比"** 请求
3. 在 URL 中替换 `{{intake_id}}` 为实际的 ID
4. 在 Body 中修改 `consumed_percentage`（例如改为 80）
5. 点击 **Send**
6. 应该返回更新后的摄入记录和新的周摘要

---

## 常见问题

### Q1: 数据库连接失败

**解决方案**：
1. 确认 PostgreSQL 服务正在运行
2. 检查 `application.yml` 中的数据库配置
3. 确认数据库名称、用户名、密码正确

### Q2: 表不存在错误

**解决方案**：
1. 确认已执行所有 SQL 脚本
2. 检查 schema 名称是否正确（`sous_chef_hp`）
3. 查看数据库日志确认表创建成功

### Q3: 401 Unauthorized 错误

**解决方案**：
1. 确认请求头中包含 `Authorization: Bearer <token>`
2. 确认 token 未过期
3. 重新登录获取新 token

### Q4: 营养目标计算不准确

**说明**：
- 系统使用 Mifflin-St Jeor 方程计算 BMR
- 活动系数默认为 1.55（中等活动水平）
- 如果用户没有设置身高、体重等信息，系统会使用默认值

### Q5: 手动摄入的营养估算不准确

**说明**：
- 当前实现使用简化的食物名称匹配
- 生产环境建议集成专业的食物数据库 API（如 USDA FoodData Central）

---

## 营养计算逻辑说明

### BMR 计算（Mifflin-St Jeor 方程）

- **男性**：`BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5`
- **女性**：`BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161`

### 每日卡路里计算

- 基础代谢率 × 活动系数（默认 1.55，中等活动水平）
- 周卡路里 = 日卡路里 × 7

### 目标调整规则

- **BMI > 25**：减脂目标，卡路里减少 15%
- **BMI < 18.5**：增肌目标，卡路里增加 15%
- **其他**：维持目标

### 宏量营养素分配

- **蛋白质**：1.0g/kg体重/天 × 7天
- **脂肪**：25%的卡路里 ÷ 9 kcal/g
- **碳水化合物**：剩余卡路里 ÷ 4 kcal/g

---

## 技术支持

如有问题，请查看：
- 项目文档：`docs/homepage-backend-implementation.md`
- API 规范：`docs/homepage-api.md`
- 后端实现总结：`docs/homepage-backend-implementation.md`

---

**最后更新**：2025-12-04
