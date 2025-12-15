#!/bin/bash

# ============================================
# Calotter 数据库重建脚本
# ============================================
# 功能：停止服务 -> 清理数据库 -> 重启容器 -> 重建数据库
# ============================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径 - 脚本在 rebuild-script-backend-v1_1 子目录，需要回到 backend-calotter 根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Calotter 数据库重建脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================
# 步骤 1: 停止现有服务
# ============================================
echo -e "${YELLOW}[1/5] 停止现有服务...${NC}"

# 停止 Java 后端服务
echo "  停止 Java 后端服务..."
pkill -f "calotter" 2>/dev/null || echo "    没有运行中的后端服务"

# 停止 Docker 容器
echo "  停止 Docker 容器..."
docker-compose down 2>/dev/null || echo "    容器可能未运行"

echo -e "${GREEN}  ✓ 服务已停止${NC}"
echo ""

# ============================================
# 步骤 2: 清理数据库数据
# ============================================
echo -e "${YELLOW}[2/5] 清理数据库数据...${NC}"
echo -e "${RED}  ⚠️  警告：这将删除所有数据库数据！${NC}"

# 删除 Docker Volume（完全清理）
echo "  删除 PostgreSQL 数据卷..."
docker-compose down -v 2>/dev/null || true

# 如果数据卷名称不同，尝试手动删除
VOLUME_NAME="backend-calotter_postgres_data"
if docker volume ls | grep -q "$VOLUME_NAME"; then
    echo "  删除数据卷: $VOLUME_NAME"
    docker volume rm "$VOLUME_NAME" 2>/dev/null || true
fi

echo -e "${GREEN}  ✓ 数据库数据已清理${NC}"
echo ""

# ============================================
# 步骤 3: 启动 PostgreSQL 容器
# ============================================
echo -e "${YELLOW}[3/5] 启动 PostgreSQL 容器...${NC}"

docker-compose up -d

# 等待容器启动
echo "  等待 PostgreSQL 启动（最多 30 秒）..."
MAX_WAIT=30
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if docker exec calotter_postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ PostgreSQL 已就绪${NC}"
        break
    fi
    echo -n "."
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo -e "${RED}  ✗ PostgreSQL 启动超时${NC}"
    echo "  请检查容器日志: docker logs calotter_postgres"
    exit 1
fi

echo ""

# ============================================
# 步骤 4: 重建数据库
# ============================================
echo -e "${YELLOW}[4/5] 重建数据库...${NC}"

# 删除现有数据库（如果存在）
echo "  删除现有数据库（如果存在）..."
docker exec calotter_postgres psql -U postgres -c "DROP DATABASE IF EXISTS calotter;" 2>/dev/null || true

# 创建新数据库
echo "  创建新数据库..."
docker exec calotter_postgres psql -U postgres -c "CREATE DATABASE calotter;" || {
    echo -e "${RED}  ✗ 数据库创建失败${NC}"
    exit 1
}

# 验证数据库创建
if docker exec calotter_postgres psql -U postgres -c "\l" | grep -q "calotter"; then
    echo -e "${GREEN}  ✓ 数据库 'calotter' 已创建${NC}"
else
    echo -e "${RED}  ✗ 数据库创建验证失败${NC}"
    exit 1
fi

echo ""

# ============================================
# 步骤 5: 验证数据库状态
# ============================================
echo -e "${YELLOW}[5/5] 验证数据库状态...${NC}"

# 检查容器状态
if docker ps | grep -q "calotter_postgres"; then
    echo -e "${GREEN}  ✓ PostgreSQL 容器运行中${NC}"
else
    echo -e "${RED}  ✗ PostgreSQL 容器未运行${NC}"
    exit 1
fi

# 测试数据库连接
if docker exec calotter_postgres psql -U postgres -d calotter -c "SELECT version();" >/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ 数据库连接正常${NC}"
else
    echo -e "${RED}  ✗ 数据库连接失败${NC}"
    exit 1
fi

echo ""

# ============================================
# 完成
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 数据库重建完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "数据库信息："
echo "  - 容器名: calotter_postgres"
echo "  - 数据库名: calotter"
echo "  - 用户名: postgres"
echo "  - 密码: 123"
echo "  - 端口: 5432"
echo ""
echo "下一步："
echo "  1. 启动后端服务: ./start-backend.sh"
echo "  2. 或者手动启动: cd calotter-start && mvn spring-boot:run"
echo ""
echo "JPA 将在首次启动时自动创建所有表结构。"
echo ""
