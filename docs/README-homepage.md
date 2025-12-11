# Homepage 文档索引

## 📂 文档结构

Homepage 相关文档已按版本分类整理：

```
docs/
├── homepage-backend-java/     # 旧版本（已废弃）
│   ├── README.md
│   ├── homepage-api-使用说明.md
│   ├── Homepage-API.postman_collection.json
│   ├── homepage-backend-implementation.md
│   ├── homepage-api.md
│   └── homepage-文档版本说明.md
│
└── homepage-calotter/          # 最新版本 ✅
    ├── README.md
    ├── calotter-homepage-使用说明.md
    ├── Calotter-Homepage-API.postman_collection.json
    ├── calotter-homepage-实现说明.md
    └── homepage-api.md
```

---

## 🎯 快速导航

### ✅ 使用 Calotter 版本（推荐）

👉 **查看**：`homepage-calotter/README.md`

**主要文档**：
- 📖 使用说明：`homepage-calotter/calotter-homepage-使用说明.md`
- 🧪 Postman 测试：`homepage-calotter/Calotter-Homepage-API.postman_collection.json`
- 🔧 实现说明：`homepage-calotter/calotter-homepage-实现说明.md`
- 📋 API 规范：`homepage-calotter/homepage-api.md`

### ⚠️ 参考 Backend-Java 版本（旧版）

👉 **查看**：`homepage-backend-java/README.md`

**注意**：这是旧版本，仅供参考，当前项目已不再使用。

---

## 📋 版本对比

| 项目 | Backend-Java（旧） | Calotter（新）✅ |
|------|-------------------|----------------|
| **端口** | 8080 | 10001 |
| **技术栈** | JPA + Repository | MyBatis Plus + Mapper |
| **代码位置** | `backend-java/` | `calotter/calotter-homepage/` |
| **响应格式** | 直接返回 DTO | `R<T>` 包装响应 |

---

## 🚀 快速开始

1. **阅读使用说明**：`homepage-calotter/calotter-homepage-使用说明.md`
2. **导入 Postman**：`homepage-calotter/Calotter-Homepage-API.postman_collection.json`
3. **查看实现细节**：`homepage-calotter/calotter-homepage-实现说明.md`

---

**最后更新**：2025-12-04
