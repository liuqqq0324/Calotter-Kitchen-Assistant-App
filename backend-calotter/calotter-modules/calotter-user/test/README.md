# User模块测试文件

本目录包含 User 模块的所有测试相关文件。

## 📁 文件说明

### 测试脚本
- **`test-user-api.sh`** - User API测试脚本（注册、登录）
- **`test-household-api.sh`** - Household API测试脚本（家庭CRUD）
- **`test-all-user-apis.sh`** - 完整测试脚本（运行所有测试）

### 文档
- **`HOUSEHOLD_API_README.md`** - Household API详细文档

## 🚀 使用方法

### 1. 测试User API

```bash
cd calotter-modules/calotter-user/test
bash test-user-api.sh
```

### 2. 测试Household API

```bash
cd calotter-modules/calotter-user/test
bash test-household-api.sh
```

### 3. 运行所有测试

```bash
cd calotter-modules/calotter-user/test
bash test-all-user-apis.sh
```

## 📋 API端点

### User API
- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录

### Household API
- `POST /api/household` - 创建家庭
- `GET /api/household/{id}` - 获取家庭详情
- `GET /api/household/invite/{inviteCode}` - 通过邀请码获取家庭
- `GET /api/household/owner/{ownerId}` - 获取用户的所有家庭
- `PUT /api/household/{id}` - 更新家庭信息
- `DELETE /api/household/{id}?ownerId={ownerId}` - 删除家庭

## ⚠️ 注意事项

1. 运行测试前确保：
   - 应用正在运行 (`http://localhost:8080`)
   - 数据库正在运行

2. 测试数据：
   - User API测试会创建随机用户（避免冲突）
   - Household API测试需要先有用户（ownerId）

3. 测试顺序：
   - 建议先运行User API测试创建用户
   - 然后运行Household API测试创建家庭
   - 最后可以使用创建的householdId测试Inventory API

## 🔗 相关模块

- **Inventory模块测试**: `../calotter-inventory/test/`
- Inventory API需要Household ID，所以建议先完成User和Household的测试

## 📊 测试流程

完整的使用流程：

1. **注册用户** → 获取 `userId`
2. **创建家庭** → 获取 `householdId`
3. **使用householdId测试Inventory API** → 创建食材、调料、厨具、剩菜
