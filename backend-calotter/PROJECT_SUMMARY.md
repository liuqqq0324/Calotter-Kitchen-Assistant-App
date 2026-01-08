# Personal Sous Chef 后端项目开发指南

## 📋 文档信息

**文档版本：** 5.0  
**最后更新：** 2026-01-08  
**项目名称：** A-team-PersonalSousChef  
**后端框架：** Spring Boot 3.2.0 + JPA + PostgreSQL

---

## 🚨 重要提醒

### ⚠️ 每次测试前请务必删除数据库！

**原因：**
- 避免测试数据污染影响测试结果
- 确保实体关系、外键约束的完整性
- 防止因旧数据导致的测试失败
- 保证测试环境的一致性

**快速删库命令：**

```bash
# 使用 Docker（推荐）
docker-compose down -v

# 使用本地 PostgreSQL
psql -U postgres -c "DROP DATABASE IF EXISTS calotter;" && \
psql -U postgres -c "CREATE DATABASE calotter;"
```

**完整测试流程：**
1. **删库** → 2. **重建库** → 3. **初始化标准库** → 4. **启动应用** → 5. **测试**

详细步骤见下方"测试前环境准备"章节。

---

## 📑 目录

1. [前置要求](#前置要求)
2. [快速开始](#快速开始)
3. [测试前环境准备（⚠️ 必读）](#测试前环境准备-必读)
4. [启动应用](#启动应用)
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

## 快速开始

### 步骤 1：进入项目目录

```bash
cd backend-calotter
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

### 步骤 4：初始化标准库数据

```bash
# 使用 Docker
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

# 或使用本地 PostgreSQL
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

### 步骤 5：启动应用

```bash
cd calotter-start
mvn spring-boot:run
```

**预期输出：**
```
Started CalotterApplication in X.XXX seconds
```

### 步骤 6：验证启动

访问：`http://localhost:8080/api/user/register`

---

## 测试前环境准备（⚠️ 必读）

### 🎯 每次测试前的标准流程

**重要：每次进行功能测试、回归测试或集成测试前，请务必执行以下步骤！**

#### 步骤 1：停止应用

```bash
# 如果应用正在运行，按 Ctrl+C 停止
# 或查找进程并停止
# Windows
netstat -ano | findstr :8080
taskkill /PID <进程ID> /F

# Linux/Mac
lsof -i :8080
kill -9 <进程ID>
```

#### 步骤 2：删除数据库（⚠️ 关键步骤）

**使用 Docker（推荐）：**

```bash
# 删除容器和数据卷（这会删除所有数据）
docker-compose down -v

# 等待完全删除
sleep 3
```

**使用本地 PostgreSQL：**

```bash
# 删除数据库
psql -U postgres -c "DROP DATABASE IF EXISTS calotter;"

# 等待删除完成
sleep 1
```

#### 步骤 3：重新创建数据库

**使用 Docker：**

```bash
# 重新启动数据库容器
docker-compose up -d postgres

# 等待数据库启动（约 5-10 秒）
sleep 10

# 验证数据库是否运行
docker ps | grep calotter_postgres
```

**使用本地 PostgreSQL：**

```bash
# 重新创建数据库
psql -U postgres -c "CREATE DATABASE calotter;"
```

#### 步骤 4：初始化标准库数据

```bash
# 使用 Docker
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

# 或使用本地 PostgreSQL
psql -U postgres -d calotter -f init-standard-libraries.sql
```

**验证标准库初始化：**

```bash
# 检查标准食材数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_ingredients;"
# 预期：83

# 检查标准调料数量
psql -U postgres -d calotter -c "SELECT COUNT(*) FROM ref_standard_spices;"
# 预期：30
```

#### 步骤 5：启动应用

```bash
cd calotter-start
mvn spring-boot:run
```

#### 步骤 6：验证应用启动

- ✅ 检查日志：应该看到 `Started CalotterApplication`
- ✅ 测试 API：访问 `http://localhost:8080/api/user/register`

### 🔄 一键重置脚本（可选）

为了方便，可以创建以下脚本：

**Windows (`reset-db.bat`):**

```batch
@echo off
echo [1/4] 停止应用...
taskkill /F /IM java.exe 2>nul

echo [2/4] 删除数据库...
docker-compose down -v
timeout /t 3 /nobreak >nul

echo [3/4] 重建数据库...
docker-compose up -d postgres
timeout /t 10 /nobreak >nul

echo [4/4] 初始化标准库...
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

echo ========================================
echo 数据库重置完成！可以启动应用了。
echo 执行: cd calotter-start && mvn spring-boot:run
echo ========================================
```

**Linux/Mac (`reset-db.sh`):**

```bash
#!/bin/bash
echo "[1/4] 停止应用..."
pkill -f "spring-boot:run" || true

echo "[2/4] 删除数据库..."
docker-compose down -v
sleep 3

echo "[3/4] 重建数据库..."
docker-compose up -d postgres
sleep 10

echo "[4/4] 初始化标准库..."
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

echo "========================================"
echo "数据库重置完成！可以启动应用了。"
echo "执行: cd calotter-start && mvn spring-boot:run"
echo "========================================"
```

**使用方法：**

```bash
# Windows
.\reset-db.bat

# Linux/Mac
chmod +x reset-db.sh
./reset-db.sh
```

---

## 启动应用

### 方式 1：使用 Maven（推荐）

```bash
cd calotter-start
mvn spring-boot:run
```

### 方式 2：使用 IDE

1. 打开项目根目录
2. 找到 `calotter-start/src/main/java/com/calotter/CalotterApplication.java`
3. 右键 → Run 'CalotterApplication'

### 方式 3：打包后运行

```bash
# 打包
mvn clean package -DskipTests

# 运行
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

```bash
# 使用 Docker
docker exec -it calotter_postgres psql -U postgres -d calotter -c "\dt"

# 或使用本地 PostgreSQL
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
 public | household_utensils             | table | postgres
 public | household_leftovers            | table | postgres
 public | dishes                         | table | postgres
 public | cooking_sessions               | table | postgres
 public | nutrition_logs                 | table | postgres
 public | daily_nutrient_aggregates      | table | postgres
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

2. **按照"测试前环境准备"重新设置环境**
   - 删除数据库
   - 重建数据库
   - 重新启动应用

### 问题 3：标准库数据为空

**错误信息：**
```
SELECT COUNT(*) FROM ref_standard_ingredients;  -- 返回 0
```

**解决方案：**

1. **重新执行初始化脚本**
   ```bash
   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
   ```

2. **检查脚本执行日志**
   - 确认没有 SQL 错误
   - 确认看到 "Standard Libraries Initialization Complete!" 消息

### 问题 4：测试数据不一致

**错误信息：**
- 测试失败，数据不匹配
- 外键约束错误
- 实体关系错误

**解决方案：**

1. **⚠️ 立即删除数据库并重建**
   ```bash
   docker-compose down -v
   docker-compose up -d postgres
   sleep 10
   docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql
   ```

2. **确认是否在测试前删除了数据库**
   - 检查数据库中是否有旧的测试数据
   - 如果有很多测试数据，应该先删库重建

3. **使用"测试前环境准备"的标准流程**

### 问题 5：Maven 编译失败

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

### 问题 6：端口被占用

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

### 问题 7：Docker 容器无法启动

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
│   │   ├── controller/              # API 控制器
│   │
│   ├── calotter-cooking/            # 烹饪模块
│   │   ├── domain/entity/           # CookingSession, Dish
│   │   ├── repository/              # 数据访问接口
│   │   ├── service/                 # 业务服务层（AI 菜单生成）
│   │   └── controller/              # API 控制器
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

# ⚠️ 删除数据库并重建（Docker）- 测试前必执行
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

### ⚠️ 测试前完整流程（一键执行）

**使用 Docker：**

```bash
# 停止应用 + 删库 + 重建 + 初始化 + 启动应用
docker-compose down -v && \
docker-compose up -d postgres && \
sleep 10 && \
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql && \
cd calotter-start && \
mvn spring-boot:run
```

**使用本地 PostgreSQL：**

```bash
# 停止应用 + 删库 + 重建 + 初始化 + 启动应用
psql -U postgres -c "DROP DATABASE IF EXISTS calotter;" && \
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

---

## 相关文档

- [README.md](./README.md) - 项目快速开始指南
- [API_CONFIG.md](./API_CONFIG.md) - AI API 配置说明（如有）
- [init-standard-libraries.sql](./init-standard-libraries.sql) - 标准库初始化脚本

---

## 📝 最后提醒

### ⚠️ 测试前请务必：

1. ✅ **删除数据库**（`docker-compose down -v` 或 `DROP DATABASE`）
2. ✅ **重建数据库**（`docker-compose up -d postgres` 或 `CREATE DATABASE`）
3. ✅ **初始化标准库**（执行 `init-standard-libraries.sql`）
4. ✅ **启动应用**（`mvn spring-boot:run`）
5. ✅ **验证环境**（检查 API 和数据库）

这样可以确保：
- 测试环境干净，不受旧数据影响
- 实体关系完整，外键约束正确
- 测试结果准确可靠

---

**文档维护：** 本文档应随项目更新及时维护，确保信息的准确性和完整性。

**最后更新：** 2026-01-08
