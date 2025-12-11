# Calotter Homepage 模块使用说明文档

## 📋 目录
1. [概述](#概述)
2. [新建文件说明](#新建文件说明)
3. [数据库设置](#数据库设置)
4. [项目配置](#项目配置)
5. [运行步骤](#运行步骤)
6. [API 接口说明](#api-接口说明)
7. [Postman 测试](#postman-测试)
8. [常见问题](#常见问题)

---

## 概述

本文档说明如何在 calotter 项目中运行和使用 Homepage 营养追踪和摄入管理功能。该功能实现了以下核心能力：

- 📊 **周营养目标计算**：根据用户的身体数据（身高、体重、年龄、性别）自动计算周营养目标
- 📈 **营养摄入追踪**：记录用户每日的食物摄入（来自菜谱或手动输入）
- 📉 **营养摘要统计**：汇总周营养摄入情况，显示已消费和剩余目标

**技术栈**：
- Spring Boot 3.5.8
- MyBatis Plus（数据访问层）
- PostgreSQL（数据库）

---

## 新建文件说明

### 📁 模块配置文件

#### 1. `calotter-homepage/pom.xml`
- **作用**：Maven 项目配置文件
- **说明**：定义了模块依赖，包括 calotter-common、Spring Boot Web 等
- **位置**：`calotter/calotter-homepage/pom.xml`

#### 2. `calotter-homepage/src/main/java/com/calotter/homepage/CalotterHomepageApplication.java`
- **作用**：Spring Boot 启动类
- **说明**：包含 `@MapperScan` 注解扫描 Mapper 接口，`@EnableDiscoveryClient` 支持服务发现
- **关键注解**：
  - `@SpringBootApplication`
  - `@MapperScan("com.calotter.homepage.mapper")`
  - `@EnableDiscoveryClient`

### 📁 Entity 实体类（使用 MyBatis Plus）

#### 1. `domain/NutritionTarget.java`
- **作用**：营养目标实体类
- **说明**：对应数据库表 `sous_chef_hp.hp_nutrition_target`
- **主要字段**：
  - `userId`：用户ID
  - `weekStart/weekEnd`：周的开始和结束日期
  - `weeklyTargetEnergy/Fat/Carbohydrates/Protein`：周营养目标值
  - `bmi`：BMI值
  - `goalType`：目标类型（fat_loss, muscle_gain, maintain）
  - `calculationModel`：计算模型（mifflin_st_jeor）

#### 2. `domain/IntakeRecord.java`
- **作用**：摄入记录实体类
- **说明**：对应数据库表 `sous_chef_hp.hp_intake_record`
- **主要字段**：
  - `userId`：用户ID
  - `date`：摄入日期
  - `sourceType`：来源类型（'recipe' 或 'manual'）
  - `recipeId/recipeTitle`：菜谱相关（如果来源是菜谱）
  - `manualFoodName/portionDescription`：手动输入相关
  - `consumedPercentage`：消费百分比（0-100）
  - `baseEnergy/Fat/Carbohydrates/Protein`：基础营养成分
  - `effectiveEnergy/Fat/Carbohydrates/Protein`：有效营养成分
- **特殊方法**：`calculateEffectiveNutrition()` - 自动计算有效营养成分

#### 3. `domain/RecipeNutrition.java`
- **作用**：菜谱营养成分实体类
- **说明**：对应数据库表 `sous_chef_hp.hp_recipe_nutrition`
- **主要字段**：
  - `recipeId`：菜谱ID
  - `energy/fat/carbohydrates/protein`：每份的营养成分

### 📁 Mapper 接口和 XML（数据访问层）

#### 1. `mapper/NutritionTargetMapper.java` + `resources/mapper/homepage/NutritionTargetMapper.xml`
- **作用**：营养目标数据访问接口
- **主要方法**：
  - `selectByUserIdAndDate()`：根据用户ID和日期查找营养目标
  - `selectByUserIdAndWeekStart()`：根据用户ID和周开始日期查找
- **说明**：继承 `BaseMapperPlus<NutritionTarget, NutritionTargetVo>`

#### 2. `mapper/IntakeRecordMapper.java` + `resources/mapper/homepage/IntakeRecordMapper.xml`
- **作用**：摄入记录数据访问接口
- **主要方法**：
  - `selectByUserIdAndDate()`：查找用户某日的摄入记录
  - `selectByUserIdAndDateAndSourceType()`：按来源类型筛选
  - `selectByUserIdAndDateRange()`：查找日期范围内的记录
  - `sumEffectiveNutritionByDateRange()`：汇总日期范围内的有效营养成分
- **说明**：使用 MyBatis XML 实现复杂查询

#### 3. `mapper/RecipeNutritionMapper.java` + `resources/mapper/homepage/RecipeNutritionMapper.xml`
- **作用**：菜谱营养成分数据访问接口
- **主要方法**：
  - `selectByRecipeId()`：根据菜谱ID查找营养成分

### 📁 Vo 类（View Object - 视图对象）

#### 1. `domain/vo/NutritionTargetVo.java`
- **作用**：营养目标视图对象
- **说明**：用于 API 响应，使用 `@AutoMapper` 注解自动映射

#### 2. `domain/vo/IntakeRecordVo.java`
- **作用**：摄入记录视图对象
- **说明**：用于 API 响应

#### 3. `domain/vo/RecipeNutritionVo.java`
- **作用**：菜谱营养成分视图对象
- **说明**：用于 API 响应

### 📁 Service 服务层

#### 1. `service/INutritionService.java`
- **作用**：营养服务接口
- **主要方法**：
  - `getWeeklyNutritionTargets()`：获取周营养目标
  - `getWeeklyNutritionSummary()`：获取周营养摘要
- **说明**：接口中定义了内部类作为响应对象

#### 2. `service/IIntakeService.java`
- **作用**：摄入记录管理服务接口
- **主要方法**：
  - `getTodayIntakes()`：获取今日摄入记录
  - `updateIntakePercentage()`：更新摄入百分比
  - `addManualIntake()`：添加手动摄入记录
- **说明**：接口中定义了内部类作为请求/响应对象

#### 3. `service/impl/NutritionServiceImpl.java`
- **作用**：营养服务实现类
- **核心功能**：
  - 使用 Mifflin-St Jeor 方程计算 BMR（基础代谢率）
  - 根据 BMI 自动调整目标类型（减脂/增肌/维持）
  - 计算宏量营养素分配
- **依赖**：
  - `NutritionTargetMapper`
  - `IntakeRecordMapper`
- **TODO**：需要实现用户信息获取（通过 Feign 或直接查询）

#### 4. `service/impl/IntakeServiceImpl.java`
- **作用**：摄入记录管理服务实现类
- **核心功能**：
  - 管理摄入记录的 CRUD 操作
  - 自动计算有效营养成分
  - 估算手动输入食物的营养成分
- **依赖**：
  - `IntakeRecordMapper`
  - `INutritionService`（用于获取周摘要）

### 📁 Controller 控制器层

#### 1. `controller/NutritionController.java`
- **作用**：营养相关 API 控制器
- **路由前缀**：`/api/nutrition`
- **接口**：
  - `GET /api/nutrition/targets/weekly`：获取周营养目标
  - `GET /api/nutrition/summary?period=week`：获取周营养摘要
- **说明**：
  - 继承 `BaseController`
  - 使用 `R<T>` 作为响应对象
  - **TODO**：需要实现 JWT token 解析

#### 2. `controller/IntakeController.java`
- **作用**：摄入记录相关 API 控制器
- **路由前缀**：`/api/intake`
- **接口**：
  - `GET /api/intake/today?source=recipe|manual`：获取今日摄入
  - `PATCH /api/intake/{intake_id}`：更新摄入百分比
  - `POST /api/intake/manual`：添加手动摄入
- **说明**：
  - 继承 `BaseController`
  - 使用 `R<T>` 作为响应对象
  - **TODO**：需要实现 JWT token 解析

---

## 数据库设置

### 步骤 1：创建 Schema 和表

在 PostgreSQL 数据库中执行以下 SQL 脚本（按顺序执行）：

```bash
# 进入数据库
psql -U postgres -d sous_chef

# 或者使用数据库客户端（如 pgAdmin、DBeaver）执行以下文件：

# 1. 创建 schema（如果不存在）
CREATE SCHEMA IF NOT EXISTS sous_chef_hp;

# 2. 执行表创建脚本
\i database/schema/hp/hp_nutrition_target.sql
\i database/schema/hp/hp_intake_record.sql
\i database/schema/hp/hp_recipe_nutrition.sql
```

或者直接执行 SQL 文件：
```bash
psql -U postgres -d sous_chef -f database/schema/hp/hp_nutrition_target.sql
psql -U postgres -d sous_chef -f database/schema/hp/hp_intake_record.sql
psql -U postgres -d sous_chef -f database/schema/hp/hp_recipe_nutrition.sql
```

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

## 项目配置

### 步骤 1：创建配置文件

创建 `calotter-homepage/src/main/resources/application.yml`：

```yaml
spring:
  application:
    name: calotter-homepage
  datasource:
    username: postgres
    password: 123
    url: jdbc:postgresql://127.0.0.1:5432/sous_chef?currentSchema=sous_chef_hp&useUnicode=true&characterEncoding=utf8
    driver-class-name: org.postgresql.Driver

mybatis-plus:
  mapper-locations: classpath:/mapper/**/*.xml
  global-config:
    db-config:
      id-type: AUTO

server:
  port: 10001  # 注意：避免与其他服务端口冲突
```

创建 `calotter-homepage/src/main/resources/application.properties`：

```properties
spring.application.name=calotter-homepage
```

### 步骤 2：配置 JWT Token 解析（可选）

如果项目中有统一的 JWT 工具类，在 Controller 中实现 `extractUserIdFromToken()` 方法：

```java
private Long extractUserIdFromToken(String authHeader) {
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
        return null;
    }
    String token = authHeader.substring(7);
    // TODO: 使用项目的JWT工具类解析token
    // 例如：return jwtUtils.extractUserId(token);
    return 1L; // 临时返回，用于测试
}
```

---

## 运行步骤

### 前置条件

1. ✅ Java 17 或更高版本
2. ✅ Maven 3.6+
3. ✅ PostgreSQL 数据库已运行
4. ✅ 已执行数据库 SQL 脚本创建表和 schema
5. ✅ calotter-common 模块已编译

### 步骤 1：编译 calotter-common 模块（如果未编译）

```bash
cd calotter/calotter-common
mvn clean install
```

### 步骤 2：编译 calotter-homepage 模块

```bash
cd calotter/calotter-homepage
mvn clean compile
```

### 步骤 3：运行应用

**方式一：使用 Maven**
```bash
cd calotter/calotter-homepage
mvn spring-boot:run
```

**方式二：使用 IDE**
1. 在 IntelliJ IDEA 或 Eclipse 中打开项目
2. 找到 `CalotterHomepageApplication.java`
3. 右键点击，选择 "Run" 或 "Debug"

### 步骤 4：验证服务启动

查看控制台输出，应该看到类似信息：

```
Started CalotterHomepageApplication in X.XXX seconds
```

默认端口：**10001**（可在 `application.yml` 中修改）

### 步骤 5：测试健康检查

```bash
curl http://localhost:10001/actuator/health
```

或者测试一个简单的接口（需要先登录获取token）：

```bash
curl -H "Authorization: Bearer <your_token>" http://localhost:10001/api/nutrition/targets/weekly
```

---

## API 接口说明

### 🔐 认证要求

所有 API 都需要在请求头中包含 JWT Token：

```
Authorization: Bearer <your_access_token>
```

**注意**：当前实现中 `extractUserIdFromToken()` 方法需要完善，临时返回 userId=1 用于测试。

### 1. 获取周营养目标

**接口**：`GET /api/nutrition/targets/weekly`

**请求头**：
```
Authorization: Bearer <accessToken>
```

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "weeklyTarget": {
      "energy": 12600,
      "fat": 350,
      "carbohydrates": 1400,
      "protein": 560
    },
    "basis": {
      "bmi": 22.3,
      "goalType": "fat_loss",
      "calculationModel": "mifflin_st_jeor",
      "weekStart": "2025-11-24",
      "weekEnd": "2025-11-30"
    }
  }
}
```

**说明**：
- 如果用户当前周没有营养目标，系统会自动根据用户的身体数据计算并创建
- 计算基于用户的年龄、性别、身高、体重（目前使用默认值，需要完善用户信息获取）

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
  "code": 200,
  "msg": "操作成功",
  "data": {
    "period": "week",
    "weekStart": "2025-11-24",
    "weekEnd": "2025-11-30",
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
}
```

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

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "date": "2025-11-29",
    "source": "recipe",
    "items": [
      {
        "intakeId": 101,
        "sourceType": "recipe",
        "recipeId": 1,
        "recipeTitle": "Garlic Butter Chicken with Steamed Broccoli",
        "consumedPercentage": 50,
        "baseNutrition": {
          "energy": 650,
          "fat": 18,
          "carbohydrates": 50,
          "protein": 30
        },
        "effectiveNutrition": {
          "energy": 325,
          "fat": 9,
          "carbohydrates": 25,
          "protein": 15
        }
      }
    ]
  }
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
  "consumedPercentage": 80
}
```

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "intake": {
      "intakeId": 101,
      "sourceType": "recipe",
      "recipeId": 1,
      "recipeTitle": "Garlic Butter Chicken with Steamed Broccoli",
      "date": "2025-11-29",
      "consumedPercentage": 80,
      "baseNutrition": {
        "energy": 650,
        "fat": 18,
        "carbohydrates": 50,
        "protein": 30
      },
      "effectiveNutrition": {
        "energy": 520,
        "fat": 14.4,
        "carbohydrates": 40,
        "protein": 24
      }
    },
    "weeklySummary": {
      "weekStart": "2025-11-24",
      "weekEnd": "2025-11-30",
      "consumed": {
        "energy": 4720,
        "fat": 134,
        "carbohydrates": 520,
        "protein": 204
      }
    }
  }
}
```

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
  "foodName": "fried rice with egg",
  "portionDescription": "1 bowl"
}
```

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "intake": {
      "intakeId": 201,
      "sourceType": "manual",
      "date": "2025-11-29",
      "manualFoodName": "fried rice with egg",
      "portionDescription": "1 bowl",
      "effectiveNutrition": {
        "energy": 650,
        "fat": 20,
        "carbohydrates": 80,
        "protein": 18
      }
    },
    "weeklySummary": {
      "weekStart": "2025-11-24",
      "weekEnd": "2025-11-30",
      "consumed": {
        "energy": 4850,
        "fat": 140,
        "carbohydrates": 560,
        "protein": 222
      }
    }
  }
}
```

---

## Postman 测试

### 导入 Postman Collection

1. 打开 Postman
2. 点击左上角 **Import** 按钮
3. 选择文件：`docs/Calotter-Homepage-API.postman_collection.json`
4. 点击 **Import** 完成导入

### 设置环境变量

在 Postman 中创建环境变量（可选，方便测试）：

1. 点击右上角环境选择器
2. 点击 **Add** 创建新环境
3. 添加以下变量：
   - `base_url`: `http://localhost:10001`（注意端口号）
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
4. 确认 schema 名称正确（`sous_chef_hp`）

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
4. **注意**：当前实现中 `extractUserIdFromToken()` 方法需要完善

### Q4: 营养目标计算不准确

**说明**：
- 系统使用 Mifflin-St Jeor 方程计算 BMR
- 活动系数默认为 1.55（中等活动水平）
- **当前实现**：如果用户没有设置身高、体重等信息，系统会使用默认值（age=30, height=170, weight=70, gender=male）
- **需要完善**：通过 Feign 调用 calotter-user 服务获取真实的用户信息

### Q5: 手动摄入的营养估算不准确

**说明**：
- 当前实现使用简化的食物名称匹配
- 生产环境建议集成专业的食物数据库 API（如 USDA FoodData Central）

### Q6: 编译错误 - 找不到 calotter-common

**解决方案**：
```bash
# 先编译 calotter-common 模块
cd calotter/calotter-common
mvn clean install

# 然后再编译 calotter-homepage
cd ../calotter-homepage
mvn clean compile
```

### Q7: 端口冲突

**解决方案**：
- 修改 `application.yml` 中的 `server.port` 为其他端口（如 10002）
- 确保端口未被其他服务占用

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

## 待完善的功能

### 1. JWT Token 解析
- 在 Controller 中实现 `extractUserIdFromToken()` 方法
- 使用项目统一的 JWT 工具类

### 2. 用户信息获取
- 通过 Feign 调用 calotter-user 服务获取用户信息
- 或直接查询用户表（如果数据库连接在同一服务中）

### 3. 配置文件
- 创建 `application.yml` 和 `application.properties`
- 配置数据库连接、端口等

---

## 技术支持

如有问题，请查看：
- 实现说明：`docs/calotter-homepage-实现说明.md`
- API 规范：`docs/homepage-api.md`
- 数据库脚本：`database/schema/hp/`

---

**最后更新**：2025-12-04
