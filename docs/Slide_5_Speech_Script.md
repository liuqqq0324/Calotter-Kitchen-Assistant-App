# Slide 5 – Sprint 1 Progress: Frontend Implementation
## 演讲稿 (Speech Script)

---

## Part 1: Slide Text (PPT 内容)

### Slide Title:
**Sprint 1 Progress: Frontend Implementation**

### Slide Layout:
- **左侧 (40%)**: 文字 Bullet Points
- **右侧 (60%)**: 三张截图并排（或者一大两小）

### Slide Text (Bullet Points):

1. **Functional App Architecture**
   - Implemented core navigation: **Home, Recipes, Kitchen, Me** (with quick Add button)
   - Bottom navigation bar with 5 destinations for intuitive user flow
   - Built with **Flutter** for smooth state management and cross-platform support
   - Centralized state management ensures seamless tab switching and data consistency

2. **The "Smart" Home Dashboard**
   - **Expiry Alert**: Prominently displays count of items expiring within 3 days
   - **Daily Pick**: Features "Recipe of the Day" section for recipe recommendations

3. **Inventory Management (The "Pantry")**
   - Fully functional CRUD (Create, Read, Update, Delete) operations
   - Users can manually adjust quantities and expiry dates
   - **Visual Status Indicators**: Color-coded cards (red for expired, orange for expiring soon)

4. **Recipe Interface**
   - Designed UI cards to display **Calorie Information** prominently
   - Step-by-step instructions ready for AI-generated content
   - Filter system for personalized recipe discovery

---

## Part 2: Speaker Notes (双语演讲稿)

### English Version:

"On Slide 5, you can see our actual mobile application running. In Sprint 1, we moved beyond wireframes to a functional prototype built with Flutter.

**First, let me explain our navigation architecture.**

We've implemented a bottom navigation bar with five key destinations: **Home** for the dashboard, **Recipes** for meal planning, **Kitchen** for inventory management, **Me** for user profile, and a prominent **Add** button in the center for quick item entry. This navigation structure ensures users can quickly access any core function with a single tap. The state management is centralized, so data remains consistent when switching between tabs. Each tab maintains its own state while sharing global data through a unified data model, which allows for smooth transitions and real-time updates across the app.

**Now, look at the Home Screen (the dashboard).**

This directly reflects the logic we discussed earlier. The top section features an **Expiry Alert card** that displays the count of items expiring within 3 days. This immediately draws the user's attention to items that need to be used up first, solving the 'waste' problem right upon login. Below that, we have the **Recipe of the Day** section, which will be populated with AI-generated recommendations based on urgent inventory.

**Second, the Inventory Tab (Kitchen).**

We have implemented full CRUD capabilities here. Users can view their digital pantry, edit quantities, and track expiry dates manually. The interface uses color-coded cards—red for expired items, orange for items expiring soon—making it easy to identify priorities at a glance. (In the next sprint, this will be populated automatically by CV.)

**Finally, the Recipe UI.**

We have designed the recipe cards to display **Calorie Information** prominently, along with cooking time and difficulty level. The frontend structure is now ready to receive the structured JSON data from our backend AI engine. Users can filter recipes based on their preferences, and the system is prepared to show step-by-step instructions once connected to the backend."

---

### 中文版本：

"在 Slide 5，大家可以看到我们实际运行的移动端应用。在 Sprint 1，我们已经从线框图进化到了使用 Flutter 构建的功能原型。

**首先，让我介绍一下我们的导航架构。**

我们实现了底部导航栏，包含五个核心入口：**Home**（首页仪表盘）、**Recipes**（菜谱规划）、**Kitchen**（库存管理）、**Me**（用户资料），以及中央突出的 **Add** 按钮用于快速添加食材。这个导航结构确保用户只需一次点击就能访问任何核心功能。状态管理采用集中式设计，每个标签页维护自己的状态，同时通过统一的数据模型共享全局数据，这确保了切换标签页时的流畅过渡和实时更新。

**现在，请看首页（仪表盘）。**

这直接体现了我们刚才讨论的核心逻辑。顶部区域是 **过期预警卡片**，它显示即将在 3 天内过期的食材数量。这能立即吸引用户关注需要优先处理的食材，让用户一登录就能解决'浪费'问题。下方是 **每日推荐** 板块，未来将根据紧急库存由 AI 生成推荐菜谱。

**其次，是库存页面（Kitchen）。**

我们在这里实现了完整的增删改查（CRUD）功能。用户可以查看他们的数字冰箱，手动编辑数量并追踪过期日期。界面使用颜色编码的卡片——红色表示已过期，橙色表示即将过期——让用户一眼就能识别优先级。（在下一个 Sprint，这里将通过 CV 自动填充）。

**最后，是菜谱界面。**

我们设计的菜谱卡片已经预留了 **卡路里信息** 的显著展示位，同时显示烹饪时间和难度等级。前端结构现在已经准备好接收来自后端 AI 引擎的结构化 JSON 数据。用户可以根据偏好筛选菜谱，系统已准备好显示步骤说明，一旦与后端连接即可使用。"

---

## Part 3: Key Talking Points (关键要点)

### 强调点：

1. **导航架构**：强调底部导航栏的五个核心入口，说明用户体验设计思路
2. **技术选择**：明确说明使用 **Flutter**（不是 Kotlin/React Native）
3. **状态管理**：说明集中式状态管理确保数据一致性
4. **过期预警**：强调是"计数显示"（count），不是完整列表，但能有效引导用户关注
5. **颜色编码**：强调 Inventory 页面的红/橙颜色标记系统
6. **卡路里展示**：明确说明 Recipe 卡片中已实现卡路里显示
7. **前后端对接**：强调前端已准备好接收后端数据

### 演示建议：

- 如果现场演示，可以：
  1. **首先展示导航栏**：说明五个标签页的功能定位
  2. 展示 Home 页的过期计数卡片
  3. 切换到 Kitchen 页，展示颜色编码的食材列表
  4. 展示 Recipe 页的卡路里信息
  5. 演示 Add 按钮的快速添加流程
  6. 强调这些功能已经可以工作，等待后端连接

---

## Part 4: 截图检查清单

### 需要准备的截图：

1. **Home Screen** ✅
   - 必须显示 "3 Items Expiring" 卡片（或实际数字）
   - 必须显示 "Recipe of the Day" 板块
   - 建议：使用手机 Mockup 边框

2. **Kitchen/Inventory Tab** ✅
   - 显示食材列表
   - 能看到红/橙颜色标记（过期/即将过期）
   - 显示过期时间信息

3. **Recipe Detail or Profile** ✅
   - Recipe 卡片：显示卡路里信息（如 "450 kcal"）
   - 或 Profile 页：显示卡路里目标设置（如果实现了）

### 截图逻辑建议：

- 如果可能，让 Home 页显示的过期计数与 Kitchen 页的实际快过期食材数量对应
- Recipe of the Day 的推荐最好能对应快过期的食材（例如：快过期的是鸡蛋，推荐番茄炒蛋）

---

## 注意事项

1. ✅ **技术栈已确认**：Flutter
2. ✅ **功能描述已修正**：过期预警是计数显示，不是列表
3. ✅ **其他功能描述符合现状**：CRUD、颜色标记、卡路里展示都已实现
4. ⚠️ **演示时注意**：如果评委问"为什么首页不直接显示列表"，可以回答："我们设计为计数+跳转，避免首页信息过载，用户点击后可在 Kitchen 页查看详情"

---

**最后更新**: 基于项目代码检查结果
**检查日期**: 2025-01-XX

