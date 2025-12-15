# Calotter Homepage 模块实现说明

## 📋 概述

本文档说明在 calotter 项目中实现的 Homepage 营养追踪和摄入管理功能。该实现使用 MyBatis Plus 框架，遵循 calotter 项目的架构规范。

## 🗂️ 已创建的文件结构

### 1. 模块配置
- `calotter-homepage/pom.xml` - Maven 配置文件
- `calotter-homepage/src/main/java/com/calotter/homepage/CalotterHomepageApplication.java` - 启动类

### 2. Entity 实体类（使用 MyBatis Plus）
- `domain/NutritionTarget.java` - 营养目标实体
- `domain/IntakeRecord.java` - 摄入记录实体
- `domain/RecipeNutrition.java` - 菜谱营养成分实体

### 3. Mapper 接口和 XML
- `mapper/NutritionTargetMapper.java` + `resources/mapper/homepage/NutritionTargetMapper.xml`
- `mapper/IntakeRecordMapper.java` + `resources/mapper/homepage/IntakeRecordMapper.xml`
- `mapper/RecipeNutritionMapper.java` + `resources/mapper/homepage/RecipeNutritionMapper.xml`

### 4. Vo 类（View Object）
- `domain/vo/NutritionTargetVo.java`
- `domain/vo/IntakeRecordVo.java`
- `domain/vo/RecipeNutritionVo.java`

### 5. Service 接口
- `service/INutritionService.java` - 营养服务接口
- `service/IIntakeService.java` - 摄入服务接口

## ✅ 已完成的工作

### 1. Service 实现类 ✅
- `service/impl/NutritionServiceImpl.java` - 营养服务实现
- `service/impl/IntakeServiceImpl.java` - 摄入服务实现

**实现特点**：
- 使用 MyBatis Plus 的 Mapper 进行数据库操作
- 使用 calotter 的 MapstructUtils 进行对象转换
- 实现了完整的业务逻辑（营养计算、摄入管理等）

### 2. Controller 类 ✅
- `controller/NutritionController.java` - 营养相关API控制器
- `controller/IntakeController.java` - 摄入相关API控制器

**实现特点**：
- 继承 `BaseController`
- 使用 `R` 作为响应对象
- 遵循 calotter 项目的 Controller 风格

## ⚠️ 待完成的工作

### 1. 配置文件
需要创建：
- `src/main/resources/application.yml` - 应用配置（参考其他模块）
- `src/main/resources/application.properties` - 可选配置

### 2. JWT Token 解析
Controller 中的 `extractUserIdFromToken()` 方法需要实现：
- 从 Authorization header 中提取 JWT token
- 解析 token 获取 userId
- 参考 calotter-user 或其他模块的 JWT 实现

### 3. 用户信息获取
NutritionServiceImpl 中需要：
- 通过 Feign 调用 calotter-user 服务获取用户信息
- 或直接查询用户表（如果数据库连接在同一服务中）

### 4. 测试和验证
- 配置数据库连接
- 测试所有 API 端点
- 验证业务逻辑正确性

## 🔧 实现步骤

### 步骤 1：完成 Service 实现类

参考 `backend-java` 中的实现，但需要：
1. 使用 MyBatis Plus 的 Mapper 替代 JPA Repository
2. 使用 `MapstructUtils` 进行 Bo/Vo 转换
3. 保持相同的业务逻辑（营养计算、摄入管理等）

### 步骤 2：完成 Controller

参考 `calotter-user` 模块的 Controller 风格：
```java
@RestController
@RequestMapping("/homepage/nutrition")
public class NutritionController extends BaseController {
    
    @GetMapping("/targets/weekly")
    public R<INutritionService.WeeklyNutritionTargetsResponse> getWeeklyTargets() {
        // 实现逻辑
    }
}
```

### 步骤 3：配置数据库连接

在 `application.yml` 中配置数据库连接（参考其他模块的配置）

### 步骤 4：测试

使用 Postman Collection 测试所有 API 端点

## 📝 注意事项

1. **数据库 Schema**：确保已执行 SQL 脚本创建 `sous_chef_hp` schema 和表
2. **依赖关系**：calotter-homepage 模块依赖 calotter-common 模块
3. **用户服务**：如果需要获取用户信息，可能需要通过 Feign 调用 calotter-user 服务
4. **认证**：API 需要 JWT 认证，参考其他模块的实现

## 🔗 相关文档

- 数据库设计：`database/schema/hp/`
- API 规范：`docs/homepage-api.md`
- 使用说明：`docs/homepage-api-使用说明.md`
- Postman Collection：`docs/Homepage-API.postman_collection.json`

## 📌 下一步

1. ✅ 完成 Service 实现类
2. ✅ 完成 Controller
3. ⏳ 配置 application.yml（参考其他模块）
4. ⏳ 实现 JWT token 解析
5. ⏳ 实现用户信息获取（Feign 或直接查询）
6. ⏳ 测试所有 API 端点

## 🎯 快速开始

### 1. 配置数据库
在 `application.yml` 中配置数据库连接（参考 `calotter-user` 模块）

### 2. 实现 JWT 解析
在 Controller 中实现 `extractUserIdFromToken()` 方法，或使用 calotter-common 中的 JWT 工具类

### 3. 启动服务
```bash
cd calotter-homepage
mvn spring-boot:run
```

### 4. 测试 API
使用 Postman Collection 测试所有端点

---

**最后更新**：2025-12-04
