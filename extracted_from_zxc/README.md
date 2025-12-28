# 微服务项目 - Spring Cloud OpenFeign + Nacos

## 项目简介

本项目演示了基于Spring Cloud OpenFeign的微服务架构，包含两个微服务：
- **address-service**: 地址服务，提供地址查询接口
- **user-service**: 用户服务，通过Feign调用地址服务

两个服务均注册到Nacos服务注册中心。

## 项目结构

```
homework2/
├── pom.xml                      # 父POM配置
├── docker-compose.yml           # Nacos容器配置
├── README.md                    # 项目文档
│
├── address-service/             # 地址服务模块
│   ├── pom.xml                  # 地址服务POM
│   └── src/main/
│       ├── java/com/example/addressservice/
│       │   ├── AddressServiceApplication.java    # 启动类
│       │   ├── controller/AddressController.java # 控制器
│       │   ├── service/AddressService.java       # 服务层
│       │   └── entity/Address.java               # 地址实体
│       └── resources/
│           └── application.yml                   # 配置文件
│
├── user-service/                # 用户服务模块
│   ├── pom.xml                  # 用户服务POM
│   └── src/main/
│       ├── java/com/example/userservice/
│       │   ├── UserServiceApplication.java       # 启动类
│       │   ├── controller/UserController.java    # 控制器
│       │   ├── service/UserService.java          # 服务层
│       │   ├── client/AddressServiceClient.java  # Feign客户端
│       │   └── dto/AddressDTO.java               # 地址DTO
│       └── resources/
│           └── application.yml                   # 配置文件
│
└── scripts/                     # 启动脚本目录
    ├── startup.sh               # 启动脚本
    └── shutdown.sh              # 关闭脚本
```

## 功能说明

### 1. Address Service (端口: 8081)

#### 接口: GET /addresses/{addressId}

查询单个收货地址，根据地址ID返回详细信息。

**请求参数:**
- `addressId` (Long): 地址ID，路径参数

**响应成功 (200):**
```json
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

**响应失败 (404):**
地址不存在时返回404 Not Found

### 2. User Service (端口: 8082)

#### 接口: GET /users/address/{addressId}

用户服务通过Feign调用address-service查询地址信息，直接返回地址数据。

**请求参数:**
- `addressId` (Long): 地址ID，路径参数

**响应成功 (200):**
```json
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

**响应失败 (404):**
地址不存在时返回404 Not Found

## 核心实现

### OpenFeign声明式客户端

使用`@FeignClient`注解，基于服务名称`address-service`调用远程服务：

```java
@FeignClient(name = "address-service")
public interface AddressServiceClient {
    @GetMapping("/addresses/{addressId}")
    AddressDTO getAddress(@PathVariable("addressId") Long addressId);
}
```

### Nacos服务注册与发现

两个服务通过`@EnableDiscoveryClient`注解启用服务发现功能，自动注册到Nacos。

**address-service配置:**
```yaml
spring:
  application:
    name: address-service
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
```

**user-service配置:**
```yaml
spring:
  application:
    name: user-service
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
```

## 运行环境要求

- Java 8+
- Maven 3.6+
- Docker & Docker Compose
- Nacos 2.1.0 (通过Docker运行)

## 快速开始

### 方式1: 使用启动脚本 (推荐)

```bash
# 进入项目根目录
cd /workspaces/homework2

# 使脚本可执行
chmod +x scripts/startup.sh scripts/shutdown.sh

# 启动所有服务
./scripts/startup.sh

# 关闭所有服务
./scripts/shutdown.sh
```

### 方式2: 手动启动

#### 步骤1: 启动Nacos

```bash
# 在项目根目录执行
docker-compose up -d

# 验证Nacos是否启动成功
curl http://localhost:8848/nacos/v1/console/health/readiness
```

#### 步骤2: 启动address-service

```bash
cd address-service
mvn clean install
mvn spring-boot:run
```

#### 步骤3: 启动user-service

```bash
cd user-service
mvn clean install
mvn spring-boot:run
```

## 接口测试

### 1. 测试Address Service

查询地址ID为1的地址信息：
```bash
curl http://localhost:8081/addresses/1
```

查询不存在的地址（返回404）：
```bash
curl -i http://localhost:8081/addresses/999
```

### 2. 测试User Service (通过Feign调用)

通过user-service查询地址（内部调用address-service）：
```bash
curl http://localhost:8082/users/address/1
```

### 3. 测试Nacos控制台

访问Nacos控制台查看服务注册情况：
```
http://localhost:8848/nacos
```

默认用户名和密码: `nacos / nacos`

在"服务管理" -> "服务列表"中可以看到已注册的两个服务：
- `address-service`
- `user-service`

## 模拟数据

Address Service内置以下模拟地址数据：

| addressId | userId | receiverName | phone | fullAddress |
|-----------|--------|--------------|-------|-------------|
| 1 | 100 | 张三 | 13800000001 | 北京市朝阳区某街道123号 |
| 2 | 101 | 李四 | 13800000002 | 上海市浦东新区某大厦456号 |
| 3 | 102 | 王五 | 13800000003 | 深圳市南山区某商厦789号 |
| 4 | 100 | 陈六 | 13800000004 | 杭州市西湖区某街道321号 |

## 核心技术栈

| 技术 | 版本 | 说明 |
|-----|------|------|
| Spring Boot | 2.7.14 | 应用框架 |
| Spring Cloud | 2021.0.8 | 微服务框架 |
| Spring Cloud OpenFeign | - | 声明式HTTP客户端 |
| Spring Cloud Alibaba | 2021.0.4.0 | 阿里云整合 |
| Nacos | 2.1.0 | 服务注册中心和配置中心 |
| Lombok | - | 代码简化工具 |

## 关键特性

✅ **OpenFeign声明式客户端** - 使用注解优雅地调用远程服务，无需硬编码URL

✅ **Nacos服务注册与发现** - 自动化服务管理，支持动态扩容

✅ **负载均衡** - Feign集成Ribbon进行客户端负载均衡

✅ **服务隔离** - 两个独立的微服务模块

✅ **标准REST接口** - 遵循RESTful规范

✅ **完整的配置管理** - 统一的YAML配置文件

## 常见问题

### Q: 如何修改Nacos地址？

编辑各服务的`application.yml`文件，修改：
```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 新的Nacos地址:8848
```

### Q: 如何增加新的地址数据？

编辑address-service服务的AddressService.java，在静态块中添加新的地址：

```java
static {
    addressMap.put(5L, new Address(5L, 103L, "新用户", "13800000005", "新地址信息"));
}
```

### Q: Feign超时如何处理？

在user-service的`application.yml`中添加：
```yaml
feign:
  client:
    config:
      address-service:
        connectTimeout: 5000
        readTimeout: 5000
```

### Q: 如何查看服务日志？

- address-service日志: `tail -f logs/address-service.log`
- user-service日志: `tail -f logs/user-service.log`

## 扩展建议

1. **添加熔断器** - 集成Hystrix或Resilience4j处理服务故障
2. **添加网关** - 使用Spring Cloud Gateway统一入口
3. **配置中心** - 使用Nacos配置中心管理动态配置
4. **链路追踪** - 集成Sleuth和Zipkin进行分布式追踪
5. **消息队列** - 集成RabbitMQ或Kafka实现异步通信
6. **数据持久化** - 使用数据库替代模拟数据
7. **认证授权** - 添加Spring Security进行安全控制

## 许可证

MIT

## 更新日期

2025-12-28