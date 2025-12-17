#!/bin/bash

# User API 测试脚本

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

test_api() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_code=${5:-200}
    
    echo -e "${YELLOW}测试: $name${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -X $method "$url")
    else
        response=$(curl -s -X $method "$url" -H "Content-Type: application/json" -d "$data")
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
echo "  User API 测试"
echo "=========================================="
echo ""

# 生成随机用户名和邮箱
TIMESTAMP=$(date +%s)
TEST_USERNAME="testuser_${TIMESTAMP}"
TEST_EMAIL="test_${TIMESTAMP}@example.com"

# 1. 注册用户
echo -e "${BLUE}========== 用户注册 ==========${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/user/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"${TEST_USERNAME}\",
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"password123\"
  }")

# 检查注册响应
REGISTER_CODE=$(echo $REGISTER_RESPONSE | grep -o '"code":[0-9]*' | cut -d':' -f2)
USER_ID=$(echo $REGISTER_RESPONSE | grep -o '"userId":[0-9]*' | cut -d':' -f2)
TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 测试注册结果
if [ "$REGISTER_CODE" = "200" ]; then
    echo -e "${YELLOW}测试: 注册用户${NC}"
    echo -e "${GREEN}✓ 通过 (code: $REGISTER_CODE)${NC}"
    echo "响应: $REGISTER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "响应: $REGISTER_RESPONSE"
    ((PASS_COUNT++))
    echo ""
    
    if [ ! -z "$USER_ID" ]; then
        echo -e "${GREEN}注册的用户ID: $USER_ID${NC}"
        if [ ! -z "$TOKEN" ]; then
            echo -e "${GREEN}Token: ${TOKEN:0:50}...${NC}"
        fi
        echo ""
    fi
else
    echo -e "${YELLOW}测试: 注册用户${NC}"
    echo -e "${RED}✗ 失败 (期望: 200, 实际: $REGISTER_CODE)${NC}"
    echo "响应: $REGISTER_RESPONSE"
    ((FAIL_COUNT++))
    echo ""
    
    # 如果注册失败（可能是用户已存在），尝试使用不同的用户名
    echo -e "${YELLOW}⚠ 注册失败，尝试使用新的随机用户名...${NC}"
    TIMESTAMP=$(date +%s)
    TEST_USERNAME="testuser_${TIMESTAMP}_retry"
    TEST_EMAIL="test_${TIMESTAMP}_retry@example.com"
    
    REGISTER_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/user/register" \
      -H "Content-Type: application/json" \
      -d "{
        \"username\": \"${TEST_USERNAME}\",
        \"email\": \"${TEST_EMAIL}\",
        \"password\": \"password123\"
      }")
    
    REGISTER_CODE=$(echo $REGISTER_RESPONSE | grep -o '"code":[0-9]*' | cut -d':' -f2)
    USER_ID=$(echo $REGISTER_RESPONSE | grep -o '"userId":[0-9]*' | cut -d':' -f2)
    TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    
    if [ "$REGISTER_CODE" = "200" ]; then
        echo -e "${YELLOW}测试: 注册用户（重试）${NC}"
        echo -e "${GREEN}✓ 通过 (code: $REGISTER_CODE)${NC}"
        echo "响应: $REGISTER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "响应: $REGISTER_RESPONSE"
        ((PASS_COUNT++))
        echo ""
        
        if [ ! -z "$USER_ID" ]; then
            echo -e "${GREEN}注册的用户ID: $USER_ID${NC}"
            if [ ! -z "$TOKEN" ]; then
                echo -e "${GREEN}Token: ${TOKEN:0:50}...${NC}"
            fi
            echo ""
        fi
    else
        echo -e "${YELLOW}测试: 注册用户（重试）${NC}"
        echo -e "${RED}✗ 失败 (期望: 200, 实际: $REGISTER_CODE)${NC}"
        echo "响应: $REGISTER_RESPONSE"
        ((FAIL_COUNT++))
        echo ""
    fi
fi

# 2. 登录用户（如果注册成功）
if [ ! -z "$USER_ID" ]; then
    echo -e "${BLUE}========== 用户登录 ==========${NC}"
    LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/user/login" \
      -H "Content-Type: application/json" \
      -d "{
        \"usernameOrEmail\": \"${TEST_USERNAME}\",
        \"password\": \"password123\"
      }")
    
    test_api "用户登录（使用用户名）" "POST" "${BASE_URL}/api/user/login" \
      "{\"usernameOrEmail\":\"${TEST_USERNAME}\",\"password\":\"password123\"}"
    
    # 3. 使用邮箱登录
    echo -e "${BLUE}========== 使用邮箱登录 ==========${NC}"
    test_api "用户登录（使用邮箱）" "POST" "${BASE_URL}/api/user/login" \
      "{\"usernameOrEmail\":\"${TEST_EMAIL}\",\"password\":\"password123\"}"
else
    echo -e "${YELLOW}⚠ 无法获取用户ID，跳过登录测试${NC}"
    echo ""
fi

# 4. 错误处理测试
echo -e "${BLUE}========== 错误处理测试 ==========${NC}"

# 测试注册已存在的用户
test_api "注册已存在的用户（应该失败）" "POST" "${BASE_URL}/api/user/register" \
  "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"password123\"}" 500

# 测试登录错误的密码
test_api "登录错误密码（应该失败）" "POST" "${BASE_URL}/api/user/login" \
  "{\"usernameOrEmail\":\"${TEST_USERNAME}\",\"password\":\"wrongpassword\"}" 500

# 测试缺少必填字段
test_api "注册缺少必填字段（应该失败）" "POST" "${BASE_URL}/api/user/register" \
  "{\"username\":\"test\"}" 400

# ==================== 测试总结 ====================
echo "=========================================="
echo -e "${GREEN}测试完成！${NC}"
echo "=========================================="
echo -e "${GREEN}通过: $PASS_COUNT${NC}"
echo -e "${RED}失败: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}❌ 有测试失败${NC}"
    exit 1
fi
