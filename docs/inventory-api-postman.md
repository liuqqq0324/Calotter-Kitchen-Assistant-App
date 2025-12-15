# Inventory API Postman 测试命令

## 基础配置
- **Base URL**: `http://localhost:8000` (本地) 或 `http://10.0.2.2:8000` (Android 模拟器)
- **Content-Type**: `application/json`

## 1. 获取库存列表 (GET)

```bash
curl -X GET "http://localhost:8000/api/ims/inventory?userId=1" \
  -H "Content-Type: application/json"
```

**Postman 设置**:
- Method: `GET`
- URL: `http://localhost:8000/api/ims/inventory?userId=1`
- Headers: `Content-Type: application/json`

## 2. 添加库存项 (POST)

```bash
curl -X POST "http://localhost:8000/api/ims/inventory?userId=1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Chicken Breast",
    "quantity": 500,
    "unit": "g",
    "expiry_date": "2025-12-20"
  }'
```

**Postman 设置**:
- Method: `POST`
- URL: `http://localhost:8000/api/ims/inventory?userId=1`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "name": "Chicken Breast",
  "quantity": 500,
  "unit": "g",
  "expiry_date": "2025-12-20"
}
```

## 3. 更新库存项 (PUT)

```bash
curl -X PUT "http://localhost:8000/api/ims/inventory?userId=1" \
  -H "Content-Type: application/json" \
  -d '{
    "inventory_id": "1",
    "quantity": 600,
    "unit": "g",
    "expiry_date": "2025-12-25"
  }'
```

**Postman 设置**:
- Method: `PUT`
- URL: `http://localhost:8000/api/ims/inventory?userId=1`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "inventory_id": "1",
  "quantity": 600,
  "unit": "g",
  "expiry_date": "2025-12-25"
}
```

## 4. 删除库存项 (DELETE)

```bash
curl -X DELETE "http://localhost:8000/api/ims/inventory?userId=1" \
  -H "Content-Type: application/json" \
  -d '{
    "inventory_id": "1"
  }'
```

**Postman 设置**:
- Method: `DELETE`
- URL: `http://localhost:8000/api/ims/inventory?userId=1`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "inventory_id": "1"
}
```

## 5. 切换厨具可用性 (POST)

```bash
curl -X POST "http://localhost:8000/api/ims/cookware/toggle?userId=1" \
  -H "Content-Type: application/json" \
  -d '{
    "cookware_id": "stove",
    "name": "Stove"
  }'
```

**Postman 设置**:
- Method: `POST`
- URL: `http://localhost:8000/api/ims/cookware/toggle?userId=1`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "cookware_id": "stove",
  "name": "Stove"
}
```

## 6. 切换调料可用性 (POST)

```bash
curl -X POST "http://localhost:8000/api/ims/seasoning/toggle" \
  -H "Content-Type: application/json" \
  -d '{
    "seasoning_id": "salt",
    "name": "Salt"
  }'
```

**Postman 设置**:
- Method: `POST`
- URL: `http://localhost:8000/api/ims/seasoning/toggle`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "seasoning_id": "salt",
  "name": "Salt"
}
```

## 测试流程建议

1. **先添加几个库存项** (使用 POST)
2. **获取库存列表** (使用 GET) - 验证添加成功
3. **更新某个库存项** (使用 PUT) - 使用返回的 `inventory_id`
4. **再次获取列表** (使用 GET) - 验证更新成功
5. **删除某个库存项** (使用 DELETE) - 使用返回的 `inventory_id`
6. **最后获取列表** (使用 GET) - 验证删除成功

## 注意事项

- `userId` 参数是必需的，需要替换为实际的用户 ID
- `expiry_date` 格式为 `YYYY-MM-DD`
- `quantity` 是 double 类型
- `inventory_id` 在添加后会返回，用于后续的更新和删除操作
