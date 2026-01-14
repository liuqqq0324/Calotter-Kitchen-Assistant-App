# Personal Sous Chef 后端项目开发指南

## 📋 文档信息

**文档版本：** 6.0  
**最后更新：** 2026-01-14  
**项目名称：** A-team-PersonalSousChef  
**后端框架：** Spring Boot 3.2.0 + JPA + PostgreSQL

---

## 📑 目录

1. [前置要求](#前置要求)
2. [全新环境搭建指南](#全新环境搭建指南)
3. [数据库建立步骤](#数据库建立步骤)
4. [启动后端应用](#启动后端应用)
5. [验证环境](#验证环境)
6. [常见问题排查](#常见问题排查)
7. [项目结构概览](#项目结构概览)

---

## 前置要求

### 必需软件

- **Java 17+**（推荐使用 OpenJDK 17）
- **Maven 3.6+**
- **PostgreSQL 15+**（或使用 Docker）
- **Docker Desktop**（可选，推荐用于数据库）

### 验证安装

```bash
# 检查 Java 版本
java -version
# 应该显示：openjdk version "17" 或更高

# 检查 Maven 版本
mvn -version
# 应该显示：Apache Maven 3.6.x 或更高

# 检查 PostgreSQL（如果已安装）
psql --version
# 应该显示：psql (PostgreSQL) 15.x 或更高

# 检查 Docker（如果使用）
docker --version
# 应该显示：Docker version 20.x 或更高
```

---

## 全新环境搭建指南

本指南适用于**全新的开发环境**，帮助团队成员快速搭建后端开发环境。

### 步骤 1：克隆项目

```bash
# 克隆项目到本地
git clone <repository-url>
cd A-team-PersonalSousChef/backend-calotter
```

### 步骤 2：启动 PostgreSQL 数据库

**方式 A：使用 Docker（推荐）**

```bash
# 启动 PostgreSQL 容器
docker-compose up -d postgres

# 等待数据库启动（约 5-10 秒）
sleep 10

# 验证数据库是否运行
docker ps | grep calotter_postgres
```

**方式 B：使用本地 PostgreSQL**

```bash
# 确保 PostgreSQL 服务正在运行
# Windows: 检查服务管理器
# Linux: sudo systemctl status postgresql
# Mac: brew services list | grep postgresql

# 创建数据库
psql -U postgres -c "CREATE DATABASE calotter;"
```

### 步骤 3：配置数据库连接

编辑 `calotter-start/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/calotter
    username: postgres
    password: 123  # Docker 默认密码，本地 PostgreSQL 请修改为你的密码
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update  # 开发环境：自动创建/更新表结构
    show-sql: true
```

**注意：**
- 如果使用本地 PostgreSQL，请将 `password` 修改为你的 PostgreSQL 密码
- Docker 默认密码为 `123`（见 `docker-compose.yml`）

### 步骤 4：配置环境变量（可选）

如果需要使用 AI API（Groq、Gemini），需要配置 API Key：

```bash
# 复制环境变量模板
cp env.template .env

# 编辑 .env 文件，填入你的 API Keys
# .env 文件应放在 backend-calotter 目录下（项目根目录）
```

**环境变量说明：**
- `GEMINI_API_KEY`: Google Gemini API Key（如果使用 Gemini）
- `GROQ_API_KEY`: Groq API Key（如果使用 Groq）

**注意：** `.env` 文件不会被提交到 Git，请妥善保管你的 API Keys。

---

## 数据库建立步骤

### 步骤 1：创建数据库

**使用 Docker（推荐）：**

```bash
# Docker 会自动创建数据库（见 docker-compose.yml）
# 只需确保容器正在运行
docker ps | grep calotter_postgres
```

**使用本地 PostgreSQL：**

```bash
# 创建数据库
psql -U postgres -c "CREATE DATABASE calotter;"

# 验证数据库是否创建成功
psql -U postgres -c "\l" | grep calotter
```

### 步骤 2：初始化标准库数据

标准库数据包括：
- 标准过敏原库（10 种）
- 标准食材库（83 种）
- 标准调料库（30 种）
- 标准厨具库（25 种）

**使用 Docker：**

```bash
# 执行初始化脚本
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
```

**使用本地 PostgreSQL：**

```bash
# 执行初始化脚本
psql -U postgres -d calotter -f init-standard-libraries.sql
```

**预期输出：**
```
NOTICE:  ========================================
NOTICE:  Standard Libraries Initialization Complete!
NOTICE:  ========================================
NOTICE:  Standard Ingredients: 83
NOTICE:  Standard Spices: 30
NOTICE:  Standard Utensils: 25
NOTICE:  Standard Allergens: 10
NOTICE:  ========================================
```

### 步骤 3：验证标准库数据

```bash
# 使用 Docker
docker exec -it calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"
# 预期：83

docker exec -it calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_spices;"
# 预期：30

docker exec -it calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_utensils;"
# 预期：25

docker exec -it calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_allergens;"
# 预期：10
```

**使用本地 PostgreSQL：**

```bash
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_spices;"
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_utensils;"
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_allergens;"
```

### 步骤 4：表结构自动创建

**重要：** 项目使用 JPA 的 `ddl-auto: update` 模式，首次启动应用时会自动创建所有表结构。

你**不需要**手动创建表，只需：
1. 创建数据库（`calotter`）
2. 初始化标准库数据
3. 启动应用，JPA 会自动创建表结构

---

## 启动后端应用

### 方式 1：使用 Maven（推荐）

```bash
# 进入启动模块目录
cd calotter-start

# 启动应用
mvn spring-boot:run
```

**预期输出：**
```
Started CalotterApplication in X.XXX seconds
```

### 方式 2：使用 IDE

1. 打开项目根目录（`backend-calotter`）
2. 找到 `calotter-start/src/main/java/com/calotter/CalotterApplication.java`
3. 右键 → Run 'CalotterApplication'

### 方式 3：打包后运行

```bash
# 在项目根目录执行
mvn clean package -DskipTests

# 运行 JAR 文件
java -jar calotter-start/target/calotter-start-1.0.0-SNAPSHOT.jar
```

### 应用配置

应用默认配置：
- **端口**：`8080`
- **数据库**：`localhost:5432/calotter`
- **JPA DDL**：`update`（自动创建/更新表结构）
- **日志级别**：`DEBUG`（开发环境）

配置文件位置：`calotter-start/src/main/resources/application.yml`

---

## 验证环境

### 1. 验证数据库连接

**使用 Docker：**

```bash
# 查看所有表
docker exec -it calotter_postgres psql -U postgres -d calotter -c "\dt"
```

**使用本地 PostgreSQL：**

```bash
# 查看所有表
psql -U postgres -d calotter -c "\dt"
```

**预期输出：** 应该看到以下表（至少）：
```
                    List of relations
 Schema |              Name               | Type  |  Owner   
--------+--------------------------------+-------+----------
 public | ref_standard_allergens         | table | postgres
 public | ref_standard_ingredients       | table | postgres
 public | ref_standard_spices            | table | postgres
 public | ref_standard_utensils          | table | postgres
 public | users                          | table | postgres
 public | households                     | table | postgres
 public | health_goals                   | table | postgres
 public | household_ingredients          | table | postgres
 public | household_spices               | table | postgres
 public | household_utensils              | table | postgres
 public | household_leftovers            | table | postgres
 public | dishes                         | table | postgres
 public | cooking_sessions               | table | postgres
 public | nutrition_logs                 | table | postgres
 public | daily_nutrient_aggregates      | table | postgres
 public | user_recipes                   | table | postgres
 public | household_favorite_dishes      | table | postgres
```

### 2. 验证标准库数据

```bash
# 检查标准食材数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"
# 预期：83

# 检查标准调料数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_spices;"
# 预期：30

# 检查标准厨具数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_utensils;"
# 预期：25

# 检查标准过敏原数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_allergens;"
# 预期：10
```

### 3. 验证 API 端点

```bash
# 测试用户注册接口
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# 预期响应：
# {"code":200,"message":"注册成功","data":{...}}
```

### 4. 验证应用日志

启动应用后，检查日志输出：
- ✅ 应该看到：`Started CalotterApplication`
- ✅ 应该看到：`Hibernate: create table ...`（首次启动）
- ❌ 不应该看到：`Connection refused` 或 `Table does not exist`

---

## 常见问题排查

### 问题 1：数据库连接失败

**错误信息：**
```
Connection to localhost:5432 refused
```

**解决方案：**

1. **检查 PostgreSQL 是否运行**
   ```bash
   # Docker
   docker ps | grep calotter_postgres
   
   # 本地 PostgreSQL
   psql -U postgres -c "SELECT version();"
   ```

2. **检查数据库配置**
   - 确认 `application.yml` 中的数据库连接信息正确
   - 确认端口号（默认 5432）
   - 确认用户名和密码

3. **检查防火墙**
   - 确认端口 5432 未被防火墙阻止

### 问题 2：表不存在

**错误信息：**
```
Table "users" does not exist
```

**解决方案：**

1. **确认 JPA DDL 配置**
   ```yaml
   spring:
     jpa:
       hibernate:
         ddl-auto: update  # 应该是 update，不是 none
   ```

2. **重新启动应用**
   - JPA 会在首次启动时自动创建表结构
   - 确保数据库已创建且连接正常

### 问题 3：标准库数据为空

**错误信息：**
```
SELECT COUNT(*) FROM ref_standard_ingredients;  -- 返回 0
```

**解决方案：**

1. **重新执行初始化脚本**
   ```bash
   # Docker
   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
   
   # 本地 PostgreSQL
   psql -U postgres -d calotter -f init-standard-libraries.sql
   ```

2. **检查脚本执行日志**
   - 确认没有 SQL 错误
   - 确认看到 "Standard Libraries Initialization Complete!" 消息

### 问题 4：Maven 编译失败

**错误信息：**
```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin
```

**解决方案：**

1. **检查 Java 版本**
   ```bash
   java -version
   # 应该是 Java 17 或更高
   ```

2. **清理并重新编译**
   ```bash
   mvn clean install -DskipTests
   ```

3. **检查 Maven 配置**
   - 确认 `pom.xml` 中的 Java 版本配置正确
   - 确认 Maven 版本（推荐 3.6+）

### 问题 5：端口被占用

**错误信息：**
```
Port 8080 is already in use
```

**解决方案：**

1. **查找占用端口的进程**
   ```bash
   # Windows
   netstat -ano | findstr :8080
   
   # Linux/Mac
   lsof -i :8080
   ```

2. **停止占用端口的进程**
   ```bash
   # Windows
   taskkill /PID <进程ID> /F
   
   # Linux/Mac
   kill -9 <进程ID>
   ```

3. **或修改应用端口**
   ```yaml
   server:
     port: 8081  # 修改为其他端口
   ```

### 问题 6：Docker 容器无法启动

**错误信息：**
```
Error response from daemon: port is already allocated
```

**解决方案：**

1. **检查端口占用**
   ```bash
   docker ps -a | grep calotter_postgres
   ```

2. **删除旧容器**
   ```bash
   docker rm -f calotter_postgres
   ```

3. **重新启动**
   ```bash
   docker-compose up -d postgres
   ```

---

## 项目结构概览

```
backend-calotter/
├── pom.xml                          # Maven 父工程
├── docker-compose.yml               # Docker Compose 配置
├── init-standard-libraries.sql      # 标准库初始化脚本
├── run_init_sql.py                  # Python 初始化脚本（可选）
├── env.template                     # 环境变量模板
├── PROJECT_SUMMARY.md               # 本文档
├── README.md                        # 项目说明
│
├── calotter-common/                 # 通用模块
│   ├── core/                        # Result, PageResult 统一响应
│   ├── domain/                      # BaseEntity, 标准库实体
│   ├── exception/                   # 全局异常处理
│   └── config/                      # JPA Auditing 配置
│
├── calotter-modules/                # 业务模块
│   ├── calotter-user/               # 用户模块
│   │   ├── domain/entity/           # User, Household, HealthGoal
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层
│   │   ├── controller/              # API 控制器
│   │
│   ├── calotter-inventory/          # 库存模块
│   │   ├── domain/entity/           # Ingredient, HouseholdUtensil, 
│   │   │                             # HouseholdSpice, LeftoverDish
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层
│   │   ├── controller/               # API 控制器
│   │
│   ├── calotter-cooking/            # 烹饪模块
│   │   ├── domain/entity/           # CookingSession, Dish, UserRecipe
│   │   ├── repository/               # 数据访问接口
│   │   ├── service/                 # 业务服务层（AI 菜单生成）
│   │   └── controller/               # API 控制器
│   │
│   └── calotter-health/             # 健康模块
│       ├── domain/entity/           # NutritionLog, DailyNutrientAggregate
│       ├── repository/              # 数据访问接口
│       ├── service/                 # 业务服务层
│       └── controller/              # API 控制器
│
└── calotter-start/                  # 启动模块
    ├── CalotterApplication.java     # 启动类
    └── application.yml               # 应用配置文件
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

---

## 快速参考命令

### 数据库操作

```bash
# 启动数据库（Docker）
docker-compose up -d postgres

# 停止数据库（Docker）
docker-compose down

# 删除数据库并重建（Docker）
docker-compose down -v && docker-compose up -d postgres

# 连接数据库（Docker）
docker exec -it calotter_postgres psql -U postgres -d calotter

# 初始化标准库（Docker）
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

# 备份数据库
pg_dump -U postgres -d calotter > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复数据库
psql -U postgres -d calotter < backup_YYYYMMDD_HHMMSS.sql
```

### 应用操作

```bash
# 编译项目
mvn clean install -DskipTests

# 启动应用
cd calotter-start && mvn spring-boot:run

# 打包应用
mvn clean package -DskipTests

# 运行测试
mvn test
```

### 完整环境搭建流程（一键执行）

**使用 Docker：**

```bash
# 启动数据库 + 初始化标准库 + 启动应用
docker-compose up -d postgres && \
sleep 10 && \
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql && \
cd calotter-start && \
mvn spring-boot:run
```

**使用本地 PostgreSQL：**

```bash
# 创建数据库 + 初始化标准库 + 启动应用
psql -U postgres -c "CREATE DATABASE calotter;" && \
psql -U postgres -d calotter -f init-standard-libraries.sql && \
cd calotter-start && \
mvn spring-boot:run
```

### 验证操作

```bash
# 检查数据库表
psql -U postgres -d calotter -c "\dt"

# 检查标准库数据
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"

# 测试 API
curl -X POST http://localhost:8080/api/user/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"123456"}'
```

---

## 数据库初始化说明

### 标准库数据

`init-standard-libraries.sql` 脚本会初始化以下标准库数据：

1. **标准过敏原库**（`ref_standard_allergens`）
   - 10 种常见过敏原（Peanut, Milk, Egg, Soybean, Wheat, Seafood, Tree Nut, Fish, Sesame, Shellfish）

2. **标准食材库**（`ref_standard_ingredients`）
   - 83 种食材，包括：
     - 水果（24 种）：Apple, Banana, Orange, Strawberry 等
     - 蔬菜（24 种）：Broccoli, Carrot, Tomato, Potato 等
     - 肉类（20 种）：Beef, Chicken, Pork, Salmon 等
     - 谷物（6 种）：Rice, Pasta, Oats 等
     - 乳制品（2 种）：Milk, Butter
     - 其他（1 种）：Sesame Seeds

3. **标准调料库**（`ref_standard_spices`）
   - 30 种调料：Salt, Black Pepper, Soy Sauce, Vinegar 等

4. **标准厨具库**（`ref_standard_utensils`）
   - 25 种厨具：Frying Pan, Wok, Pot, Oven, Rice Cooker 等

### 初始化脚本特性

- **幂等性**：使用 `ON CONFLICT` 确保可重复执行
- **安全性**：不会删除或覆盖用户数据
- **完整性**：自动关联食材与过敏原的关系

### 表结构自动创建

**重要：** 项目使用 JPA 的 `ddl-auto: update` 模式，首次启动应用时会自动创建所有表结构。

你**不需要**手动创建表，只需：
1. 创建数据库（`calotter`）
2. 初始化标准库数据
3. 启动应用，JPA 会自动创建表结构

---

## 相关文档

- [README.md](./README.md) - 项目快速开始指南
- [env.template](./env.template) - 环境变量配置模板
- [init-standard-libraries.sql](./init-standard-libraries.sql) - 标准库初始化脚本
- [docker-compose.yml](./docker-compose.yml) - Docker Compose 配置

---

## 📝 最后提醒

### ✅ 全新环境搭建检查清单

1. ✅ **安装必需软件**（Java 17+, Maven 3.6+, PostgreSQL 15+ 或 Docker）
2. ✅ **启动 PostgreSQL 数据库**（Docker 或本地）
3. ✅ **创建数据库**（`calotter`）
4. ✅ **初始化标准库数据**（执行 `init-standard-libraries.sql`）
5. ✅ **配置数据库连接**（编辑 `application.yml`）
6. ✅ **配置环境变量**（可选，如果需要 AI API）
7. ✅ **启动应用**（`mvn spring-boot:run`）
8. ✅ **验证环境**（检查 API 和数据库）

### 🎯 关键要点

- **表结构自动创建**：JPA 会在首次启动时自动创建所有表，无需手动创建
- **标准库数据必需**：必须执行 `init-standard-libraries.sql` 初始化标准库数据
- **环境变量可选**：只有在使用 AI API 时才需要配置 `.env` 文件

---

**文档维护：** 本文档应随项目更新及时维护，确保信息的准确性和完整性。

**最后更新：** 2026-01-14
