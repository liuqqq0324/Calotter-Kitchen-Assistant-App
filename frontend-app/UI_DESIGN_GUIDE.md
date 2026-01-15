# UI 设计风格对比指南

本项目包含三种完全不同的 UI 设计风格，展示了同一数据的多种呈现方式。

---

## 🎨 三种设计风格

### 1. 📖 Scrapbook（剪贴簿）
**文件**: `lib/design_a_scrapbook.dart`

**灵感**: 手工剪贴簿，充满个性和温度

**特点**:
- 🎨 纯色背景（泡沫白）
- 📄 白色卡片 + 粗黑边框
- 📌 顶部胶带装饰
- 🔄 随机旋转效果（每张卡片轻微倾斜）
- 🖤 硬阴影（offset 3,3，无模糊）
- ✏️ 手写字体 Caveat
- 🧡 橙色贴纸风格按钮

**情感**: 温馨、怀旧、手工感、个性化

---

### 2. 🪵 Rafting（漂流）
**文件**: `lib/design_b_rafting.dart`

**灵感**: 河流中的鹅卵石，由海草连接

**特点**:
- 🤍 纯白背景
- 💎 超圆角卡片（BorderRadius 32）
- 🌿 左侧垂直连接线（海草）
- ⚫ 绿色圆点连接卡片
- 🚫 无边框、无阴影（扁平设计）
- 🫧 淡蓝色半透明卡片背景
- 💊 药丸形状按钮（StadiumBorder）
- 🌬️ 大量留白

**情感**: 平静、自然、流动感、极简主义

---

### 3. 💧 Glass（玻璃态）
**文件**: `lib/design_c_glass.dart`

**灵感**: 磨砂玻璃效果（Glassmorphism）

**特点**:
- 🌊 渐变背景（淡蓝→白）
- 🔮 BackdropFilter 模糊（sigma 10）
- ✨ 低透明度卡片（白色 25%）
- 💎 精致白色边框（1.5px）
- 🌟 柔和蓝色发光（外阴影）
- 🟠 半透明橙色按钮
- 📱 现代 iOS/macOS 风格

**情感**: 精致、现代、科技感、轻盈

---

## 🚀 快速运行

### 方式 1：对比运行器（推荐）
一次性查看并切换所有三种设计：

```bash
flutter run -t lib/ui_comparison_runner.dart -d chrome
```

### 方式 2：单独运行每种设计

```bash
# 剪贴簿风格
flutter run -t lib/main_scrapbook.dart -d chrome

# 漂流风格
flutter run -t lib/main_rafting.dart -d chrome

# 玻璃态风格
flutter run -t lib/main_glass.dart -d chrome
```

---

## 📱 设备选择

```bash
# 查看可用设备
flutter devices

# Web 浏览器（推荐，启动最快）
-d chrome

# iPhone
-d "艾玛"
-d 00008130-00040C6C0E06001C

# macOS 桌面
-d macos
```

---

## 📊 设计对比表

| 特性 | 📖 Scrapbook | 🪵 Rafting | 💧 Glass |
|------|-------------|-----------|----------|
| **背景** | 泡沫白 | 纯白 | 渐变（蓝→白） |
| **卡片** | 白色 | 淡蓝 15% | 白色 25% |
| **透明度** | 不透明 | 不透明 | **半透明** |
| **模糊** | ❌ | ❌ | ✅ BackdropFilter |
| **边框** | 粗黑边（2px） | 无 | 白色细边（1.5px） |
| **圆角** | 普通（8px） | 超圆（32px） | 中等（16px） |
| **阴影** | 硬阴影（黑） | 无 | 柔和发光（蓝） |
| **特效** | 旋转+胶带 | 连接线+圆点 | 模糊+发光 |
| **按钮** | 贴纸风格 | 药丸形状 | 玻璃按钮 |
| **风格** | 手工、复古 | 扁平、宁静 | 现代、精致 |
| **复杂度** | ⭐⭐ | ⭐ | ⭐⭐⭐ |
| **适用场景** | 个人日记、记录 | 极简 App | 现代 App |

---

## 🎯 使用场景推荐

### 📖 Scrapbook 适合：
- 个人记录类应用
- 亲子/家庭应用
- 美食日记、旅行日记
- 强调温度和个性的产品

### 🪵 Rafting 适合：
- 工具类应用
- 专注于内容的应用
- 冥想、健康类应用
- 追求极简主义的产品

### 💧 Glass 适合：
- 现代化企业应用
- 科技产品
- iOS/macOS 原生应用
- 追求精致感的产品

---

## 🎨 配色方案（Riverbank Palette）

所有设计都使用统一的配色方案：

```dart
class AppPalette {
  static const Color riverDeepBrown = Color(0xFF6B4F4F);  // 深棕色
  static const Color waterBlue = Color(0xFFA1C6EA);       // 水蓝色
  static const Color seaweedGreen = Color(0xFF4E785E);    // 海草绿
  static const Color foamWhite = Color(0xFFE3F2FD);       // 泡沫白
  static const Color appetiteOrange = Color(0xFFF0B27A);  // 橙色
}
```

---

## 📝 Mock 数据

所有设计使用相同的 Mock 数据（`lib/mock_data_source.dart`）：

- Fresh Salmon（三文鱼）- 500g, 2 天
- Organic Spinach（有机菠菜）- 1 袋, 4 天
- Hokkaido Milk（北海道牛奶）- 200ml, 1 天
- Eggs (Large)（大鸡蛋）- 6 个, 10 天
- Avocado（牛油果）- 2 个, 3 天
- Clams (Otter favorite)（蛤蜊）- 1kg, 1 天

---

## 🔧 技术细节

### Scrapbook 核心技术
```dart
Transform.rotate(
  angle: randomAngle,
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(width: 2),
      boxShadow: [
        BoxShadow(
          offset: Offset(3, 3),
          blurRadius: 0, // 硬阴影
        ),
      ],
    ),
  ),
)
```

### Rafting 核心技术
```dart
Stack(
  children: [
    Positioned(
      left: 40,
      child: Container(width: 4), // 连接线
    ),
    ListView(
      children: [
        Row(
          children: [
            CircleAvatar(radius: 6), // 连接点
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

### Glass 核心技术
```dart
import 'dart:ui'; // 必须导入

ClipRRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      color: Colors.white.withOpacity(0.25),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: -5, // 负值向内
          ),
        ],
      ),
    ),
  ),
)
```

---

## 📂 文件结构

```
lib/
├── mock_data_source.dart          # Mock 数据和配色板
├── design_a_scrapbook.dart        # 剪贴簿设计
├── design_b_rafting.dart          # 漂流设计
├── design_c_glass.dart            # 玻璃态设计
├── ui_comparison_runner.dart      # 对比运行器（推荐）
├── main_scrapbook.dart            # 剪贴簿单独运行
├── main_rafting.dart              # 漂流单独运行
└── main_glass.dart                # 玻璃态单独运行
```

---

## 💡 设计哲学

每种设计都传达不同的情感和价值观：

1. **Scrapbook**: "Life is handmade"
   - 强调个性化和手工感
   - 每一张卡片都是独特的（随机旋转）
   - 像亲手制作的相册

2. **Rafting**: "Less is more"
   - 极简主义、大量留白
   - 让内容自己说话
   - 流动、平静、自然

3. **Glass**: "Future is transparent"
   - 现代、精致、轻盈
   - 层次感和深度
   - 科技与美学的结合

---

## 🎓 学习价值

这个项目展示了：
- ✅ 如何用相同数据创建完全不同的视觉效果
- ✅ Flutter 中的高级 UI 技巧
- ✅ 设计系统的实现
- ✅ 情感化设计的应用
- ✅ 品牌一致性与多样性的平衡

---

## 🚀 下一步

### 混合风格
可以尝试混搭不同设计的元素：
- Scrapbook 的旋转 + Glass 的模糊
- Rafting 的留白 + Scrapbook 的装饰
- Glass 的透明度 + Rafting 的圆角

### 添加动画
- 卡片出现动画
- 页面切换过渡
- 按钮按下效果

### 主题切换
- 暗色模式适配
- 自定义配色方案
- 用户可选主题

---

**创建日期**: 2026-01-15  
**作者**: Emma  
**项目**: CalOtter (Personal Sous Chef)
