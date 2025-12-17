# Inventory API 测试文件

本目录包含 Inventory API 模块的所有测试相关文件。

## 📁 文件说明

### 测试脚本
- **`inject-test-data.sh`** - 自动注入测试数据到数据库
- **`test-inventory-api.sh`** - 基础API测试脚本
- **`test-inventory-full.sh`** - 完整CRUD测试脚本（包含所有模块）
- **`test-search-api.sh`** - 标准食材库查找功能测试脚本
- **`test-ingredients-crud.sh`** - Ingredients CRUD API 测试脚本（新增，推荐使用）

### 数据文件
- **`insert-test-data.sql`** - SQL测试数据脚本

### 文档
- **`INVENTORY_API_TEST_RESULTS.md`** - 详细测试结果文档
- **`INVENTORY_API_TEST_SUMMARY.md`** - 测试总结文档
- **`test-search-examples.md`** - 标准食材库查找功能测试用例

## 🚀 使用方法

### 1. 注入测试数据

```bash
# 从test目录运行
cd calotter-modules/calotter-inventory/test
bash inject-test-data.sh

# 或者从项目根目录运行
cd backend-calotter
bash calotter-modules/calotter-inventory/test/inject-test-data.sh
```

### 2. 运行测试

```bash
# 标准食材库查找功能测试
bash test-search-api.sh

# Ingredients CRUD API 测试（推荐，专门测试库存管理）
bash test-ingredients-crud.sh

# 完整测试（包含所有模块：ingredients, spices, utensils, leftovers）
bash test-inventory-full.sh

# 基础测试
bash test-inventory-api.sh
```

## 📋 测试数据

注入的测试数据包括：

- **用户**: testuser / inventory_test (密码: password123)
- **家庭**: Household ID 1 (邀请码: TEST001)
- **标准食材**: 90个 (ID: 1001-1090)
  - 肉类: 20个 (1001-1020)
  - 蔬菜类: 48个 (1003-1006, 1010, 1021-1050)
  - 谷物类: 11个 (1007, 1051-1060)
  - 水果类: 15个 (1061-1075)
  - 豆制品类: 5个 (1076-1080)
  - 其他类: 11个 (1081-1090)
- **标准调料**: 15个 (ID: 3001-3015)
- **标准厨具**: 15个 (ID: 2001-2015)
- **标准过敏原**: 8个 (ID: 1-8)

## ⚠️ 注意事项

1. 运行测试前确保：
   - 数据库容器正在运行 (`docker ps | grep postgres`)
   - 应用正在运行 (`http://localhost:8080`)

2. 脚本路径：
   - 所有脚本已配置为从test目录运行
   - 如果从其他目录运行，请使用绝对路径或相对路径

3. 测试环境：
   - 测试使用Household ID: 1
   - 如需使用其他ID，请修改脚本中的`HOUSEHOLD_ID`变量

## 📊 测试结果

所有API测试均通过，返回200状态码。详细结果请查看：
- `INVENTORY_API_TEST_SUMMARY.md` - 快速总结
- `INVENTORY_API_TEST_RESULTS.md` - 详细结果

## 🔍 查找功能测试

标准食材库查找功能测试用例请参考：
- `test-search-examples.md` - 包含精确匹配和模糊匹配的测试用例

### 快速测试查找功能

```bash
# 精确匹配测试
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=鸡胸肉&fuzzy=false"

# 模糊匹配测试（应该返回多个结果）
curl "http://localhost:8080/api/inventory/standard-ingredients/search?name=白菜&fuzzy=true"
```
