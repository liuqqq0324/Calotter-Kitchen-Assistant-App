# API 配置文档

## 文档信息

**文档版本：** 2.0  
**最后更新：** 2026-01-05  
**适用项目：** Personal Sous Chef Backend

---

## 目录

1. [服务器配置](#服务器配置)
2. [数据库配置](#数据库配置)
3. [JWT 配置](#jwt-配置)
4. [AI API 配置](#ai-api-配置)
5. [日志配置](#日志配置)
6. [前端 API 配置](#前端-api-配置)

---

## 服务器配置

### 端口配置

**配置文件位置：** `calotter-start/src/main/resources/application.yml`

```yaml
server:
  port: 8080  # 默认端口
```

**说明：**
- 开发环境默认使用 8080 端口
- 生产环境可根据需要修改端口
- 修改后需要重启应用

---

## 数据库配置

### PostgreSQL 配置

**配置文件位置：** `calotter-start/src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/calotter
    username: postgres
    password: 123  # 请修改为实际密码
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update  # 开发环境：自动更新表结构
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        use_sql_comments: true
```

### 配置说明

#### `ddl-auto` 选项

- **`update`**（开发环境推荐）：自动更新表结构，新增字段会自动添加
- **`validate`**（生产环境推荐）：只验证表结构，不修改
- **`create`**：每次启动删除并重新创建表（会丢失数据）
- **`create-drop`**：启动时创建，关闭时删除
- **`none`**：不做任何操作

#### 生产环境建议

1. 使用 `ddl-auto: validate`
2. 使用 Flyway 或 Liquibase 进行数据库版本管理
3. 配置连接池参数：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

### 数据库初始化

#### 初始化标准库数据

```bash
# 使用 Docker
docker exec -i calotter_postgres psql -U postgres -d calotter < init-standard-libraries.sql

# 或直接连接数据库执行
psql -U postgres -d calotter -f init-standard-libraries.sql
```

**标准库包含：**
- 标准食材库（83项）
- 标准调料库（30项）
- 标准厨具库（25项）
- 标准过敏原库（10项）

---

## JWT 配置

### 配置项

**配置文件位置：** `calotter-start/src/main/resources/application.yml`

```yaml
jwt:
  key: YourSuperSecretKeyForJWTTokenGenerationThatShouldBeAtLeast32CharactersLong!
  issuer: CalotterBackend
  audience: CalotterFrontend
  expiration: 3000  # Token过期时间（秒），默认50分钟
```

### 配置说明

#### `key`
- **作用**：JWT Token 签名密钥
- **要求**：至少32个字符
- **安全建议**：
  - 生产环境使用强随机密钥
  - 不要将密钥提交到代码仓库
  - 使用环境变量或密钥管理服务

#### `issuer`
- **作用**：Token 发行者标识
- **默认值**：CalotterBackend

#### `audience`
- **作用**：Token 受众标识
- **默认值**：CalotterFrontend

#### `expiration`
- **作用**：Token 过期时间（秒）
- **默认值**：3000（50分钟）
- **建议值**：
  - 开发环境：3000-3600（50-60分钟）
  - 生产环境：1800-3600（30-60分钟）

### 环境变量配置（推荐）

**生产环境建议使用环境变量：**

```yaml
jwt:
  key: ${JWT_SECRET_KEY:YourSuperSecretKeyForJWTTokenGenerationThatShouldBeAtLeast32CharactersLong!}
  expiration: ${JWT_EXPIRATION:3000}
```

**设置环境变量：**

**Windows PowerShell:**
```powershell
$env:JWT_SECRET_KEY = "your-secret-key-here"
$env:JWT_EXPIRATION = "3600"
```

**macOS/Linux:**
```bash
export JWT_SECRET_KEY="your-secret-key-here"
export JWT_EXPIRATION="3600"
```

---

## AI API 配置

详见 [AI_API_CONFIG.md](./AI_API_CONFIG.md)

### 快速参考

**配置位置：** `calotter-start/src/main/resources/application.yml`

```yaml
ai:
  api:
    mode: mock  # mock / gemini / groq
    gemini:
      api-key: ${GEMINI_API_KEY:}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
    groq:
      api-key: ${GROQ_API_KEY:}
      url: https://api.groq.com/openai/v1/chat/completions
      model: llama-3.3-70b-versatile
  nutrition:
    provider: gemini
    gemini:
      api-key: ${GEMINI_API_KEY:}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
```

---

## 日志配置

### 默认配置

**配置文件位置：** `calotter-start/src/main/resources/application.yml`

```yaml
logging:
  level:
    root: INFO
    com.calotter: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

### 日志级别说明

- **`INFO`**：一般信息日志
- **`DEBUG`**：调试信息（开发环境）
- **`TRACE`**：详细跟踪信息（开发环境）

### 生产环境建议

```yaml
logging:
  level:
    root: INFO
    com.calotter: INFO
    org.hibernate.SQL: WARN  # 生产环境关闭 SQL 日志
    org.hibernate.type.descriptor.sql.BasicBinder: WARN
  file:
    name: logs/calotter.log
    max-size: 10MB
    max-history: 30
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

---

## 前端 API 配置

### Flutter 前端配置

**配置文件位置：** `frontend-app/lib/config/api_config.dart`

```dart
class ApiConfig {
  // 服务器IP配置
  static const String serverIp = "172.24.16.227";  // 真机调试时使用此 IP
  static const String simulatorIp = "10.0.2.2";     // Android 模拟器
  
  // 服务端口（后端单体应用，使用 8080）
  static const String userPort = "8080";
  static const String cookingPort = "8080";
  static const String inventoryPort = "8080";
  static const String healthPort = "8080";
  
  // Base URL
  static String get userBaseUrl => "http://$serverIp:$userPort";
  static String get cookingBaseUrl => "http://$serverIp:$cookingPort";
  static String get inventoryBaseUrl => "http://$serverIp:$inventoryPort";
  static String get healthBaseUrl => "http://$serverIp:$healthPort";
}
```

### 配置说明

#### IP 地址配置

- **真机调试**：使用实际服务器的 IP 地址（如 `172.24.16.227`）
- **Android 模拟器**：使用 `10.0.2.2`（模拟器专用地址，指向宿主机）
- **iOS 模拟器**：使用 `localhost` 或 `127.0.0.1`

#### 端口配置

- 所有服务使用同一个端口 `8080`（后端单体应用）
- 如需修改，需要同时修改后端 `server.port` 和前端配置

### 网络环境配置

#### 开发环境
- 后端运行在：`http://localhost:8080`
- 前端连接：`http://10.0.2.2:8080`（Android 模拟器）
- 或：`http://localhost:8080`（iOS 模拟器）

#### 生产环境
- 后端运行在：`http://your-server-ip:8080`
- 前端连接：`http://your-server-ip:8080`
- 建议使用 HTTPS 和域名

---

## 配置检查清单

### 开发环境

- [ ] 数据库连接配置正确
- [ ] 数据库已创建并初始化标准库
- [ ] JWT 密钥已配置（开发环境可使用默认值）
- [ ] 日志级别设置为 DEBUG（便于调试）
- [ ] AI API 模式设置为 `mock`（开发测试）

### 生产环境

- [ ] 数据库连接配置正确（使用强密码）
- [ ] JWT 密钥使用强随机密钥（通过环境变量配置）
- [ ] Token 过期时间合理（30-60分钟）
- [ ] 日志级别设置为 INFO
- [ ] 日志文件配置正确（文件路径、轮转策略）
- [ ] AI API Key 通过环境变量配置（不写在配置文件中）
- [ ] `ddl-auto` 设置为 `validate`（或使用 Flyway）
- [ ] 数据库连接池参数已优化

---

## 常见问题

### 1. 数据库连接失败

**错误信息：** `Connection refused` 或 `FATAL: password authentication failed`

**解决方案：**
- 检查 PostgreSQL 服务是否启动
- 检查数据库连接 URL、用户名、密码是否正确
- 检查数据库是否已创建
- 检查防火墙设置

### 2. JWT Token 验证失败

**错误信息：** `Token 无效或已过期`

**解决方案：**
- 检查 JWT 密钥配置是否一致
- 检查 Token 是否过期
- 检查请求头格式：`Authorization: Bearer {token}`

### 3. AI API 调用失败

**错误信息：** `API key is invalid` 或 `Rate limit exceeded`

**解决方案：**
- 检查 API Key 是否正确配置
- 检查 API Key 是否有效
- 检查 API 配额是否用完
- 开发环境建议使用 `mock` 模式

### 4. 端口被占用

**错误信息：** `Port 8080 is already in use`

**解决方案：**
- 修改 `server.port` 配置为其他端口（如 8081）
- 或停止占用 8080 端口的其他应用

---

## 配置示例

### 完整开发环境配置

```yaml
spring:
  application:
    name: calotter
  
  datasource:
    url: jdbc:postgresql://localhost:5432/calotter
    username: postgres
    password: 123
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        use_sql_comments: true

server:
  port: 8080

logging:
  level:
    root: INFO
    com.calotter: DEBUG
    org.hibernate.SQL: DEBUG

jwt:
  key: YourSuperSecretKeyForJWTTokenGenerationThatShouldBeAtLeast32CharactersLong!
  issuer: CalotterBackend
  audience: CalotterFrontend
  expiration: 3000

ai:
  api:
    mode: mock
    gemini:
      api-key: ${GEMINI_API_KEY:}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
    groq:
      api-key: ${GROQ_API_KEY:}
      url: https://api.groq.com/openai/v1/chat/completions
      model: llama-3.3-70b-versatile
  nutrition:
    provider: gemini
    gemini:
      api-key: ${GEMINI_API_KEY:}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
```

### 生产环境配置建议

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:calotter}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

server:
  port: ${SERVER_PORT:8080}

logging:
  level:
    root: INFO
    com.calotter: INFO
  file:
    name: logs/calotter.log
    max-size: 10MB
    max-history: 30

jwt:
  key: ${JWT_SECRET_KEY}
  issuer: CalotterBackend
  audience: CalotterFrontend
  expiration: ${JWT_EXPIRATION:3600}

ai:
  api:
    mode: ${AI_API_MODE:gemini}
    gemini:
      api-key: ${GEMINI_API_KEY}
      base-url: https://generativelanguage.googleapis.com
      model: gemini-2.5-pro
```

---

**文档维护：** 配置变更时请及时更新本文档。

