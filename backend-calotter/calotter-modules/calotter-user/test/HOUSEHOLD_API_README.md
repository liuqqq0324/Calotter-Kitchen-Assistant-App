# Household API 文档

## 📁 文件位置

Household API 在 `calotter-user` 模块中实现，因为 Household 实体属于用户模块。

### 创建的文件

1. **DTO 层**
   - `controller/dto/HouseholdRequest.java` - 请求DTO
   - `controller/dto/HouseholdResponse.java` - 响应DTO

2. **Service 层**
   - `service/HouseholdService.java` - 业务逻辑

3. **Controller 层**
   - `controller/HouseholdController.java` - REST API

## 🔌 API 端点

### 1. 创建家庭
```http
POST /api/household
Content-Type: application/json

{
  "name": "我的家庭",
  "ownerId": 1
}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "我的家庭",
    "inviteCode": "ABC123",
    "ownerId": 1
  }
}
```

### 2. 获取家庭详情
```http
GET /api/household/{id}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "我的家庭",
    "inviteCode": "ABC123",
    "ownerId": 1
  }
}
```

### 3. 通过邀请码获取家庭
```http
GET /api/household/invite/{inviteCode}
```

**示例：**
```bash
GET /api/household/invite/ABC123
```

### 4. 获取用户的所有家庭
```http
GET /api/household/owner/{ownerId}
```

**响应：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "我的家庭",
      "inviteCode": "ABC123",
      "ownerId": 1
    }
  ]
}
```

### 5. 更新家庭信息
```http
PUT /api/household/{id}
Content-Type: application/json

{
  "name": "更新后的家庭名称",
  "ownerId": 1
}
```

**注意：** 只有所有者可以更新家庭信息

### 6. 删除家庭
```http
DELETE /api/household/{id}?ownerId={ownerId}
```

**示例：**
```bash
DELETE /api/household/1?ownerId=1
```

**注意：** 只有所有者可以删除家庭

## 🧪 测试

### 使用测试脚本
```bash
cd calotter-modules/calotter-inventory/test
bash test-household-api.sh
```

### 手动测试

```bash
# 1. 创建家庭
curl -X POST http://localhost:8080/api/household \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试家庭",
    "ownerId": 1
  }'

# 2. 获取家庭详情（假设ID为1）
curl http://localhost:8080/api/household/1

# 3. 通过邀请码获取家庭
curl http://localhost:8080/api/household/invite/ABC123

# 4. 获取用户的所有家庭
curl http://localhost:8080/api/household/owner/1

# 5. 更新家庭
curl -X PUT http://localhost:8080/api/household/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新后的名称",
    "ownerId": 1
  }'

# 6. 删除家庭
curl -X DELETE "http://localhost:8080/api/household/1?ownerId=1"
```

## 🔐 权限控制

- **创建家庭**：需要有效的 `ownerId`
- **更新家庭**：只有所有者可以更新
- **删除家庭**：只有所有者可以删除
- **查看家庭**：任何人都可以查看（通过ID或邀请码）

## ✨ 特性

1. **自动生成邀请码**：创建家庭时自动生成6位唯一邀请码
2. **权限验证**：更新和删除操作会验证所有者身份
3. **数据验证**：使用 `@Valid` 注解进行请求数据验证
4. **错误处理**：统一的错误响应格式

## 📝 注意事项

1. **邀请码唯一性**：系统会自动确保邀请码的唯一性
2. **级联删除**：删除家庭时，相关的库存数据（通过外键约束）会自动删除
3. **所有者验证**：更新和删除操作必须提供正确的 `ownerId`

## 🔗 与 Inventory API 的关系

Household API 是 Inventory API 的前置条件：
- 创建库存数据前，需要先创建 Household
- Inventory API 的 `householdId` 参数必须引用已存在的 Household

**使用流程：**
1. 注册用户 → 获取 `userId`
2. 创建家庭 → 获取 `householdId`
3. 使用 `householdId` 创建库存数据（食材、调料、厨具、剩菜）
