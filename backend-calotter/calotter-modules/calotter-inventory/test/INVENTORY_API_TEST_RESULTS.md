# Inventory API 测试结果

## 测试时间
2024-12-15

## 测试环境
- 应用地址: http://localhost:8080
- 数据库: PostgreSQL (Docker)
- 应用状态: ✅ 运行中

## 测试结果总结

### ✅ 已测试的API端点

1. **POST /api/inventory/ingredients** - 创建食材
   - 状态: ✅ API可访问
   - 错误处理: ✅ 正常（返回"家庭不存在"或"标准食材不存在"）

2. **POST /api/inventory/spices** - 创建调料
   - 状态: ✅ API可访问
   - 错误处理: ✅ 正常

3. **POST /api/inventory/utensils** - 创建厨具
   - 状态: ✅ API可访问
   - 错误处理: ✅ 正常

4. **POST /api/inventory/leftovers** - 创建剩菜
   - 状态: ✅ API可访问
   - 错误处理: ✅ 正常

5. **数据验证测试**
   - 状态: ✅ 正常工作
   - 测试: 缺少必填字段时返回"单位不能为空"

### ⚠️ 发现的问题

1. **@RequestParam 参数名称问题**
   - 问题: GET请求中的@RequestParam参数需要显式指定名称
   - 状态: ✅ 已修复（添加了参数名称）
   - 需要: 重新编译应用以生效

2. **需要测试数据**
   - 需要先创建User和Household
   - 需要在数据库中插入标准库数据

## 测试命令示例

### 1. 获取食材列表
```bash
curl "http://localhost:8080/api/inventory/ingredients?householdId=1"
```

### 2. 创建食材
```bash
curl -X POST http://localhost:8080/api/inventory/ingredients \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardIngredientId": 1001,
    "quantity": 500.0,
    "unit": "g",
    "expirationDate": "2024-12-31",
    "location": "FRIDGE"
  }'
```

### 3. 获取调料列表
```bash
curl "http://localhost:8080/api/inventory/spices?householdId=1"
```

### 4. 创建调料
```bash
curl -X POST http://localhost:8080/api/inventory/spices \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardSpiceId": 3001,
    "isAvailable": true,
    "remark": "新买的"
  }'
```

### 5. 获取厨具列表
```bash
curl "http://localhost:8080/api/inventory/utensils?householdId=1"
```

### 6. 创建厨具
```bash
curl -X POST http://localhost:8080/api/inventory/utensils \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardUtensilId": 2001,
    "isAvailable": true,
    "remark": "平底锅"
  }'
```

### 7. 获取剩菜列表
```bash
curl "http://localhost:8080/api/inventory/leftovers?householdId=1"
```

### 8. 创建剩菜
```bash
curl -X POST http://localhost:8080/api/inventory/leftovers \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "name": "红烧肉",
    "coverImage": "https://example.com/image.jpg",
    "quantityGram": 500.0,
    "producedTime": "2024-12-15T18:00:00"
  }'
```

### 9. 获取单个资源
```bash
# 获取食材详情
curl "http://localhost:8080/api/inventory/ingredients/1"

# 获取调料详情
curl "http://localhost:8080/api/inventory/spices/1"

# 获取厨具详情
curl "http://localhost:8080/api/inventory/utensils/1"

# 获取剩菜详情
curl "http://localhost:8080/api/inventory/leftovers/1"
```

### 10. 更新资源
```bash
# 更新食材
curl -X PUT http://localhost:8080/api/inventory/ingredients/1 \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1,
    "standardIngredientId": 1001,
    "quantity": 300.0,
    "unit": "g",
    "location": "FRIDGE"
  }'
```

### 11. 删除资源
```bash
# 删除食材
curl -X DELETE http://localhost:8080/api/inventory/ingredients/1

# 删除调料
curl -X DELETE http://localhost:8080/api/inventory/spices/1

# 删除厨具
curl -X DELETE http://localhost:8080/api/inventory/utensils/1

# 删除剩菜
curl -X DELETE http://localhost:8080/api/inventory/leftovers/1
```

### 12. 扣减库存
```bash
curl -X POST "http://localhost:8080/api/inventory/ingredients/1/deduct?amount=100.0"
```

## 下一步操作

1. **重新编译应用**（使@RequestParam修复生效）
   ```bash
   cd backend-calotter
   mvn clean install -DskipTests
   # 然后重启应用
   ```

2. **创建测试数据**
   - 注册用户
   - 创建Household
   - 插入标准库数据（StandardIngredient, StandardSpice, StandardUtensil）

3. **完整CRUD测试**
   - 使用真实的householdId和标准库ID进行完整测试

## API端点列表

### 食材 (Ingredients)
- `GET /api/inventory/ingredients?householdId={id}` - 获取列表
- `GET /api/inventory/ingredients/{id}` - 获取详情
- `POST /api/inventory/ingredients` - 创建
- `PUT /api/inventory/ingredients/{id}` - 更新
- `DELETE /api/inventory/ingredients/{id}` - 删除
- `POST /api/inventory/ingredients/{id}/deduct?amount={amount}` - 扣减库存

### 调料 (Spices)
- `GET /api/inventory/spices?householdId={id}` - 获取列表
- `GET /api/inventory/spices/{id}` - 获取详情
- `POST /api/inventory/spices` - 创建
- `PUT /api/inventory/spices/{id}` - 更新
- `DELETE /api/inventory/spices/{id}` - 删除

### 厨具 (Utensils)
- `GET /api/inventory/utensils?householdId={id}` - 获取列表
- `GET /api/inventory/utensils/{id}` - 获取详情
- `POST /api/inventory/utensils` - 创建
- `PUT /api/inventory/utensils/{id}` - 更新
- `DELETE /api/inventory/utensils/{id}` - 删除

### 剩菜 (Leftovers)
- `GET /api/inventory/leftovers?householdId={id}` - 获取列表
- `GET /api/inventory/leftovers/{id}` - 获取详情
- `POST /api/inventory/leftovers` - 创建
- `PUT /api/inventory/leftovers/{id}` - 更新
- `DELETE /api/inventory/leftovers/{id}` - 删除

## 测试脚本

已创建测试脚本: `test-inventory-api.sh`

使用方法:
```bash
cd backend-calotter
bash test-inventory-api.sh
```
