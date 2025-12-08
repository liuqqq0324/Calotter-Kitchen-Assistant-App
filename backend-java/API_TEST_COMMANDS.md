# 后端 API 测试命令

## 前置准备

确保后端正在运行：
```bash
curl http://localhost:8080/hello
```

应该返回：
```json
{"time":"...","message":"Hello World from Java Spring Boot!","status":"Success"}
```

---

## 1. 用户注册

```bash
curl -X POST http://localhost:8080/api/ums/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "confirmPassword": "password123"
  }'
```

**成功响应：**
```json
{"userId":1,"message":"Registered successfully"}
```

---

## 2. 用户登录（获取 Token）

```bash
curl -X POST http://localhost:8080/api/ums/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "testuser",
    "password": "password123"
  }'
```

**成功响应：**
```json
{
  "userId": 1,
  "kitchenId": 1,
  "token": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "expiresIn": 3600
  }
}
```

**保存 Token 到变量（方便后续使用）：**
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/ums/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"testuser","password":"password123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['token']['accessToken'])")

echo "Token: $TOKEN"
```

---

## 3. 获取用户信息（需要 Token）

```bash
# 先设置 TOKEN 变量（使用上面登录获取的 token）
curl http://localhost:8080/api/ums/user \
  -H "Authorization: Bearer $TOKEN"
```

**或者直接使用 token：**
```bash
curl http://localhost:8080/api/ums/user \
  -H "Authorization: Bearer <your-token-here>"
```

**成功响应：**
```json
{
  "userId": 1,
  "userName": "testuser",
  "email": "test@example.com",
  "profile": {
    "age": null,
    "height": null,
    "weight": null
  }
}
```

---

## 4. 更新用户信息（需要 Token）

```bash
curl -X PUT http://localhost:8080/api/ums/user \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "profile": {
      "age": 25,
      "height": 175,
      "weight": 70
    }
  }'
```

---

## 5. 获取用户偏好（需要 Token）

```bash
curl http://localhost:8080/api/ums/user/preferences \
  -H "Authorization: Bearer $TOKEN"
```

**成功响应：**
```json
{
  "userId": 1,
  "preferences": {
    "dietaryType": null,
    "cuisineTypes": [],
    "spiceLevel": null,
    "cookingTimePreference": null
  }
}
```

---

## 6. 更新用户偏好（需要 Token）

```bash
curl -X PUT http://localhost:8080/api/ums/user/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "dietaryType": "vegetarian",
    "cuisineTypes": ["Chinese", "Italian"],
    "spiceLevel": "medium",
    "cookingTimePreference": "30-60 minutes"
  }'
```

---

## 7. 获取用户禁忌（需要 Token）

```bash
curl http://localhost:8080/api/ums/user/taboos \
  -H "Authorization: Bearer $TOKEN"
```

**成功响应：**
```json
{
  "userId": 1,
  "taboos": []
}
```

---

## 8. 更新用户禁忌（需要 Token）

```bash
curl -X PUT http://localhost:8080/api/ums/user/taboos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "taboos": ["pork", "alcohol"]
  }'
```

---

## 9. 获取用户过敏原（需要 Token）

```bash
curl http://localhost:8080/api/ums/user/allergies \
  -H "Authorization: Bearer $TOKEN"
```

**成功响应：**
```json
{
  "userId": 1,
  "allergies": []
}
```

---

## 10. 更新用户过敏原（需要 Token）

```bash
curl -X PUT http://localhost:8080/api/ums/user/allergies \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "allergies": ["peanuts", "shellfish"]
  }'
```

---

## 11. 获取标准食材库（公开端点，无需 Token）

```bash
curl http://localhost:8080/api/StandardLibrary/ingredients
```

---

## 12. 测试端点（公开端点，无需 Token）

```bash
# Hello World
curl http://localhost:8080/hello

# 天气预报示例
curl http://localhost:8080/WeatherForecast
```

---

## 完整测试流程示例

```bash
# 1. 注册用户
curl -X POST http://localhost:8080/api/ums/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"demo123","confirmPassword":"demo123"}'

# 2. 登录获取 Token
TOKEN=$(curl -s -X POST http://localhost:8080/api/ums/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"demo","password":"demo123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['token']['accessToken'])")

# 3. 获取用户信息
curl http://localhost:8080/api/ums/user \
  -H "Authorization: Bearer $TOKEN"

# 4. 更新用户信息
curl -X PUT http://localhost:8080/api/ums/user \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"profile":{"age":30,"height":180,"weight":75}}'

# 5. 更新用户偏好
curl -X PUT http://localhost:8080/api/ums/user/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"dietaryType":"vegan","cuisineTypes":["Japanese","Thai"],"spiceLevel":"high","cookingTimePreference":"15-30 minutes"}'

# 6. 更新用户禁忌
curl -X PUT http://localhost:8080/api/ums/user/taboos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"taboos":["beef","pork"]}'

# 7. 更新用户过敏原
curl -X PUT http://localhost:8080/api/ums/user/allergies \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"allergies":["peanuts","dairy"]}'

# 8. 查看所有信息
echo "=== 用户信息 ==="
curl -s http://localhost:8080/api/ums/user -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo -e "\n=== 用户偏好 ==="
curl -s http://localhost:8080/api/ums/user/preferences -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo -e "\n=== 用户禁忌 ==="
curl -s http://localhost:8080/api/ums/user/taboos -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo -e "\n=== 用户过敏原 ==="
curl -s http://localhost:8080/api/ums/user/allergies -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

---

## 格式化 JSON 输出

如果安装了 `python3`，可以使用以下方式格式化 JSON：

```bash
curl -s http://localhost:8080/api/ums/user \
  -H "Authorization: Bearer $TOKEN" \
  | python3 -m json.tool
```

或者使用 `jq`（如果已安装）：

```bash
curl -s http://localhost:8080/api/ums/user \
  -H "Authorization: Bearer $TOKEN" \
  | jq
```

---

## 错误处理

**401 Unauthorized：** Token 无效或已过期，需要重新登录

**403 Forbidden：** Token 格式错误或缺少权限

**404 Not Found：** 用户不存在或端点路径错误

**400 Bad Request：** 请求参数格式错误

---

## 快速参考

| 端点 | 方法 | 需要 Token | 说明 |
|------|------|-----------|------|
| `/api/ums/auth/register` | POST | ❌ | 用户注册 |
| `/api/ums/auth/login` | POST | ❌ | 用户登录 |
| `/api/ums/user` | GET | ✅ | 获取用户信息 |
| `/api/ums/user` | PUT | ✅ | 更新用户信息 |
| `/api/ums/user/preferences` | GET | ✅ | 获取用户偏好 |
| `/api/ums/user/preferences` | PUT | ✅ | 更新用户偏好 |
| `/api/ums/user/taboos` | GET | ✅ | 获取用户禁忌 |
| `/api/ums/user/taboos` | PUT | ✅ | 更新用户禁忌 |
| `/api/ums/user/allergies` | GET | ✅ | 获取用户过敏原 |
| `/api/ums/user/allergies` | PUT | ✅ | 更新用户过敏原 |
| `/api/StandardLibrary/ingredients` | GET | ❌ | 获取标准食材 |
| `/hello` | GET | ❌ | 测试端点 |
| `/WeatherForecast` | GET | ❌ | 天气预报示例 |
