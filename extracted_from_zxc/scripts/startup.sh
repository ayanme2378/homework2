#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  启动 Spring Cloud 微服务系统${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR" || exit 1

# 检查是否需要编译
if [ ! -f "address-service/target/address-service-1.0.0.jar" ] || [ ! -f "user-service/target/user-service-1.0.0.jar" ]; then
    echo -e "${YELLOW}检测到缺少JAR文件，开始编译...${NC}"
    mvn clean package -DskipTests -q
    if [ $? -ne 0 ]; then
        echo -e "${RED}编译失败！${NC}"
        exit 1
    fi
fi

# 创建日志目录
mkdir -p logs

# 启动Nacos容器
echo -e "${YELLOW}1. 启动Nacos服务器...${NC}"
docker-compose up -d
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}(Nacos可能已运行或Docker服务不可用，继续启动微服务)${NC}"
fi

# 等待Nacos启动
echo -e "${YELLOW}   等待Nacos启动完成...${NC}"
sleep 10

# 检查Nacos健康状态
echo -e "${YELLOW}2. 检查Nacos健康状态...${NC}"
for i in {1..30}; do
    if curl -s -f http://localhost:8848/nacos/v1/console/health/readiness > /dev/null 2>&1; then
        echo -e "${GREEN}   Nacos已启动！${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${YELLOW}   Nacos启动超时，但继续启动微服务...${NC}"
    else
        echo -n "."
        sleep 1
    fi
done
echo ""

# 启动address-service
echo -e "${YELLOW}3. 启动 Address Service (端口: 8081)...${NC}"
java -jar address-service/target/address-service-1.0.0.jar > logs/address-service.log 2>&1 &
ADDRESS_PID=$!
echo -e "${GREEN}   Address Service已启动，PID: $ADDRESS_PID${NC}"

# 等待address-service启动
sleep 5

# 启动user-service
echo -e "${YELLOW}4. 启动 User Service (端口: 8082)...${NC}"
java -jar user-service/target/user-service-1.0.0.jar > logs/user-service.log 2>&1 &
USER_PID=$!
echo -e "${GREEN}   User Service已启动，PID: $USER_PID${NC}"

# 等待user-service启动
sleep 3

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  所有服务启动完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 显示服务信息
echo -e "${BLUE}服务信息:${NC}"
echo "  Nacos控制台:     ${YELLOW}http://localhost:8848/nacos${NC}"
echo "  Address Service: ${YELLOW}http://localhost:8081${NC}"
echo "  User Service:    ${YELLOW}http://localhost:8082${NC}"
echo ""

echo -e "${BLUE}快速测试:${NC}"
echo "  查询地址1:    ${YELLOW}curl http://localhost:8081/addresses/1${NC}"
echo "  用户查询地址1:${YELLOW}curl http://localhost:8082/users/address/1${NC}"
echo "  运行完整测试: ${YELLOW}cd $PROJECT_DIR && bash test-api.sh${NC}"
echo ""

echo -e "${BLUE}日志文件:${NC}"
echo "  Address Service: ${YELLOW}tail -f $PROJECT_DIR/logs/address-service.log${NC}"
echo "  User Service:    ${YELLOW}tail -f $PROJECT_DIR/logs/user-service.log${NC}"
echo ""

echo -e "${BLUE}关闭服务:${NC}"
echo "  执行关闭脚本: ${YELLOW}bash $SCRIPT_DIR/shutdown.sh${NC}"
echo ""

