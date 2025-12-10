# Homepage 文档版本说明

## 📋 文档组织结构

Homepage 相关文档已按版本分类整理到两个文件夹：

### 📁 `docs/homepage-backend-java/` - 旧版本（已废弃）

⚠️ **注意：这是旧版本，当前项目已不再使用**

包含文档：
- `homepage-api-使用说明.md` - 使用说明（端口 8080）
- `Homepage-API.postman_collection.json` - Postman 集合（端口 8080）
- `homepage-backend-implementation.md` - 实现说明
- `homepage-api.md` - API 规范（通用）
- `homepage-文档版本说明.md` - 版本说明
- `README.md` - 文件夹说明

**技术栈**：Spring Boot + JPA  
**代码位置**：`backend-java/`  
**端口**：8080

### 📁 `docs/homepage-calotter/` - 最新版本 ✅

✅ **当前推荐使用的版本**

包含文档：
- `calotter-homepage-使用说明.md` - 使用说明（端口 10001）✅
- `Calotter-Homepage-API.postman_collection.json` - Postman 集合（端口 10001）✅
- `calotter-homepage-实现说明.md` - 实现说明 ✅
- `homepage-api.md` - API 规范（通用）
- `README.md` - 文件夹说明

**技术栈**：Spring Boot + MyBatis Plus  
**代码位置**：`calotter/calotter-homepage/`  
**端口**：10001

---

## 🎯 推荐使用的文档

**如果你使用的是 calotter 项目（最新版本），请使用：**

📂 `docs/homepage-calotter/` 文件夹中的所有文档

1. ✅ **`homepage-calotter/calotter-homepage-使用说明.md`** - 详细的使用说明
2. ✅ **`homepage-calotter/Calotter-Homepage-API.postman_collection.json`** - Postman 测试集合
3. ✅ **`homepage-calotter/calotter-homepage-实现说明.md`** - 实现细节说明
4. ✅ **`homepage-calotter/homepage-api.md`** - API 接口规范

---

## ⚠️ 重要区别

### 端口
- **backend-java 版本**：8080
- **calotter 版本**：10001

### 技术栈
- **backend-java**：JPA + Repository
- **calotter**：MyBatis Plus + Mapper

### 文件路径
- **backend-java**：`backend-java/src/main/java/com/souschef/...`
- **calotter**：`calotter/calotter-homepage/src/main/java/com/calotter/homepage/...`

### 响应格式
- **backend-java**：直接返回 DTO 对象
- **calotter**：使用 `R<T>` 包装响应（`{"code": 200, "msg": "...", "data": {...}}`）

---

## 📝 使用建议

1. **新项目开发**：使用 `homepage-calotter/` 文件夹中的文档
2. **旧项目维护**：如需参考旧实现，可查看 `homepage-backend-java/` 文件夹
3. **API 规范**：两个版本都遵循 `homepage-api.md` 中的接口规范

---

**最后更新**：2025-12-04
