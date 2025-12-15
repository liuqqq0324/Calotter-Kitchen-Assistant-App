#!/bin/bash

# Inventory API 完整测试脚本
# 使用真实数据测试所有CRUD操作

BASE_URL="http://localhost:8080"
HOUSEHOLD_ID=1
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
echo "  Inventory API 完整测试"
echo "=========================================="
echo -e "${BLUE}使用 Household ID: $HOUSEHOLD_ID${NC}"
echo ""

# ==================== 食材测试 ====================
echo -e "${BLUE}========== 食材 (Ingredients) ==========${NC}"

# 1. 获取食材列表
test_api "获取食材列表" "GET" "${BASE_URL}/api/inventory/ingredients?householdId=${HOUSEHOLD_ID}"

# 2. 创建食材
CREATE_INGREDIENT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardIngredientId\": 1002,
    \"quantity\": 10.0,
    \"unit\": \"pcs\",
    \"expirationDate\": \"2024-12-25\",
    \"location\": \"FRIDGE\"
  }")

test_api "创建食材" "POST" "${BASE_URL}/api/inventory/ingredients" \
  "{\"householdId\":${HOUSEHOLD_ID},\"standardIngredientId\":1002,\"quantity\":10.0,\"unit\":\"pcs\",\"expirationDate\":\"2024-12-25\",\"location\":\"FRIDGE\"}"

INGREDIENT_ID=$(echo $CREATE_INGREDIENT_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$INGREDIENT_ID" ]; then
    # 3. 获取食材详情
    test_api "获取食材详情" "GET" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}"
    
    # 4. 更新食材
    test_api "更新食材" "PUT" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}" \
      "{\"householdId\":${HOUSEHOLD_ID},\"standardIngredientId\":1002,\"quantity\":8.0,\"unit\":\"pcs\",\"location\":\"FRIDGE\"}"
    
    # 5. 扣减库存
    test_api "扣减库存" "POST" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}/deduct?amount=2.0"
    
    # 6. 删除食材
    test_api "删除食材" "DELETE" "${BASE_URL}/api/inventory/ingredients/${INGREDIENT_ID}"
fi

# ==================== 调料测试 ====================
echo -e "${BLUE}========== 调料 (Spices) ==========${NC}"

# 1. 获取调料列表
test_api "获取调料列表" "GET" "${BASE_URL}/api/inventory/spices?householdId=${HOUSEHOLD_ID}"

# 2. 创建调料
CREATE_SPICE_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/spices" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardSpiceId\": 3004,
    \"isAvailable\": true,
    \"remark\": \"新买的醋\"
  }")

test_api "创建调料" "POST" "${BASE_URL}/api/inventory/spices" \
  "{\"householdId\":${HOUSEHOLD_ID},\"standardSpiceId\":3004,\"isAvailable\":true,\"remark\":\"新买的醋\"}"

SPICE_ID=$(echo $CREATE_SPICE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$SPICE_ID" ]; then
    # 3. 获取调料详情
    test_api "获取调料详情" "GET" "${BASE_URL}/api/inventory/spices/${SPICE_ID}"
    
    # 4. 更新调料
    test_api "更新调料" "PUT" "${BASE_URL}/api/inventory/spices/${SPICE_ID}" \
      "{\"householdId\":${HOUSEHOLD_ID},\"standardSpiceId\":3004,\"isAvailable\":false,\"remark\":\"用完了\"}"
    
    # 5. 删除调料
    test_api "删除调料" "DELETE" "${BASE_URL}/api/inventory/spices/${SPICE_ID}"
fi

# ==================== 厨具测试 ====================
echo -e "${BLUE}========== 厨具 (Utensils) ==========${NC}"

# 1. 获取厨具列表
test_api "获取厨具列表" "GET" "${BASE_URL}/api/inventory/utensils?householdId=${HOUSEHOLD_ID}"

# 2. 创建厨具
CREATE_UTENSIL_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/utensils" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"standardUtensilId\": 2003,
    \"isAvailable\": true,
    \"remark\": \"新买的汤锅\"
  }")

test_api "创建厨具" "POST" "${BASE_URL}/api/inventory/utensils" \
  "{\"householdId\":${HOUSEHOLD_ID},\"standardUtensilId\":2003,\"isAvailable\":true,\"remark\":\"新买的汤锅\"}"

UTENSIL_ID=$(echo $CREATE_UTENSIL_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$UTENSIL_ID" ]; then
    # 3. 获取厨具详情
    test_api "获取厨具详情" "GET" "${BASE_URL}/api/inventory/utensils/${UTENSIL_ID}"
    
    # 4. 更新厨具
    test_api "更新厨具" "PUT" "${BASE_URL}/api/inventory/utensils/${UTENSIL_ID}" \
      "{\"householdId\":${HOUSEHOLD_ID},\"standardUtensilId\":2003,\"isAvailable\":false,\"remark\":\"坏了\"}"
    
    # 5. 删除厨具
    test_api "删除厨具" "DELETE" "${BASE_URL}/api/inventory/utensils/${UTENSIL_ID}"
fi

# ==================== 剩菜测试 ====================
echo -e "${BLUE}========== 剩菜 (Leftovers) ==========${NC}"

# 1. 获取剩菜列表
test_api "获取剩菜列表" "GET" "${BASE_URL}/api/inventory/leftovers?householdId=${HOUSEHOLD_ID}"

# 2. 创建剩菜
CREATE_LEFTOVER_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/leftovers" \
  -H "Content-Type: application/json" \
  -d "{
    \"householdId\": ${HOUSEHOLD_ID},
    \"name\": \"测试剩菜-糖醋排骨\",
    \"quantityGram\": 800.0,
    \"producedTime\": \"2024-12-15T18:00:00\"
  }")

test_api "创建剩菜" "POST" "${BASE_URL}/api/inventory/leftovers" \
  "{\"householdId\":${HOUSEHOLD_ID},\"name\":\"测试剩菜-糖醋排骨\",\"quantityGram\":800.0,\"producedTime\":\"2024-12-15T18:00:00\"}"

LEFTOVER_ID=$(echo $CREATE_LEFTOVER_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$LEFTOVER_ID" ]; then
    # 3. 获取剩菜详情
    test_api "获取剩菜详情" "GET" "${BASE_URL}/api/inventory/leftovers/${LEFTOVER_ID}"
    
    # 4. 更新剩菜
    test_api "更新剩菜" "PUT" "${BASE_URL}/api/inventory/leftovers/${LEFTOVER_ID}" \
      "{\"householdId\":${HOUSEHOLD_ID},\"name\":\"测试剩菜-糖醋排骨（已更新）\",\"quantityGram\":600.0,\"producedTime\":\"2024-12-15T18:00:00\"}"
    
    # 5. 删除剩菜
    test_api "删除剩菜" "DELETE" "${BASE_URL}/api/inventory/leftovers/${LEFTOVER_ID}"
fi

# ==================== 错误处理测试 ====================
echo -e "${BLUE}========== 错误处理测试 ==========${NC}"

# 测试不存在的资源
test_api "获取不存在的食材" "GET" "${BASE_URL}/api/inventory/ingredients/99999" "" 500

# 测试缺少必填字段
test_api "创建食材（缺少必填字段）" "POST" "${BASE_URL}/api/inventory/ingredients" \
  "{\"householdId\":${HOUSEHOLD_ID}}" 400

# 测试不存在的household
test_api "使用不存在的householdId" "GET" "${BASE_URL}/api/inventory/ingredients?householdId=99999" "" 500

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
