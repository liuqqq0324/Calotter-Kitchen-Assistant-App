# Personal Sous Chef

个人厨师助手应用 - 一个全栈移动应用项目。

## 项目结构

- `frontend-app/` - Flutter 移动应用前端
- `backend-api/` - 后端 API 服务
- `ai-engine/` - AI 引擎服务
- `database/` - 数据库初始化脚本
- `docs/` - 项目文档

## 快速开始

**详细的环境设置和操作指南，请查看：[环境设置指南](docs/环境设置指南.md)**

### 简要步骤

1. **安装前置要求**
   - Flutter SDK (3.10.1+)
   - Docker 和 Docker Compose
   - Python 3.11+ (AI 引擎需要)

2. **设置 Flutter 前端**
   ```bash
   cd frontend-app
   flutter pub get
   ```

3. **启动后端服务**
   ```bash
   docker-compose up -d
   ```

4. **运行 Flutter 应用**
   ```bash
   cd frontend-app
   flutter run
   ```

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

