# Calotter Backend - Spring Boot JPA

基于 Spring Boot 3.2.0 和 JPA 的 Personal Sous Chef 后端项目。

## 📋 目录

- [项目架构](#项目架构)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
  - [前置要求](#前置要求)
  - [首次启动（干净环境）](#首次启动干净环境)
  - [日常开发（更新后重建）](#日常开发更新后重建)
- [前后端联通测试](#前后端联通测试)
- [项目结构详解](#项目结构详解)
- [数据库说明](#数据库说明)
- [API 端点](#api-端点)
- [开发建议](#开发建议)

---

## 🏗️ 项目架构

### 模块化设计

项目采用 Maven 多模块架构，遵循领域驱动设计（DDD）原则：

```
backend-calotter/
├── calotter-common/              # 通用模块（被所有模块依赖）
│   ├── 核心实体基类（BaseEntity）
│   ├── 统一响应格式（Result<T>）
│   ├── 异常处理（GlobalExceptionHandler）
│   ├── JPA 审计配置
│   └── 标准库实体（StandardIngredient, StandardSpice, etc.）
│
├── calotter-modules/             # 业务模块聚合层
│   ├── calotter-user/           # 用户模块
│   │   ├── User（用户）
│   │   ├── Household（家庭组）
│   │   ├── FamilyMember（家庭成员）
│   │   └── HealthGoal（健康目标）
│   │
│   ├── calotter-inventory/      # 库存模块
│   │   ├── Ingredient（食材库存）
│   │   ├── HouseholdUtensil（厨具）
│   │   ├── HouseholdSpice（调料）
│   │   └── LeftoverDish（剩菜）
│   │
│   ├── calotter-cooking/        # 烹饪模块
│   │   ├── CookingSession（烹饪会话）
│   │   ├── AI 菜单生成服务
│   │   └── 营养估算服务
│   │
│   └── calotter-health/         # 健康模块（可选）
│
└── calotter-start/              # 启动模块（唯一入口）
    ├── CalotterApplication.java  # Spring Boot 启动类
    └── application.yml           # 应用配置
```

### 模块依赖关系

```
calotter-start
  ├── calotter-common (基础)
  ├── calotter-user (用户)
  │   └── calotter-common
  ├── calotter-inventory (库存)
  │   ├── calotter-common
  │   └── calotter-user
  └── calotter-cooking (烹饪)
      ├── calotter-common
      ├── calotter-user
      └── calotter-inventory
```

### 核心设计模式

1. **分层架构**：Controller → Service → Repository → Entity
2. **统一响应格式**：所有 API 返回 `Result<T>` 格式
3. **JPA 审计**：自动记录创建/更新时间
4. **标准库模式**：所有业务数据关联标准库（如 StandardIngredient）

---

## 🛠️ 技术栈

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**（Hibernate）
- **PostgreSQL 15**
- **Docker & Docker Compose**（数据库）
- **Maven 3.6+**
- **Lombok**
- **JWT**（用户认证）
- **Spring AI**（Gemini API）
- **Groq API**（AI 菜单生成）

---

## 🚀 快速开始

### 前置要求

- **Java 17+**（推荐使用 JDK 17）
- **Maven 3.6+**
- **Docker & Docker Compose**（用于启动 PostgreSQL）
- **Python 3.x**（可选，用于运行初始化脚本）

### 首次启动（干净环境）

#### 步骤 1: 启动 PostgreSQL 数据库

```bash
# 进入项目根目录
cd backend-calotter

# 启动 PostgreSQL 容器
docker-compose up -d

# 验证数据库是否启动成功
docker ps | grep calotter_postgres
```

数据库配置（已在 `docker-compose.yml` 中配置）：
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `calotter`
- **Username**: `postgres`
- **Password**: `123`

#### 步骤 2: 配置环境变量（可选）

如果需要使用 AI 功能（菜单生成、营养估算），需要配置 API Keys：
   
   ```bash
   # 复制环境变量模板
   cp env.template .env
   
   # 编辑 .env 文件，填入你的 API Keys
# 至少需要配置以下之一：
# - GEMINI_API_KEY（用于 Spring AI Gemini）
# - GROQ_API_KEY（用于 Groq API）
```

`.env` 文件示例：
```bash
GEMINI_API_KEY=your_gemini_api_key_here
GROQ_API_KEY=your_groq_api_key_here
```

> **注意**：Spring Boot 会自动加载 `.env` 文件，无需手动设置环境变量。

#### 步骤 3: 建表并填充标准库（首次启动 Spring Boot）

**重要**：删库后只需启动一次 Spring Boot 即可自动完成建表和标准库填充，无需单独运行初始化脚本。

- **JPA**（`ddl-auto: update`）：启动时自动创建/更新所有表结构。
- **DataSqlRunner**：在 Hibernate 建表完成后自动执行 `calotter-start/src/main/resources/data.sql`，插入标准库数据（过敏原、食材、调料、厨具）。

```bash
# 进入启动模块
cd calotter-start

# 启动 Spring Boot 应用（自动建表 + 自动执行 data.sql 填充标准库）
mvn spring-boot:run

# 等待看到 "Started CalotterApplication" 后，可按 Ctrl+C 停止，或保持运行
```

**标准库内容**（由 data.sql 填充）：
- 标准过敏原库（10 条）、标准食材库（154 条，YOLO 83 + 欧美扩展；别名如 Zucchini 已删，仅保留 Courgette）、标准调料库（40 条）、标准厨具库（34 条）

**若需在不启动应用时单独执行 data.sql**：`python run_init_sql.py` 或 `psql -h localhost -U postgres -d calotter -f calotter-start/src/main/resources/data.sql`（需先由 JPA 建表，否则会报错）。

#### 步骤 4: 编译项目

```bash
# 在项目根目录执行
mvn clean install

# 如果遇到依赖下载问题，可以跳过测试
mvn clean install -DskipTests
```

#### 步骤 5: 启动后端应用（若步骤 3 未停止可跳过）

```bash
# 进入启动模块
cd calotter-start

# 启动 Spring Boot 应用
mvn spring-boot:run

# 或者使用 IDE 直接运行 CalotterApplication.java
```

启动成功后，你应该看到：
```
Started CalotterApplication in X.XXX seconds
```

应用默认运行在：**http://localhost:8080**

#### 步骤 6: 验证启动成功

```bash
# 测试健康检查端点（如果存在）
curl http://localhost:8080/actuator/health

# 或者测试用户注册端点
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

### 日常开发（更新后重建）

每次代码更新后，建议执行以下步骤确保数据库和代码同步：

#### 快速重建流程

```bash
# 1. 停止后端应用（如果正在运行）
# 在运行应用的终端按 Ctrl+C

# 2. 删除并重建数据库（⚠️ 会删除所有数据）
docker-compose down -v          # 删除容器和数据卷
docker-compose up -d            # 重新创建容器

# 3. 等待数据库启动（约 5 秒）
# Windows PowerShell: Start-Sleep -Seconds 5
# Linux/Mac: sleep 5

# 4. 建表并填充标准库（启动一次 Spring Boot 即可，DataSqlRunner 会自动执行 data.sql）
cd calotter-start
mvn spring-boot:run
# 等待看到 "Started CalotterApplication" 后，按 Ctrl+C 停止（或保持运行）

# 5. 重新编译并启动（若步骤 4 已停止）
cd ..
mvn clean install
cd calotter-start
mvn spring-boot:run
```

#### 仅删除数据（保留表结构）

如果只想清空数据但保留表结构：

   ```sql
-- 连接到数据库
docker exec -it calotter_postgres psql -U postgres -d calotter

-- 执行清空脚本（在 psql 中）
TRUNCATE TABLE household_ingredients CASCADE;
TRUNCATE TABLE household_spices CASCADE;
TRUNCATE TABLE household_utensils CASCADE;
TRUNCATE TABLE household_leftovers CASCADE;
TRUNCATE TABLE cooking_sessions CASCADE;
TRUNCATE TABLE family_members CASCADE;
TRUNCATE TABLE health_goals CASCADE;
TRUNCATE TABLE households CASCADE;
TRUNCATE TABLE users CASCADE;

-- 退出 psql 后，在项目根目录重新初始化标准库（二选一）：
-- python run_init_sql.py
-- 或: psql -h localhost -U postgres -d calotter -f calotter-start/src/main/resources/data.sql
```

或使用 Python 脚本（在项目根目录）：

```python
# 创建临时脚本 clear_data.py
import psycopg2

conn = psycopg2.connect(
    host='localhost',
    port=5432,
    database='calotter',
    user='postgres',
    password='123'
)
conn.autocommit = True
cursor = conn.cursor()

# 清空所有业务数据表
tables = [
    'household_ingredients',
    'household_spices',
    'household_utensils',
    'household_leftovers',
    'cooking_sessions',
    'family_members',
    'health_goals',
    'households',
    'users'
]

for table in tables:
    cursor.execute(f'TRUNCATE TABLE {table} CASCADE;')
    print(f'✅ Cleared {table}')

cursor.close()
conn.close()
```

---

## 🔗 前后端联通测试

### 前置准备

1. **后端已启动**：确保后端运行在 `http://localhost:8080`
2. **前端已启动**：确保 Flutter 前端已运行
3. **配置前端 API 地址**：编辑 `frontend-app/lib/config/api_config.dart`

```dart
// 模拟器使用
static const String serverIp = "10.0.2.2";

// 真机使用（替换为你的电脑 IP）
static const String serverIp = "192.168.1.100";  // 你的局域网 IP
```

### 测试步骤

#### 1. 测试用户注册

**后端端点**：`POST /api/user/register`

**使用 curl**：
```bash
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "message": "Registration successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1,
    "householdId": 1
  }
}
```

**前端测试**：
- 打开 Flutter 应用
- 进入注册页面
- 填写注册信息并提交
- 检查是否成功跳转到主页

#### 2. 测试用户登录

**后端端点**：`POST /api/user/login`

```bash
curl -X POST http://localhost:8080/api/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

#### 3. 测试获取标准食材库

**后端端点**：`GET /api/inventory/standard-ingredients`

```bash
# 需要先获取 token（从注册/登录响应中）
TOKEN="your_jwt_token_here"

curl -X GET http://localhost:8080/api/inventory/standard-ingredients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**前端测试**：
- 登录后进入库存页面
- 点击添加食材
- 检查标准食材列表是否正常加载

#### 4. 测试添加食材

**后端端点**：`POST /api/inventory/ingredients`

```bash
curl -X POST http://localhost:8080/api/inventory/ingredients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardIngredientId": 1001,
    "quantity": 5.0,
    "unit": "pcs",
    "expirationDate": "2024-12-31",
    "location": "FRIDGE"
  }'
```

#### 5. 测试 AI 菜单生成

**后端端点**：`POST /api/cooking/generate-menu`

```bash
curl -X POST http://localhost:8080/api/cooking/generate-menu \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "cuisine": "chinese",
    "taste": ["spicy", "sweet"],
    "dietHabits": [],
    "avoidIngredients": []
  }'
```

> **注意**：此端点需要配置 AI API Key（Groq 或 Gemini）

### 常见问题排查

#### 问题 1: 前端无法连接后端

**症状**：前端显示网络错误或超时

**排查步骤**：
1. 检查后端是否运行：`curl http://localhost:8080/actuator/health`
2. 检查前端 API 配置：`frontend-app/lib/config/api_config.dart`
3. 真机测试时，确保手机和电脑在同一局域网
4. 检查防火墙是否阻止了 8080 端口

#### 问题 2: 数据库连接失败

**症状**：后端启动时报错 `Connection refused` 或 `Authentication failed`

**排查步骤**：
1. 检查 PostgreSQL 容器是否运行：`docker ps | grep postgres`
2. 检查数据库配置：`calotter-start/src/main/resources/application.yml`
3. 验证数据库连接：
   ```bash
   docker exec -it calotter_postgres psql -U postgres -d calotter
   ```

#### 问题 3: 标准库数据缺失

**症状**：前端无法加载标准食材列表

**排查步骤**：
1. 检查标准库数据：
   ```sql
   SELECT COUNT(*) FROM ref_standard_ingredients;
   ```
2. 如果数据为空，重新运行初始化脚本：
   ```bash
   python run_init_sql.py
   ```

---

## 📁 项目结构详解

### calotter-common（通用模块）

**职责**：提供所有模块共享的基础功能

**核心组件**：
- `BaseEntity`：所有实体的基类，包含审计字段
- `Result<T>`：统一 API 响应格式
- `GlobalExceptionHandler`：全局异常处理
- `StandardIngredient`、`StandardSpice` 等标准库实体

### calotter-user（用户模块）

**职责**：用户、家庭、家庭成员、健康目标管理

**核心实体**：
- `User`：用户账户
- `Household`：家庭组（多用户共享）
- `FamilyMember`：家庭成员（关联健康目标）
- `HealthGoal`：健康目标

**关键特性**：
- JWT 认证
- 家庭邀请功能（QR 码）
- 用户偏好管理（JSONB 字段）

### calotter-inventory（库存模块）

**职责**：食材、厨具、调料、剩菜管理

**核心实体**：
- `Ingredient`：食材库存（关联 StandardIngredient）
- `HouseholdUtensil`：厨具（关联 StandardUtensil）
- `HouseholdSpice`：调料（关联 StandardSpice）
- `LeftoverDish`：剩菜

**关键特性**：
- 单位验证（primary_unit, secondary_unit, conversion_factor）
- 过期提醒
- 库存扣减（烹饪时）

### calotter-cooking（烹饪模块）

**职责**：AI 菜单生成、烹饪会话管理

**核心实体**：
- `CookingSession`：烹饪会话记录

**关键服务**：
- `AiMenuService`：AI 菜单生成（支持 Groq、Gemini）
- `CookingContextBuilderService`：构建 AI 上下文
- `NutritionEstimatorService`：营养估算

### calotter-start（启动模块）

**职责**：应用入口、配置管理

**核心文件**：
- `CalotterApplication.java`：Spring Boot 启动类
- `application.yml`：应用配置
- `DotenvConfig.java`：.env 文件加载

---

## 🗄️ 数据库说明

### 数据库初始化（删库后可自动建表 + 自动填充）

- **JPA**（`ddl-auto: update`）：启动时自动创建/更新所有表结构  
- **DataSqlRunner**：在 Hibernate 建表完成后自动执行 `data.sql`，插入标准库数据  

因此**删库后只需启动一次 Spring Boot**，即可自动完成建表和标准库填充，无需单独运行初始化脚本。

**若需仅手动执行 data.sql**（不启动应用）：`python run_init_sql.py` 或 `psql -f calotter-start/src/main/resources/data.sql`。

### 主要表结构

#### 标准库表（只读，由 data.sql 初始化）
- `ref_standard_allergens`：标准过敏原库（10 条）
- `ref_standard_ingredients`：标准食材库（154 条，YOLO 83 + 欧美扩展；别名已删，仅保留一种称呼如 Courgette）
- `ref_standard_spices`：标准调料库（40 条）
- `ref_standard_utensils`：标准厨具库（34 条）

#### 业务表（由 JPA 自动创建）
- `users`：用户表
- `households`：家庭组表
- `family_members`：家庭成员表
- `health_goals`：健康目标表
- `household_ingredients`：食材库存表
- `household_utensils`：厨具表
- `household_spices`：调料表
- `household_leftovers`：剩菜表
- `cooking_sessions`：烹饪会话表

### 单位系统

所有食材支持**双单位系统**：

- `primary_unit`：主单位（如 `pcs`, `g`, `ml`）
- `secondary_unit`：次单位（如 `g`, `kg`, `L`）
- `unit_conversion_factor`：转换系数（1 primary_unit = unit_conversion_factor secondary_unit）
- `standard_unit`：标准单位（`g` 或 `ml`），用于营养计算

**示例**：
- Apple: `primary_unit='pcs'`, `secondary_unit='g'`, `conversion_factor=150.0` (1 pcs = 150 g)
- Beef: `primary_unit='g'`, `secondary_unit='kg'`, `conversion_factor=0.001` (1 g = 0.001 kg)
- Milk: `primary_unit='ml'`, `secondary_unit='L'`, `conversion_factor=0.001` (1 ml = 0.001 L)

---

## 🔌 API 端点

### 用户模块

- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `GET /api/user/profile` - 获取用户资料
- `PUT /api/user/profile` - 更新用户资料
- `GET /api/user/preferences` - 获取偏好选项

### 库存模块

- `GET /api/inventory/standard-ingredients` - 获取标准食材库
- `GET /api/inventory/standard-spices` - 获取标准调料库
- `GET /api/inventory/standard-utensils` - 获取标准厨具库
- `GET /api/inventory/ingredients` - 获取家庭食材列表
- `POST /api/inventory/ingredients` - 添加食材
- `PUT /api/inventory/ingredients/{id}` - 更新食材
- `DELETE /api/inventory/ingredients/{id}` - 删除食材

### 烹饪模块

- `POST /api/cooking/generate-menu` - 生成 AI 菜单
- `POST /api/cooking/generate-context` - 生成 AI 上下文
- `POST /api/cooking/start-session` - 开始烹饪会话
- `POST /api/cooking/finish-session` - 结束烹饪会话

### 健康模块

- `GET /api/health/goals` - 获取健康目标
- `POST /api/health/goals` - 创建健康目标

---

## 💡 开发建议

### 1. 数据库管理

- **开发环境**：使用 `ddl-auto: update` 自动更新表结构
- **生产环境**：建议使用 Flyway 或 Liquibase 进行版本管理
- **数据迁移**：修改实体类后，JPA 会自动更新表结构

### 2. 模块开发

- **新增实体**：继承 `BaseEntity` 以自动获得审计字段
- **API 响应**：统一使用 `Result<T>` 格式
- **异常处理**：抛出业务异常，由 `GlobalExceptionHandler` 统一处理

### 3. 标准库更新

- **添加新食材**：编辑 `calotter-start/src/main/resources/data.sql`
- **对齐 YOLO 模型**：确保标准食材库与 `frontend-app/lib/core/config/yolo_labels_config.dart`、`ingredient_icon_config.dart` 中的标签/图标一致

### 4. 测试

- **单元测试**：每个模块都有对应的测试类
- **集成测试**：在 `calotter-start/src/test` 中
- **API 测试**：使用 curl 或 Postman

### 5. 代码规范

- 使用 Lombok 减少样板代码
- 遵循 RESTful API 设计规范
- 使用有意义的变量和方法名
- 添加必要的注释（特别是业务逻辑）

---

## 📝 注意事项

1. **JPA Auditing**：当前使用固定用户 ID（1L），后续需要集成 Spring Security
2. **JSONB 字段**：`User.settings`、`FamilyMember.preferences` 等使用 PostgreSQL JSONB 类型
3. **级联删除**：`Household` 删除时会级联删除所有关联的库存数据
4. **模块依赖**：注意模块间的依赖关系，避免循环依赖
5. **环境变量**：`.env` 文件不要提交到 Git，使用 `env.template` 作为模板

---

## 🆘 故障排除

### 常见错误

1. **端口被占用**：修改 `application.yml` 中的 `server.port`
2. **数据库连接失败**：检查 Docker 容器是否运行，密码是否正确
3. **编译失败**：运行 `mvn clean install -U` 更新依赖
4. **AI API 调用失败**：检查 `.env` 文件中的 API Key 是否正确

### 获取帮助

- 查看日志：`calotter-start` 目录下的日志文件
- 检查数据库：`docker exec -it calotter_postgres psql -U postgres -d calotter`
- 查看 Spring Boot 启动日志中的错误信息

---

## 📚 相关文档

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Spring Data JPA 文档](https://spring.io/projects/spring-data-jpa)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)

---

**最后更新**：2024-01-XX
