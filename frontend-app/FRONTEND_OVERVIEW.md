# CalOtter 前端项目概述

## 📱 项目简介

**项目名称**: CalOtter (Personal Sous Chef)  
**技术栈**: Flutter (Dart)  
**支持平台**: iOS, Android, Web, macOS, Linux, Windows  
**主题风格**: 手绘风格（Sketchy Design），使用 Caveat 手写字体

---

## 🏗️ 项目架构

### 核心目录结构

```
lib/
├── config/              # 配置文件（API 配置等）
├── data/                # 本地数据存储和 Mock 数据
├── models/              # 数据模型
├── pages/               # 所有页面（19个页面）
│   ├── ums/            # 用户管理系统（登录、注册、用户资料）
│   ├── home/           # 首页相关
│   ├── recipes/        # 食谱相关
│   ├── inventory/      # 库存管理
│   ├── add_item/       # 添加物品
│   └── household/      # 家庭管理
├── services/            # API 服务层（12个服务）
├── widgets/             # 可复用组件（14个自定义组件）
└── theme/              # 主题配置
```

---

## 📄 页面结构（共19个页面）

### 一级页面（7个）

| 页面 | 文件路径 | 功能描述 | 访问方式 |
|------|---------|---------|---------|
| **LandingPage** | `ums/auth/landing_page.dart` | 欢迎页/登录注册入口 | 应用启动首页 |
| **LoginPage** | `ums/auth/login_page.dart` | 用户登录 | 从 LandingPage |
| **RegistrationPage** | `ums/auth/registration_page.dart` | 用户注册 | 从 LandingPage |
| **HomePage** | `home/home_page.dart` | 首页（营养信息、今日食谱） | 底部导航栏 Tab 0 |
| **RecipesHomePage** | `recipes/recipes_home_page.dart` | 食谱列表和生成 | 底部导航栏 Tab 1 |
| **InventoryPage** | `inventory/inventory_page.dart` | 库存管理（食材、调料、厨具） | 底部导航栏 Tab 3 |
| **ProfileViewPage** | `ums/profile/profile_view_page.dart` | 个人中心 | 底部导航栏 Tab 4 |

### 次级页面（12个）

**食谱相关（4个）:**
- `RecipeFilterPage` - 食谱筛选条件设置
- `RecipeGeneratePage` - 生成食谱菜单
- `RecipeInstructionPage` - 食谱制作步骤指导
- `RecipeMealSummaryPage` - 完成一餐后的总结

**库存管理相关（3个）:**
- `EditIngredientPage` - 编辑/添加食材
- `AddItemPage` - 添加新物品（扫描或手动）
- `ReviewIngredientsPage` - 审核识别出的食材

**用户管理相关（5个）:**
- `ProfileEditPage` - 编辑用户资料
- `PreferencesListPage` - 管理用户偏好
- `DietHabitsListPage` - 管理饮食习惯
- `AllergiesListPage` - 管理过敏信息
- `SettingsPage` - 设置（修改密码、退出登录）

**家庭管理相关（2个）:**
- `HouseholdManagePage` - 家庭管理（邀请、移除成员）
- `ScanJoinHouseholdPage` - 扫码加入家庭

---

## 🎨 核心功能模块

### 1. 用户管理系统（UMS）
- **认证**: 登录、注册、退出登录
- **用户资料**: 查看、编辑个人信息
- **偏好设置**: 饮食习惯、过敏信息、禁忌管理
- **账户管理**: 修改密码、删除账户

### 2. 库存管理
- **食材管理**: 添加、编辑、删除食材
- **图像识别**: 使用 YOLO 模型识别食材（通过相机扫描）
- **过期提醒**: 标记已过期和临期食材
- **分类管理**: 食材、调料、厨具三大类
- **单位支持**: g, ml, pcs 等多种单位

### 3. 食谱系统
- **食谱生成**: 基于库存食材生成食谱
- **食谱筛选**: 按菜系、口味、难度等条件筛选
- **烹饪指导**: 分步骤展示制作流程
- **语音控制**: 烹饪时语音查看下一步（TTS + STT）
- **手势控制**: 使用 Google ML Kit 进行手势识别
- **收藏管理**: 收藏喜欢的食谱

### 4. 首页功能
- **营养追踪**: 显示每日营养摄入
- **今日食谱**: 推荐每日三餐
- **快速添加**: 快速添加食材消耗记录

### 5. 家庭共享
- **二维码邀请**: 生成二维码邀请家庭成员
- **扫码加入**: 扫描二维码加入家庭
- **成员管理**: 查看和移除家庭成员

---

## 🔧 技术实现

### 核心依赖

```yaml
依赖项:
  - cupertino_icons: ^1.0.8        # iOS 风格图标
  - video_player: ^2.8.2           # 背景视频播放
  - animated_text_kit: ^4.2.2      # 手写动画效果
  - http: ^1.6.0                   # HTTP 请求
  - shared_preferences: ^2.5.3     # 本地存储
  - image_picker: ^1.0.4           # 图片选择
  - image: ^4.0.17                 # 图片处理
  - path_provider: ^2.1.1          # 文件路径
  - google_fonts: ^6.2.1           # Google 字体（备用）
  - qr_flutter: ^4.1.0             # 二维码生成
  - mobile_scanner: ^7.1.4         # 二维码扫描
  - speech_to_text: ^7.3.0         # 语音识别（STT）
  - flutter_tts: ^3.8.0            # 语音合成（TTS）
  - camera: ^0.10.5                # 相机访问
  - google_mlkit_pose_detection: ^0.14.0  # 手势识别
```

### 数据模型

**核心模型（4个）:**
1. **Ingredient** - 食材模型
   - 属性: name, expiryDate, quantity, unit, inventoryId
   - 方法: isExpired, isExpiringSoon

2. **RecipeModel** - 食谱模型
   - 包含: recipeId, dishName, ingredients, steps, nutrition

3. **Cookware** - 厨具模型
   - 属性: name, category, imagePlaceholder

4. **Leftover** - 剩菜模型
   - 属性: name, expiryDate, quantity

### API 服务层（12个服务）

| 服务 | 文件 | 功能描述 |
|------|------|---------|
| AuthService | `auth_service.dart` | 用户认证（登录、注册、登出） |
| UserService | `user_service.dart` | 用户资料管理 |
| InventoryApiService | `inventory_api_service.dart` | 库存管理 API |
| RecipeApiService | `recipe_api_service.dart` | 食谱相关 API |
| FavoriteRecipesApiService | `favorite_recipes_api_service.dart` | 收藏食谱管理 |
| HomepageApiService | `homepage_api_service.dart` | 首页数据获取 |
| HouseholdService | `household_service.dart` | 家庭管理 API |
| CookingApiService | `cooking_api_service.dart` | 烹饪相关 API |
| StandardLibraryService | `standard_library_service.dart` | 标准食材库 |
| YoloService | `yolo_service.dart` | YOLO 图像识别 |
| CookingVoiceAssistant | `cooking_voice_assistant.dart` | 语音助手 |
| CookingGestureControl | `cooking_gesture_control.dart` | 手势控制 |

### 自定义组件（14个）

| 组件 | 文件 | 功能描述 |
|------|------|---------|
| SketchyCard | `sketchy_card.dart` | 手绘风格卡片 |
| SketchyButton | `sketchy_button.dart` | 手绘风格按钮 |
| SketchyBorder | `sketchy_border.dart` | 手绘风格边框 |
| GradientButton | `gradient_button.dart` | 渐变按钮 |
| HandwritingAnimation | `handwriting_animation.dart` | 手写动画效果 |
| VideoBackground | `video_background.dart` | 视频背景 |
| IngredientCard | `ingredient_card.dart` | 食材卡片 |
| LeftoverCard | `leftover_card.dart` | 剩菜卡片 |
| ExpiryTag | `expiry_tag.dart` | 过期标签 |
| QuantitySelector | `quantity_selector.dart` | 数量选择器 |
| ItemToggleGrid | `item_toggle_grid.dart` | 物品切换网格 |
| GenerateRecipeButton | `generate_recipe_button.dart` | 生成食谱按钮 |
| InviteQrCodeWidget | `invite_qr_code_widget.dart` | 邀请二维码组件 |

---

## 🎨 设计特色

### 手绘风格（Sketchy Design）
- **字体**: Caveat 手写字体（Regular, Bold, SemiBold, Medium）
- **卡片**: 带手绘边框的卡片效果
- **按钮**: 手绘风格按钮
- **动画**: 手写文字动画效果

### 主题色
- **主色调**: 深橙色（Deep Orange）
- **品牌标识**: 🦦 海獭 Emoji + "CalOtter" 手写字体

### 背景元素
- 欢迎页使用视频背景（`otter_seal_dance33.mp4`）
- 手绘草图背景（`sketch.png`）

---

## 🔄 数据流

### 本地存储
- **SharedPreferences**: 用户偏好、临时数据
- **Mock 数据**: `data/mock_recipes.dart`、`data/user_static_data.dart`
- **状态管理**: `data/collected_recipes_store.dart`、`data/consumption_history_store.dart`

### API 交互
- **Base URL 配置**: `config/api_config.dart`
- **HTTP 客户端**: 使用 `http` 包
- **认证机制**: Token-based authentication

---

## 🚀 特色功能

### 1. AI 图像识别
- 使用 YOLO 模型识别食材
- 支持相机实时扫描
- 模型文件: `assets/models/best.onnx`

### 2. 智能烹饪助手
- **语音控制**: 烹饪时免手操作，语音查看下一步
- **手势识别**: 使用 Google ML Kit 识别手势
- **TTS 播报**: 语音播报烹饪步骤

### 3. 家庭共享
- 二维码邀请机制
- 多人协同管理库存
- 家庭成员管理

### 4. 营养追踪
- 每日营养摄入统计
- 卡路里、蛋白质、碳水、脂肪追踪
- 可视化图表展示

---

## 🎯 主要用户流程

### 新用户注册流程
1. LandingPage（欢迎页）
2. RegistrationPage（注册）
3. LoginPage（登录）
4. MainScaffold（进入主应用）

### 添加食材流程
1. InventoryPage → 点击 "Add" 按钮
2. AddItemPage → 选择扫描或手动添加
3. （扫描）YoloService 识别食材
4. ReviewIngredientsPage → 审核识别结果
5. EditIngredientPage → 编辑单个食材信息
6. 保存 → 返回 InventoryPage

### 生成食谱流程
1. RecipesHomePage → 点击 "Generate Recipe"
2. RecipeFilterPage → 设置筛选条件（可选）
3. RecipeGeneratePage → 生成食谱列表
4. RecipeInstructionPage → 查看制作步骤
5. （完成所有食谱）RecipeMealSummaryPage → 总结页面

---

## 📊 项目统计

- **总页面数**: 19 个
- **服务层**: 12 个 API 服务
- **自定义组件**: 14 个
- **数据模型**: 4 个核心模型
- **支持平台**: 6 个（iOS, Android, Web, macOS, Linux, Windows）
- **代码行数**: 约 5000+ 行（估算）

---

## 🔒 权限需求

- 📷 **相机权限**: 食材扫描、手势识别
- 🎤 **麦克风权限**: 语音控制
- 📁 **存储权限**: 保存图片、缓存数据
- 📶 **网络权限**: API 请求

---

## 🐛 已知问题

1. ~~onnxruntime 不支持 Web 平台~~（已移除）
2. 部分包版本可以升级（见 `flutter pub outdated`）

---

## 📝 开发备注

### UI Playground
- 文件: `lib/ui_playground.dart`
- 用途: 快速设计和测试 UI 组件
- 启动方式: `flutter run -t lib/main_playground.dart`

### 测试页面
- `pages/test_pages/backend_test_page.dart` - 后端 API 测试页面

---

## 🎨 设计理念

CalOtter 前端采用**手绘风格**设计，旨在创造一个温馨、轻松的烹饪助手体验。通过手写字体、草图边框和动画效果，让用户感受到人性化和亲切感。同时结合 AI 技术（图像识别、语音控制、手势识别），提供智能化的厨房管理和烹饪指导。

---

## 📞 联系方式

项目路径: `/Users/emma/Desktop/2025summer intern/A-team-PersonalSousChef/frontend-app`

---

**最后更新**: 2026-01-15
