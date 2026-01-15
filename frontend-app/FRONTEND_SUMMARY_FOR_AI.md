# CalOtter 前端项目简介（给 AI 的版本）

## 项目概述
CalOtter 是一个智能厨房助手 Flutter 应用，采用手绘风格设计。

## 技术栈
- **框架**: Flutter 3.10+
- **语言**: Dart
- **平台**: iOS, Android, Web, macOS
- **设计**: 手绘风格（Caveat 手写字体）
- **品牌**: 🦦 CalOtter

## 核心功能（5大模块）

### 1. 用户管理系统（UMS）
- 登录/注册（LandingPage, LoginPage, RegistrationPage）
- 用户资料管理（ProfileViewPage, ProfileEditPage）
- 偏好设置（饮食习惯、过敏信息）

### 2. 库存管理
- 文件：`pages/inventory/inventory_page.dart`
- 功能：管理食材、调料、厨具
- 特色：
  - YOLO 图像识别扫描食材
  - 过期/临期提醒
  - 支持多种单位（g, ml, pcs）

### 3. 食谱系统
- 文件：`pages/recipes/recipes_home_page.dart`
- 功能：
  - AI 生成食谱（基于库存）
  - 分步烹饪指导（RecipeInstructionPage）
  - 语音控制（烹饪时免手操作）
  - 手势识别（Google ML Kit）
  - 收藏管理

### 4. 首页
- 文件：`pages/home/home_page.dart`
- 功能：营养追踪、今日食谱推荐、快速添加食材

### 5. 家庭共享
- 文件：`pages/household/`
- 功能：二维码邀请、多人协同管理库存

## 项目结构

```
lib/
├── pages/          # 19个页面
│   ├── ums/       # 用户管理（7个页面）
│   ├── home/      # 首页
│   ├── recipes/   # 食谱（5个页面）
│   ├── inventory/ # 库存（2个页面）
│   ├── add_item/  # 添加物品（2个页面）
│   └── household/ # 家庭管理（2个页面）
├── services/      # 12个 API 服务
├── widgets/       # 14个自定义组件
├── models/        # 4个数据模型
└── data/          # Mock 数据和本地存储
```

## 关键服务（12个）

| 服务 | 功能 |
|------|------|
| AuthService | 登录、注册、登出 |
| UserService | 用户资料管理 |
| InventoryApiService | 库存 CRUD |
| RecipeApiService | 食谱生成、查询 |
| FavoriteRecipesApiService | 收藏管理 |
| HomepageApiService | 首页数据 |
| HouseholdService | 家庭管理 |
| YoloService | 图像识别 |
| CookingVoiceAssistant | 语音助手 |
| CookingGestureControl | 手势控制 |
| StandardLibraryService | 标准食材库 |
| CookingApiService | 烹饪相关 |

## 核心数据模型

### Ingredient（食材）
```dart
{
  name: String,          // 名称
  expiryDate: DateTime,  // 过期时间
  quantity: double,      // 数量
  unit: String,          // 单位
  inventoryId: String?,  // 后端 ID
  isExpired: bool,       // 是否过期
  isExpiringSoon: bool   // 是否临期
}
```

### RecipeModel（食谱）
```dart
{
  recipeId: int,
  dishName: String,
  ingredients: List<RecipeIngredientModel>,
  steps: List<RecipeStepModel>,
  nutrition: RecipeNutritionModel,
  totalTimeMin: int
}
```

## 自定义组件（手绘风格）

- **SketchyCard** - 手绘风格卡片
- **SketchyButton** - 手绘风格按钮
- **HandwritingAnimation** - 手写动画
- **VideoBackground** - 视频背景
- **IngredientCard** - 食材卡片
- **ExpiryTag** - 过期标签
- **QuantitySelector** - 数量选择器
- **InviteQrCodeWidget** - 二维码组件

## 主要用户流程

### 添加食材
1. InventoryPage → 点击添加
2. AddItemPage → 扫描或手动
3. YoloService 识别食材（如果扫描）
4. ReviewIngredientsPage → 审核
5. EditIngredientPage → 编辑
6. 保存 → 返回库存

### 生成食谱
1. RecipesHomePage → 生成食谱
2. RecipeFilterPage → 设置筛选（可选）
3. RecipeGeneratePage → 查看生成的食谱
4. RecipeInstructionPage → 烹饪指导
   - 支持语音控制（"下一步"）
   - 支持手势控制
5. RecipeMealSummaryPage → 完成总结

## 技术亮点

### 1. AI 图像识别
- YOLO 模型识别食材
- 模型文件：`assets/models/best.onnx`
- ~~使用 onnxruntime（已移除，Web 不支持）~~

### 2. 语音控制
- 使用 `speech_to_text` 和 `flutter_tts`
- 烹饪时免手操作
- 语音播报步骤

### 3. 手势识别
- Google ML Kit Pose Detection
- 识别烹饪手势

### 4. 二维码系统
- `qr_flutter` 生成邀请码
- `mobile_scanner` 扫码加入家庭

## 底部导航栏（MainScaffold）

| Tab | 页面 | 功能 |
|-----|------|------|
| 0 - Home | HomePage | 首页、营养追踪 |
| 1 - Recipes | RecipesHomePage | 食谱列表 |
| 2 - Add | AddItemPage | 添加物品（弹出） |
| 3 - Kitchen | InventoryPage | 库存管理 |
| 4 - Me | ProfileViewPage | 个人中心 |

## API 配置
- 文件：`lib/config/api_config.dart`
- 后端 Base URL 配置
- Token-based authentication

## 开发工具
- **UI Playground**: `lib/ui_playground.dart`
  - 快速测试 UI 设计
  - 启动：`flutter run -t lib/main_playground.dart`

## 项目统计
- 总页面：19个
- API 服务：12个
- 自定义组件：14个
- 数据模型：4个
- 代码行数：5000+行

## 设计理念
手绘风格 + AI 技术，打造温馨智能的厨房助手体验。
