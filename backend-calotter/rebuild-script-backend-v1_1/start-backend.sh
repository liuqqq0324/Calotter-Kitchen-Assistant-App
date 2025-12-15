#!/bin/bash

# ============================================
# Calotter 后端启动脚本
# ============================================
# 功能：编译项目 -> 启动后端服务（后台运行）
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
echo -e "${BLUE}  Calotter 后端启动脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================
# 前置检查
# ============================================
echo -e "${YELLOW}[检查] 前置条件检查...${NC}"

# 检查 Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}  ✗ Java 未安装${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo -e "${GREEN}  ✓ Java: $JAVA_VERSION${NC}"

# 检查 Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}  ✗ Maven 未安装${NC}"
    exit 1
fi
MVN_VERSION=$(mvn -version | head -n 1)
echo -e "${GREEN}  ✓ $MVN_VERSION${NC}"

# 检查 Docker 容器
if ! docker ps | grep -q "calotter_postgres"; then
    echo -e "${YELLOW}  ⚠ PostgreSQL 容器未运行${NC}"
    echo "  正在启动 PostgreSQL..."
    cd "$PROJECT_ROOT"
    docker-compose up -d
    sleep 5
fi

# 检查数据库连接
if docker exec calotter_postgres pg_isready -U postgres >/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ PostgreSQL 已就绪${NC}"
else
    echo -e "${RED}  ✗ PostgreSQL 未就绪，请先运行 rebuild-database.sh${NC}"
    exit 1
fi

echo ""

# ============================================
# 步骤 1: 停止现有后端服务
# ============================================
echo -e "${YELLOW}[1/4] 停止现有后端服务...${NC}"

# 查找并停止运行中的服务
EXISTING_PID=$(pgrep -f "calotter-start" || true)
if [ -n "$EXISTING_PID" ]; then
    echo "  停止进程 PID: $EXISTING_PID"
    kill $EXISTING_PID 2>/dev/null || true
    sleep 2
    # 如果还在运行，强制杀死
    if kill -0 $EXISTING_PID 2>/dev/null; then
        kill -9 $EXISTING_PID 2>/dev/null || true
    fi
    echo -e "${GREEN}  ✓ 已停止现有服务${NC}"
else
    echo "  没有运行中的后端服务"
fi

echo ""

# ============================================
# 步骤 2: 编译项目
# ============================================
echo -e "${YELLOW}[2/4] 编译项目...${NC}"

echo "  执行: mvn clean install -DskipTests"
mvn clean install -DskipTests

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ 编译成功${NC}"
else
    echo -e "${RED}  ✗ 编译失败${NC}"
    exit 1
fi

echo ""

# ============================================
# 步骤 3: 创建日志目录
# ============================================
echo -e "${YELLOW}[3/4] 准备日志目录...${NC}"

LOG_DIR="$PROJECT_ROOT/logs"
mkdir -p "$LOG_DIR"
echo -e "${GREEN}  ✓ 日志目录: $LOG_DIR${NC}"

# 确保在项目根目录
cd "$PROJECT_ROOT"

echo ""

# ============================================
# 步骤 4: 启动后端服务
# ============================================
echo -e "${YELLOW}[4/4] 启动后端服务...${NC}"

cd calotter-start

# 后台启动服务
echo "  启动 Spring Boot 应用（后台运行）..."
nohup mvn spring-boot:run > ../logs/backend.log 2>&1 &
BACKEND_PID=$!

# 等待服务启动
echo "  等待服务启动（最多 30 秒）..."
MAX_WAIT=30
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8080/actuator/health >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 服务已启动${NC}"
        break
    fi
    # 检查进程是否还在运行
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${RED}  ✗ 服务启动失败，请查看日志: tail -f ../logs/backend.log${NC}"
        exit 1
    fi
    echo -n "."
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo -e "${YELLOW}  ⚠ 服务可能还在启动中，请稍后检查${NC}"
fi

echo ""

# ============================================
# 完成
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 后端服务启动完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "服务信息："
echo "  - 进程 ID: $BACKEND_PID"
echo "  - 服务地址: http://localhost:8080"
echo "  - 日志文件: $LOG_DIR/backend.log"
echo ""
echo "常用命令："
echo "  - 查看日志: tail -f $LOG_DIR/backend.log"
echo "  - 停止服务: kill $BACKEND_PID"
echo "  - 检查健康: curl http://localhost:8080/actuator/health"
echo ""
echo "JPA 将在首次启动时自动创建所有表结构。"
echo ""
