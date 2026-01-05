# Personal Sous Chef 项目完整总结文档

## 文档信息

**文档版本：** 3.0  
**最后更新：** 2026-01-05  
**项目名称：** A-team-PersonalSousChef  
**后端框架：** Spring Boot 3.2.0 + JPA

---

## 目录

1. [项目概述](#项目概述)
2. [技术架构](#技术架构)
3. [模块结构](#模块结构)
4. [数据模型](#数据模型)
5. [API 接口总览](#api-接口总览)
6. [配置说明](#配置说明)
7. [部署指南](#部署指南)
8. [开发指南](#开发指南)

---

## 项目概述

Personal Sous Chef 是一个智能个人厨师助手应用，帮助用户：
- 管理家庭食材库存
- 基于库存和偏好生成个性化菜单
- 跟踪营养摄入和健康目标
- 管理烹饪会话和剩菜

### 核心特性

- **多用户家庭共享**：支持家庭成员共享库存和烹饪记录
- **AI 菜单生成**：基于库存、偏好和健康目标智能生成菜单
- **营养跟踪**：自动记录烹饪和剩菜的营养信息
- **标准库管理**：提供标准食材、调料、厨具库

---

## 技术架构

### 技术栈

**后端：**
- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- PostgreSQL 15
- Maven 3.6+
- Lombok
- JWT 认证
- Spring Events（事件驱动）

**数据库：**
- PostgreSQL 15（生产环境）
- H2 Database（集成测试环境）

**容器化：**
- Docker Desktop
- Docker Compose

### 架构模式

- **模块化设计**：Maven 多模块架构，关注点分离
- **领域驱动设计（DDD）**：按业务领域划分模块
- **事件驱动**：使用 Spring Events 实现模块间解耦
- **RESTful API**：统一响应格式，标准化接口

---

## 模块结构

### 目录结构

```
backend-calotter/
├── pom.xml                          # 父工程（统一依赖版本）
├── calotter-common/                 # 通用模块
│   ├── core/                        # Result, PageResult 统一响应
│   ├── domain/                      # BaseEntity, 标准库实体
│   ├── exception/                   # 全局异常处理
│   └── config/                      # JPA Auditing 配置
├── calotter-modules/                # 业务模块聚合层
│   ├── calotter-user/               # 用户模块
│   │   ├── domain/entity/           # User, Household, HealthGoal
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层
│   │   └── controller/              # API 控制器
│   ├── calotter-health/             # 健康模块
│   │   ├── domain/entity/           # NutritionLog, DailyNutrientAggregate
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层
│   │   └── controller/              # API 控制器
│   ├── calotter-inventory/          # 库存模块
│   │   ├── domain/entity/           # Ingredient, HouseholdUtensil, 
│   │   │                             # HouseholdSpice, LeftoverDish
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层
│   │   └── controller/              # API 控制器
│   └── calotter-cooking/            # 烹饪模块
│       ├── domain/entity/           # CookingSession, Dish
│       ├── repository/              # 数据访问接口
│       ├── service/                 # 业务服务层
│       └── controller/              # API 控制器
└── calotter-start/                  # 启动模块
    ├── CalotterApplication.java     # 启动类
    └── application.yml              # 配置文件
```

### 模块依赖关系

```
calotter-common (基础模块)
    ↑
    ├── calotter-user (用户模块)
    │       ↑
    │       ├── calotter-inventory (库存模块)
    │       │       ↑
    │       │       └── calotter-cooking (烹饪模块)
    │       │
    │       └── calotter-health (健康模块)
    │
    └── calotter-start (启动模块，聚合所有模块)
```

**说明：**
- `calotter-common`：提供通用功能，被所有模块依赖
- `calotter-user`：用户和家庭管理，不依赖其他业务模块
- `calotter-inventory`：库存管理，依赖 `calotter-user`
- `calotter-cooking`：烹饪管理，依赖 `calotter-user` 和 `calotter-inventory`
- `calotter-health`：健康管理，依赖 `calotter-user`
- `calotter-start`：启动模块，聚合所有业务模块

---

## 数据模型

### 核心实体

#### User（用户）
- `id`: 主键
- `username`: 用户名（唯一）
- `email`: 邮箱（唯一）
- `passwordHash`: 密码哈希
- `role`: 角色（ROLE_USER, ROLE_ADMIN）
- `status`: 状态（0:未激活, 1:可用, 2:封禁）
- `isOnboarded`: 是否完成引导
- `profile`: JSONB 字段，用户资料（年龄、性别、身高、体重）
- `preferences`: JSONB 字段，用户偏好（口味、菜系）
- `joinedHouseholds`: 多对多关系，用户加入的家庭

#### Household（家庭组）
- `id`: 主键
- `name`: 家庭名称
- `inviteCode`: 邀请码（唯一）
- `ownerId`: 所有者用户ID
- `members`: 多对多关系，家庭成员

#### HealthGoal（健康目标）
- `id`: 主键
- `userId`: 用户ID（外键）
- `status`: 状态（1:活跃, 0:已归档）
- `goalType`: 目标类型（LOSE_FAT, MUSCLE_GAIN, MAINTENANCE）
- `activityLevel`: 活动水平
- `dailyCalories`: 每日卡路里目标
- `protein`, `fat`, `carb`, `fiber`: 营养素目标

#### Ingredient（食材库存）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `standardIngredientId`: 标准食材ID（外键）
- `quantity`: 数量
- `unit`: 单位（g, kg, pcs等）
- `expirationDate`: 过期日期
- `location`: 存储位置（FRIDGE, FREEZER, PANTRY）

#### HouseholdSpice（调料）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `standardSpiceId`: 标准调料ID（外键）
- `isAvailable`: 是否可用
- `remark`: 备注

#### HouseholdUtensil（厨具）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `standardUtensilId`: 标准厨具ID（外键）
- `isAvailable`: 是否可用
- `remark`: 备注

#### LeftoverDish（剩菜）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `dishId`: 菜品ID（外键，关联 Dish）
- `currentQuantityGram`: 当前重量（克）
- `storedAt`: 存储时间
- `ingredientsSnapshot`: JSONB 字段，食材快照
- `nutritionSnapshot`: JSONB 字段，营养快照

#### Dish（菜品）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `name`: 菜名
- `description`: 描述
- `totalWeightGram`: 总重量（克）
- `totalCalories`: 总卡路里
- `totalProtein`, `totalFat`, `totalCarb`, `totalFiber`: 营养素
- `cookingTimeMinutes`: 烹饪时间（分钟）
- `difficulty`: 难度（EASY, MEDIUM, HARD）
- `steps`: JSONB 字段，烹饪步骤
- `ingredientSnapshots`: JSONB 字段，食材快照
- `favorite`: 是否收藏

#### CookingSession（烹饪会话）
- `id`: 主键
- `householdId`: 家庭ID（外键）
- `status`: 状态（IN_PROGRESS, COOKED, CANCELLED）
- `completedDishIds`: JSONB 字段，已完成的菜品ID列表
- `ingredientsSnapshot`: JSONB 字段，食材快照
- `totalNutritionSnapshot`: JSONB 字段，总营养快照
- `remainingRatio`: 剩余比例

#### NutritionLog（营养日志）
- `id`: 主键
- `userId`: 用户ID（外键）
- `dishId`: 菜品ID（外键，可选）
- `sourceType`: 来源类型（APP_COOKING, LEFTOVER, MANUAL, EXTERNAL）
- `foodName`: 食物名称
- `eatenAt`: 进食时间
- `mealType`: 餐次类型（BREAKFAST, LUNCH, DINNER, SNACK）
- `quantity`: 数量
- `unit`: 单位
- `consumedPercentage`: 消费百分比（0-100）
- `energy`, `protein`, `fat`, `carbohydrates`, `fiber`: 营养素

#### DailyNutrientAggregate（每日营养聚合）
- `id`: 主键
- `userId`: 用户ID（外键）
- `logDate`: 日期
- `totalEnergy`: 总卡路里
- `totalProtein`, `totalFat`, `totalCarbohydrates`, `totalFiber`: 营养素总和

### 标准库实体

#### StandardIngredient（标准食材库）
- `id`: 主键（手动分配，如 1001）
- `name`: 食材名称（英文）
- `category`: 分类（FRUIT, VEG, MEAT, GRAIN, DAIRY, OTHER）
- `calories`, `protein`, `fat`, `carb`, `fiber`: 营养素（每100g）
- `averageGramPerUnit`: 单位换算（每单位对应的克数）
- `shelfLifePantry/Fridge/Freezer`: 保质期（天）
- `defaultLocation`: 默认存储位置

#### StandardSpice（标准调料库）
- `id`: 主键（手动分配，如 3001）
- `name`: 调料名称（英文）

#### StandardUtensil（标准厨具库）
- `id`: 主键（手动分配，如 2001）
- `name`: 厨具名称（英文）
- `iconUrl`: 图标URL

#### RefAllergen（标准过敏原库）
- `id`: 主键
- `name`: 过敏原名称（英文）
- `description`: 描述

---

## API 接口总览

### 统一响应格式

所有 API 响应遵循统一格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

**状态码说明：**
- `200`: 成功
- `400`: 请求参数错误
- `401`: 未授权
- `403`: 禁止访问
- `404`: 资源不存在
- `500`: 服务器内部错误

### 认证方式

大部分 API 需要在请求头中携带 JWT Token：

```
Authorization: Bearer {token}
```

---

### 用户模块 API (`/api/user`)

#### 认证相关
- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `POST /api/user/logout` - 用户登出

#### 用户信息
- `GET /api/user?id={userId}` - 获取用户信息
- `PUT /api/user?id={userId}` - 更新用户信息

#### 用户偏好
- `GET /api/user/preferences?id={userId}` - 获取用户偏好
- `PUT /api/user/preferences?id={userId}` - 更新用户偏好
- `GET /api/user/preferences-map?id={userId}` - 获取用户偏好（Map格式）
- `PUT /api/user/preferences-map?id={userId}` - 更新用户偏好（Map格式）

#### 用户禁忌和过敏
- `GET /api/user/taboos?id={userId}` - 获取用户禁忌
- `PUT /api/user/taboos?id={userId}` - 更新用户禁忌
- `GET /api/user/allergies?id={userId}` - 获取用户过敏
- `PUT /api/user/allergies?id={userId}` - 更新用户过敏

#### 标准库查询
- `GET /api/user/standard-allergens` - 获取所有标准过敏原

**兼容路径：** `/api/ums/user/*`（支持前端现有路径）

---

### 家庭模块 API (`/api/household`)

- `POST /api/household` - 创建家庭
- `GET /api/household/{id}` - 获取家庭详情
- `PUT /api/household/{id}` - 更新家庭信息
- `DELETE /api/household/{id}?ownerId={ownerId}` - 删除家庭
- `GET /api/household/invite/{inviteCode}` - 通过邀请码获取家庭
- `GET /api/household/owner/{ownerId}` - 获取用户的所有家庭
- `GET /api/household/current?userId={userId}` - 获取用户的当前活跃家庭

---

### 库存模块 API (`/api/inventory`)

#### 食材管理
- `POST /api/inventory/ingredients` - 创建食材
- `GET /api/inventory/ingredients?householdId={householdId}` - 获取食材列表
- `GET /api/inventory/ingredients/{id}` - 获取食材详情
- `PUT /api/inventory/ingredients/{id}` - 更新食材
- `DELETE /api/inventory/ingredients/{id}` - 删除食材
- `POST /api/inventory/ingredients/{id}/deduct?amount={amount}` - 扣减食材库存

#### 调料管理
- `POST /api/inventory/spices` - 创建调料
- `GET /api/inventory/spices?householdId={householdId}` - 获取调料列表
- `GET /api/inventory/spices/{id}` - 获取调料详情
- `PUT /api/inventory/spices/{id}` - 更新调料
- `DELETE /api/inventory/spices/{id}` - 删除调料
- `PATCH /api/inventory/spices/{id}/toggle` - 切换调料可用性

#### 厨具管理
- `POST /api/inventory/utensils` - 创建厨具
- `GET /api/inventory/utensils?householdId={householdId}` - 获取厨具列表
- `GET /api/inventory/utensils/{id}` - 获取厨具详情
- `PUT /api/inventory/utensils/{id}` - 更新厨具
- `DELETE /api/inventory/utensils/{id}` - 删除厨具
- `PATCH /api/inventory/utensils/{id}/toggle` - 切换厨具可用性

#### 剩菜管理
- `POST /api/inventory/leftovers` - 创建剩菜
- `GET /api/inventory/leftovers?householdId={householdId}` - 获取剩菜列表
- `GET /api/inventory/leftovers/{id}` - 获取剩菜详情
- `PUT /api/inventory/leftovers/{id}` - 更新剩菜
- `DELETE /api/inventory/leftovers/{id}` - 删除剩菜

#### 标准库查询
- `GET /api/inventory/standard-ingredients` - 获取所有标准食材
- `GET /api/inventory/standard-spices` - 获取所有标准调料
- `GET /api/inventory/standard-utensils` - 获取所有标准厨具
- `GET /api/inventory/standard-ingredients/search?name={name}&fuzzy={fuzzy}` - 搜索标准食材

---

### 烹饪模块 API

#### AI 菜单生成 (`/api/ai`)
- `POST /api/ai/generate-menus?householdId={householdId}` - 生成菜单

#### 烹饪会话 (`/api/cooking`)
- `POST /api/cooking/start` - 开始烹饪会话
- `POST /api/cooking/finish` - 完成烹饪会话

#### 收藏管理 (`/api/recipes`)
- `POST /api/recipes/favorite?householdId={householdId}` - 收藏/取消收藏
- `GET /api/recipes/favorites?householdId={householdId}` - 获取收藏列表
- `GET /api/recipes/default-filter?householdId={householdId}` - 获取默认过滤器

---

### 健康模块 API

#### 营养日志 (`/api/nutrition`)
- `POST /api/nutrition/log/manual` - 创建手动营养日志
- `POST /api/nutrition/log/leftover?leftoverId={id}&userId={id}&consumedGram={gram}` - 从剩菜记录营养
- `GET /api/nutrition/targets/weekly?userId={userId}&weekStart={date}` - 获取周健康报告
- `GET /api/nutrition/summary?period=week&userId={userId}` - 获取周营养摘要

#### 摄入记录 (`/api/intake`)
- `GET /api/intake/today?userId={userId}&source={source}` - 获取今日摄入
- `PATCH /api/intake/{intake_id}?userId={userId}` - 更新摄入百分比
- `POST /api/intake/manual?userId={userId}` - 添加手动摄入
- `DELETE /api/intake/{intake_id}?userId={userId}` - 删除摄入记录

---

## 配置说明

### 应用配置 (`application.yml`)

#### 服务器配置
```yaml
server:
  port: 8080
```

#### 数据库配置
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/calotter
    username: postgres
    password: 123
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update  # 开发环境：自动更新表结构
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
```

#### JWT 配置
```yaml
jwt:
  key: YourSuperSecretKeyForJWTTokenGenerationThatShouldBeAtLeast32CharactersLong!
  issuer: CalotterBackend
  audience: CalotterFrontend
  expiration: 3000  # Token过期时间（秒），默认50分钟
```

#### AI API 配置

详见 [AI_API_CONFIG.md](./AI_API_CONFIG.md)

---

## 部署指南

### 重要提示：数据库迁移

**⚠️ 如果从旧版本升级或首次部署，请注意数据库迁移：**

1. **开发环境（全新部署）**
   - 建议直接删除旧数据库并重新创建
   - 使用 `ddl-auto: update` 自动创建表结构
   - 重新初始化标准库数据

2. **开发环境（从旧版本升级）**
   - 如果实体类有重大变更（字段类型变更、删除字段等）
   - **建议删除数据库重新创建**，避免数据不一致
   - 如果只是新增字段，可以使用 `ddl-auto: update`

3. **生产环境（从旧版本升级）**
   - **必须使用数据库迁移工具**（Flyway/Liquibase）
   - **不建议使用 `ddl-auto: update`**（可能导致数据丢失）
   - 先备份数据库，然后执行迁移脚本

### 开发环境部署

#### 1. 前置要求
- Java 17+
- Maven 3.6+
- PostgreSQL 15+
- Docker Desktop（可选，用于数据库）

#### 2. 数据库准备

**情况 A：全新环境（首次部署）**

**使用 Docker：**
```bash
cd backend-calotter
docker-compose up -d postgres
```

**或手动创建：**
```sql
CREATE DATABASE calotter;
```

**情况 B：从旧版本升级（需要迁移）**

**⚠️ 重要：如果实体类有重大变更，建议删除旧数据库重新创建**

```bash
# 停止应用

# 使用 Docker
docker-compose down -v  # -v 参数会删除数据卷（谨慎使用！）

# 或手动删除数据库
psql -U postgres
DROP DATABASE calotter;
CREATE DATABASE calotter;
\q
```

**然后重新创建：**
```bash
# 使用 Docker
docker-compose up -d postgres

# 或手动创建
psql -U postgres -c "CREATE DATABASE calotter;"
```

#### 3. 配置数据库连接

编辑 `calotter-start/src/main/resources/application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/calotter
    username: postgres
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update  # 开发环境：自动更新表结构
```

#### 4. 初始化标准库数据

```bash
cd backend-calotter
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

# 或手动执行
psql -U postgres -d calotter -f init-standard-libraries.sql
```

#### 5. 编译项目

```bash
cd backend-calotter
mvn clean install -DskipTests
```

#### 6. 启动应用

```bash
cd calotter-start
mvn spring-boot:run
```

或直接运行 `CalotterApplication.java`

#### 7. 验证启动

访问：`http://localhost:8080/api/user/register`

---

### 测试工作流

#### 新环境测试工作流（首次部署）

**场景：** 全新的开发环境，首次部署项目

**步骤：**

1. **准备数据库**
   ```bash
   # 使用 Docker
   cd backend-calotter
   docker-compose up -d postgres
   
   # 等待数据库启动（约 5-10 秒）
   sleep 10
   ```

2. **创建数据库**
   ```bash
   # 使用 Docker（数据库已在容器中创建）
   # 或手动创建
   psql -U postgres -c "CREATE DATABASE calotter;"
   ```

3. **初始化标准库数据**
   ```bash
   cd backend-calotter
   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
   ```

4. **配置应用**
   ```yaml
   # calotter-start/src/main/resources/application.yml
   spring:
     jpa:
       hibernate:
         ddl-auto: update  # 自动创建表结构
   ```

5. **启动应用**
   ```bash
   cd backend-calotter/calotter-start
   mvn spring-boot:run
   ```

6. **验证数据库表结构**
   ```bash
   # 连接数据库检查表是否创建
   psql -U postgres -d calotter -c "\dt"
   
   # 应该看到以下表：
   # - users
   # - households
   # - health_goals
   # - household_ingredients
   # - household_spices
   # - household_utensils
   # - household_leftovers
   # - dishes
   # - cooking_sessions
   # - nutrition_logs
   # - daily_nutrient_aggregates
   # - ref_standard_ingredients
   # - ref_standard_spices
   # - ref_standard_utensils
   # - ref_standard_allergens
   ```

7. **测试 API**
   ```bash
   # 测试用户注册
   curl -X POST http://localhost:8080/api/user/register \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "test@example.com",
       "password": "password123"
     }'
   ```

8. **验证标准库数据**
   ```bash
   # 检查标准食材库
   psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"
   # 应该返回 83（或更多）
   
   # 检查标准调料库
   psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_spices;"
   # 应该返回 30（或更多）
   ```

---

#### 旧环境测试工作流（从旧版本升级）

**场景：** 已有旧版本的数据库，需要升级到新版本

**⚠️ 重要决策点：**

**选项 A：删除旧数据库重新创建（推荐用于开发环境）**

适用于：
- 开发/测试环境
- 实体类有重大变更（字段类型变更、删除字段、表结构重构）
- 可以接受数据丢失

**步骤：**

1. **备份数据（可选，如果需要保留测试数据）**
   ```bash
   # 导出数据
   pg_dump -U postgres -d calotter > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **停止应用**
   ```bash
   # 停止正在运行的应用（Ctrl+C 或 kill）
   ```

3. **删除旧数据库**
   ```bash
   # 使用 Docker（删除数据卷）
   docker-compose down -v
   
   # 或手动删除
   psql -U postgres -c "DROP DATABASE calotter;"
   ```

4. **重新创建数据库**
   ```bash
   # 使用 Docker
   docker-compose up -d postgres
   sleep 10
   
   # 或手动创建
   psql -U postgres -c "CREATE DATABASE calotter;"
   ```

5. **按照"新环境测试工作流"的步骤 3-8 继续**

---

**选项 B：保留数据并使用 ddl-auto: update（仅适用于小型变更）**

适用于：
- 只是新增字段或表
- 没有删除或修改现有字段
- 开发环境，可以接受部分风险

**步骤：**

1. **备份数据（必须！）**
   ```bash
   pg_dump -U postgres -d calotter > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **停止应用**
   ```bash
   # 停止正在运行的应用
   ```

3. **检查实体类变更**
   - 检查是否有字段类型变更
   - 检查是否有字段删除
   - 检查是否有表名变更
   
   **如果有上述变更，请使用选项 A（删除重建）**

4. **配置应用（确保使用 update）**
   ```yaml
   spring:
     jpa:
       hibernate:
         ddl-auto: update  # 自动更新表结构
   ```

5. **启动应用**
   ```bash
   cd backend-calotter/calotter-start
   mvn spring-boot:run
   ```

6. **检查启动日志**
   - 查看是否有表结构更新日志
   - 查看是否有错误信息
   - 如果出现错误，回滚到备份数据

7. **验证数据库变更**
   ```bash
   # 检查新表是否创建
   psql -U postgres -d calotter -c "\dt"
   
   # 检查新字段是否添加
   psql -U postgres -d calotter -c "\d users"  # 检查 users 表结构
   ```

8. **测试应用功能**
   - 测试现有功能是否正常
   - 测试新功能是否正常
   - 如果出现问题，恢复备份数据

9. **更新标准库数据（如果需要）**
   ```bash
   # 如果标准库有变更，重新初始化
   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
   
   # 注意：这会覆盖现有的标准库数据
   # 如果只需要添加新数据，手动执行 INSERT 语句
   ```

---

**选项 C：使用数据库迁移工具（生产环境推荐）**

适用于：
- 生产环境
- 需要保留所有数据
- 需要精确控制数据库变更

**步骤：**

1. **安装 Flyway 或 Liquibase**
   - 在项目中添加 Flyway/Liquibase 依赖
   - 创建迁移脚本目录

2. **创建迁移脚本**
   ```sql
   -- V1__create_tables.sql
   -- V2__add_new_fields.sql
   -- V3__modify_table_structure.sql
   ```

3. **配置迁移工具**
   ```yaml
   spring:
     flyway:
       enabled: true
       locations: classpath:db/migration
   ```

4. **执行迁移**
   - 应用启动时自动执行迁移脚本
   - 或使用命令行工具手动执行

5. **验证迁移结果**
   - 检查数据库表结构
   - 验证数据完整性
   - 测试应用功能

---

### 常见迁移场景

#### 场景 1：实体类新增字段

**影响：** 低风险

**操作：**
- 使用 `ddl-auto: update`
- 新字段会添加到表中
- 现有数据不受影响

#### 场景 2：实体类删除字段

**影响：** 高风险（数据丢失）

**操作：**
- **开发环境：** 删除数据库重新创建
- **生产环境：** 使用迁移工具，先备份数据，然后删除字段

#### 场景 3：字段类型变更

**影响：** 高风险（可能数据丢失或转换失败）

**操作：**
- **开发环境：** 删除数据库重新创建
- **生产环境：** 使用迁移工具，编写数据转换脚本

#### 场景 4：表名变更

**影响：** 高风险（需要重命名表）

**操作：**
- **开发环境：** 删除数据库重新创建
- **生产环境：** 使用迁移工具，执行 `ALTER TABLE` 语句

#### 场景 5：新增表

**影响：** 低风险

**操作：**
- 使用 `ddl-auto: update`
- 新表会自动创建

#### 场景 6：删除表

**影响：** 高风险（数据丢失）

**操作：**
- **开发环境：** 删除数据库重新创建
- **生产环境：** 使用迁移工具，先备份数据，然后删除表

---

### 生产环境部署

#### 建议配置

1. **数据库配置**
   - 使用连接池（如 HikariCP）
   - 设置合适的连接池大小
   - 使用 `ddl-auto: validate` 或使用 Flyway/Liquibase

2. **JWT 配置**
   - 使用强随机密钥
   - 设置合理的过期时间
   - 考虑使用 Refresh Token

3. **日志配置**
   - 设置合适的日志级别
   - 配置日志轮转

4. **性能优化**
   - 启用 JPA 二级缓存
   - 优化数据库索引
   - 使用 CDN 加速静态资源

---

## 开发指南

### 代码规范

1. **命名规范**
   - 类名：大驼峰（PascalCase）
   - 方法名：小驼峰（camelCase）
   - 常量：全大写下划线（UPPER_SNAKE_CASE）
   - 包名：全小写

2. **实体类规范**
   - 继承 `BaseEntity` 获得审计字段
   - 使用 `@Data` 和 `@EqualsAndHashCode(callSuper = true)`
   - JSONB 字段使用 `@JdbcTypeCode(SqlTypes.JSON)`

3. **Service 层规范**
   - 业务逻辑封装在 Service 层
   - 使用 `@Transactional` 管理事务
   - 抛出 `IllegalArgumentException` 表示业务异常

4. **Controller 层规范**
   - 使用 `@RestController` 和 `@RequestMapping`
   - 使用 `@Valid` 验证请求参数
   - 统一返回 `Result<T>` 格式

### 测试

#### 单元测试
- 使用 JUnit 5
- 使用 Mockito 进行 Mock
- 测试覆盖 Service 层逻辑

#### 集成测试
- 使用 `@SpringBootTest`
- 使用 H2 内存数据库
- 测试完整的 API 流程

### 数据库管理

#### 表结构更新
- 开发环境：使用 `ddl-auto: update` 自动更新
- 生产环境：使用 Flyway 或 Liquibase 进行版本管理

#### 标准库数据
- 使用 `init-standard-libraries.sql` 初始化
- 标准库数据变更需要更新 SQL 脚本

### 事件驱动

项目使用 Spring Events 实现模块间解耦：

- `CookingSessionCompletedEvent`：烹饪会话完成事件
- `NutritionLogCreatedEvent`：营养日志创建事件

事件监听器位于各模块的 `service/listener` 包中。

---

## 附录

### 数据库表列表

- `users` - 用户表
- `households` - 家庭表
- `health_goals` - 健康目标表
- `household_ingredients` - 食材库存表
- `household_spices` - 调料表
- `household_utensils` - 厨具表
- `household_leftovers` - 剩菜表
- `dishes` - 菜品表
- `cooking_sessions` - 烹饪会话表
- `nutrition_logs` - 营养日志表
- `daily_nutrient_aggregates` - 每日营养聚合表
- `ref_standard_ingredients` - 标准食材库
- `ref_standard_spices` - 标准调料库
- `ref_standard_utensils` - 标准厨具库
- `ref_standard_allergens` - 标准过敏原库

### 相关文档

- [AI API 配置文档](./AI_API_CONFIG.md)
- [README.md](./README.md) - 快速开始指南
- [Postman 集合](../docs/postman/) - API 测试集合

---

**文档维护：** 本文档应随项目更新及时维护，确保信息的准确性和完整性。

