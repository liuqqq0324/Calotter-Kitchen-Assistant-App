#!/bin/bash

# Calotter Cooking API 测试脚本
# 自动创建测试数据并测试 cooking 模块

BASE_URL="http://localhost:8080"

echo "========================================"
echo "  Calotter Cooking API 测试脚本"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试函数
test_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}▶ $description${NC}"
    echo "  $method $endpoint"
    
    if [ "$method" == "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" == "200" ]; then
        echo -e "  ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    else
        echo -e "  ${RED}✗ 失败 (HTTP $http_code)${NC}"
    fi
    echo "  响应: $body"
    echo ""
    
    # 返回响应体供后续使用
    echo "$body"
}

echo "========== 第 1 步：注册用户 =========="
USER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "test@example.com"
    }')
echo "响应: $USER_RESPONSE"

# 提取 userId
USER_ID=$(echo $USER_RESPONSE | grep -o '"userId":[0-9]*' | grep -o '[0-9]*')
if [ -z "$USER_ID" ]; then
    echo -e "${YELLOW}用户可能已存在，尝试登录...${NC}"
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/login" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "password": "password123"
        }')
    echo "登录响应: $LOGIN_RESPONSE"
    USER_ID=$(echo $LOGIN_RESPONSE | grep -o '"userId":[0-9]*' | grep -o '[0-9]*')
fi

if [ -z "$USER_ID" ]; then
    USER_ID=1
    echo -e "${YELLOW}无法获取 userId，使用默认值: $USER_ID${NC}"
else
    echo -e "${GREEN}✓ 用户ID: $USER_ID${NC}"
fi
echo ""

echo "========== 第 2 步：创建家庭 =========="
HOUSEHOLD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/household" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"测试家庭\",
        \"ownerId\": $USER_ID
    }")
echo "响应: $HOUSEHOLD_RESPONSE"

# 提取 householdId
HOUSEHOLD_ID=$(echo $HOUSEHOLD_RESPONSE | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
if [ -z "$HOUSEHOLD_ID" ]; then
    HOUSEHOLD_ID=1
    echo -e "${YELLOW}无法获取 householdId，使用默认值: $HOUSEHOLD_ID${NC}"
else
    echo -e "${GREEN}✓ 家庭ID: $HOUSEHOLD_ID${NC}"
fi
echo ""

echo "========== 第 3 步：测试获取收藏列表 =========="
curl -s "$BASE_URL/api/recipes/favorites?householdId=$HOUSEHOLD_ID" | python3 -m json.tool 2>/dev/null || \
curl -s "$BASE_URL/api/recipes/favorites?householdId=$HOUSEHOLD_ID"
echo ""
echo ""

echo "========== 第 4 步：收藏一个菜谱 =========="
FAVORITE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/recipes/favorite?householdId=$HOUSEHOLD_ID" \
    -H "Content-Type: application/json" \
    -d '{
        "title": "番茄炒蛋",
        "short_description": "经典家常菜，营养美味",
        "servings": 2,
        "cooking_time_min": 15,
        "difficulty": "easy",
        "nutrition_estimate": {
            "calories": 250,
            "protein_g": 12,
            "fat_g": 15,
            "carbs_g": 10
        },
        "ingredients": [
            {"name": "鸡蛋", "amount_value": 3, "amount_unit": "个"},
            {"name": "番茄", "amount_value": 2, "amount_unit": "个"},
            {"name": "盐", "amount_value": 3, "amount_unit": "g"},
            {"name": "葱花", "amount_value": 10, "amount_unit": "g"}
        ],
        "steps": [
            {"step_number": 1, "instruction": "将鸡蛋打入碗中，加少许盐打散", "step_time_min": 2},
            {"step_number": 2, "instruction": "番茄洗净切块", "step_time_min": 3},
            {"step_number": 3, "instruction": "热锅凉油，倒入蛋液炒至凝固盛出", "step_time_min": 3},
            {"step_number": 4, "instruction": "锅中加油，放入番茄翻炒出汁", "step_time_min": 4},
            {"step_number": 5, "instruction": "加入炒好的鸡蛋，翻炒均匀，撒葱花出锅", "step_time_min": 3}
        ]
    }')
echo "响应: $FAVORITE_RESPONSE"
echo ""

echo "========== 第 5 步：再次获取收藏列表（应该有数据了）=========="
curl -s "$BASE_URL/api/recipes/favorites?householdId=$HOUSEHOLD_ID" | python3 -m json.tool 2>/dev/null || \
curl -s "$BASE_URL/api/recipes/favorites?householdId=$HOUSEHOLD_ID"
echo ""
echo ""

echo "========== 第 6 步：开始烹饪 =========="
START_RESPONSE=$(curl -s -X POST "$BASE_URL/api/cooking/start" \
    -H "Content-Type: application/json" \
    -d "{
        \"householdId\": $HOUSEHOLD_ID,
        \"initiatorId\": $USER_ID,
        \"recipe\": {
            \"title\": \"番茄炒蛋\",
            \"short_description\": \"经典家常菜\",
            \"servings\": 2,
            \"cooking_time_min\": 15,
            \"difficulty\": \"easy\",
            \"nutrition_estimate\": {
                \"calories\": 250,
                \"protein_g\": 12,
                \"fat_g\": 15,
                \"carbs_g\": 10
            },
            \"ingredients\": [
                {\"name\": \"鸡蛋\", \"amount_value\": 3, \"amount_unit\": \"个\"},
                {\"name\": \"番茄\", \"amount_value\": 2, \"amount_unit\": \"个\"}
            ],
            \"steps\": [
                {\"step_number\": 1, \"instruction\": \"打散鸡蛋\", \"step_time_min\": 2},
                {\"step_number\": 2, \"instruction\": \"切番茄\", \"step_time_min\": 3},
                {\"step_number\": 3, \"instruction\": \"炒熟\", \"step_time_min\": 10}
            ]
        }
    }")
echo "响应: $START_RESPONSE"

# 提取 sessionId
SESSION_ID=$(echo $START_RESPONSE | grep -o '"sessionId":[0-9]*' | grep -o '[0-9]*')
if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(echo $START_RESPONSE | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
fi
if [ -z "$SESSION_ID" ]; then
    SESSION_ID=1
    echo -e "${YELLOW}无法获取 sessionId，使用默认值: $SESSION_ID${NC}"
else
    echo -e "${GREEN}✓ Session ID: $SESSION_ID${NC}"
fi
echo ""

echo "========== 第 7 步：结束烹饪 =========="
FINISH_RESPONSE=$(curl -s -X POST "$BASE_URL/api/cooking/finish" \
    -H "Content-Type: application/json" \
    -d "{
        \"sessionId\": $SESSION_ID
    }")
echo "响应: $FINISH_RESPONSE"
echo ""

echo "========================================"
echo -e "${GREEN}  测试完成！${NC}"
echo "========================================"
echo ""
echo "测试数据汇总："
echo "  - 用户ID: $USER_ID"
echo "  - 家庭ID: $HOUSEHOLD_ID"  
echo "  - Session ID: $SESSION_ID"
echo ""
echo "你现在可以在 Postman 中使用这些 ID 进行更多测试。"

