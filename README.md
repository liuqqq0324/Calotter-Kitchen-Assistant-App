# Personal Sous Chef

个人厨师助手应用 - 一个全栈移动应用项目。

## 项目结构

- `frontend-app/` - Flutter 移动应用前端
- `backend-api/` - 后端 API 服务
- `ai-engine/` - AI 引擎服务
- `database/` - 数据库初始化脚本
- `docs/` - 项目文档

## 快速开始

**📖 详细启动指南：请查看 [启动指南.md](启动指南.md) 或 [STARTUP_GUIDE.md](STARTUP_GUIDE.md)**

### 简要步骤

1. **安装前置要求**
   - Docker Desktop（用于 PostgreSQL 数据库）
   - .NET SDK 10.0（用于 C# 后端）
   - Flutter SDK 3.10.1+（用于 Flutter 前端）
   - Android Studio（用于 Android 模拟器）

2. **启动数据库**
   ```bash
   docker-compose up -d postgres
   ```

3. **启动后端服务**
   ```bash
   cd backend-csharp
   dotnet restore  # 首次运行需要
   dotnet run
   ```

4. **启动前端应用**
   ```bash
   cd frontend-app
   flutter pub get  # 首次运行需要
   flutter run
   ```

**⚠️ 重要提示：** 请按照 [启动指南.md](启动指南.md) 中的详细步骤操作，确保所有服务按正确顺序启动。

## 文档

- [开发进度 / Development Progress](docs/开发进度%20-%20Development%20Progress.md) - 当前开发进度和要点记录
- [环境设置指南](docs/环境设置指南.md) - 完整的环境设置和操作说明
- [需求文档](docs/Personal%20Sous%20Chef%20Proposal%20-%20FRs%20and%20NFRs.md) - 功能需求和非功能需求
- [数据交换格式](docs/Personal%20Chef%20Data%20Exchange%20JSON%20Format.md) - API 数据格式规范
- [Sprint 计划](docs/Sprint%201/Sprint%20Planning.md) - Sprint 1 计划文档

## 开发

当前分支：`chase/flutter-base-android`

## 许可证

[待添加]

