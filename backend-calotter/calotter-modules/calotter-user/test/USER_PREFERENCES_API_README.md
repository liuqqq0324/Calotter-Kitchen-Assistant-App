# 用户偏好、禁忌、过敏 API 测试指南

## 📁 文件位置

用户偏好、禁忌、过敏 API 在 `calotter-user` 模块中实现。

### 相关文件

1. **DTO 层**
   - `controller/dto/PreferencesRequest.java` - 偏好请求DTO
   - `controller/dto/PreferencesResponse.java` - 偏好响应DTO
   - `controller/dto/TaboosRequest.java` - 禁忌请求DTO
   - `controller/dto/TaboosResponse.java` - 禁忌响应DTO
   - `controller/dto/AllergiesRequest.java` - 过敏请求DTO
   - `controller/dto/AllergiesResponse.java` - 过敏响应DTO

2. **Service 层**
   - `service/UserService.java` - 业务逻辑（新增6个方法）

3. **Controller 层**
   - `controller/UserController.java` - REST API（新增6个端点）

4. **Repository 层**
   - `repository/FamilyMemberRepository.java` - 添加了 `findByUserId()` 方法
   - `repository/RefAllergenRepository.java` - 新建，支持按名称查找过敏原

## 🔌 API 端点

### 路径说明

所有 API 支持两种路径：
- `/api/user/*` (标准路径)
- `/api/ums/user/*` (兼容前端现有路径)

### 认证方式

所有 API 都需要 JWT 认证，有两种方式：
1. **通过 Authorization Header**（推荐）：
   ```
   Authorization: Bearer <token>
   ```
2. **通过请求参数**（用于测试）：
   ```
   ?id=<userId>
   ```

---

## 1. 用户偏好 API

### 1.1 获取用户偏好

```http
GET /api/user/preferences
Authorization: Bearer <token>
```

或者：

```http
GET /api/user/preferences?id=<userId>
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "preferences": {
      "dietaryType": "Vegetarian",
      "cuisineTypes": ["Chinese", "Italian"],
      "spiceLevel": "Medium",
      "cookingTimePreference": "30-60min"
    }
  }
}
```

**如果用户没有设置偏好：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "preferences": {}
  }
}
```

### 1.2 更新用户偏好

```http
PUT /api/user/preferences
Authorization: Bearer <token>
Content-Type: application/json

{
  "dietaryType": "Vegetarian",
  "cuisineTypes": ["Chinese", "Italian", "Japanese"],
  "spiceLevel": "Medium",
  "cookingTimePreference": "30-60min"
}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "preferences": {
      "dietaryType": "Vegetarian",
      "cuisineTypes": ["Chinese", "Italian", "Japanese"],
      "spiceLevel": "Medium",
      "cookingTimePreference": "30-60min"
    }
  }
}
```

**字段说明：**
- `dietaryType`: 饮食类型（如 "Vegetarian", "Vegan", "Omnivore"）
- `cuisineTypes`: 菜系列表（如 ["Chinese", "Italian"]）
- `spiceLevel`: 辣度等级（如 "Mild", "Medium", "Spicy"）
- `cookingTimePreference`: 烹饪时间偏好（如 "15-30min", "30-60min", "60min+"）

**注意：** 所有字段都是可选的，只更新提供的字段。

---

## 2. 用户禁忌 API

### 2.1 获取用户禁忌

```http
GET /api/user/taboos
Authorization: Bearer <token>
```

或者：

```http
GET /api/user/taboos?id=<userId>
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "taboos": ["Cilantro", "Carrot", "Lamb"]
  }
}
```

**如果用户没有设置禁忌：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "taboos": []
  }
}
```

### 2.2 更新用户禁忌

```http
PUT /api/user/taboos
Authorization: Bearer <token>
Content-Type: application/json

{
  "taboos": ["Cilantro", "Carrot", "Lamb", "Onion"]
}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "taboos": ["Cilantro", "Carrot", "Lamb", "Onion"]
  }
}
```

**字段说明：**
- `taboos`: 禁忌食材列表（字符串数组）

---

## 3. 用户过敏 API

### 3.1 获取用户过敏

```http
GET /api/user/allergies
Authorization: Bearer <token>
```

或者：

```http
GET /api/user/allergies?id=<userId>
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "allergies": ["Peanuts", "Crustaceans", "Lactose"]
  }
}
```

**如果用户没有设置过敏：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "allergies": []
  }
}
```

### 3.2 更新用户过敏

```http
PUT /api/user/allergies
Authorization: Bearer <token>
Content-Type: application/json

{
  "allergies": ["Peanuts", "Crustaceans", "Lactose", "Gluten"]
}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "allergies": ["Peanuts", "Crustaceans", "Lactose", "Gluten"]
  }
}
```

**字段说明：**
- `allergies`: 过敏原名称列表（字符串数组）

**重要提示：**
- 过敏原名称必须与 `ref_standard_allergens` 表中的名称完全匹配
- 如果提供的过敏原名称在标准库中不存在，该名称将被忽略
- 如果用户没有家庭成员记录，系统会自动创建一个（需要用户有家庭）

---

## 🧪 测试步骤

### 前置条件

1. **启动后端服务**
   ```bash
   cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-start
   mvn spring-boot:run
   ```

2. **准备测试用户**
   - 使用现有用户（如 `testuser`）
   - 或注册新用户获取 token

3. **获取 JWT Token**
   ```bash
   # 登录获取 token
   curl -X POST http://localhost:8080/api/user/login \
     -H "Content-Type: application/json" \
     -d '{
       "usernameOrEmail": "testuser",
       "password": "password123"
     }'
   ```

### 使用测试脚本

我们提供了自动化测试脚本 `test-user-preferences-api.sh`：

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-user/test
bash test-user-preferences-api.sh
```

### 手动测试

#### 测试用户偏好

```bash
# 1. 获取用户偏好（使用 token）
TOKEN="your-jwt-token"
curl -X GET "http://localhost:8080/api/user/preferences" \
  -H "Authorization: Bearer $TOKEN"

# 2. 更新用户偏好
curl -X PUT "http://localhost:8080/api/user/preferences" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dietaryType": "Vegetarian",
    "cuisineTypes": ["Chinese", "Italian"],
    "spiceLevel": "Medium",
    "cookingTimePreference": "30-60min"
  }'

# 3. 再次获取验证更新
curl -X GET "http://localhost:8080/api/user/preferences" \
  -H "Authorization: Bearer $TOKEN"
```

#### 测试用户禁忌

```bash
# 1. 获取用户禁忌
curl -X GET "http://localhost:8080/api/user/taboos" \
  -H "Authorization: Bearer $TOKEN"

# 2. 更新用户禁忌
curl -X PUT "http://localhost:8080/api/user/taboos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "taboos": ["Cilantro", "Carrot", "Lamb"]
  }'

# 3. 再次获取验证更新
curl -X GET "http://localhost:8080/api/user/taboos" \
  -H "Authorization: Bearer $TOKEN"
```

#### 测试用户过敏

```bash
# 1. 获取用户过敏
curl -X GET "http://localhost:8080/api/user/allergies" \
  -H "Authorization: Bearer $TOKEN"

# 2. 更新用户过敏
curl -X PUT "http://localhost:8080/api/user/allergies" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "allergies": ["Peanuts", "Crustaceans"]
  }'

# 3. 再次获取验证更新
curl -X GET "http://localhost:8080/api/user/allergies" \
  -H "Authorization: Bearer $TOKEN"
```

#### 使用 userId 参数测试（无需 token）

```bash
# 使用 userId 参数（用于测试）
USER_ID=1

# 获取偏好
curl -X GET "http://localhost:8080/api/user/preferences?id=$USER_ID"

# 更新偏好
curl -X PUT "http://localhost:8080/api/user/preferences?id=$USER_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "dietaryType": "Vegetarian",
    "cuisineTypes": ["Chinese"]
  }'
```

---

## 📊 数据存储说明

### 用户偏好和禁忌

存储在 `users` 表的 `settings` 字段（JSONB 类型）：

```json
{
  "preferences": {
    "dietaryType": "Vegetarian",
    "cuisineTypes": ["Chinese", "Italian"],
    "spiceLevel": "Medium",
    "cookingTimePreference": "30-60min"
  },
  "taboos": ["Cilantro", "Carrot", "Lamb"]
}
```

### 用户过敏

存储在 `family_members` 表的 `allergies` 关联（多对多关系）：
- 通过 `member_allergies` 中间表关联 `ref_standard_allergens` 表
- 如果用户没有家庭成员记录，更新过敏时会自动创建

---

## ⚠️ 常见问题

### 1. Token 无效或已过期

**错误信息：**
```json
{
  "code": 400,
  "message": "Token 无效或已过期"
}
```

**解决方案：**
- 重新登录获取新的 token
- 检查 Authorization header 格式：`Bearer <token>`

### 2. 用户不存在

**错误信息：**
```json
{
  "code": 400,
  "message": "用户不存在"
}
```

**解决方案：**
- 检查 userId 是否正确
- 确认用户已注册

### 3. 用户没有家庭（更新过敏时）

**错误信息：**
```json
{
  "code": 400,
  "message": "用户没有家庭，无法设置过敏信息"
}
```

**解决方案：**
- 用户需要先有家庭（注册时会自动创建）
- 如果家庭被删除，需要先创建家庭

### 4. 过敏原名称不匹配

**问题：** 更新过敏时，某些过敏原名称在标准库中找不到

**说明：**
- 系统会忽略不存在的过敏原名称
- 只保存标准库中存在的过敏原
- 建议先查询标准库中的过敏原名称

**查询标准过敏原：**
```sql
SELECT id, name, description FROM ref_standard_allergens;
```

---

## 🔍 验证数据

### 查看用户偏好和禁忌（数据库）

```sql
-- 查看用户的 settings
SELECT id, username, settings 
FROM users 
WHERE id = 1;

-- 查看 settings 中的偏好
SELECT id, username, 
       settings->'preferences' as preferences,
       settings->'taboos' as taboos
FROM users 
WHERE id = 1;
```

### 查看用户过敏（数据库）

```sql
-- 查看用户的家庭成员
SELECT fm.id, fm.name, fm.user_id, h.name as household_name
FROM family_members fm
JOIN households h ON fm.household_id = h.id
WHERE fm.user_id = 1;

-- 查看用户的过敏原
SELECT fm.id, fm.name, ra.name as allergen_name
FROM family_members fm
JOIN member_allergies ma ON fm.id = ma.member_id
JOIN ref_standard_allergens ra ON ma.allergen_id = ra.id
WHERE fm.user_id = 1;
```

---

## 📝 测试检查清单

- [ ] 后端服务已启动
- [ ] 测试用户已注册并获取 token
- [ ] 测试获取用户偏好（空数据）
- [ ] 测试更新用户偏好
- [ ] 测试再次获取用户偏好（验证更新）
- [ ] 测试获取用户禁忌（空数据）
- [ ] 测试更新用户禁忌
- [ ] 测试再次获取用户禁忌（验证更新）
- [ ] 测试获取用户过敏（空数据）
- [ ] 测试更新用户过敏
- [ ] 测试再次获取用户过敏（验证更新）
- [ ] 测试路径兼容性（/api/user/* 和 /api/ums/user/*）
- [ ] 测试错误处理（无效 token、用户不存在等）
- [ ] 验证数据库中的数据正确存储

---

## 🚀 下一步

完成测试后，可以：
1. 在前端 UI 中测试这些 API
2. 集成到完整的用户流程中
3. 添加更多的业务逻辑验证
4. 优化错误处理和用户体验

---

**文档生成时间**：2025-12-18  
**API 版本**：v1.0  
**维护人**：开发团队
