# calotter-user 模块文档

> **模块职责**：用户管理、家庭管理、家庭成员管理、健康目标管理  
> **适用对象**：负责用户模块开发的团队成员  
> **最后更新**：2025-12-16

---

## 📋 目录

1. [模块概述](#模块概述)
2. [目录结构](#目录结构)
3. [核心实体](#核心实体)
4. [主要功能](#主要功能)
5. [API接口](#api接口)
6. [代码示例](#代码示例)
7. [与其他模块的交互](#与其他模块的交互)
8. [开发指南](#开发指南)

---

## 模块概述

`calotter-user` 模块负责整个系统的**用户相关功能**，包括：

- 👤 **用户管理**：注册、登录、用户信息管理
- 🏠 **家庭管理**：创建家庭、加入家庭、家庭信息管理
- 👨‍👩‍👧‍👦 **家庭成员管理**：添加家庭成员、管理成员信息
- 🎯 **健康目标管理**：设置和管理家庭成员的健康目标

### 模块位置

```
backend-calotter/
└── calotter-modules/
    └── calotter-user/          # 用户模块
        ├── pom.xml
        └── src/main/java/com/calotter/user/
```

---

## 目录结构

```
calotter-user/
├── pom.xml                                    # Maven配置文件
└── src/main/java/com/calotter/user/
    ├── controller/                           # 控制器层（API接口）
    │   ├── UserController.java              # 用户相关API（注册、登录、登出）
    │   ├── HouseholdController.java         # 家庭相关API
    │   └── dto/                              # 请求/响应DTO
    │       ├── RegisterRequest.java         # 注册请求
    │       ├── LoginRequest.java            # 登录请求
    │       ├── AuthResponse.java            # 认证响应（包含token）
    │       ├── HouseholdRequest.java         # 家庭请求
    │       └── HouseholdResponse.java       # 家庭响应
    ├── service/                              # 业务逻辑层
    │   ├── UserService.java                 # 用户服务（注册、登录逻辑）
    │   ├── HouseholdService.java            # 家庭服务
    │   └── JwtService.java                   # JWT Token服务
    ├── repository/                           # 数据访问层
    │   ├── UserRepository.java              # 用户数据访问
    │   ├── HouseholdRepository.java         # 家庭数据访问
    │   ├── FamilyMemberRepository.java      # 家庭成员数据访问
    │   └── HealthGoalRepository.java        # 健康目标数据访问
    ├── domain/                               # 实体层
    │   └── entity/
    │       ├── User.java                    # 用户实体
    │       ├── Household.java                # 家庭实体
    │       ├── FamilyMember.java            # 家庭成员实体
    │       └── HealthGoal.java              # 健康目标实体
    └── config/                               # 配置类
        └── SecurityConfig.java              # Spring Security配置（密码加密）
```

### 各目录说明

- **controller/**：定义API接口，接收HTTP请求，返回响应
- **service/**：处理业务逻辑，验证数据，调用Repository
- **repository/**：操作数据库，增删改查
- **domain/entity/**：定义数据库表结构
- **config/**：配置类，如安全配置

---

## 核心实体

### 1. User（用户）

**作用**：存储用户的基本信息

**主要字段**：
- `id`：用户ID（主键）
- `username`：用户名（唯一）
- `email`：邮箱（唯一）
- `passwordHash`：加密后的密码
- `role`：角色（ROLE_USER、ROLE_ADMIN）
- `status`：状态（0:未激活, 1:可用, 2:封禁）
- `isOnboarded`：是否完成引导流程
- `settings`：用户设置（JSON格式）

**数据库表**：`users`

**继承**：`BaseEntity`（包含创建时间、更新时间等）

### 2. Household（家庭）

**作用**：代表一个家庭组，所有库存、烹饪记录都属于某个家庭

**主要字段**：
- `id`：家庭ID（主键）
- `name`：家庭名称
- `inviteCode`：邀请码（唯一，用于加入家庭）
- `ownerId`：所有者用户ID

**数据库表**：`households`

**关系**：
- 一个家庭有多个家庭成员（`@OneToMany` → `FamilyMember`）
- 一个家庭有多个库存（通过外键关联，在inventory模块中）

### 3. FamilyMember（家庭成员）

**作用**：存储家庭成员信息，包括偏好、过敏原等

**主要字段**：
- `id`：成员ID（主键）
- `household`：所属家庭（`@ManyToOne`）
- `name`：成员姓名
- `age`：年龄
- `gender`：性别
- `preferences`：偏好设置（JSON格式）
- `allergens`：过敏原列表

**数据库表**：`family_members`

### 4. HealthGoal（健康目标）

**作用**：存储家庭成员的健康目标（如每日卡路里、蛋白质等）

**主要字段**：
- `id`：目标ID（主键）
- `member`：所属家庭成员（`@ManyToOne`）
- `calorieGoal`：每日卡路里目标
- `proteinGoal`：每日蛋白质目标
- `carbGoal`：每日碳水化合物目标
- `fatGoal`：每日脂肪目标

**数据库表**：`health_goals`

---

## 主要功能

### 1. 用户注册

**流程**：
1. 前端发送注册请求（用户名、邮箱、密码）
2. `UserController.register()` 接收请求
3. `UserService.register()` 处理：
   - 验证用户名是否已存在
   - 验证邮箱是否已存在
   - 加密密码
   - 创建用户并保存
   - 自动创建默认家庭
   - 生成JWT Token
4. 返回认证响应（包含token）

**API**：`POST /api/user/register`

### 2. 用户登录

**流程**：
1. 前端发送登录请求（用户名/邮箱、密码）
2. `UserController.login()` 接收请求
3. `UserService.login()` 处理：
   - 查找用户（支持用户名或邮箱）
   - 验证密码
   - 检查用户状态
   - 生成JWT Token
   - 获取用户的家庭信息
4. 返回认证响应（包含token）

**API**：`POST /api/user/login`

### 3. 家庭管理

**功能**：
- 创建家庭：`POST /api/household`
- 更新家庭：`PUT /api/household/{id}`
- 获取家庭详情：`GET /api/household/{id}`
- 通过邀请码加入：`GET /api/household/invite/{inviteCode}`
- 获取用户的所有家庭：`GET /api/household/owner/{ownerId}`
- 删除家庭：`DELETE /api/household/{id}`

**特点**：
- 每个家庭有唯一的邀请码
- 只有所有者可以修改/删除家庭
- 删除家庭会级联删除所有关联数据（通过数据库外键）

---

## API接口

### 用户相关API

#### 1. 用户注册

```http
POST /api/user/register
Content-Type: application/json

{
  "username": "zhangsan",
  "email": "zhangsan@example.com",
  "password": "123456"
}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1,
    "username": "zhangsan",
    "email": "zhangsan@example.com",
    "role": "ROLE_USER",
    "householdId": 1
  }
}
```

#### 2. 用户登录

```http
POST /api/user/login
Content-Type: application/json

{
  "usernameOrEmail": "zhangsan",
  "password": "123456"
}
```

**响应**：同注册响应

#### 3. 用户登出

```http
POST /api/user/logout
Authorization: Bearer {token}
```

**响应**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": "Logged out successfully"
}
```

### 家庭相关API

#### 1. 创建家庭

```http
POST /api/household
Content-Type: application/json

{
  "name": "张三的家",
  "ownerId": 1
}
```

#### 2. 获取家庭详情

```http
GET /api/household/{id}
```

#### 3. 通过邀请码获取家庭

```http
GET /api/household/invite/{inviteCode}
```

---

## 代码示例

### 示例1：用户注册流程

```java
// Controller层
@PostMapping("/register")
public Result<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
    try {
        AuthResponse response = userService.register(request);
        return Result.success(response);
    } catch (IllegalArgumentException e) {
        return Result.error(e.getMessage());
    }
}

// Service层
@Transactional
public AuthResponse register(RegisterRequest request) {
    // 1. 验证用户名是否已存在
    if (userRepository.existsByUsername(request.getUsername())) {
        throw new IllegalArgumentException("用户名已存在");
    }
    
    // 2. 验证邮箱是否已存在
    if (userRepository.existsByEmail(request.getEmail())) {
        throw new IllegalArgumentException("邮箱已被注册");
    }
    
    // 3. 创建用户
    User user = new User();
    user.setUsername(request.getUsername());
    user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
    user.setEmail(request.getEmail());
    user.setRole("ROLE_USER");
    user.setStatus(1);
    
    // 4. 保存用户
    user = userRepository.save(user);
    
    // 5. 自动创建默认家庭
    HouseholdRequest householdRequest = new HouseholdRequest();
    householdRequest.setName(user.getUsername() + "'s Home");
    householdRequest.setOwnerId(user.getId());
    HouseholdResponse household = householdService.createHousehold(householdRequest);
    
    // 6. 生成JWT Token
    String token = jwtService.generateToken(user.getId(), user.getUsername());
    
    // 7. 返回响应
    return AuthResponse.builder()
            .token(token)
            .userId(user.getId())
            .username(user.getUsername())
            .email(user.getEmail())
            .role(user.getRole())
            .householdId(household.getId())
            .build();
}
```

### 示例2：创建家庭

```java
// Service层
@Transactional
public HouseholdResponse createHousehold(HouseholdRequest request) {
    // 1. 验证用户是否存在
    User owner = userRepository.findById(request.getOwnerId())
            .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
    
    // 2. 生成唯一的邀请码
    String inviteCode = generateInviteCode();
    
    // 3. 创建家庭
    Household household = new Household();
    household.setName(request.getName());
    household.setOwnerId(request.getOwnerId());
    household.setInviteCode(inviteCode);
    
    // 4. 保存家庭
    household = householdRepository.save(household);
    
    // 5. 返回响应
    return toHouseholdResponse(household);
}
```

---

## 与其他模块的交互

### 被哪些模块使用？

1. **calotter-inventory（库存模块）**
   - 使用 `Household` 实体：所有库存都属于某个家庭
   - 依赖关系：inventory模块依赖user模块

2. **calotter-cooking（烹饪模块）**
   - 使用 `User` 和 `FamilyMember`：需要用户和家庭成员信息来生成个性化推荐
   - 依赖关系：cooking模块依赖user模块

3. **calotter-health（健康模块）**
   - 使用 `FamilyMember`：记录家庭成员的营养摄入
   - 依赖关系：health模块依赖user模块

### 依赖哪些模块？

- **calotter-common**：使用 `Result`、`BaseEntity` 等基础类

### 交互示例

**场景**：库存模块创建食材时，需要关联家庭

```java
// 在 inventory 模块中
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "household_id", nullable = false)
private Household household;  // 引用 user 模块的 Household
```

---

## 开发指南

### 如何添加新功能？

#### 1. 添加新的实体

1. 在 `domain/entity/` 下创建新的实体类
2. 继承 `BaseEntity`
3. 使用 `@Entity` 和 `@Table` 注解
4. 定义字段和关系

**示例**：
```java
@Entity
@Table(name = "user_profiles")
public class UserProfile extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    // ... 其他字段
}
```

#### 2. 添加新的Repository

1. 在 `repository/` 下创建接口
2. 继承 `JpaRepository<Entity, ID>`
3. 定义自定义查询方法

**示例**：
```java
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    Optional<UserProfile> findByUserId(Long userId);
}
```

#### 3. 添加新的Service

1. 在 `service/` 下创建服务类
2. 使用 `@Service` 注解
3. 注入需要的Repository
4. 实现业务逻辑

**示例**：
```java
@Service
@RequiredArgsConstructor
public class UserProfileService {
    private final UserProfileRepository userProfileRepository;
    
    public UserProfile createProfile(Long userId, UserProfileRequest request) {
        // 业务逻辑
    }
}
```

#### 4. 添加新的Controller

1. 在 `controller/` 下创建控制器类
2. 使用 `@RestController` 和 `@RequestMapping` 注解
3. 注入Service
4. 定义API方法

**示例**：
```java
@RestController
@RequestMapping("/api/user-profile")
@RequiredArgsConstructor
public class UserProfileController {
    private final UserProfileService userProfileService;
    
    @PostMapping
    public Result<UserProfileResponse> createProfile(@RequestBody UserProfileRequest request) {
        UserProfileResponse response = userProfileService.createProfile(request);
        return Result.success(response);
    }
}
```

### 常见问题

#### Q1: 如何修改用户密码？

**A**: 在 `UserService` 中添加方法：
```java
public void changePassword(Long userId, String oldPassword, String newPassword) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
    
    // 验证旧密码
    if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
        throw new IllegalArgumentException("旧密码错误");
    }
    
    // 更新密码
    user.setPasswordHash(passwordEncoder.encode(newPassword));
    userRepository.save(user);
}
```

#### Q2: 如何实现用户权限控制？

**A**: 目前使用JWT Token进行认证。可以在Controller方法上添加权限检查：
```java
@GetMapping("/admin/users")
public Result<List<User>> getAllUsers(@RequestHeader("Authorization") String token) {
    // 验证token
    Long userId = jwtService.getUserIdFromToken(token);
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
    
    // 检查权限
    if (!"ROLE_ADMIN".equals(user.getRole())) {
        throw new IllegalArgumentException("无权限访问");
    }
    
    // 返回数据
    return Result.success(userRepository.findAll());
}
```

#### Q3: 如何修改家庭信息？

**A**: 使用 `HouseholdService.updateHousehold()` 方法，需要验证是否为所有者。

---

## 测试

模块包含测试文件，位于 `src/test/java/com/calotter/user/`：

- `UserServiceTest.java`：用户服务测试
- `HouseholdServiceTest.java`：家庭服务测试
- `JwtServiceTest.java`：JWT服务测试

运行测试：
```bash
cd calotter-modules/calotter-user
mvn test
```

---

**文档结束** - 如有疑问，请查看[总览文档](./后端架构总览.md)或联系团队成员。

