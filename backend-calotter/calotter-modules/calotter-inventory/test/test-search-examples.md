# 标准食材库查找功能测试用例

本文档提供了测试标准食材库查找功能的测试用例，包括精确匹配和模糊匹配。

## 📋 测试数据概览

当前测试数据包含 **90个标准食材**，涵盖以下分类：
- **肉类 (MEAT)**: 20个 (ID: 1001-1020)
- **蔬菜类 (VEG)**: 48个 (ID: 1003-1006, 1010, 1021-1050)
- **谷物类 (GRAIN)**: 11个 (ID: 1007, 1051-1060)
- **水果类 (FRUIT)**: 15个 (ID: 1061-1075)
- **豆制品类 (BEAN)**: 5个 (ID: 1076-1080)
- **其他类**: 11个 (ID: 1081-1090)

## 🧪 测试用例

### 1. 精确匹配测试 (fuzzy=false)

这些测试用例应该返回单个结果。

| 测试名称 | 输入 | 预期结果 |
|---------|------|---------|
| 精确匹配-鸡胸肉 | `name=鸡胸肉` | 返回 ID: 1001 |
| 精确匹配-西红柿 | `name=西红柿` | 返回 ID: 1003 |
| 精确匹配-大米 | `name=大米` | 返回 ID: 1007 |
| 精确匹配-苹果 | `name=苹果` | 返回 ID: 1061 |
| 精确匹配-牛奶 | `name=牛奶` | 返回 ID: 1081 |

### 2. 模糊匹配测试 (fuzzy=true)

这些测试用例应该返回多个结果。

| 测试名称 | 输入 | 预期结果数量 | 预期包含 |
|---------|------|------------|---------|
| 模糊匹配-白菜 | `name=白菜` | 3个 | 白菜(1021), 大白菜(1022), 小白菜(1023) |
| 模糊匹配-萝卜 | `name=萝卜` | 2个 | 白萝卜(1044), 青萝卜(1045) |
| 模糊匹配-豆 | `name=豆` | 多个 | 豆腐(1010), 豆角(1037), 四季豆(1038), 扁豆(1039), 豌豆(1048), 毛豆(1049), 豆干(1077), 腐竹(1078), 豆皮(1079), 黄豆(1080) |
| 模糊匹配-鸡 | `name=鸡` | 3个 | 鸡胸肉(1001), 鸡腿(1011), 鸡翅(1012) |
| 模糊匹配-面 | `name=面` | 2个 | 面条(1052), 挂面(1053) |
| 模糊匹配-椒 | `name=椒` | 3个 | 青椒(1034), 红椒(1035), 辣椒(1036) |

### 3. 边界情况测试

| 测试名称 | 输入 | 预期结果 |
|---------|------|---------|
| 空字符串 | `name=` | 返回错误或空列表 |
| 不存在的食材 | `name=不存在的食材` | 返回空列表 |
| 部分匹配-单个字符 | `name=肉` | 返回所有包含"肉"的食材 |
| 大小写测试 | `name=JI` | 应该不区分大小写（如果支持） |

## 🔍 API 测试命令

### 精确匹配测试

```bash
# 测试精确匹配 - 鸡胸肉
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=鸡胸肉&fuzzy=false"

# 测试精确匹配 - 西红柿
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=西红柿&fuzzy=false"
```

### 模糊匹配测试

```bash
# 测试模糊匹配 - 白菜（应该返回3个结果）
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=白菜&fuzzy=true"

# 测试模糊匹配 - 豆（应该返回多个结果）
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=豆&fuzzy=true"

# 测试模糊匹配 - 鸡（应该返回3个结果）
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=鸡&fuzzy=true"
```

### 带认证的测试

如果需要认证，添加 Authorization header：

```bash
# 获取 token（先登录）
TOKEN=$(curl -X POST "http://localhost:8080/api/user/login" \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"testuser","password":"password123"}' \
  | jq -r '.data.token')

# 使用 token 测试
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=白菜&fuzzy=true" \
  -H "Authorization: Bearer $TOKEN"
```

## 📊 预期测试结果

### 精确匹配响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1001,
    "name": "鸡胸肉",
    "category": "MEAT",
    "calories": 165,
    "protein": 31.0,
    "fat": 3.6,
    "carb": 0.0,
    "fiber": 0.0,
    "averageGramPerUnit": 100,
    "shelfLifePantry": 1,
    "shelfLifeFridge": 2,
    "shelfLifeFreezer": 180,
    "defaultLocation": "FRIDGE"
  }
}
```

### 模糊匹配响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1021,
      "name": "白菜",
      "category": "VEG",
      ...
    },
    {
      "id": 1022,
      "name": "大白菜",
      "category": "VEG",
      ...
    },
    {
      "id": 1023,
      "name": "小白菜",
      "category": "VEG",
      ...
    }
  ]
}
```

## ✅ 测试检查清单

- [ ] 精确匹配返回单个结果
- [ ] 模糊匹配返回多个结果
- [ ] 不存在的食材返回空结果
- [ ] 响应格式符合 `Result<T>` 标准
- [ ] 所有字段都正确返回
- [ ] 查找不区分大小写（如果实现）
- [ ] 特殊字符处理正确

## 📝 注意事项

1. **数据准备**: 运行测试前，确保已执行 `insert-test-data.sql` 脚本
2. **服务状态**: 确保后端服务正在运行（`http://localhost:8080`）
3. **数据库连接**: 确保数据库连接正常
4. **认证要求**: 某些 API 可能需要认证，请先登录获取 token

## 🔗 相关文档

- [Inventory API 文档](../../docs/backend-architecture-docs/calotter-inventory模块文档.md)
- [测试数据脚本](./insert-test-data.sql)
- [测试脚本](./test-inventory-api.sh)
