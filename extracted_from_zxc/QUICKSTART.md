# 快速参考指南 (Quick Reference)

## 🚀 60秒快速开始

```bash
# 1. 进入项目目录
cd /workspaces/homework2

# 2. 给脚本添加执行权限
chmod +x scripts/*.sh test-api.sh

# 3. 启动所有服务
./scripts/startup.sh

# 4. 等待15秒服务启动

# 5. 测试API
curl http://localhost:8081/addresses/1
curl http://localhost:8082/users/address/1

# 6. 关闭所有服务
./scripts/shutdown.sh
```

---

## 📍 服务访问地址

| 服务 | URL | 端口 |
|------|-----|------|
| Address Service | http://localhost:8081 | 8081 |
| User Service | http://localhost:8082 | 8082 |
| Nacos控制台 | http://localhost:8848/nacos | 8848 |

---

## 📌 核心API接口

### Address Service

**查询单个地址**
```
GET http://localhost:8081/addresses/{addressId}
```

示例:
```bash
curl http://localhost:8081/addresses/1
```

响应:
```json
{
    "addressId": 1,
    "userId": 100,
    "receiverName": "张三",
    "phone": "13800000001",
    "fullAddress": "北京市朝阳区某街道123号"
}
```

### User Service

**通过Feign查询地址**
```
GET http://localhost:8082/users/address/{addressId}
```

示例:
```bash
curl http://localhost:8082/users/address/1
```

响应: (同Address Service)
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

## 🔑 关键代码片段

### OpenFeign客户端声明

```java
@FeignClient(name = "address-service")
public interface AddressServiceClient {
    @GetMapping("/addresses/{addressId}")
    AddressDTO getAddress(@PathVariable("addressId") Long addressId);
}
```

### 启用Feign

```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients  // ← 必须添加
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

### Nacos配置

```yaml
spring:
  application:
    name: address-service          # 服务名称
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 # Nacos地址
```

---

## 🛠️ 常用命令

### 编译
```bash
mvn clean compile
```

### 打包
```bash
mvn clean package -DskipTests
```

### 查看日志
```bash
# Address Service
tail -f logs/address-service.log

# User Service
tail -f logs/user-service.log
```

### 查找错误
```bash
grep ERROR logs/*.log
```

### 查看进程
```bash
ps aux | grep java | grep -v grep
```

### 杀死进程
```bash
# 杀死address-service
pkill -f "address-service-1.0.0.jar"

# 杀死user-service
pkill -f "user-service-1.0.0.jar"
```

### Docker命令
```bash
# 启动Nacos
docker-compose up -d

# 停止Nacos
docker-compose down

# 查看日志
docker-compose logs -f nacos
```

---

## 🧪 测试数据

内置4条模拟地址数据:

| ID | 姓名 | 电话 | 地址 |
|----|------|------|------|
| 1 | 张三 | 13800000001 | 北京市朝阳区某街道123号 |
| 2 | 李四 | 13800000002 | 上海市浦东新区某大厦456号 |
| 3 | 王五 | 13800000003 | 深圳市南山区某商厦789号 |
| 4 | 陈六 | 13800000004 | 杭州市西湖区某街道321号 |

测试不存在的地址: `curl http://localhost:8081/addresses/999` (返回404)

---

## 🐛 故障排查

### 问题: Feign调用失败

**检查步骤**:
```bash
# 1. 确认Nacos运行
curl http://localhost:8848/nacos/v1/console/health/readiness

# 2. 查看服务注册
curl http://localhost:8848/nacos/v1/ns/service/list

# 3. 查看user-service日志
tail -20 logs/user-service.log | grep -i feign
```

### 问题: 端口被占用

```bash
# 查看占用的进程
lsof -i :8081   # Address Service
lsof -i :8082   # User Service
lsof -i :8848   # Nacos

# 杀死进程
kill -9 <PID>
```

### 问题: 编译失败

```bash
# 清理maven缓存
rm -rf ~/.m2/repository/

# 重新编译
mvn clean compile -DskipTests
```

---

## 📚 项目文档导航

| 文档 | 用途 |
|------|------|
| [README.md](README.md) | 项目概览和功能说明 |
| [DEVELOPMENT.md](DEVELOPMENT.md) | 详细开发指南 |
| [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | 文件结构和实现细节 |
| [QUICKSTART.md](QUICKSTART.md) | 本文档 |

---

## 🔗 文件导航

### 必看的3个核心文件

1. **OpenFeign客户端** (最重要)
   - 文件: `user-service/src/main/java/com/example/userservice/client/AddressServiceClient.java`
   - 说明: OpenFeign的声明式客户端实现

2. **启动类**
   - Address: `address-service/src/main/java/com/example/addressservice/AddressServiceApplication.java`
   - User: `user-service/src/main/java/com/example/userservice/UserServiceApplication.java`
   - 说明: 注意@EnableDiscoveryClient和@EnableFeignClients注解

3. **配置文件**
   - Address: `address-service/src/main/resources/application.yml`
   - User: `user-service/src/main/resources/application.yml`
   - 说明: Nacos服务发现配置

---

## 💡 常见操作

### 添加新的模拟地址

编辑: `address-service/src/main/java/.../AddressService.java`

```java
static {
    // 添加新数据
    addressMap.put(5L, new Address(5L, 103L, "新用户", "13800000005", "新地址"));
}
```

然后重启服务。

### 修改服务端口

编辑 `application.yml`:
```yaml
server:
  port: 9081  # 改为新端口
```

### 修改Nacos地址

编辑 `application.yml`:
```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 新的IP:8848
```

---

## 📊 项目统计

```
总文件数:        23
├─ Java文件:     9
├─ YAML配置:     5  
├─ POM配置:      3
├─ 文档:         3
└─ 脚本:         3

代码行数:        ~500
Java代码:        ~250
XML配置:         ~150
文档:            ~100+

微服务数:        2
REST接口:        3
模拟数据:        4条
```

---

## 🎓 学习要点

完成本项目你将学到:

✅ Spring Cloud OpenFeign的声明式客户端用法  
✅ Nacos服务注册与服务发现机制  
✅ 微服务间的同步调用方式  
✅ Spring Boot 2.7的核心特性  
✅ Maven多模块项目管理  
✅ Docker Compose容器编排  
✅ RESTful API设计最佳实践  
✅ 微服务故障排查技巧  

---

## 🔄 完整工作流程

```
1. 启动脚本
   └─> docker-compose up -d (启动Nacos)
   └─> java -jar address-service.jar (启动地址服务)
   └─> java -jar user-service.jar (启动用户服务)

2. 服务启动
   └─> address-service向Nacos注册
   └─> user-service向Nacos注册

3. 客户端请求
   └─> curl /users/address/1
   └─> UserController处理请求
   └─> UserService调用AddressServiceClient

4. Feign调用
   └─> Feign查询Nacos获取address-service地址
   └─> 发送HTTP GET请求到address-service
   └─> AddressController返回Address数据

5. 响应返回
   └─> UserService接收AddressDTO
   └─> UserController返回给客户端
   └─> 客户端收到完整地址信息
```

---

## 📞 获取帮助

**查看Nacos控制台**:
```
http://localhost:8848/nacos
用户名: nacos
密码: nacos
```

**查看服务列表**:
```bash
curl http://localhost:8848/nacos/v1/ns/service/list | jq .
```

**查看服务实例**:
```bash
curl 'http://localhost:8848/nacos/v1/ns/instances?serviceName=address-service' | jq .
```

**查看应用日志**:
```bash
# 实时查看日志
tail -f logs/address-service.log
tail -f logs/user-service.log

# 搜索特定内容
grep "ERROR\|WARN" logs/*.log
grep "Feign" logs/*.log
```

---

## 版本信息

```
项目版本:       1.0.0
Spring Boot:    2.7.14
Spring Cloud:   2021.0.8
Java:           8+
Nacos:          2.1.0
创建日期:       2025-12-28
```

---

**快速开始**: `./scripts/startup.sh`  
**测试API**: `./test-api.sh`  
**关闭服务**: `./scripts/shutdown.sh`

祝你使用愉快! 🎉
