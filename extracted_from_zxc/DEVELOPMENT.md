# Spring Cloud OpenFeign 微服务项目 - 开发者指南

## 快速开始 (5分钟)

### 前置要求
- Java 8+ (推荐 Java 11+)
- Maven 3.6+
- Docker & Docker Compose
- curl (用于测试API)

### 启动服务

```bash
# 进入项目根目录
cd /workspaces/homework2

# 使脚本可执行
chmod +x scripts/startup.sh scripts/shutdown.sh

# 启动所有服务
./scripts/startup.sh
```

### 测试接口

```bash
# 1. 直接查询Address Service
curl http://localhost:8081/addresses/1

# 2. 通过User Service查询（调用Address Service）
curl http://localhost:8082/users/address/1

# 3. 查看所有已注册的服务
curl http://localhost:8848/nacos/v1/ns/service/list | jq .
```

### 关闭服务

```bash
./scripts/shutdown.sh
```

---

## 项目架构

### 微服务组件

#### 1. Address Service (地址服务)
**端口**: 8081  
**职责**: 提供地址数据查询接口

**主要文件**:
- [AddressController.java](address-service/src/main/java/com/example/addressservice/controller/AddressController.java) - REST控制器
- [AddressService.java](address-service/src/main/java/com/example/addressservice/service/AddressService.java) - 业务逻辑
- [Address.java](address-service/src/main/java/com/example/addressservice/entity/Address.java) - 实体类

**API接口**:

```
GET /addresses/{addressId}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| addressId | Long | 地址ID（路径参数） |

**响应示例**:
```json
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

**错误处理**:
- 地址不存在: 返回 `404 Not Found`

#### 2. User Service (用户服务)
**端口**: 8082  
**职责**: 通过OpenFeign调用Address Service提供统一的用户服务接口

**主要文件**:
- [UserController.java](user-service/src/main/java/com/example/userservice/controller/UserController.java) - REST控制器
- [UserService.java](user-service/src/main/java/com/example/userservice/service/UserService.java) - 业务逻辑
- [AddressServiceClient.java](user-service/src/main/java/com/example/userservice/client/AddressServiceClient.java) - Feign客户端
- [AddressDTO.java](user-service/src/main/java/com/example/userservice/dto/AddressDTO.java) - 数据传输对象

**API接口**:

```
GET /users/address/{addressId}
```

**响应示例**:
```json
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

---

## OpenFeign 声明式客户端

### 核心特性

OpenFeign 是一个声明式的HTTP客户端，提供了优雅的接口定义方式：

```java
@FeignClient(name = "address-service")
public interface AddressServiceClient {
    @GetMapping("/addresses/{addressId}")
    AddressDTO getAddress(@PathVariable("addressId") Long addressId);
}
```

### 关键注解说明

| 注解 | 位置 | 说明 |
|------|------|------|
| `@FeignClient` | 接口 | 声明Feign客户端，`name`为服务名称 |
| `@GetMapping` | 方法 | 指定HTTP GET请求 |
| `@PathVariable` | 参数 | 映射URL路径变量 |

### 工作流程

```
User Service 
    ↓
UserController (/users/address/{id})
    ↓
UserService.getUserAddress()
    ↓
AddressServiceClient.getAddress() [Feign客户端]
    ↓
Nacos Service Discovery [服务发现]
    ↓
Address Service (8081)
```

---

## Nacos 服务注册与发现

### 工作原理

1. **服务注册**: 两个微服务启动时自动向Nacos注册
2. **服务发现**: Feign通过Nacos查找到address-service的地址
3. **负载均衡**: Feign集成的Ribbon进行客户端负载均衡

### 配置文件示例

```yaml
spring:
  application:
    name: address-service          # 服务名称
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 # Nacos服务器地址
        namespace: public           # 命名空间
        group: DEFAULT_GROUP        # 分组
```

### 查看注册的服务

访问Nacos Web控制台: http://localhost:8848/nacos

默认用户名/密码: `nacos` / `nacos`

导航路径: 服务管理 → 服务列表

---

## 项目代码结构

```
homework2/
├── pom.xml                                          # 父POM（依赖管理）
├── docker-compose.yml                              # Docker Compose配置
├── README.md                                        # 项目概览
├── DEVELOPMENT.md                                  # 本文件
├── test-api.sh                                     # API测试脚本
│
├── address-service/                                # 地址服务模块
│   ├── pom.xml                                     # 服务依赖配置
│   └── src/main/
│       ├── java/com/example/addressservice/
│       │   ├── AddressServiceApplication.java      # 启动类 (@SpringBootApplication, @EnableDiscoveryClient)
│       │   ├── controller/
│       │   │   └── AddressController.java          # REST控制器 (@RestController, @GetMapping)
│       │   ├── service/
│       │   │   └── AddressService.java             # 业务逻辑 (@Service)
│       │   └── entity/
│       │       └── Address.java                    # 实体类
│       └── resources/
│           └── application.yml                     # 应用配置
│
├── user-service/                                   # 用户服务模块
│   ├── pom.xml                                     # 服务依赖配置
│   └── src/main/
│       ├── java/com/example/userservice/
│       │   ├── UserServiceApplication.java         # 启动类 (@SpringBootApplication, @EnableDiscoveryClient, @EnableFeignClients)
│       │   ├── controller/
│       │   │   └── UserController.java             # REST控制器
│       │   ├── service/
│       │   │   └── UserService.java                # 业务逻辑
│       │   ├── client/
│       │   │   └── AddressServiceClient.java       # Feign客户端 (@FeignClient)
│       │   └── dto/
│       │       └── AddressDTO.java                 # 数据传输对象
│       └── resources/
│           └── application.yml                     # 应用配置
│
├── scripts/                                        # 管理脚本
│   ├── startup.sh                                  # 启动脚本
│   └── shutdown.sh                                 # 关闭脚本
│
└── logs/                                           # 日志目录
    ├── address-service.log                         # Address Service日志
    └── user-service.log                            # User Service日志
```

---

## 核心依赖版本

| 依赖 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 2.7.14 | 应用框架 |
| Spring Cloud | 2021.0.8 | 微服务框架 |
| Spring Cloud OpenFeign | - | 声明式HTTP客户端 |
| Spring Cloud Alibaba | 2021.0.4.0 | 阿里巴巴集成 |
| Nacos Client | 2.1.0 | 服务发现和配置 |
| Ribbon | - | 客户端负载均衡 |

---

## 开发指南

### 添加新的API接口

#### 在Address Service中添加

1. 在`AddressService.java`中添加业务方法:
```java
public Address findByUserId(Long userId) {
    return addressMap.values().stream()
        .filter(addr -> addr.getUserId().equals(userId))
        .findFirst()
        .orElse(null);
}
```

2. 在`AddressController.java`中添加接口:
```java
@GetMapping("/users/{userId}")
public ResponseEntity<Address> getAddressByUserId(@PathVariable Long userId) {
    Address address = addressService.findByUserId(userId);
    if (address == null) {
        return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(address);
}
```

#### 在User Service中调用

1. 在`AddressServiceClient.java`中添加Feign方法:
```java
@GetMapping("/addresses/users/{userId}")
AddressDTO getAddressByUserId(@PathVariable("userId") Long userId);
```

2. 在`UserService.java`中使用:
```java
public AddressDTO getUserAddressByUserId(Long userId) {
    return addressServiceClient.getAddressByUserId(userId);
}
```

3. 在`UserController.java`中暴露接口:
```java
@GetMapping("/user/{userId}/address")
public ResponseEntity<AddressDTO> getUserAddressByUserId(@PathVariable Long userId) {
    AddressDTO address = userService.getUserAddressByUserId(userId);
    return ResponseEntity.ok(address);
}
```

### 添加数据库支持

1. 添加数据库依赖（在pom.xml中）:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
```

2. 创建Repository:
```java
@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByUserId(Long userId);
}
```

3. 修改Service使用Repository替代静态数据

### 添加全局异常处理

创建`GlobalExceptionHandler.java`:
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException e) {
        Map<String, String> error = new HashMap<>();
        error.put("error", e.getMessage());
        return ResponseEntity.status(500).body(error);
    }
}
```

### 配置Feign超时

在user-service的`application.yml`中:
```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 5000      # 连接超时（毫秒）
        readTimeout: 5000         # 读取超时（毫秒）
      address-service:            # 特定服务配置
        connectTimeout: 3000
        readTimeout: 3000
```

---

## 常见问题与解决方案

### Q1: Feign调用失败，提示"address-service not found"

**原因**: Nacos服务发现未正常工作

**解决方案**:
1. 确认Nacos正在运行: `curl http://localhost:8848/nacos/v1/console/health/readiness`
2. 查看user-service日志: `tail -f logs/user-service.log | grep -i nacos`
3. 确认address-service已在Nacos中注册

### Q2: 端口被占用

**症状**: 启动脚本报告端口已在使用

**解决方案**:
```bash
# 查看占用的进程
lsof -i :8081   # Address Service
lsof -i :8082   # User Service
lsof -i :8848   # Nacos

# 杀死进程
kill -9 <PID>
```

### Q3: Docker Compose启动失败

**症状**: `docker-compose up -d` 出错

**解决方案**:
```bash
# 检查Docker状态
docker ps

# 清理已停止的容器
docker-compose down

# 重新启动
docker-compose up -d
```

### Q4: 修改后的代码未生效

**原因**: 需要重新编译和打包

**解决方案**:
```bash
# 关闭服务
./scripts/shutdown.sh

# 重新编译打包
mvn clean package -DskipTests

# 启动服务
./scripts/startup.sh
```

---

## 性能优化建议

### 1. 连接池优化
在application.yml中配置:
```yaml
feign:
  httpclient:
    enabled: true  # 启用Apache HttpClient
```

### 2. 缓存优化
添加缓存依赖:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

使用`@Cacheable`注解缓存address查询结果

### 3. 熔断器
集成Hystrix进行服务容错:
```java
@FeignClient(name = "address-service", fallback = AddressServiceClientFallback.class)
```

---

## 部署建议

### 使用Docker部署

1. 创建Dockerfile:
```dockerfile
FROM openjdk:8-jdk-alpine
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

2. 使用Docker Compose部署:
```yaml
version: '3'
services:
  address-service:
    build: ./address-service
    ports:
      - "8081:8081"
  user-service:
    build: ./user-service
    ports:
      - "8082:8082"
```

### 使用Kubernetes部署

创建deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: address-service
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: address-service
        image: address-service:latest
        ports:
        - containerPort: 8081
```

---

## 监控与日志

### 查看实时日志

```bash
# Address Service
tail -f logs/address-service.log

# User Service
tail -f logs/user-service.log

# 搜索错误
grep ERROR logs/*.log

# 搜索特定关键词
grep -i "feign" logs/*.log
```

### 性能指标收集

可以集成Micrometer和Prometheus:
```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

访问: http://localhost:8081/actuator/prometheus

---

## 测试

### 单元测试示例

```java
@SpringBootTest
public class AddressServiceTest {
    
    @Autowired
    private AddressService addressService;
    
    @Test
    public void testGetAddressById() {
        Address address = addressService.getAddressById(1L);
        assertNotNull(address);
        assertEquals("张三", address.getReceiverName());
    }
}
```

### 集成测试

```bash
# 运行所有测试
mvn test

# 运行特定测试
mvn test -Dtest=AddressServiceTest
```

---

## 参考资源

- [Spring Cloud OpenFeign官方文档](https://spring.io/projects/spring-cloud-openfeign)
- [Nacos官方文档](https://nacos.io/zh-cn/)
- [Spring Cloud官方文档](https://spring.io/projects/spring-cloud)
- [Spring Boot官方文档](https://spring.io/projects/spring-boot)

---

## 更新日期

2025-12-28

## 许可证

MIT
