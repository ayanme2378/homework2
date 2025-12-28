#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Spring Cloud OpenFeign 微服务测试${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 测试address-service
echo -e "${YELLOW}1. 测试 Address Service - 查询存在的地址${NC}"
echo "请求: GET http://localhost:8081/addresses/1"
curl -s http://localhost:8081/addresses/1 | jq . 2>/dev/null || echo "未收到有效的JSON响应"
echo ""

echo -e "${YELLOW}2. 测试 Address Service - 查询不存在的地址 (应返回404)${NC}"
echo "请求: GET http://localhost:8081/addresses/999"
curl -i -s http://localhost:8081/addresses/999 2>/dev/null | head -1
echo ""

echo -e "${YELLOW}3. 测试 User Service - 通过Feign调用Address Service${NC}"
echo "请求: GET http://localhost:8082/users/address/1"
curl -s http://localhost:8082/users/address/1 | jq . 2>/dev/null || echo "未收到有效的JSON响应"
echo ""

echo -e "${YELLOW}4. 测试 User Service - 通过Feign调用不存在的地址${NC}"
echo "请求: GET http://localhost:8082/users/address/999"
curl -i -s http://localhost:8082/users/address/999 2>/dev/null | head -1
echo ""

echo -e "${YELLOW}5. 测试所有可用的地址ID${NC}"
for id in 1 2 3 4; do
  echo -n "Address ID $id: "
  curl -s http://localhost:8081/addresses/$id | jq -r '.receiverName, .phone' 2>/dev/null | tr '\n' ' ' || echo "查询失败"
  echo ""
done
echo ""

echo -e "${YELLOW}6. Nacos服务注册中心检查${NC}"
echo "请求: GET http://localhost:8848/nacos/v1/ns/service/list"
curl -s "http://localhost:8848/nacos/v1/ns/service/list" | jq . 2>/dev/null | head -20 || echo "无法连接到Nacos"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  所有测试完成${NC}"
echo -e "${GREEN}========================================${NC}"
