# Calotter Backend - Spring Boot JPA

基于 Spring Boot 3.2.0 和 JPA 的 Personal Sous Chef 后端重构项目。

## 项目结构

```
backend-calotter/
├── calotter/                    # Maven 父工程
│   ├── calotter-common/         # 通用模块（工具类、Result、异常处理、BaseEntity）
│   ├── calotter-modules/        # 业务模块聚合层
│   │   ├── calotter-user/       # 用户模块（User, Household, FamilyMember, HealthGoal）
│   │   ├── calotter-cooking/    # 烹饪模块（CookingSession, AI 上下文构建）
│   │   └── calotter-inventory/  # 库存模块（Ingredient, HouseholdUtensil, HouseholdSpice, LeftoverDish）
│   └── calotter-start/          # 启动模块（唯一的入口）
```

## 技术栈

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **PostgreSQL**
- **Lombok**
- **Maven**

## 快速开始

### 前置要求

- Java 17+
- Maven 3.6+
- PostgreSQL 数据库

### 启动步骤

1. **配置数据库**

   编辑 `calotter-start/src/main/resources/application.yml`，修改数据库连接信息：

   ```yaml
   spring:
     datasource:
       url: jdbc:postgresql://localhost:5432/calotter
       username: postgres
       password: postgres
   ```

2. **创建数据库**

   ```sql
   CREATE DATABASE calotter;
   ```

3. **编译项目**

   ```bash
   cd backend-calotter
   mvn clean install
   ```

4. **启动应用**

   ```bash
   cd calotter-start
   mvn spring-boot:run
   ```

   或者直接运行 `CalotterApplication.java`

## 核心特性

### 1. 实体类设计

- **BaseEntity**: 所有实体的基类，包含审计字段（createTime, updateTime, createBy, updateBy）
- **标准库实体**: RefAllergen, StandardIngredient, StandardUtensil, StandardSpice
- **用户模块**: User, Household, FamilyMember, HealthGoal
- **库存模块**: Ingredient, HouseholdUtensil, HouseholdSpice, LeftoverDish
- **烹饪模块**: CookingSession

### 2. JPA 特性

- 使用 `@MappedSuperclass` 实现实体继承
- 使用 `@EntityListeners` 和 JPA Auditing 自动填充审计字段
- 使用 `@JdbcTypeCode(SqlTypes.JSON)` 支持 PostgreSQL JSONB 字段
- 使用级联操作（CascadeType.ALL）和孤儿删除（orphanRemoval = true）

### 3. 模块化设计

- **calotter-common**: 通用功能，被所有业务模块依赖
- **calotter-modules**: 业务逻辑模块，相互独立但可相互引用
- **calotter-start**: 启动模块，聚合所有业务模块

## API 端点

### 烹饪模块

- `POST /api/cooking/generate-context` - 生成 AI 烹饪上下文

## 数据库

项目使用 JPA 的 `ddl-auto: update` 自动创建和更新表结构。首次启动时会自动创建所有表。

### 主要表结构

- `users` - 用户表
- `households` - 家庭组表
- `family_members` - 家庭成员表
- `health_goals` - 健康目标表
- `household_ingredients` - 食材库存表
- `household_utensils` - 厨具表
- `household_spices` - 调料表
- `household_leftovers` - 剩菜表
- `cooking_sessions` - 烹饪会话表
- `ref_standard_ingredients` - 标准食材库
- `ref_standard_utensils` - 标准厨具库
- `ref_standard_spices` - 标准调料库
- `ref_standard_allergens` - 标准过敏原库

## 注意事项

1. **JPA Auditing**: 需要在配置类中启用，当前使用固定用户ID（1L），后续需要集成 Spring Security
2. **JSONB 字段**: User.settings, FamilyMember.preferences, CookingSession.requestContext/aiResponse 使用 PostgreSQL JSONB 类型
3. **级联删除**: Household 删除时会级联删除所有关联的库存数据
4. **模块依赖**: inventory 模块依赖 user 模块，cooking 模块依赖 user 和 inventory 模块

## 开发建议

1. 使用 IDE 的 Maven 工具进行模块管理
2. 修改实体类后，JPA 会自动更新表结构（开发环境）
3. 生产环境建议使用 Flyway 或 Liquibase 进行数据库版本管理
4. 后续需要集成 Spring Security 实现用户认证和授权
