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
| Exact match - Chicken Breast | `name=Chicken Breast` | 返回 ID: 1001 |
| Exact match - Tomato | `name=Tomato` | 返回 ID: 1003 |
| Exact match - Rice | `name=Rice` | 返回 ID: 1007 |
| Exact match - Apple | `name=Apple` | 返回 ID: 1061 |
| Exact match - Milk | `name=Milk` | 返回 ID: 1081 |

### 2. 模糊匹配测试 (fuzzy=true)

这些测试用例应该返回多个结果。

| 测试名称 | 输入 | 预期结果数量 | 预期包含 |
|---------|------|------------|---------|
| Fuzzy match - Cabbage | `name=Cabbage` | 3个 | Cabbage(1021), Napa Cabbage(1022), Baby Bok Choy(1023) |
| Fuzzy match - Radish | `name=Radish` | 2个 | White Radish(1044), Green Radish(1045) |
| Fuzzy match - Bean | `name=Bean` | 多个 | Tofu(1010), Green Bean(1037), Snap Bean(1038), Lima Bean(1039), Pea(1048), Edamame(1049), Dried Tofu(1077), Bean Curd Stick(1078), Tofu Skin(1079), Soybean(1080) |
| Fuzzy match - Chicken | `name=Chicken` | 3个 | Chicken Breast(1001), Chicken Thigh(1011), Chicken Wing(1012) |
| Fuzzy match - Noodle | `name=Noodle` | 2个 | Noodle(1052), Dried Noodle(1053) |
| Fuzzy match - Pepper | `name=Pepper` | 3个 | Green Bell Pepper(1034), Red Bell Pepper(1035), Chili Pepper(1036) |

### 3. 边界情况测试

| 测试名称 | 输入 | 预期结果 |
|---------|------|---------|
| Empty string | `name=` | 返回错误或空列表 |
| Non-existent ingredient | `name=NonExistentIngredient` | 返回空列表 |
| Partial match - single character | `name=C` | 返回所有包含"C"的食材 |
| Case sensitivity test | `name=chicken` | 应该不区分大小写（如果支持） |

## 🔍 API 测试命令

### 精确匹配测试

```bash
# Test exact match - Chicken Breast
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Chicken Breast" \
  --data-urlencode "fuzzy=false"

# Test exact match - Tomato
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Tomato" \
  --data-urlencode "fuzzy=false"
```

### 模糊匹配测试

```bash
# Test fuzzy match - Cabbage (should return 3 results)
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Cabbage" \
  --data-urlencode "fuzzy=true"

# Test fuzzy match - Bean (should return multiple results)
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Bean" \
  --data-urlencode "fuzzy=true"

# Test fuzzy match - Chicken (should return 3 results)
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Chicken" \
  --data-urlencode "fuzzy=true"
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
    "name": "Chicken Breast",
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
      "name": "Cabbage",
      "category": "VEG",
      ...
    },
    {
      "id": 1022,
      "name": "Napa Cabbage",
      "category": "VEG",
      ...
    },
    {
      "id": 1023,
      "name": "Baby Bok Choy",
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
