# Homepage 文档整理说明

## ✅ 整理完成

Homepage 相关文档已按版本分类整理到两个文件夹中。

---

## 📂 文件夹结构

```
docs/
├── homepage-backend-java/          # 旧版本（已废弃）
│   ├── README.md
│   ├── homepage-api-使用说明.md
│   ├── Homepage-API.postman_collection.json
│   ├── homepage-backend-implementation.md
│   ├── homepage-api.md
│   └── homepage-文档版本说明.md
│
├── homepage-calotter/               # 最新版本 ✅
│   ├── README.md
│   ├── calotter-homepage-使用说明.md
│   ├── Calotter-Homepage-API.postman_collection.json
│   ├── calotter-homepage-实现说明.md
│   └── homepage-api.md
│
├── homepage-文档版本说明.md        # 版本说明（根目录）
└── README-homepage.md              # 快速索引
```

---

## 📋 文件分类详情

### 🔵 Backend-Java 版本（旧版）

**位置**：`docs/homepage-backend-java/`

| 文件名 | 说明 | 状态 |
|--------|------|------|
| `README.md` | 文件夹说明 | ⚠️ 旧版 |
| `homepage-api-使用说明.md` | 使用说明文档 | ⚠️ 旧版 |
| `Homepage-API.postman_collection.json` | Postman 测试集合 | ⚠️ 旧版 |
| `homepage-backend-implementation.md` | 实现说明文档 | ⚠️ 旧版 |
| `homepage-api.md` | API 规范（通用） | 📄 通用 |
| `homepage-文档版本说明.md` | 版本说明 | 📄 说明 |

**技术信息**：
- 端口：8080
- 技术栈：Spring Boot + JPA
- 代码位置：`backend-java/`

### 🟢 Calotter 版本（最新）✅

**位置**：`docs/homepage-calotter/`

| 文件名 | 说明 | 状态 |
|--------|------|------|
| `README.md` | 文件夹说明 | ✅ 最新 |
| `calotter-homepage-使用说明.md` | 使用说明文档 | ✅ 最新 |
| `Calotter-Homepage-API.postman_collection.json` | Postman 测试集合 | ✅ 最新 |
| `calotter-homepage-实现说明.md` | 实现说明文档 | ✅ 最新 |
| `homepage-api.md` | API 规范（通用） | 📄 通用 |

**技术信息**：
- 端口：10001
- 技术栈：Spring Boot + MyBatis Plus
- 代码位置：`calotter/calotter-homepage/`

---

## 🎯 使用指南

### 推荐使用（Calotter 版本）

1. **查看使用说明**：
   ```
   docs/homepage-calotter/calotter-homepage-使用说明.md
   ```

2. **导入 Postman Collection**：
   ```
   docs/homepage-calotter/Calotter-Homepage-API.postman_collection.json
   ```

3. **查看实现细节**：
   ```
   docs/homepage-calotter/calotter-homepage-实现说明.md
   ```

4. **查看 API 规范**：
   ```
   docs/homepage-calotter/homepage-api.md
   ```

### 参考旧版本（Backend-Java）

如需参考旧版本实现，可查看：
```
docs/homepage-backend-java/
```

---

## 📝 主要区别

| 项目 | Backend-Java | Calotter ✅ |
|------|--------------|------------|
| **端口** | 8080 | 10001 |
| **技术栈** | JPA + Repository | MyBatis Plus + Mapper |
| **代码路径** | `backend-java/src/...` | `calotter/calotter-homepage/src/...` |
| **响应格式** | 直接返回 DTO | `R<T>` 包装 |
| **数据库访问** | JPA Repository | MyBatis Plus Mapper |

---

## 🔗 相关文档

- **版本说明**：`docs/homepage-文档版本说明.md`
- **快速索引**：`docs/README-homepage.md`
- **Backend-Java 说明**：`docs/homepage-backend-java/README.md`
- **Calotter 说明**：`docs/homepage-calotter/README.md`

---

**整理完成时间**：2025-12-04
