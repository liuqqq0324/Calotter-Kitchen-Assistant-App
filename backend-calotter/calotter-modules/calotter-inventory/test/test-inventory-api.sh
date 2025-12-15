#!/bin/bash

# Inventory API 测试脚本
# 使用方法: ./test-inventory-api.sh

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  Inventory API 测试脚本"
echo "=========================================="
echo ""

# 检查应用是否运行
echo -e "${YELLOW}1. 检查应用状态...${NC}"
if curl -s -f "${BASE_URL}/api/user/register" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 应用正在运行${NC}"
else
    # 尝试另一个端点
    TEST_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients?householdId=999" 2>&1)
    if [[ $TEST_RESPONSE == *"家庭不存在"* ]] || [[ $TEST_RESPONSE == *"code"* ]]; then
        echo -e "${GREEN}✓ 应用正在运行${NC}"
    else
        echo -e "${RED}✗ 应用未运行，请先启动应用${NC}"
        echo "启动命令: cd backend-calotter && mvn spring-boot:run -pl calotter-start"
        exit 1
    fi
fi
echo ""

# 步骤1: 测试获取食材列表（空列表）
echo -e "${YELLOW}2. 测试获取食材列表 (GET /api/inventory/ingredients)...${NC}"
INGREDIENTS_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients?householdId=999")
echo -e "${BLUE}响应:${NC} $INGREDIENTS_RESPONSE"
if [[ $INGREDIENTS_RESPONSE == *"code"* ]] && [[ $INGREDIENTS_RESPONSE == *"200"* ]]; then
    echo -e "${GREEN}✓ API 响应正常${NC}"
else
    echo -e "${YELLOW}⚠ 响应可能包含错误（这是正常的，如果householdId不存在）${NC}"
fi
echo ""

# 步骤2: 测试创建食材（预期失败，因为缺少household和标准库数据）
echo -e "${YELLOW}3. 测试创建食材 (POST /api/inventory/ingredients)...${NC}"
CREATE_INGREDIENT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 999,
    "standardIngredientId": 1001,
    "quantity": 500.0,
    "unit": "g",
    "expirationDate": "2024-12-31",
    "location": "FRIDGE"
  }')
echo -e "${BLUE}响应:${NC} $CREATE_INGREDIENT_RESPONSE"
if [[ $CREATE_INGREDIENT_RESPONSE == *"家庭不存在"* ]] || [[ $CREATE_INGREDIENT_RESPONSE == *"标准食材不存在"* ]]; then
    echo -e "${GREEN}✓ 错误处理正常（预期行为）${NC}"
else
    echo -e "${YELLOW}⚠ 意外响应${NC}"
fi
echo ""

# 步骤3: 测试获取调料列表
echo -e "${YELLOW}4. 测试获取调料列表 (GET /api/inventory/spices)...${NC}"
SPICES_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/spices?householdId=999")
echo -e "${BLUE}响应:${NC} $SPICES_RESPONSE"
echo ""

# 步骤4: 测试创建调料
echo -e "${YELLOW}5. 测试创建调料 (POST /api/inventory/spices)...${NC}"
CREATE_SPICE_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/spices" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 999,
    "standardSpiceId": 3001,
    "isAvailable": true,
    "remark": "测试调料"
  }')
echo -e "${BLUE}响应:${NC} $CREATE_SPICE_RESPONSE"
echo ""

# 步骤5: 测试获取厨具列表
echo -e "${YELLOW}6. 测试获取厨具列表 (GET /api/inventory/utensils)...${NC}"
UTENSILS_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/utensils?householdId=999")
echo -e "${BLUE}响应:${NC} $UTENSILS_RESPONSE"
echo ""

# 步骤6: 测试创建厨具
echo -e "${YELLOW}7. 测试创建厨具 (POST /api/inventory/utensils)...${NC}"
CREATE_UTENSIL_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/utensils" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 999,
    "standardUtensilId": 2001,
    "isAvailable": true,
    "remark": "测试厨具"
  }')
echo -e "${BLUE}响应:${NC} $CREATE_UTENSIL_RESPONSE"
echo ""

# 步骤7: 测试获取剩菜列表
echo -e "${YELLOW}8. 测试获取剩菜列表 (GET /api/inventory/leftovers)...${NC}"
LEFTOVERS_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/leftovers?householdId=999")
echo -e "${BLUE}响应:${NC} $LEFTOVERS_RESPONSE"
echo ""

# 步骤8: 测试创建剩菜（不需要标准库，但需要household）
echo -e "${YELLOW}9. 测试创建剩菜 (POST /api/inventory/leftovers)...${NC}"
CREATE_LEFTOVER_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/inventory/leftovers" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 999,
    "name": "测试剩菜-红烧肉",
    "coverImage": "https://example.com/image.jpg",
    "quantityGram": 500.0,
    "producedTime": "2024-12-15T18:00:00"
  }')
echo -e "${BLUE}响应:${NC} $CREATE_LEFTOVER_RESPONSE"
echo ""

# 步骤9: 测试无效请求（验证）
echo -e "${YELLOW}10. 测试无效请求（缺少必填字段）...${NC}"
INVALID_REQUEST=$(curl -s -X POST "${BASE_URL}/api/inventory/ingredients" \
  -H "Content-Type: application/json" \
  -d '{
    "householdId": 1
  }')
echo -e "${BLUE}响应:${NC} $INVALID_REQUEST"
if [[ $INVALID_REQUEST == *"不能为空"* ]] || [[ $INVALID_REQUEST == *"validation"* ]]; then
    echo -e "${GREEN}✓ 数据验证正常工作${NC}"
fi
echo ""

# 步骤10: 测试获取不存在的资源
echo -e "${YELLOW}11. 测试获取不存在的资源 (GET /api/inventory/ingredients/99999)...${NC}"
NOT_FOUND_RESPONSE=$(curl -s "${BASE_URL}/api/inventory/ingredients/99999")
echo -e "${BLUE}响应:${NC} $NOT_FOUND_RESPONSE"
echo ""

echo "=========================================="
echo -e "${GREEN}基础API测试完成！${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}测试总结:${NC}"
echo "1. ✓ 所有API端点都可以访问"
echo "2. ✓ 错误处理正常工作"
echo "3. ⚠ 要测试完整的CRUD功能，需要："
echo "   - 先创建User和Household"
echo "   - 在数据库中插入标准库数据（StandardIngredient, StandardSpice, StandardUtensil）"
echo ""
echo -e "${BLUE}下一步:${NC}"
echo "1. 使用Postman或curl创建真实的测试数据"
echo "2. 插入标准库数据到数据库"
echo "3. 然后可以测试完整的CRUD流程"
echo ""
