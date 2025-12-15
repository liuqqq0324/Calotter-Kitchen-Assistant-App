# Spring Boot 请求流程图（简化版）

## 📊 完整流程图

```
┌─────────────────────────────────────────────────────────────────┐
│  1. 前端发送请求                                                │
│     PUT /api/kitchen/inventory/123                             │
│     Headers: Authorization: Bearer <token>                     │
│     Body: { "quantity": 500, "unit": "g" }                     │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. Tomcat 服务器接收（端口 8080）                              │
│     文件: application.yml (server.port)                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. Spring Security Filter Chain                               │
│     ┌─────────────────────────────────────┐                    │
│     │ 3.1 CORS Filter                     │                    │
│     │ 文件: SecurityConfig.java           │                    │
│     │ 检查跨域是否允许                     │                    │
│     └─────────────────────────────────────┘                    │
│                            ↓                                    │
│     ┌─────────────────────────────────────┐                    │
│     │ 3.2 JWT Authentication Filter      │                    │
│     │ 文件: JwtAuthenticationFilter.java │                    │
│     │ 1. 提取 Authorization header       │                    │
│     │ 2. 调用 JwtService.validateToken() │                    │
│     │ 3. 提取 userId 存入 SecurityContext│                    │
│     └─────────────────────────────────────┘                    │
│                            ↓                                    │
│     ┌─────────────────────────────────────┐                    │
│     │ 3.3 Authorization Check            │                    │
│     │ 文件: SecurityConfig.java           │                    │
│     │ 检查用户是否有权限访问               │                    │
│     └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. DispatcherServlet（Spring MVC 核心）                       │
│     根据路径和方法匹配对应的 Controller                          │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  5. Controller 层                                              │
│     文件: KitchenController.java（需要创建）                     │
│     ┌─────────────────────────────────────┐                    │
│     │ @PutMapping("/inventory/{id}")      │                    │
│     │ public ResponseEntity update(...) {  │                    │
│     │   1. 接收参数                        │                    │
│     │   2. 调用 Service                    │                    │
│     │   3. 返回响应                        │                    │
│     └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  6. Service 层（业务逻辑）                                      │
│     文件: InventoryService.java（需要创建）                     │
│     ┌─────────────────────────────────────┐                    │
│     │ public InventoryItem update(...) {  │                    │
│     │   1. 验证权限                        │                    │
│     │   2. 业务逻辑处理                     │                    │
│     │   3. 调用 Repository                │                    │
│     └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  7. Repository 层（数据访问）                                  │
│     文件: InventoryRepository.java（需要创建）                  │
│     ┌─────────────────────────────────────┐                    │
│     │ JPA 自动实现方法                    │                    │
│     │ - findById()                       │                    │
│     │ - save()                           │                    │
│     └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  8. Entity 层（数据库映射）                                    │
│     文件: InventoryItem.java（已存在）                          │
│     @Entity 注解映射到数据库表                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  9. 数据库（PostgreSQL）                                        │
│     文件: application.yml, docker-compose.yml                   │
│     ┌─────────────────────────────────────┐                    │
│     │ UPDATE inventory_items               │                    │
│     │ SET quantity = 500                   │                    │
│     │ WHERE id = 123;                      │                    │
│     └─────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                    【响应反向返回】
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  响应流程（反向）                                               │
│  数据库 → Repository → Service → Controller → Filter → 前端    │
└─────────────────────────────────────────────────────────────────┘
```

## 🔑 关键文件位置

```
backend-java/
├── src/main/java/com/souschef/
│   ├── config/
│   │   ├── SecurityConfig.java          ← 3.1, 3.3 安全配置
│   │   └── JwtAuthenticationFilter.java ← 3.2 JWT 认证
│   │
│   ├── controller/                      ← 5. Controller 层
│   │   ├── AuthController.java
│   │   ├── UserController.java
│   │   └── KitchenController.java      ← 需要创建（示例）
│   │
│   ├── service/                        ← 6. Service 层
│   │   ├── JwtService.java             ← 3.2 中使用
│   │   └── InventoryService.java      ← 需要创建（示例）
│   │
│   ├── repository/                     ← 7. Repository 层
│   │   ├── UserRepository.java
│   │   └── InventoryRepository.java    ← 需要创建（示例）
│   │
│   └── entity/                        ← 8. Entity 层
│       ├── User.java
│       ├── Kitchen.java
│       └── InventoryItem.java
│
└── src/main/resources/
    └── application.yml                 ← 2. 配置文件
```

## 📝 代码示例（完整实现）

### Controller 示例
```java
@RestController
@RequestMapping("/api/kitchen")
public class KitchenController {
    
    @Autowired
    private InventoryService inventoryService;
    
    @PutMapping("/inventory/{inventoryId}")
    public ResponseEntity<?> updateInventoryItem(
            @PathVariable Integer inventoryId,
            @RequestBody UpdateInventoryRequest request,
            HttpServletRequest httpRequest) {
        
        // 从 JWT token 获取用户ID
        Long userId = getCurrentUserId(httpRequest);
        
        // 调用 Service
        InventoryItem item = inventoryService.updateInventoryItem(
            inventoryId, userId, request);
        
        return ResponseEntity.ok(item);
    }
}
```

### Service 示例
```java
@Service
public class InventoryService {
    
    @Autowired
    private InventoryRepository inventoryRepository;
    
    public InventoryItem updateInventoryItem(
            Integer inventoryId, 
            Long userId, 
            UpdateInventoryRequest request) {
        
        // 1. 查找库存项
        InventoryItem item = inventoryRepository.findById(inventoryId)
            .orElseThrow(() -> new NotFoundException("Not found"));
        
        // 2. 验证权限（确保是用户的库存）
        if (!item.getKitchen().getUserId().equals(userId)) {
            throw new UnauthorizedException("Not your item");
        }
        
        // 3. 更新数据
        item.setQuantity(request.getQuantity());
        item.setUnit(request.getUnit());
        
        // 4. 保存
        return inventoryRepository.save(item);
    }
}
```

### Repository 示例
```java
@Repository
public interface InventoryRepository 
    extends JpaRepository<InventoryItem, Integer> {
    // JPA 自动提供 findById(), save(), delete() 等方法
}
```

## 🎓 学习要点

1. **请求先经过 Filter，再到 Controller**
2. **Controller 只负责接收请求和返回响应**
3. **Service 处理业务逻辑，不直接操作数据库**
4. **Repository 负责数据访问，使用 JPA 自动生成 SQL**
5. **Entity 类定义了数据库表结构**

