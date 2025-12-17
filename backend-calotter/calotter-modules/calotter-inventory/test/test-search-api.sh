#!/bin/bash

# 标准食材库查找 API 测试脚本
# 使用方法: bash test-search-api.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="http://localhost:8080/api/inventory/standard-ingredients/search"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  标准食材库查找 API 测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 测试 1: 精确匹配 - Chicken Breast
echo -e "${YELLOW}[Test 1] Exact match - Chicken Breast${NC}"
curl -s -G "$BASE_URL" \
  --data-urlencode "name=Chicken Breast" \
  --data-urlencode "fuzzy=false" | python3 -m json.tool
echo ""
echo ""

# 测试 2: 精确匹配 - Tomato
echo -e "${YELLOW}[Test 2] Exact match - Tomato${NC}"
curl -s -G "$BASE_URL" \
  --data-urlencode "name=Tomato" \
  --data-urlencode "fuzzy=false" | python3 -m json.tool
echo ""
echo ""

# 测试 3: 模糊匹配 - Cabbage（应该返回3个结果）
echo -e "${YELLOW}[Test 3] Fuzzy match - Cabbage (should return 3 results)${NC}"
curl -s -G "$BASE_URL" \
  --data-urlencode "name=Cabbage" \
  --data-urlencode "fuzzy=true" | python3 -m json.tool | head -80
echo ""
echo ""

# 测试 4: 模糊匹配 - Chicken（应该返回3个结果：Chicken Breast, Chicken Thigh, Chicken Wing）
echo -e "${YELLOW}[Test 4] Fuzzy match - Chicken (should return 3 results)${NC}"
curl -s -G "$BASE_URL" \
  --data-urlencode "name=Chicken" \
  --data-urlencode "fuzzy=true" | python3 -m json.tool | head -80
echo ""
echo ""

# 测试 5: 模糊匹配 - Bean（应该返回多个结果）
echo -e "${YELLOW}[Test 5] Fuzzy match - Bean (should return multiple results)${NC}"
RESULT=$(curl -s -G "$BASE_URL" \
  --data-urlencode "name=Bean" \
  --data-urlencode "fuzzy=true" | python3 -m json.tool)
echo "$RESULT" | head -100
COUNT=$(echo "$RESULT" | grep -c '"id"' || echo "0")
echo ""
echo -e "${GREEN}Found $COUNT results${NC}"
echo ""
echo ""

# 测试 6: 不存在的食材
echo -e "${YELLOW}[Test 6] Exact match - Non-existent ingredient${NC}"
curl -s -G "$BASE_URL" \
  --data-urlencode "name=NonExistentIngredient" \
  --data-urlencode "fuzzy=false" | python3 -m json.tool
echo ""
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Test completed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Note: If you encounter 400 errors, make sure to use --data-urlencode parameter for URL encoding"
echo ""
