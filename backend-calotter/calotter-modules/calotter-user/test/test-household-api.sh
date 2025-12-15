#!/bin/bash

# Household API 测试脚本

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
echo "  Household API 测试"
echo "=========================================="
echo ""

# 1. 创建家庭
echo -e "${BLUE}========== 创建家庭 ==========${NC}"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/household" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试家庭",
    "ownerId": 1
  }')

test_api "创建家庭" "POST" "${BASE_URL}/api/household" \
  '{"name":"测试家庭","ownerId":1}'

HOUSEHOLD_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
INVITE_CODE=$(echo $CREATE_RESPONSE | grep -o '"inviteCode":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$HOUSEHOLD_ID" ]; then
    echo -e "${GREEN}创建的家庭ID: $HOUSEHOLD_ID${NC}"
    echo -e "${GREEN}邀请码: $INVITE_CODE${NC}"
    echo ""
    
    # 2. 获取家庭详情
    echo -e "${BLUE}========== 获取家庭详情 ==========${NC}"
    test_api "获取家庭详情" "GET" "${BASE_URL}/api/household/${HOUSEHOLD_ID}"
    
    # 3. 通过邀请码获取家庭
    if [ ! -z "$INVITE_CODE" ]; then
        echo -e "${BLUE}========== 通过邀请码获取家庭 ==========${NC}"
        test_api "通过邀请码获取家庭" "GET" "${BASE_URL}/api/household/invite/${INVITE_CODE}"
    fi
    
    # 4. 获取用户的所有家庭
    echo -e "${BLUE}========== 获取用户的所有家庭 ==========${NC}"
    test_api "获取用户的所有家庭" "GET" "${BASE_URL}/api/household/owner/1"
    
    # 5. 更新家庭
    echo -e "${BLUE}========== 更新家庭 ==========${NC}"
    test_api "更新家庭" "PUT" "${BASE_URL}/api/household/${HOUSEHOLD_ID}" \
      "{\"name\":\"测试家庭（已更新）\",\"ownerId\":1}"
    
    # 6. 删除家庭
    echo -e "${BLUE}========== 删除家庭 ==========${NC}"
    test_api "删除家庭" "DELETE" "${BASE_URL}/api/household/${HOUSEHOLD_ID}?ownerId=1"
    
    # 7. 验证删除
    echo -e "${BLUE}========== 验证删除 ==========${NC}"
    test_api "获取已删除的家庭（应该失败）" "GET" "${BASE_URL}/api/household/${HOUSEHOLD_ID}" "" 500
else
    echo -e "${RED}无法获取家庭ID，跳过后续测试${NC}"
fi

# 8. 错误处理测试
echo -e "${BLUE}========== 错误处理测试 ==========${NC}"
test_api "创建家庭（缺少必填字段）" "POST" "${BASE_URL}/api/household" \
  '{"name":"测试"}' 400

test_api "获取不存在的家庭" "GET" "${BASE_URL}/api/household/99999" "" 500

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
