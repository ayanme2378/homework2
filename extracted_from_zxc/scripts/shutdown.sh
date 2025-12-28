#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  关闭 Spring Cloud 微服务系统${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR" || exit 1

# 停止Java进程
echo -e "${YELLOW}1. 停止微服务进程...${NC}"

# 停止address-service
if pgrep -f "address-service-1.0.0.jar" > /dev/null; then
    echo -e "   正在关闭 Address Service..."
    pkill -f "address-service-1.0.0.jar"
    sleep 2
    echo -e "${GREEN}   Address Service已关闭${NC}"
else
    echo -e "   Address Service未运行"
fi

# 停止user-service
if pgrep -f "user-service-1.0.0.jar" > /dev/null; then
    echo -e "   正在关闭 User Service..."
    pkill -f "user-service-1.0.0.jar"
    sleep 2
    echo -e "${GREEN}   User Service已关闭${NC}"
else
    echo -e "   User Service未运行"
fi

echo ""

# 停止Nacos容器
echo -e "${YELLOW}2. 停止Nacos容器...${NC}"
docker-compose down > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   Nacos容器已停止${NC}"
else
    echo -e "${YELLOW}   (Nacos容器停止失败或未运行)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  所有服务已关闭${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

