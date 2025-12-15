# Homepage 文档版本说明

## 📋 文档版本对应关系

目前关于 Homepage 的文档分为两个版本：

### 🔵 Backend-Java 版本（旧版本）

以下文档是针对 `backend-java` 文件夹下的实现：

1. **`homepage-api-使用说明.md`**
   - 路径：`docs/homepage-api-使用说明.md`
   - 针对：`backend-java` 模块
   - 端口：8080
   - 技术栈：Spring Boot + JPA
   - 状态：⚠️ **旧版本，已不再使用**

2. **`Homepage-API.postman_collection.json`**
   - 路径：`docs/Homepage-API.postman_collection.json`
   - 针对：`backend-java` 模块
   - 端口：8080
   - 状态：⚠️ **旧版本，已不再使用**

3. **`homepage-backend-implementation.md`**
   - 路径：`docs/homepage-backend-implementation.md`
   - 针对：通用实现说明（主要基于 backend-java）
   - 状态：⚠️ **参考文档，已过时**

### 🟢 Calotter 版本（最新版本）✅

以下文档是针对 `calotter` 文件夹下的最新实现：

1. **`calotter-homepage-使用说明.md`** ✅
   - 路径：`docs/calotter-homepage-使用说明.md`
   - 针对：`calotter/calotter-homepage` 模块
   - 端口：10001
   - 技术栈：Spring Boot + MyBatis Plus
   - 状态：✅ **最新版本，推荐使用**

2. **`Calotter-Homepage-API.postman_collection.json`** ✅
   - 路径：`docs/Calotter-Homepage-API.postman_collection.json`
   - 针对：`calotter/calotter-homepage` 模块
   - 端口：10001
   - 状态：✅ **最新版本，推荐使用**

3. **`calotter-homepage-实现说明.md`** ✅
   - 路径：`docs/calotter-homepage-实现说明.md`
   - 针对：`calotter/calotter-homepage` 模块
   - 状态：✅ **最新版本，推荐使用**

### 📄 API 规范文档（通用）

1. **`homepage-api.md`**
   - 路径：`docs/homepage-api.md`
   - 说明：API 接口规范文档，两个版本都遵循此规范
   - 状态：✅ **通用文档，两个版本都适用**

---

## 🎯 推荐使用的文档

**如果你使用的是 calotter 项目（最新版本），请使用以下文档：**

1. ✅ **`docs/calotter-homepage-使用说明.md`** - 详细的使用说明
2. ✅ **`docs/Calotter-Homepage-API.postman_collection.json`** - Postman 测试集合
3. ✅ **`docs/calotter-homepage-实现说明.md`** - 实现细节说明
4. ✅ **`docs/homepage-api.md`** - API 接口规范

---

## ⚠️ 注意事项

1. **不要混用文档**：backend-java 版本的文档和 calotter 版本的文档不能混用
2. **端口不同**：
   - backend-java 版本：8080
   - calotter 版本：10001
3. **技术栈不同**：
   - backend-java：JPA + Repository
   - calotter：MyBatis Plus + Mapper
4. **文件路径不同**：
   - backend-java：`backend-java/src/main/java/com/souschef/...`
   - calotter：`calotter/calotter-homepage/src/main/java/com/calotter/homepage/...`

---

## 📝 建议

如果项目已经切换到 calotter 版本，建议：

1. **保留旧文档**：可以保留 backend-java 版本的文档作为参考，但应明确标记为"旧版本"
2. **更新文档标题**：在旧文档开头添加"⚠️ 旧版本 - 已废弃"标记
3. **统一使用新文档**：所有新功能开发和使用都应参考 calotter 版本的文档

---

**最后更新**：2025-12-04
