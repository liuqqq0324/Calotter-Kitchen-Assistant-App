#!/bin/bash

# 测试数据注入脚本
# 自动执行SQL脚本注入测试数据

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  注入 Inventory API 测试数据"
echo "=========================================="
echo ""

# 检查Docker容器是否运行
echo -e "${YELLOW}1. 检查数据库容器...${NC}"
if ! docker ps | grep -q calotter_postgres; then
    echo -e "${RED}✗ 数据库容器未运行${NC}"
    echo "请先启动数据库: docker-compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ 数据库容器运行中${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 执行SQL脚本
echo -e "${YELLOW}2. 执行SQL脚本注入数据...${NC}"
if docker exec -i calotter_postgres psql -U postgres -d calotter < "${SCRIPT_DIR}/insert-test-data.sql"; then
    echo -e "${GREEN}✓ 数据注入成功${NC}"
else
    echo -e "${RED}✗ 数据注入失败${NC}"
    exit 1
fi
echo ""

# 验证数据
echo -e "${YELLOW}3. 验证数据...${NC}"
echo -e "${BLUE}用户数据:${NC}"
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT id, username, email FROM users WHERE username IN ('testuser', 'inventory_test');"

echo -e "${BLUE}家庭数据:${NC}"
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT id, name, invite_code, owner_id FROM households WHERE invite_code IN ('TEST001', 'TEST002');"

echo -e "${BLUE}标准食材数量:${NC}"
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) as count FROM ref_standard_ingredients;"

echo -e "${BLUE}标准调料数量:${NC}"
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) as count FROM ref_standard_spices;"

echo -e "${BLUE}标准厨具数量:${NC}"
docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT COUNT(*) as count FROM ref_standard_utensils;"

echo ""
echo "=========================================="
echo -e "${GREEN}数据注入完成！${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}测试数据信息:${NC}"
echo "1. 用户: testuser / inventory_test (密码: password123)"
echo "2. 家庭邀请码: TEST001, TEST002"
echo "3. 标准食材ID: 1001-1010"
echo "4. 标准调料ID: 3001-3015"
echo "5. 标准厨具ID: 2001-2015"
echo ""
echo -e "${BLUE}获取Household ID:${NC}"
HOUSEHOLD_ID=$(docker exec calotter_postgres psql -U postgres -d calotter -t -c "SELECT id FROM households WHERE invite_code = 'TEST001' LIMIT 1;" | xargs)
echo "TEST001 的 Household ID: $HOUSEHOLD_ID"
echo ""
echo -e "${YELLOW}现在可以使用以下命令测试API:${NC}"
echo "curl \"http://localhost:8080/api/inventory/ingredients?householdId=$HOUSEHOLD_ID\""
echo ""
