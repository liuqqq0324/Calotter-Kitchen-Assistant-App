# 完整测试指南 - User 和 Inventory 模块

---

## 🗑️ 清库和重建数据库流程（可选，用于全新开始）

如果需要完全清理数据库并重新开始，请按照以下步骤操作：

### ⚠️ 警告

**此操作将删除所有数据库数据，包括：**
- 所有用户数据
- 所有家庭数据
- 所有库存数据
- 所有标准食材库数据
- 所有其他业务数据

**请确保已备份重要数据！**

---

### 步骤 0.1: 停止后端服务

**执行目录**: 任意目录（这些是系统命令，可在任何位置执行）

```bash
# 方法 1: 使用 pkill（推荐）
pkill -f "calotter-start"

# 方法 2: 通过端口停止
lsof -ti:8080 | xargs kill -9

# 方法 3: 查找并手动停止
ps aux | grep "calotter-start" | grep -v grep
# 找到 PID 后使用: kill <PID>
```

**验证后端已停止**（任意目录执行）:
```bash
# 检查进程
ps aux | grep "calotter-start" | grep -v grep

# 检查端口（应该没有输出）
lsof -i:8080
```

---

### 步骤 0.2: 使用脚本重建数据库（推荐）

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/rebuild-script-backend-v1_1
./rebuild-database.sh
```

**脚本会自动执行**:
1. ✅ 停止现有服务
2. ✅ 清理数据库数据（删除数据卷）
3. ✅ 启动 PostgreSQL 容器
4. ✅ 删除并重建数据库
5. ✅ 验证数据库状态

**预期输出**:
```
========================================
  Calotter 数据库重建脚本
========================================

[1/5] 停止现有服务...
  ✓ 服务已停止

[2/5] 清理数据库数据...
  ✓ 数据库数据已清理

[3/5] 启动 PostgreSQL 容器...
  ✓ PostgreSQL 已就绪

[4/5] 重建数据库...
  ✓ 数据库 'calotter' 已创建

[5/5] 验证数据库状态...
  ✓ PostgreSQL 容器运行中
  ✓ 数据库连接正常

✅ 数据库重建完成！
```

---

### 步骤 0.3: 手动重建数据库（如果脚本不可用）

#### 0.3.1 停止并删除容器和数据卷

**执行目录**: `/Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter`

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter

# 停止并删除容器和数据卷
docker-compose down -v

# 验证数据卷已删除
docker volume ls | grep postgres
```

#### 0.3.2 启动 PostgreSQL 容器

**执行目录**: `/Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter`

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter

# 启动容器
docker-compose up -d

# 等待容器启动（最多 30 秒）
MAX_WAIT=30
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if docker exec calotter_postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo "✓ PostgreSQL 已就绪"
        break
    fi
    echo -n "."
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done
```

#### 0.3.3 删除并重建数据库

**执行目录**: 任意目录（docker exec 命令可在任何位置执行）

```bash
# 删除现有数据库（如果存在）
docker exec calotter_postgres psql -U postgres -c "DROP DATABASE IF EXISTS calotter;"

# 创建新数据库
docker exec calotter_postgres psql -U postgres -c "CREATE DATABASE calotter;"

# 验证数据库创建
docker exec calotter_postgres psql -U postgres -c "\l" | grep calotter
```

**预期输出**:
```
 calotter  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
```

#### 0.3.4 验证数据库状态

**执行目录**: 任意目录（docker exec 命令可在任何位置执行）

```bash
# 测试数据库连接
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT version();"

# 检查表是否存在（应该为空，因为还没有启动后端）
docker exec calotter_postgres psql -U postgres -d calotter -c "\dt"
```

---

### 步骤 0.4: 启动后端服务（自动创建表结构）

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/rebuild-script-backend-v1_1
./start-backend.sh
```

**重要**: 后端首次启动时，JPA 会自动创建所有表结构。

**等待后端启动完成**（约30-60秒），然后验证表结构：

```bash
# 检查表是否已创建
docker exec calotter_postgres psql -U postgres -d calotter -c "\dt"

# 应该看到类似以下输出：
#  Schema |              Name               | Type  |  Owner
# --------+----------------------------------+-------+----------
#  public | households                      | table | postgres
#  public | household_ingredients            | table | postgres
#  public | ref_standard_ingredients         | table | postgres
#  public | users                            | table | postgres
#  ... (更多表)
```

---

### 步骤 0.5: 注入测试数据

数据库重建完成后，需要重新注入测试数据：

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash inject-test-data.sh
```

**预期输出**:
- ✅ 数据注入成功
- ✅ 用户数据已创建 (testuser, inventory_test)
- ✅ Household 数据已创建 (TEST001, TEST002)
- ✅ 标准食材库: 90个
- ✅ 标准调料库: 15个
- ✅ 标准厨具库: 15个

---

### 清库流程总结

**完整命令序列**（一键执行）:

```bash
# 1. 停止后端
pkill -f "calotter-start"

# 2. 重建数据库
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/rebuild-script-backend-v1_1
./rebuild-database.sh

# 3. 启动后端（自动创建表结构）
./start-backend.sh

# 4. 等待后端启动完成（约30-60秒），然后注入测试数据
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash inject-test-data.sh
```

---

## 📋 测试用户信息

**用户名**: `testuser`  
**密码**: `password123`  
**邮箱**: `testuser@example.com`

**该用户拥有的测试数据**:
- ✅ 2个 Household (TEST001, TEST002)
- ✅ 2个初始库存食材 (Chicken Breast, Tomato)
- ✅ 2个调料 (Salt, Soy Sauce)
- ✅ 2个厨具 (Frying Pan, Wok)
- ✅ 1个剩菜 (Test Leftover - Braised Pork)
- ✅ 90个标准食材库数据
- ✅ 15个标准调料库数据
- ✅ 15个标准厨具库数据
- ✅ 8个标准过敏原数据

---

## 🚀 完整测试流程

### 步骤 1: 启动后端服务

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/rebuild-script-backend-v1_1
./start-backend.sh
```

**等待后端启动完成**（约30-60秒），看到以下信息表示启动成功：
```
✓ Backend started successfully
✓ Backend is running (PID: xxxxx)
```

---

### 步骤 2: 注入测试数据

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash inject-test-data.sh
```

**预期输出**:
- ✅ 数据注入成功
- ✅ 用户数据已创建 (testuser, inventory_test)
- ✅ Household 数据已创建 (TEST001, TEST002)
- ✅ 标准食材库: 90个
- ✅ 标准调料库: 15个
- ✅ 标准厨具库: 15个

---

### 步骤 3: 验证测试数据

```bash
# 验证 testuser 和其 household 关联
docker exec calotter_postgres psql -U postgres -d calotter -c "
SELECT 
    u.id as user_id, 
    u.username, 
    h.id as household_id, 
    h.name as household_name, 
    h.invite_code,
    (SELECT COUNT(*) FROM household_ingredients WHERE household_id = h.id) as ingredient_count
FROM users u
LEFT JOIN households h ON h.owner_id = u.id
WHERE u.username = 'testuser';
"
```

**预期结果**: 应该看到 `testuser` 关联到 2 个 household，且有 2 个库存食材。

---

### 步骤 4: 测试 User API

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-user/test
bash test-all-user-apis.sh
```

**测试内容**:
- ✅ 用户注册
- ✅ 用户登录
- ✅ 获取用户信息
- ✅ 创建 Household
- ✅ 获取 Household 列表
- ✅ 加入 Household（通过邀请码）

---

### 步骤 5: 测试 Inventory API

#### 5.1 测试 Inventory CRUD 操作

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash test-ingredients-crud.sh
```

**测试内容**:
- ✅ GET 获取库存列表
- ✅ POST 添加库存
- ✅ GET 根据ID获取库存
- ✅ PUT 更新库存
- ✅ DELETE 删除库存
- ✅ 错误处理测试

#### 5.2 测试标准食材搜索 API

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash test-search-api.sh
```

**测试内容**:
- ✅ 精确匹配搜索
- ✅ 模糊匹配搜索
- ✅ 边界条件测试

---

## 🔍 手动测试命令（可选）

### 1. 用户登录获取 Token

```bash
# 登录获取 JWT Token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}' | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])")

echo "Token: $TOKEN"
```

### 2. 获取 Household ID

```bash
# 获取 testuser 的 household ID
HOUSEHOLD_ID=$(docker exec calotter_postgres psql -U postgres -d calotter -t -c \
  "SELECT h.id FROM households h JOIN users u ON h.owner_id = u.id WHERE u.username = 'testuser' LIMIT 1;" | xargs)

echo "Household ID: $HOUSEHOLD_ID"
```

### 3. 测试获取库存列表

```bash
# 使用上面获取的 TOKEN 和 HOUSEHOLD_ID
curl -s "http://localhost:8080/api/inventory/ingredients?householdId=$HOUSEHOLD_ID" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

### 4. 测试添加库存

```bash
curl -s -X POST "http://localhost:8080/api/inventory/ingredients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": $HOUSEHOLD_ID,
    \"standardIngredientId\": 1004,
    \"quantity\": 500.0,
    \"unit\": \"g\",
    \"expirationDate\": \"2025-12-25\",
    \"location\": \"FRIDGE\"
  }" | python3 -m json.tool
```

### 5. 测试标准食材搜索

```bash
# 精确匹配
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Chicken Breast" \
  --data-urlencode "fuzzy=false" | python3 -m json.tool

# 模糊匹配
curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
  --data-urlencode "name=Cabbage" \
  --data-urlencode "fuzzy=true" | python3 -m json.tool
```

---

## 📊 验证测试结果

### 检查后端日志

```bash
# 查看后端日志
tail -f /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/logs/backend.log
```

### 检查数据库数据

```bash
# 查看 testuser 的所有库存
docker exec calotter_postgres psql -U postgres -d calotter -c "
SELECT 
    hi.id,
    rsi.name as ingredient_name,
    hi.quantity,
    hi.unit,
    hi.expiration_date,
    hi.location
FROM household_ingredients hi
JOIN households h ON hi.household_id = h.id
JOIN users u ON h.owner_id = u.id
JOIN ref_standard_ingredients rsi ON hi.standard_ingredient_id = rsi.id
WHERE u.username = 'testuser';
"
```

---

## 🛠️ 故障排查

### 后端未启动
```bash
# 检查后端进程
ps aux | grep java | grep calotter

# 检查端口占用
lsof -i :8080
```

### 数据库连接失败
```bash
# 检查 PostgreSQL 容器
docker ps | grep calotter_postgres

# 检查数据库连接
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT 1;"
```

### 测试数据未注入
```bash
# 重新注入数据
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/calotter-modules/calotter-inventory/test
bash inject-test-data.sh
```

---

## ✅ 测试检查清单

- [ ] 后端服务已启动（端口 8080）
- [ ] 测试数据已注入（testuser 存在且有 household）
- [ ] User API 测试通过
- [ ] Inventory CRUD API 测试通过
- [ ] 标准食材搜索 API 测试通过
- [ ] testuser 可以登录并获取 token
- [ ] testuser 可以访问其 household 的库存数据

---

## 📝 注意事项

1. **后端启动时间**: 首次启动可能需要 30-60 秒，请耐心等待
2. **Token 有效期**: JWT Token 有时效性，过期后需要重新登录
3. **Household ID**: 每次注入数据后，household ID 可能不同，建议动态获取
4. **数据清理**: 测试数据会保留在数据库中，如需清理可以手动删除或重新注入

---

**测试完成后，所有功能应该正常工作！** 🎉

---

## 📱 前端端到端测试指南

### 前置条件

在开始前端测试之前，请确保：
- ✅ 后端服务已启动（端口 8080）
- ✅ 测试数据已注入（testuser 用户存在且有库存数据）
- ✅ Flutter 环境已配置完成

---

### 步骤 1: 配置前端 API 地址

#### 1.1 检查 API 配置

编辑 `frontend-app/lib/config/api_config.dart`：

```dart
// Android 模拟器使用
static const String serverIp = "10.0.2.2";

// 真机调试时，请修改为你电脑的局域网 IP
// static const String serverIp = "192.168.1.100"; // 示例：替换为你的实际 IP
```

**重要提示**：
- **Android 模拟器**: 使用 `10.0.2.2`（这是模拟器访问宿主机 localhost 的特殊 IP）
- **iOS 模拟器**: 使用 `localhost` 或 `127.0.0.1`
- **真机调试**: 使用你电脑的局域网 IP（如 `192.168.1.100`）

#### 1.2 获取电脑局域网 IP（真机调试时）

**macOS/Linux**:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows**:
```bash
ipconfig
# 查找 "IPv4 地址" 或 "IPv4 Address"
```

---

### 步骤 2: 启动 Flutter 应用

#### 2.1 进入前端目录

```bash
cd /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/frontend-app
```

#### 2.2 安装依赖（首次运行或依赖更新后）

```bash
flutter pub get
```

#### 2.3 检查可用设备

```bash
flutter devices
```

**预期输出示例**:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
iPhone 15 Pro (mobile)      • 12345678-1234  • ios            • com.apple.CoreSimulator.SimRuntime.iOS-17-0
```

#### 2.4 运行应用

**Android 模拟器**:
```bash
flutter run -d emulator-5554
# 或直接运行（会自动选择设备）
flutter run
```

**iOS 模拟器**:
```bash
flutter run -d ios
```

**真机调试**:
```bash
# 先确保设备已连接并启用开发者模式
flutter devices
flutter run -d <device-id>
```

**Web 浏览器**（用于快速测试）:
```bash
flutter run -d chrome
```

---

### 步骤 3: 测试 User 模块功能

#### 3.1 用户登录测试

**测试步骤**:
1. 打开应用，进入登录页面
2. 输入测试用户信息：
   - **用户名**: `testuser`
   - **密码**: `password123`
3. 点击"登录"按钮

**预期结果**:
- ✅ 登录成功，跳转到主页面
- ✅ 用户信息正确显示
- ✅ Token 已保存到本地存储

**验证方法**:
- 检查应用是否显示用户信息
- 检查是否能访问需要登录的功能（如 Inventory 页面）

#### 3.2 用户注册测试（可选）

**测试步骤**:
1. 在登录页面点击"注册"或"新用户"
2. 填写注册信息：
   - 用户名（使用随机用户名，如 `testuser_new_123`）
   - 邮箱（如 `test_new@example.com`）
   - 密码（如 `password123`）
3. 提交注册

**预期结果**:
- ✅ 注册成功，自动登录
- ✅ 自动创建 Household
- ✅ 跳转到主页面

#### 3.3 错误处理测试

**测试场景**:
1. **错误密码**: 使用 `testuser` + 错误密码 → 应显示错误提示
2. **不存在的用户**: 使用不存在的用户名 → 应显示错误提示
3. **空字段**: 不填写用户名或密码 → 应显示验证错误

---

### 步骤 4: 测试 Inventory 模块功能

#### 4.1 查看库存列表

**测试步骤**:
1. 登录后，导航到 Inventory（库存）页面
2. 查看库存列表

**预期结果**:
- ✅ 显示已存在的库存食材（Chicken Breast 500g, Tomato 1000g）
- ✅ 食材信息正确显示（名称、数量、单位、过期日期、位置）
- ✅ 列表可以滚动

**验证数据**:
- 应该看到 2 个初始库存食材（如果使用 testuser 登录）

#### 4.2 添加库存食材

**测试步骤**:
1. 在 Inventory 页面，点击"添加"或"+"按钮
2. 进入添加食材页面
3. 在食材名称输入框中输入或搜索：
   - 输入 `Chicken` → 应该显示自动完成建议（如 Chicken Breast, Chicken Thigh）
   - 选择 `Chicken Breast`
4. 填写其他信息：
   - 数量: `300`
   - 单位: `g`
   - 过期日期: 选择未来日期（如 7 天后）
   - 位置: 选择 `FRIDGE`
5. 点击"保存"或"确认"

**预期结果**:
- ✅ 食材名称自动完成功能正常工作
- ✅ 可以搜索标准食材库（精确匹配和模糊匹配）
- ✅ 保存成功，返回库存列表
- ✅ 新添加的食材显示在列表中
- ✅ 数量正确显示（如果已存在相同食材，应该合并或显示为新的条目）

#### 4.3 编辑库存食材

**测试步骤**:
1. 在库存列表中，点击某个食材卡片
2. 进入编辑页面
3. 修改信息（如数量、过期日期）
4. 保存更改

**预期结果**:
- ✅ 编辑页面正确加载现有数据
- ✅ 可以修改所有字段
- ✅ 保存后，列表中的数据已更新

#### 4.4 删除库存食材

**测试步骤**:
1. 在库存列表中，找到要删除的食材
2. 长按或点击删除按钮（根据 UI 设计）
3. 确认删除

**预期结果**:
- ✅ 删除确认对话框显示
- ✅ 确认后，食材从列表中移除
- ✅ 数据库中的数据已删除

#### 4.5 标准食材搜索功能测试

**测试场景**:

1. **精确匹配搜索**:
   - 输入 `Chicken Breast` → 应该精确匹配到标准食材库中的 "Chicken Breast"
   - 输入 `Tomato` → 应该精确匹配到 "Tomato"

2. **模糊匹配搜索**:
   - 输入 `Cabbage` → 应该显示多个匹配项（Cabbage, Napa Cabbage, Baby Bok Choy）
   - 输入 `Rice` → 应该显示相关谷物类食材

3. **边界条件测试**:
   - 输入空字符串 → 应该显示提示或默认列表
   - 输入不存在的食材 → 应该显示"未找到"提示
   - 输入特殊字符 → 应该正确处理

**预期结果**:
- ✅ 自动完成列表正确显示匹配的食材
- ✅ 可以选择列表中的食材
- ✅ 搜索响应速度快
- ✅ 错误处理正确

---

### 步骤 5: 完整流程测试

#### 5.1 完整添加库存流程

**测试步骤**:
1. 登录应用（使用 `testuser` / `password123`）
2. 进入 Inventory 页面
3. 点击"添加食材"
4. 搜索并选择标准食材（如 `Carrot`）
5. 填写完整信息并保存
6. 验证新食材出现在列表中
7. 点击新添加的食材，验证详情正确
8. 编辑食材信息（如修改数量）
9. 保存并验证更新
10. 删除该食材，验证删除成功

**预期结果**:
- ✅ 所有步骤都能正常完成
- ✅ 数据正确保存到数据库
- ✅ UI 状态正确更新

#### 5.2 数据同步测试

**测试步骤**:
1. 在应用中添加一个食材
2. 使用 API 测试脚本验证数据已保存：
   ```bash
   # 获取 Token 和 Household ID（参考前面的手动测试命令）
   curl -s "http://localhost:8080/api/inventory/ingredients?householdId=$HOUSEHOLD_ID" \
     -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
   ```
3. 在数据库中验证数据：
   ```bash
   docker exec calotter_postgres psql -U postgres -d calotter -c "
   SELECT hi.id, rsi.name, hi.quantity, hi.unit, hi.expiration_date, hi.location
   FROM household_ingredients hi
   JOIN ref_standard_ingredients rsi ON hi.standard_ingredient_id = rsi.id
   JOIN households h ON hi.household_id = h.id
   JOIN users u ON h.owner_id = u.id
   WHERE u.username = 'testuser'
   ORDER BY hi.create_time DESC
   LIMIT 5;
   "
   ```

**预期结果**:
- ✅ 前端添加的数据能在 API 中查询到
- ✅ 数据库中的数据正确
- ✅ 数据一致性良好

---

## 🐛 前端测试常见问题排查

### 问题 1: 无法连接到后端

**症状**: 应用显示网络错误或无法加载数据

**排查步骤**:
1. 检查后端是否运行：
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. 检查 API 配置：
   - Android 模拟器: 使用 `10.0.2.2`
   - iOS 模拟器: 使用 `localhost` 或 `127.0.0.1`
   - 真机: 使用电脑的局域网 IP

3. 检查网络连接：
   ```bash
   # 在模拟器/真机上测试连接
   # Android 模拟器可以使用 adb
   adb shell ping 10.0.2.2
   ```

**解决方案**:
- 确保后端服务在运行
- 检查 `api_config.dart` 中的 IP 配置
- 真机调试时，确保手机和电脑在同一局域网

### 问题 2: 登录失败

**症状**: 输入正确用户名密码后仍无法登录

**排查步骤**:
1. 检查后端日志：
   ```bash
   tail -f /Users/chase/Documents/Internship/Projects/chef_git/A-team-PersonalSousChef/backend-calotter/logs/backend.log
   ```

2. 使用 API 测试登录：
   ```bash
   curl -X POST http://localhost:8080/api/user/login \
     -H "Content-Type: application/json" \
     -d '{"usernameOrEmail":"testuser","password":"password123"}'
   ```

3. 检查用户是否存在：
   ```bash
   docker exec calotter_postgres psql -U postgres -d calotter -c \
     "SELECT id, username, email FROM users WHERE username = 'testuser';"
   ```

**解决方案**:
- 确保测试数据已注入
- 检查用户名和密码是否正确
- 查看后端错误日志

### 问题 3: 库存列表为空

**症状**: 登录后 Inventory 页面显示为空

**排查步骤**:
1. 检查用户是否有 Household：
   ```bash
   docker exec calotter_postgres psql -U postgres -d calotter -c "
   SELECT u.username, h.id, h.name, h.invite_code
   FROM users u
   LEFT JOIN households h ON h.owner_id = u.id
   WHERE u.username = 'testuser';
   "
   ```

2. 检查库存数据：
   ```bash
   docker exec calotter_postgres psql -U postgres -d calotter -c "
   SELECT COUNT(*) FROM household_ingredients hi
   JOIN households h ON hi.household_id = h.id
   JOIN users u ON h.owner_id = u.id
   WHERE u.username = 'testuser';
   "
   ```

3. 检查前端是否正确获取 householdId：
   - 查看应用日志或调试信息
   - 确认登录后 householdId 已保存到本地存储

**解决方案**:
- 重新注入测试数据
- 检查用户和 household 的关联
- 确认前端正确获取和使用 householdId

### 问题 4: 标准食材搜索不工作

**症状**: 输入食材名称时没有自动完成建议

**排查步骤**:
1. 检查标准食材数据是否存在：
   ```bash
   docker exec calotter_postgres psql -U postgres -d calotter -c \
     "SELECT COUNT(*) FROM ref_standard_ingredients;"
   ```

2. 测试搜索 API：
   ```bash
   curl -s -G "http://localhost:8080/api/inventory/standard-ingredients/search" \
     --data-urlencode "name=Chicken" \
     --data-urlencode "fuzzy=true" | python3 -m json.tool
   ```

3. 检查前端网络请求：
   - 使用 Flutter DevTools 查看网络请求
   - 检查请求 URL 和参数是否正确

**解决方案**:
- 确保标准食材数据已注入（90个食材）
- 检查 API 端点是否正确
- 查看前端网络请求日志

### 问题 5: 热重载不工作

**症状**: 修改代码后应用没有自动更新

**解决方案**:
- 在运行的应用中按 `r` 进行热重载
- 按 `R` 进行热重启（完全重启）
- 如果热重载失败，停止应用并重新运行 `flutter run`

---

## ✅ 前端测试检查清单

- [ ] Flutter 环境配置完成
- [ ] API 地址配置正确（模拟器/真机）
- [ ] 后端服务已启动
- [ ] 测试数据已注入
- [ ] 应用可以正常启动
- [ ] 用户登录功能正常
- [ ] 库存列表可以正常显示
- [ ] 添加库存功能正常
- [ ] 编辑库存功能正常
- [ ] 删除库存功能正常
- [ ] 标准食材搜索功能正常
- [ ] 数据同步正确（前端 ↔ 后端 ↔ 数据库）

---

## 📝 前端测试注意事项

1. **API 地址配置**: 
   - 模拟器和真机使用不同的 IP 地址
   - 提交代码前检查是否使用默认配置

2. **Token 管理**:
   - Token 保存在本地存储（SharedPreferences）
   - Token 过期后需要重新登录

3. **Household ID**:
   - 登录后自动获取并保存 householdId
   - 所有库存操作都需要 householdId

4. **数据同步**:
   - 添加/编辑/删除操作后，列表会自动刷新
   - 如果数据未更新，检查网络请求是否成功

5. **错误处理**:
   - 网络错误应显示友好的错误提示
   - 验证错误应显示具体的字段错误信息

---

**前端测试完成后，整个 User 和 Inventory 模块的端到端测试就完成了！** 🎉
