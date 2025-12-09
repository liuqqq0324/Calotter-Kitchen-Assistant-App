# Calotter-User API 测试文档

**基础URL**: `http://localhost:10000`

---

## 一、认证相关 API (`/api/ums`)

### 1. 用户注册
- **方法**: `POST`
- **URL**: `http://localhost:10000/api/ums/auth/register`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "username": "testuser",
    "password": "password123",
    "confirmPassword": "password123",
    "email": "test@example.com"
  }
  ```

### 2. 用户登录
- **方法**: `POST`
- **URL**: `http://localhost:10000/api/ums/auth/login`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "identifier": "testuser",
    "password": "password123"
  }
  ```

### 3. 获取用户信息
- **方法**: `GET`
- **URL**: `http://localhost:10000/api/ums/user?id=1`
- **Query参数**: `id` (必需，用户ID)

### 4. 获取用户偏好
- **方法**: `GET`
- **URL**: `http://localhost:10000/api/ums/user/preferences?id=1`
- **Query参数**: `id` (必需，用户ID)

### 5. 更新用户偏好
- **方法**: `PUT`
- **URL**: `http://localhost:10000/api/ums/user/preferences?id=1`
- **Query参数**: `id` (必需，用户ID)
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "dietaryType": "vegetarian",
    "spiceLevel": "medium",
    "cookingTimePreference": "quick",
    "cuisineTypes": ["Chinese", "Italian"]
  }
  ```

### 6. 获取用户禁忌
- **方法**: `GET`
- **URL**: `http://localhost:10000/api/ums/user/taboos?id=1`
- **Query参数**: `id` (必需，用户ID)

### 7. 更新用户禁忌
- **方法**: `PUT`
- **URL**: `http://localhost:10000/api/ums/user/taboos?id=1`
- **Query参数**: `id` (必需，用户ID)
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "taboos": ["pork", "beef"]
  }
  ```

### 8. 获取用户过敏
- **方法**: `GET`
- **URL**: `http://localhost:10000/api/ums/user/allergies?id=1`
- **Query参数**: `id` (必需，用户ID)

### 9. 更新用户过敏
- **方法**: `PUT`
- **URL**: `http://localhost:10000/api/ums/user/allergies?id=1`
- **Query参数**: `id` (必需，用户ID)
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "allergies": ["peanuts", "shellfish"]
  }
  ```

---

## 二、用户管理 API (`/user/user`)

### 1. 查询用户列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/user/list`
- **Query参数** (可选):
  - `pageNum`: 页码 (默认: 1)
  - `pageSize`: 每页数量 (默认: 10)
  - 其他查询条件根据UserBo字段

### 2. 导出用户列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/user/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选):
  ```json
  {
    "username": "testuser"
  }
  ```

### 3. 获取用户详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/user/{id}`
- **路径参数**: `id` (用户ID)

### 4. 添加用户
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/user`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "username": "newuser",
    "email": "newuser@example.com",
    "passwordHash": "hashedpassword",
    "displayName": "New User",
    "status": 1
  }
  ```

### 5. 修改用户
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/user`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "username": "updateduser",
    "email": "updated@example.com",
    "displayName": "Updated User"
  }
  ```

### 6. 删除用户
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/user/{ids}`
- **路径参数**: `ids` (用户ID，多个用逗号分隔，如: `1,2,3`)

---

## 三、偏好管理 API (`/user/preference`)

### 1. 查询偏好列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/preference/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出偏好列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/preference/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取偏好详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/preference/{id}`
- **路径参数**: `id` (偏好ID)

### 4. 添加偏好
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/preference`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "name": "dietaryType:vegetarian"
  }
  ```

### 5. 修改偏好
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/preference`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "name": "dietaryType:vegan"
  }
  ```

### 6. 删除偏好
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/preference/{ids}`
- **路径参数**: `ids` (偏好ID，多个用逗号分隔)

---

## 四、限制管理 API (`/user/restriction`)

### 1. 查询限制列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/restriction/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出限制列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/restriction/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取限制详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/restriction/{id}`
- **路径参数**: `id` (限制ID)

### 4. 添加限制
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/restriction`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "name": "peanuts"
  }
  ```

### 5. 修改限制
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/restriction`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "name": "tree nuts"
  }
  ```

### 6. 删除限制
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/restriction/{ids}`
- **路径参数**: `ids` (限制ID，多个用逗号分隔)

---

## 五、用户角色管理 API (`/user/userRole`)

### 1. 查询用户角色列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/userRole/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出用户角色列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/userRole/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取用户角色详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/userRole/{id}`
- **路径参数**: `id` (用户角色ID)

### 4. 添加用户角色
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/userRole`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "userId": 1,
    "name": "Owner",
    "accountOwner": true
  }
  ```

### 5. 修改用户角色
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/userRole`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "name": "Updated Role"
  }
  ```

### 6. 删除用户角色
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/userRole/{ids}`
- **路径参数**: `ids` (用户角色ID，多个用逗号分隔)

---

## 六、角色偏好管理 API (`/user/rolePreference`)

### 1. 查询角色偏好列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/rolePreference/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出角色偏好列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/rolePreference/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取角色偏好详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/rolePreference/{id}`
- **路径参数**: `id` (角色偏好ID)

### 4. 添加角色偏好
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/rolePreference`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "roleId": 1,
    "preferenceId": 1,
    "level": 1
  }
  ```

### 5. 修改角色偏好
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/rolePreference`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "level": 2
  }
  ```

### 6. 删除角色偏好
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/rolePreference/{ids}`
- **路径参数**: `ids` (角色偏好ID，多个用逗号分隔)

---

## 七、角色限制管理 API (`/user/roleRestriction`)

### 1. 查询角色限制列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleRestriction/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出角色限制列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleRestriction/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取角色限制详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleRestriction/{id}`
- **路径参数**: `id` (角色限制ID)

### 4. 添加角色限制
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleRestriction`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "roleId": 1,
    "restrictionId": 1,
    "type": 1
  }
  ```
  > 注意: `type` 字段: 1=过敏, 2=禁忌

### 5. 修改角色限制
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/roleRestriction`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "type": 2
  }
  ```

### 6. 删除角色限制
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/roleRestriction/{ids}`
- **路径参数**: `ids` (角色限制ID，多个用逗号分隔)

---

## 八、角色菜系管理 API (`/user/roleCuisine`)

### 1. 查询角色菜系列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleCuisine/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出角色菜系列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleCuisine/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取角色菜系详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleCuisine/{id}`
- **路径参数**: `id` (角色菜系ID)

### 4. 添加角色菜系
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleCuisine`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "roleId": 1,
    "cuisineId": 1
  }
  ```

### 5. 修改角色菜系
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/roleCuisine`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "cuisineId": 2
  }
  ```

### 6. 删除角色菜系
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/roleCuisine/{ids}`
- **路径参数**: `ids` (角色菜系ID，多个用逗号分隔)

---

## 九、角色日志管理 API (`/user/roleLog`)

### 1. 查询角色日志列表
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleLog/list`
- **Query参数** (可选):
  - `pageNum`: 页码
  - `pageSize`: 每页数量

### 2. 导出角色日志列表
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleLog/export`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON, 可选): 查询条件

### 3. 获取角色日志详情
- **方法**: `GET`
- **URL**: `http://localhost:10000/user/roleLog/{id}`
- **路径参数**: `id` (角色日志ID)

### 4. 添加角色日志
- **方法**: `POST`
- **URL**: `http://localhost:10000/user/roleLog`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "roleId": 1,
    "weight": 70.5,
    "height": 175
  }
  ```

### 5. 修改角色日志
- **方法**: `PUT`
- **URL**: `http://localhost:10000/user/roleLog`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (JSON):
  ```json
  {
    "id": 1,
    "weight": 72.0
  }
  ```

### 6. 删除角色日志
- **方法**: `DELETE`
- **URL**: `http://localhost:10000/user/roleLog/{ids}`
- **路径参数**: `ids` (角色日志ID，多个用逗号分隔)

---

## 注意事项

1. **分页参数**: 所有列表查询接口都支持分页，使用 `pageNum` 和 `pageSize` 参数
2. **路径参数**: 删除接口的 `{ids}` 支持多个ID，用逗号分隔，如: `1,2,3`
3. **Content-Type**: 所有POST和PUT请求都需要设置 `Content-Type: application/json`
4. **响应格式**: 
   - 标准CRUD接口返回格式: `{"code": 200, "msg": "操作成功", "data": {...}}`
   - UMS API接口返回格式: 直接返回数据对象
5. **认证**: 目前大部分接口的权限检查被注释掉了，但实际部署时可能需要添加认证token

---

## 快速测试流程建议

1. 首先测试用户注册: `POST /api/ums/auth/register`
2. 然后测试用户登录: `POST /api/ums/auth/login`
3. 获取用户信息: `GET /api/ums/user?id={userId}`
4. 更新用户偏好: `PUT /api/ums/user/preferences?id={userId}`
5. 测试其他CRUD接口
