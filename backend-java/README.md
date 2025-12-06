# Sous Chef Backend - Spring Boot

这是 Personal Sous Chef 项目的 Spring Boot 后端实现。

## 功能特性

- 用户认证和授权（JWT）
- 用户信息管理
- 用户偏好、禁忌、过敏原管理
- 标准库（食材、炊具、调料）查询
- PostgreSQL 数据库集成
- Docker 支持

## 技术栈

- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security
- PostgreSQL
- JWT (jjwt)
- Maven

## 快速开始

### 前置要求

- Java 17 或更高版本
- Maven 3.6+
- Docker Desktop（用于运行 PostgreSQL）

### 启动步骤

1. **启动 PostgreSQL 数据库**：
   ```bash
   cd backend-java
   docker-compose up -d
   ```

2. **运行应用**：
   ```bash
   mvn spring-boot:run
   ```

   或者使用 IDE 直接运行 `SousChefBackendApplication.java`

3. **访问应用**：
   - API 基础路径: `http://localhost:8080`
   - 测试端点: `http://localhost:8080/hello`

## API 端点

### 认证
- `POST /api/ums/auth/register` - 用户注册
- `POST /api/ums/auth/login` - 用户登录

### 用户信息
- `GET /api/ums/user` - 获取用户信息
- `PUT /api/ums/user` - 更新用户信息
- `GET /api/ums/user/preferences` - 获取用户偏好
- `PUT /api/ums/user/preferences` - 更新用户偏好
- `GET /api/ums/user/taboos` - 获取用户禁忌
- `PUT /api/ums/user/taboos` - 更新用户禁忌
- `GET /api/ums/user/allergies` - 获取用户过敏原
- `PUT /api/ums/user/allergies` - 更新用户过敏原

### 标准库
- `GET /api/StandardLibrary/ingredients` - 获取所有标准食材

### 测试
- `GET /hello` - Hello World 测试端点
- `GET /WeatherForecast` - 天气预报示例端点

## 配置

配置文件位于 `src/main/resources/application.yml`

主要配置项：
- 数据库连接：PostgreSQL (localhost:5432)
- JWT 密钥和过期时间
- 服务器端口：8080

## 数据库

应用使用 PostgreSQL 数据库，通过 Docker Compose 启动。

数据库会自动创建表结构（通过 JPA Hibernate），并初始化种子数据。

## 从 .NET 后端迁移

此 Spring Boot 后端完全移植自 `backend-csharp` 文件夹下的 .NET 实现，保持了相同的 API 接口和功能。

