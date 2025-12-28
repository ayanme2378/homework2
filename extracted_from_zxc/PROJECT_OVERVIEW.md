# 项目概览与关键文件说明

## 📋 核心实现清单

本项目实现了所有需求的功能：

### ✅ 需求1: 基于Spring Cloud OpenFeign实现微服务调用
- [x] Address Service (地址服务) - 实现完成
- [x] User Service (用户服务) - 实现完成
- [x] OpenFeign声明式客户端 - 禁用RestTemplate硬编码
- [x] 基于Nacos的服务注册与发现

### ✅ 需求2: Address Service接口定义与实现
- [x] GET /addresses/{addressId} - 根据地址ID查询单个收货地址
- [x] 返回数据字段: addressId, userId, receiverName, phone, fullAddress
- [x] 地址不存在返回404状态码
- [x] 内置模拟数据4条

### ✅ 需求3: User Service通过OpenFeign调用
- [x] OpenFeign声明式客户端实现 - AddressServiceClient.java
- [x] 基于服务名称调用(address-service)
- [x] GET /users/address/{addressId} - 接收地址ID并返回地址信息

### ✅ 需求4: 额外要求
- [x] Nacos服务注册中心配置
- [x] 两个微服务完成注册与发现
- [x] Feign基于服务名称调用
- [x] 代码结构规范
- [x] 配置文件完整

---

## 📁 关键文件说明

### 项目配置文件

#### `pom.xml` (父POM)
**作用**: 管理所有微服务的依赖版本  
**关键内容**:
- Spring Boot 2.7.14
- Spring Cloud 2021.0.8
- Spring Cloud Alibaba 2021.0.4.0 (Nacos支持)
- 公共依赖管理

```xml
<dependencyManagement>
    <!-- Spring Cloud依赖管理 -->
    <!-- Spring Cloud Alibaba依赖管理 -->
</dependencyManagement>
```

#### `docker-compose.yml`
**作用**: 定义和启动Nacos容器  
**关键服务**:
- nacos:standalone (单机模式)
- 端口: 8848 (HTTP), 9848/9849 (gRPC)
- 自动健康检查

---

### Address Service 微服务

#### 文件: `address-service/pom.xml`
**职责**: Address Service的依赖配置  
**核心依赖**:
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

#### 文件: `address-service/src/main/java/.../AddressServiceApplication.java`
**职责**: Spring Boot应用启动类  
**关键注解**:
```java
@SpringBootApplication
@EnableDiscoveryClient  // 启用Nacos服务发现
public class AddressServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AddressServiceApplication.class, args);
    }
}
```

#### 文件: `address-service/src/main/java/.../entity/Address.java`
**职责**: 地址数据模型  
**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| addressId | Long | 地址ID (主键) |
| userId | Long | 用户ID |
| receiverName | String | 收货人姓名 |
| phone | String | 电话号码 |
| fullAddress | String | 完整地址 |

**实现方式**: 
- 手动编写构造器（避免Lombok版本兼容问题）
- 提供完整的getter/setter方法
- toString()方法用于日志

#### 文件: `address-service/src/main/java/.../service/AddressService.java`
**职责**: 业务逻辑层  
**核心方法**:
```java
public Address getAddressById(Long addressId) {
    return addressMap.get(addressId);
}
```

**模拟数据**:
```
ID: 1 → 张三 (13800000001)
ID: 2 → 李四 (13800000002)
ID: 3 → 王五 (13800000003)
ID: 4 → 陈六 (13800000004)
```

#### 文件: `address-service/src/main/java/.../controller/AddressController.java`
**职责**: REST接口暴露  
**核心接口**:
```java
@RestController
@RequestMapping("/addresses")
public class AddressController {
    
    @GetMapping("/{addressId}")
    public ResponseEntity<Address> getAddress(@PathVariable Long addressId) {
        Address address = addressService.getAddressById(addressId);
        if (address == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(address);
    }
}
```

#### 文件: `address-service/src/main/resources/application.yml`
**职责**: 应用配置  
**关键配置**:
```yaml
server:
  port: 8081

spring:
  application:
    name: address-service              # 服务注册名称

  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848    # Nacos地址
```

---

### User Service 微服务

#### 文件: `user-service/pom.xml`
**职责**: User Service的依赖配置  
**额外依赖**:
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

#### 文件: `user-service/src/main/java/.../UserServiceApplication.java`
**职责**: Spring Boot应用启动类  
**关键注解**:
```java
@SpringBootApplication
@EnableDiscoveryClient      // 启用Nacos服务发现
@EnableFeignClients         // 启用Feign客户端
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

#### 📌 文件: `user-service/src/main/java/.../client/AddressServiceClient.java`
**职责**: OpenFeign声明式客户端 (核心文件)  
**实现特点**:
- 使用`@FeignClient`注解声明，基于服务名称调用
- 完全避免硬编码URL
- 自动集成Ribbon负载均衡
- 与Nacos集成实现服务发现

```java
@FeignClient(name = "address-service")
public interface AddressServiceClient {
    
    /**
     * 根据地址ID查询单个收货地址
     * 通过服务名称address-service进行调用
     */
    @GetMapping("/addresses/{addressId}")
    AddressDTO getAddress(@PathVariable("addressId") Long addressId);
}
```

**工作流程**:
1. User Service启动时向Nacos注册
2. Nacos中注册了address-service的实例信息
3. Feign拦截`@FeignClient`标注的接口
4. 运行时查询Nacos获取address-service的IP:PORT
5. 动态构造HTTP请求并发送
6. 自动反序列化响应为AddressDTO对象

#### 文件: `user-service/src/main/java/.../dto/AddressDTO.java`
**职责**: 数据传输对象  
**用途**: 
- 用于接收address-service的返回值
- 与Address实体类字段完全相同
- 通过HTTP JSON自动反序列化

```java
public class AddressDTO {
    private Long addressId;
    private Long userId;
    private String receiverName;
    private String phone;
    private String fullAddress;
    // getter/setter...
}
```

#### 文件: `user-service/src/main/java/.../service/UserService.java`
**职责**: 业务逻辑层  
**核心方法**:
```java
@Service
public class UserService {
    
    @Autowired
    private AddressServiceClient addressServiceClient;
    
    public AddressDTO getUserAddress(Long addressId) {
        // 调用address-service
        return addressServiceClient.getAddress(addressId);
    }
}
```

**特点**:
- 注入AddressServiceClient (Feign客户端)
- 直接调用Feign接口方法
- 自动处理HTTP通信

#### 文件: `user-service/src/main/java/.../controller/UserController.java`
**职责**: REST接口暴露  
**核心接口**:
```java
@RestController
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/address/{addressId}")
    public ResponseEntity<AddressDTO> getAddress(@PathVariable Long addressId) {
        try {
            AddressDTO address = userService.getUserAddress(addressId);
            return ResponseEntity.ok(address);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
```

#### 文件: `user-service/src/main/resources/application.yml`
**职责**: 应用配置  
**关键配置**:
```yaml
server:
  port: 8082

spring:
  application:
    name: user-service

  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
```

---

### 脚本和文档

#### 文件: `scripts/startup.sh`
**职责**: 自动化启动脚本  
**功能**:
1. 检查并编译项目（如需要）
2. 启动Nacos Docker容器
3. 等待Nacos就绪
4. 启动address-service (后台进程)
5. 启动user-service (后台进程)
6. 显示服务信息和测试命令

**使用方式**:
```bash
chmod +x scripts/startup.sh
./scripts/startup.sh
```

#### 文件: `scripts/shutdown.sh`
**职责**: 自动化关闭脚本  
**功能**:
1. 杀死address-service进程
2. 杀死user-service进程
3. 停止Nacos Docker容器

**使用方式**:
```bash
chmod +x scripts/shutdown.sh
./scripts/shutdown.sh
```

#### 文件: `test-api.sh`
**职责**: API功能测试脚本  
**测试项目**:
1. Address Service单个查询
2. Address Service不存在地址（404）
3. User Service通过Feign调用
4. User Service不存在地址（404）
5. 测试所有模拟数据
6. Nacos服务列表查询

**使用方式**:
```bash
chmod +x test-api.sh
./test-api.sh
```

#### 文件: `README.md`
**职责**: 项目概览文档  
**内容**:
- 项目简介
- 项目结构
- API功能说明
- 运行环境要求
- 快速开始指南
- 常见问题解答
- 技术栈说明

#### 文件: `DEVELOPMENT.md`
**职责**: 开发者详细指南  
**内容**:
- 快速开始（5分钟）
- 项目架构详解
- OpenFeign核心特性
- Nacos工作原理
- 代码结构详解
- 开发指南（如何添加功能）
- 问题排查指南
- 性能优化建议
- 部署建议

---

## 🔄 请求调用流程图

```
┌─────────────────────────────────────────────────────────────┐
│                   客户端 (curl / 浏览器)                      │
└──────────────────────────────┬────────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │                     │
                    │  Address Service    │  User Service
                    │   (端口: 8081)       │  (端口: 8082)
                    │                     │
                    │ GET /addresses/{id} │  GET /users/address/{id}
                    │                     │
                    │  AddressService     │  UserService
                    │  ├─ getAddressById()│  ├─ getUserAddress()
                    │  └─ addressMap      │  │  └─ 调用Feign客户端
                    │                     │  │
                    │                     │  AddressServiceClient
                    │                     │  (Feign客户端)
                    │                     │  @FeignClient(name="address-service")
                    │                     │
                    │                     │  ①.查询Nacos注册表
                    │                     │  ②.获取address-service地址
                    │                     │  ③.发送HTTP请求
                    │                     │  ④.解析JSON响应
                    │                     │  ⑤.返回AddressDTO对象
                    │                     │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼─────────────┐
                    │    Nacos Server       │
                    │   (端口: 8848)        │
                    │                       │
                    │ 服务注册表:            │
                    │ - address-service:8081│
                    │ - user-service:8082   │
                    └───────────────────────┘
```

---

## 🧪 API测试用例

### 场景1: 查询存在的地址
```bash
curl http://localhost:8081/addresses/1

# 预期响应 (200 OK)
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

### 场景2: 查询不存在的地址
```bash
curl -i http://localhost:8081/addresses/999

# 预期响应 (404 Not Found)
HTTP/1.1 404 Not Found
```

### 场景3: User Service通过Feign调用
```bash
curl http://localhost:8082/users/address/1

# 预期响应 (200 OK，数据由address-service返回)
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

### 场景4: 查看Nacos注册的服务
```bash
curl http://localhost:8848/nacos/v1/ns/service/list

# 预期响应包含:
{
    "doms": ["address-service", "user-service"],
    ...
}
```

---

## 📊 项目统计

| 指标 | 数值 |
|------|------|
| 微服务数量 | 2 个 |
| 接口数量 | 3 个 |
| Java文件数 | 10 个 |
| 配置文件 | 3 个 (2个application.yml + docker-compose.yml) |
| 依赖项 | 50+ 个 |
| 代码行数 | ~500 行 |
| 文档文件 | 3 个 (README + DEVELOPMENT + 本文件) |

---

## 🎯 下一步可能的扩展

1. **数据持久化**: 
   - 集成Spring Data JPA
   - 配置MySQL数据库
   - 实现AddressRepository

2. **服务容错**:
   - 集成Hystrix熔断器
   - 实现降级策略
   - 添加重试机制

3. **API网关**:
   - 部署Spring Cloud Gateway
   - 实现路由和限流

4. **分布式追踪**:
   - 集成Sleuth和Zipkin
   - 追踪请求链路

5. **消息队列**:
   - 集成RabbitMQ或Kafka
   - 实现异步通信

6. **认证授权**:
   - 添加Spring Security
   - 实现JWT令牌

7. **配置中心**:
   - 使用Nacos配置管理
   - 动态更新配置

8. **监控告警**:
   - 集成Prometheus
   - 配置Grafana仪表板

---

## 📝 文件清单

```
✓ pom.xml                                        # 父POM
✓ docker-compose.yml                            # Nacos容器
✓ README.md                                     # 项目概览
✓ DEVELOPMENT.md                                # 开发指南
✓ PROJECT_OVERVIEW.md                           # 本文件

address-service:
  ✓ pom.xml                                     # 服务POM
  ✓ AddressServiceApplication.java              # 启动类
  ✓ controller/AddressController.java           # 控制器
  ✓ service/AddressService.java                 # 业务逻辑
  ✓ entity/Address.java                         # 实体类
  ✓ application.yml                             # 配置

user-service:
  ✓ pom.xml                                     # 服务POM
  ✓ UserServiceApplication.java                 # 启动类
  ✓ controller/UserController.java              # 控制器
  ✓ service/UserService.java                    # 业务逻辑
  ✓ client/AddressServiceClient.java            # Feign客户端 ⭐
  ✓ dto/AddressDTO.java                         # DTO
  ✓ application.yml                             # 配置

scripts:
  ✓ startup.sh                                  # 启动脚本
  ✓ shutdown.sh                                 # 关闭脚本

other:
  ✓ test-api.sh                                 # API测试
```

---

## 总结

本项目是一个完整的Spring Cloud OpenFeign微服务示例，展示了：

✅ **OpenFeign声明式客户端** - 优雅地声明HTTP调用，无需硬编码URL  
✅ **Nacos服务注册与发现** - 自动化的服务管理  
✅ **微服务架构** - 独立部署和扩展  
✅ **标准REST接口** - 遵循RESTful规范  
✅ **完整的工程实践** - 配置、日志、文档齐全  

可直接用于学习或作为生产项目的参考模板。

---

最后更新: 2025-12-28
