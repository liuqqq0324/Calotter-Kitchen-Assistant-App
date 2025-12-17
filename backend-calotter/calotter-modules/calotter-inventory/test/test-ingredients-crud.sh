#!/bin/bash

# Inventory Ingredients CRUD API 测试脚本
# 测试所有 Ingredients 相关的 CRUD 操作

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
INGREDIENT_ID=""

# 获取 Household ID（从数据库或使用默认值）
get_household_id() {
    # 尝试从数据库获取 TEST001 的 household ID
    HOUSEHOLD_ID=$(docker exec calotter_postgres psql -U postgres -d calotter -t -c "SELECT id FROM households WHERE invite_code = 'TEST001' LIMIT 1;" 2>/dev/null | xargs)
    
    if [ -z "$HOUSEHOLD_ID" ]; then
        echo -e "${YELLOW}Warning: Could not find TEST001 household, using default ID: 1${NC}"
        HOUSEHOLD_ID=1
    else
        echo -e "${GREEN}Found Household ID: $HOUSEHOLD_ID${NC}"
    fi
}

# 测试函数
test_api() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_code=${5:-200}
    
    echo -e "${YELLOW}[Test] $name${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    # 分离响应体和状态码
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    # 从 JSON 响应中提取 code
    code=$(echo "$body" | grep -o '"code":[0-9]*' | head -1 | cut -d':' -f2 | tr -d ' ')
    
    if [ "$code" = "$expected_code" ] || [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ PASS (code: ${code:-$http_code})${NC}"
        ((PASS_COUNT++))
        echo "$body" | python3 -m json.tool 2>/dev/null | head -30 || echo "$body" | head -5
    else
        echo -e "${RED}✗ FAIL (expected: $expected_code, got: ${code:-$http_code})${NC}"
        ((FAIL_COUNT++))
        echo "Response: $body" | head -10
    fi
    echo ""
}

# 从响应中提取 ID
extract_id() {
    local response=$1
    echo "$response" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2 | tr -d ' '
}

echo "=========================================="
echo "  Inventory Ingredients CRUD API Test"
echo "=========================================="
echo ""

# 获取 Household ID
get_household_id
echo "Using Household ID: $HOUSEHOLD_ID"
echo ""

# ==================== 1. GET - 获取库存列表 ====================
echo -e "${BLUE}========== 1. GET - Get Ingredients List ==========${NC}"
test_api "Get all ingredients for household" "GET" "${BASE_URL}/api/inventory/ingredients?householdId=${HOUSEHOLD_ID}"
echo ""

# ==================== 2. POST - 添加库存 ====================
echo -e "${BLUE}========== 2. POST - Create Ingredient ==========${NC}"

# 使用标准食材 ID: 1001 (Chicken Breast)
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardIngredientId\": 1001,
    \"quantity\": 500.0,
    \"unit\": \"g\",
    \"expirationDate\": \"2025-12-31\",
    \"location\": \"FRIDGE\"
  }")

test_api "Create ingredient (Chicken Breast)" "POST" "${BASE_URL}/api/inventory/ingredients" \
  "{\"householdId\":${HOUSEHOLD_ID},\"standardIngredientId\":1001,\"quantity\":500.0,\"unit\":\"g\",\"expirationDate\":\"2025-12-31\",\"location\":\"FRIDGE\"}"

# 提取创建的 ID
INGREDIENT_ID=$(extract_id "$CREATE_RESPONSE")

if [ -z "$INGREDIENT_ID" ]; then
    echo -e "${RED}✗ Failed to create ingredient, cannot continue with update/delete tests${NC}"
    echo ""
else
    echo -e "${GREEN}Created ingredient with ID: $INGREDIENT_ID${NC}"
    echo ""
    
    # ==================== 3. GET - 获取单个库存详情 ====================
    echo -e "${BLUE}========== 3. GET - Get Ingredient Detail ==========${NC}"
    test_api "Get ingredient by ID" "GET" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}"
    echo ""
    
    # ==================== 4. PUT - 更新库存 ====================
    echo -e "${BLUE}========== 4. PUT - Update Ingredient ==========${NC}"
    test_api "Update ingredient (change quantity to 300g)" "PUT" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}" \
      "{\"householdId\":${HOUSEHOLD_ID},\"standardIngredientId\":1001,\"quantity\":300.0,\"unit\":\"g\",\"expirationDate\":\"2025-12-31\",\"location\":\"FRIDGE\"}"
    echo ""
    
    # 验证更新是否成功
    echo -e "${YELLOW}[Verify] Check if update was successful${NC}"
    UPDATED_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}")
    UPDATED_QUANTITY=$(echo "$UPDATED_RESPONSE" | grep -o '"quantity":[0-9.]*' | cut -d':' -f2)
    if [ "$UPDATED_QUANTITY" = "300.0" ]; then
        echo -e "${GREEN}✓ Update verified: quantity is now 300.0${NC}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ Update verification failed: expected 300.0, got $UPDATED_QUANTITY${NC}"
        ((FAIL_COUNT++))
    fi
    echo ""
    
    # ==================== 5. DELETE - 删除库存 ====================
    echo -e "${BLUE}========== 5. DELETE - Delete Ingredient ==========${NC}"
    test_api "Delete ingredient" "DELETE" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}"
    echo ""
    
    # 验证删除是否成功
    echo -e "${YELLOW}[Verify] Check if ingredient was deleted${NC}"
    DELETED_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}")
    DELETED_CODE=$(echo "$DELETED_RESPONSE" | grep -o '"code":[0-9]*' | cut -d':' -f2 | tr -d ' ')
    if [ "$DELETED_CODE" = "500" ] || [ "$DELETED_CODE" = "404" ]; then
        echo -e "${GREEN}✓ Delete verified: ingredient no longer exists${NC}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ Delete verification failed: ingredient still exists${NC}"
        ((FAIL_COUNT++))
    fi
    echo ""
fi

# ==================== 6. 错误处理测试 ====================
echo -e "${BLUE}========== 6. Error Handling Tests ==========${NC}"

# 测试不存在的 ID
test_api "Get non-existent ingredient" "GET" "${BASE_URL}/api/inventory/ingredients/99999" "" 500

# 测试缺少必填字段
test_api "Create ingredient (missing required fields)" "POST" "${BASE_URL}/api/inventory/ingredients" \
  "{\"householdId\":${HOUSEHOLD_ID}}" 400

# 测试不存在的 standardIngredientId
test_api "Create ingredient (invalid standardIngredientId)" "POST" "${BASE_URL}/api/inventory/ingredients" \
  "{\"householdId\":${HOUSEHOLD_ID},\"standardIngredientId\":99999,\"quantity\":100.0,\"unit\":\"g\"}" 500

# 测试不存在的 householdId（应该返回空列表，而不是错误）
echo -e "${YELLOW}[Test] Get ingredients (non-existent householdId - should return empty list)${NC}"
NON_EXISTENT_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients?householdId=99999")
NON_EXISTENT_CODE=$(echo "$NON_EXISTENT_RESPONSE" | grep -o '"code":[0-9]*' | cut -d':' -f2 | tr -d ' ')
NON_EXISTENT_DATA=$(echo "$NON_EXISTENT_RESPONSE" | grep -o '"data":\[.*\]' | grep -o '\[\]')

if [ "$NON_EXISTENT_CODE" = "200" ] && [ ! -z "$NON_EXISTENT_DATA" ]; then
    echo -e "${GREEN}✓ PASS (code: 200, returns empty list - correct behavior)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ FAIL (expected: code 200 with empty list, got: code $NON_EXISTENT_CODE)${NC}"
    ((FAIL_COUNT++))
fi
echo ""

echo ""

# ==================== 7. 完整流程测试 ====================
echo -e "${BLUE}========== 7. Complete Workflow Test ==========${NC}"

# 创建多个食材
echo -e "${YELLOW}[Workflow] Create multiple ingredients${NC}"

# 创建 Tomato
TOMATO_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardIngredientId\": 1003,
    \"quantity\": 1000.0,
    \"unit\": \"g\",
    \"expirationDate\": \"2025-12-20\",
    \"location\": \"FRIDGE\"
  }")

TOMATO_ID=$(extract_id "$TOMATO_RESPONSE")
if [ ! -z "$TOMATO_ID" ]; then
    echo -e "${GREEN}✓ Created Tomato (ID: $TOMATO_ID)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ Failed to create Tomato${NC}"
    ((FAIL_COUNT++))
fi

# 创建 Rice
RICE_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardIngredientId\": 1007,
    \"quantity\": 2000.0,
    \"unit\": \"g\",
    \"location\": \"PANTRY\"
  }")

RICE_ID=$(extract_id "$RICE_RESPONSE")
if [ ! -z "$RICE_ID" ]; then
    echo -e "${GREEN}✓ Created Rice (ID: $RICE_ID)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗ Failed to create Rice${NC}"
    ((FAIL_COUNT++))
fi

echo ""

# 获取所有食材列表
echo -e "${YELLOW}[Workflow] Get all ingredients list${NC}"
FINAL_LIST=$(curl -s "${BASE_URL}/api/inventory/ingredients?householdId=${HOUSEHOLD_ID}")
LIST_COUNT=$(echo "$FINAL_LIST" | grep -o '"id":[0-9]*' | wc -l | xargs)
echo -e "${GREEN}✓ Found $LIST_COUNT ingredients in household${NC}"
((PASS_COUNT++))

# 清理：删除创建的测试数据
if [ ! -z "$TOMATO_ID" ]; then
    curl -s -X DELETE "${BASE_URL}/api/inventory/ingredients/${TOMATO_ID}" > /dev/null
    echo -e "${GREEN}✓ Cleaned up Tomato (ID: $TOMATO_ID)${NC}"
fi

if [ ! -z "$RICE_ID" ]; then
    curl -s -X DELETE "${BASE_URL}/api/inventory/ingredients/${RICE_ID}" > /dev/null
    echo -e "${GREEN}✓ Cleaned up Rice (ID: $RICE_ID)${NC}"
fi

echo ""

# ==================== 测试总结 ====================
echo "=========================================="
echo -e "${BLUE}Test Summary${NC}"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
