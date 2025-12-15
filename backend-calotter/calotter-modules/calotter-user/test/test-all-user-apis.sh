#!/bin/bash

# User模块完整API测试脚本
# 测试User API和Household API

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  User模块完整API测试"
echo "=========================================="
echo ""

# 1. 测试User API
echo -e "${BLUE}========== 1. 测试User API ==========${NC}"
bash "${SCRIPT_DIR}/test-user-api.sh"
USER_TEST_RESULT=$?

echo ""
echo -e "${BLUE}========== 2. 测试Household API ==========${NC}"
bash "${SCRIPT_DIR}/test-household-api.sh"
HOUSEHOLD_TEST_RESULT=$?

echo ""
echo "=========================================="
echo -e "${GREEN}所有测试完成！${NC}"
echo "=========================================="

if [ $USER_TEST_RESULT -eq 0 ] && [ $HOUSEHOLD_TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ 部分测试失败${NC}"
    exit 1
fi
