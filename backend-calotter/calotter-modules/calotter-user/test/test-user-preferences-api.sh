#!/bin/bash

# 用户偏好、禁忌、过敏 API 测试脚本

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
TOKEN=""
USER_ID=""

test_api() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_code=${5:-200}
    local use_token=${6:-true}
    
    echo -e "${YELLOW}测试: $name${NC}"
    
    local headers="Content-Type: application/json"
    if [ "$use_token" = "true" ] && [ -n "$TOKEN" ]; then
        headers="$headers\nAuthorization: Bearer $TOKEN"
    fi
    
    if [ -z "$data" ]; then
        if [ "$use_token" = "true" ] && [ -n "$TOKEN" ]; then
            response=$(curl -s -X $method "$url" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $TOKEN")
        else
            response=$(curl -s -X $method "$url" \
                -H "Content-Type: application/json")
        fi
    else
        if [ "$use_token" = "true" ] && [ -n "$TOKEN" ]; then
            response=$(curl -s -X $method "$url" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $TOKEN" \
                -d "$data")
        else
            response=$(curl -s -X $method "$url" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    fi
    
    code=$(echo $response | grep -o '"code":[0-9]*' | cut -d':' -f2)
    
    if [ "$code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ 通过 (code: $code)${NC}"
        ((PASS_COUNT++))
        echo "响应: $response" | python3 -m json.tool 2>/dev/null || echo "响应: $response"
    else
        echo -e "${RED}✗ 失败 (期望: $expected_code, 实际: $code)${NC}"
        ((FAIL_COUNT++))
        echo "响应: $response"
    fi
    echo ""
}

echo "=========================================="
echo "  用户偏好、禁忌、过敏 API 测试"
echo "=========================================="
echo ""

# 检查后端服务是否运行
echo -e "${BLUE}检查后端服务...${NC}"
if ! curl -s "$BASE_URL/api/user/login" > /dev/null 2>&1; then
    echo -e "${RED}✗ 后端服务未运行，请先启动后端服务${NC}"
    echo "启动命令: cd calotter-start && mvn spring-boot:run"
    exit 1
fi
echo -e "${GREEN}✓ 后端服务运行中${NC}"
echo ""

# 登录获取 token
echo -e "${BLUE}登录获取 token...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/login" \
    -H "Content-Type: application/json" \
    -d '{
        "usernameOrEmail": "testuser",
        "password": "password123"
    }')

LOGIN_CODE=$(echo $LOGIN_RESPONSE | grep -o '"code":[0-9]*' | cut -d':' -f2)

if [ "$LOGIN_CODE" = "200" ]; then
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    USER_ID=$(echo $LOGIN_RESPONSE | grep -o '"userId":[0-9]*' | cut -d':' -f2)
    echo -e "${GREEN}✓ 登录成功${NC}"
    echo "Token: ${TOKEN:0:50}..."
    echo "User ID: $USER_ID"
    echo ""
else
    echo -e "${RED}✗ 登录失败${NC}"
    echo "响应: $LOGIN_RESPONSE"
    echo ""
    echo -e "${YELLOW}尝试使用 userId 参数进行测试（无需 token）...${NC}"
    USER_ID=1
    echo ""
fi

# ==========================================
# 测试用户偏好 API
# ==========================================
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  测试用户偏好 API${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. 获取用户偏好（初始状态）
test_api "获取用户偏好（初始）" \
    "GET" \
    "$BASE_URL/api/user/preferences" \
    "" \
    "200"

# 2. 更新用户偏好
test_api "更新用户偏好" \
    "PUT" \
    "$BASE_URL/api/user/preferences" \
    '{
        "dietaryType": "Vegetarian",
        "cuisineTypes": ["Chinese", "Italian", "Japanese"],
        "spiceLevel": "Medium",
        "cookingTimePreference": "30-60min"
    }' \
    "200"

# 3. 再次获取用户偏好（验证更新）
test_api "获取用户偏好（验证更新）" \
    "GET" \
    "$BASE_URL/api/user/preferences" \
    "" \
    "200"

# 4. 部分更新用户偏好
test_api "部分更新用户偏好" \
    "PUT" \
    "$BASE_URL/api/user/preferences" \
    '{
        "spiceLevel": "Spicy",
        "cookingTimePreference": "15-30min"
    }' \
    "200"

# 5. 测试路径兼容性（/api/ums/user/*）
test_api "测试路径兼容性 (/api/ums/user/preferences)" \
    "GET" \
    "$BASE_URL/api/ums/user/preferences" \
    "" \
    "200"

# 6. 使用 userId 参数测试（如果 token 不可用）
if [ -z "$TOKEN" ] && [ -n "$USER_ID" ]; then
    test_api "使用 userId 参数获取偏好" \
        "GET" \
        "$BASE_URL/api/user/preferences?id=$USER_ID" \
        "" \
        "200" \
        "false"
fi

echo ""

# ==========================================
# 测试用户禁忌 API
# ==========================================
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  测试用户禁忌 API${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. 获取用户禁忌（初始状态）
test_api "获取用户禁忌（初始）" \
    "GET" \
    "$BASE_URL/api/user/taboos" \
    "" \
    "200"

# 2. 更新用户禁忌
test_api "更新用户禁忌" \
    "PUT" \
    "$BASE_URL/api/user/taboos" \
    '{
        "taboos": ["Cilantro", "Carrot", "Lamb", "Onion"]
    }' \
    "200"

# 3. 再次获取用户禁忌（验证更新）
test_api "获取用户禁忌（验证更新）" \
    "GET" \
    "$BASE_URL/api/user/taboos" \
    "" \
    "200"

# 4. 清空用户禁忌
test_api "清空用户禁忌" \
    "PUT" \
    "$BASE_URL/api/user/taboos" \
    '{
        "taboos": []
    }' \
    "200"

# 5. 测试路径兼容性
test_api "测试路径兼容性 (/api/ums/user/taboos)" \
    "GET" \
    "$BASE_URL/api/ums/user/taboos" \
    "" \
    "200"

echo ""

# ==========================================
# 测试用户过敏 API
# ==========================================
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  测试用户过敏 API${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. 获取用户过敏（初始状态）
test_api "获取用户过敏（初始）" \
    "GET" \
    "$BASE_URL/api/user/allergies" \
    "" \
    "200"

# 2. 更新用户过敏
# 注意：过敏原名称必须与标准库中的名称匹配
test_api "更新用户过敏" \
    "PUT" \
    "$BASE_URL/api/user/allergies" \
    '{
        "allergies": ["Peanuts", "Crustaceans", "Lactose"]
    }' \
    "200"

# 3. 再次获取用户过敏（验证更新）
test_api "获取用户过敏（验证更新）" \
    "GET" \
    "$BASE_URL/api/user/allergies" \
    "" \
    "200"

# 4. 更新过敏（添加更多）
test_api "更新用户过敏（添加更多）" \
    "PUT" \
    "$BASE_URL/api/user/allergies" \
    '{
        "allergies": ["Peanuts", "Crustaceans", "Lactose", "Gluten"]
    }' \
    "200"

# 5. 清空用户过敏
test_api "清空用户过敏" \
    "PUT" \
    "$BASE_URL/api/user/allergies" \
    '{
        "allergies": []
    }' \
    "200"

# 6. 测试路径兼容性
test_api "测试路径兼容性 (/api/ums/user/allergies)" \
    "GET" \
    "$BASE_URL/api/ums/user/allergies" \
    "" \
    "200"

echo ""

# ==========================================
# 测试错误处理
# ==========================================
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  测试错误处理${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# 1. 测试无效 token
test_api "测试无效 token" \
    "GET" \
    "$BASE_URL/api/user/preferences" \
    "" \
    "400" \
    "false"

# 2. 测试无效的 JSON
test_api "测试无效的 JSON" \
    "PUT" \
    "$BASE_URL/api/user/preferences" \
    '{invalid json}' \
    "400"

# 3. 测试不存在的用户（如果使用 userId 参数）
if [ -n "$USER_ID" ]; then
    test_api "测试不存在的用户" \
        "GET" \
        "$BASE_URL/api/user/preferences?id=99999" \
        "" \
        "400" \
        "false"
fi

echo ""

# ==========================================
# 测试总结
# ==========================================
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  测试总结${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""
echo -e "${GREEN}通过: $PASS_COUNT${NC}"
echo -e "${RED}失败: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}✗ 部分测试失败${NC}"
    exit 1
fi
