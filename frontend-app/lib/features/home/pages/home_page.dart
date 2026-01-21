import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/features/home/dialogs/add_food_dialog.dart';
import 'package:personal_sous_chef/features/home/dialogs/todays_recipes_dialog.dart';
import 'package:personal_sous_chef/services/api/homepage_api_service.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 字体：使用本地字体 PatrickHand（在 pubspec.yaml 中注册）
  static const String _fontFamily = 'PatrickHand';

  TextStyle _pangolin({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  bool _isLoading = true;
  int _nutritionPageIndex = 0; // 0 = daily, 1 = weekly
  final PageController _nutritionPageController = PageController(
    initialPage: 0,
  );

  Map<String, double> _dailyNutritionData = {
    'energy_current': 0.0,
    'energy_target': 2000.0,
    'protein_current': 0.0,
    'protein_target': 100.0,
    'fat_current': 0.0,
    'fat_target': 65.0,
    'carbs_current': 0.0,
    'carbs_target': 250.0,
  };
  Map<String, double> _nutritionData = {
    'energy_current': 0.0,
    'energy_target': 2000.0,
    'protein_current': 0.0,
    'protein_target': 100.0,
    'fat_current': 0.0,
    'fat_target': 65.0,
    'carbs_current': 0.0,
    'carbs_target': 250.0,
  };

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  @override
  void dispose() {
    _nutritionPageController.dispose();
    super.dispose();
  }

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);

    try {
      // 1) Weekly summary + targets (weekly card)
      final summaryResult =
          await HomepageApiService.getWeeklyNutritionSummary();

      if (!mounted) return;

      if (summaryResult['success'] == true && summaryResult['data'] != null) {
        final data = summaryResult['data'] as Map<String, dynamic>;
        final consumed = data['consumed'] as Map<String, dynamic>? ?? {};

        final targetResult =
            await HomepageApiService.getWeeklyNutritionTargets();

        if (!mounted) return;

        Map<String, dynamic> weeklyTarget = {};
        if (targetResult['success'] == true && targetResult['data'] != null) {
          final targetData = targetResult['data'] as Map<String, dynamic>;
          weeklyTarget =
              targetData['weeklyTarget'] as Map<String, dynamic>? ?? {};
        }

        setState(() {
          final weeklyEnergy =
              (weeklyTarget['energy'] as num?)?.toDouble() ?? 14000.0;
          final weeklyProtein =
              (weeklyTarget['protein'] as num?)?.toDouble() ?? 700.0;
          final weeklyFat = (weeklyTarget['fat'] as num?)?.toDouble() ?? 455.0;
          final weeklyCarbs =
              (weeklyTarget['carbohydrates'] as num?)?.toDouble() ?? 1750.0;

          _nutritionData = {
            'energy_current': (consumed['energy'] as num?)?.toDouble() ?? 0.0,
            'energy_target': weeklyEnergy,
            'protein_current': (consumed['protein'] as num?)?.toDouble() ?? 0.0,
            'protein_target': weeklyProtein,
            'fat_current': (consumed['fat'] as num?)?.toDouble() ?? 0.0,
            'fat_target': weeklyFat,
            'carbs_current':
                (consumed['carbohydrates'] as num?)?.toDouble() ?? 0.0,
            'carbs_target': weeklyCarbs,
          };
        });

        // 2) Daily summary + targets (daily card) - use backend endpoints for consistency
        await _loadDailyNutritionDataFromBackend();

        if (!mounted) return;
        setState(() => _isLoading = false);
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (mounted) {
          final errorCode = summaryResult['code'] as int?;
          final errorMsg = summaryResult['error'] as String? ?? 'Unknown error';

          // 如果是401/403，提示重新登录
          if (errorCode == 401 || errorCode == 403) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please login again: $errorMsg'),
                backgroundColor: const Color(0xFFF0B27A), // Appetite Orange
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load nutrition data: $errorMsg'),
                backgroundColor: const Color(0xFFE74C3C),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _loadNutritionData,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: const Color(0xFFE74C3C),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadNutritionData,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadDailyNutritionDataFromBackend() async {
    try {
      if (!mounted) return;

      final targetResult = await HomepageApiService.getDailyNutritionTargets();
      final summaryResult = await HomepageApiService.getDailyNutritionSummary();

      if (!mounted) return;
      if (targetResult['success'] != true || summaryResult['success'] != true) {
        return;
      }

      final targetData = (targetResult['data'] as Map<String, dynamic>?) ?? {};
      final dailyTarget =
          (targetData['dailyTarget'] as Map?)?.cast<String, dynamic>() ?? {};

      final summaryData =
          (summaryResult['data'] as Map<String, dynamic>?) ?? {};
      final consumed =
          (summaryData['consumed'] as Map?)?.cast<String, dynamic>() ?? {};

      setState(() {
        _dailyNutritionData = {
          'energy_current': (consumed['energy'] as num?)?.toDouble() ?? 0.0,
          'energy_target': (dailyTarget['energy'] as num?)?.toDouble() ?? 0.0,
          'protein_current': (consumed['protein'] as num?)?.toDouble() ?? 0.0,
          'protein_target': (dailyTarget['protein'] as num?)?.toDouble() ?? 0.0,
          'fat_current': (consumed['fat'] as num?)?.toDouble() ?? 0.0,
          'fat_target': (dailyTarget['fat'] as num?)?.toDouble() ?? 0.0,
          'carbs_current':
              (consumed['carbohydrates'] as num?)?.toDouble() ?? 0.0,
          'carbs_target':
              (dailyTarget['carbohydrates'] as num?)?.toDouble() ?? 0.0,
        };
      });
    } catch (_) {
      // keep previous daily data; do not fail the whole dashboard
    }
  }

  Widget _buildNutritionDashboardCard({
    required String title,
    required Map<String, double> nutritionData,
    required VoidCallback onRefresh,
    required String targetPeriodLabel, // "daily" | "weekly"
  }) {
    return SketchyCard(
      backgroundColor: const Color(0xFFFFFFF0), // Paper White
      borderColor: const Color(0xFF6B4F4F), // River Deep Brown
      borderWidth: 2.5,
      padding: const EdgeInsets.all(18),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF4E785E), // Seaweed Green
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        size: 22,
                        color: Color(0xFF6B4F4F), // River Deep Brown
                      ),
                      const SizedBox(width: 10),
                      Text(
                        targetPeriodLabel == 'daily' ? 'Daily' : 'Weekly',
                        style: _pangolin(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B4F4F), // River Deep Brown
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF6B4F4F), // River Deep Brown
                        ),
                        onPressed: onRefresh,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Energy",
                    unit: "kcal",
                    current: nutritionData['energy_current'] ?? 0.0,
                    target: nutritionData['energy_target'] ?? 0.0,
                    color: const Color(0xFFF0B27A), // Appetite Orange
                    icon: Icons.local_fire_department,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Protein",
                    unit: "g",
                    current: nutritionData['protein_current'] ?? 0.0,
                    target: nutritionData['protein_target'] ?? 0.0,
                    color: const Color(0xFF6BA4D8), // Sky Blue
                    icon: Icons.fitness_center,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Fat",
                    unit: "g",
                    current: nutritionData['fat_current'] ?? 0.0,
                    target: nutritionData['fat_target'] ?? 0.0,
                    color: const Color(0xFFFFD966), // Butter Yellow
                    icon: Icons.water_drop,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Carbohydrates",
                    unit: "g",
                    current: nutritionData['carbs_current'] ?? 0.0,
                    target: nutritionData['carbs_target'] ?? 0.0,
                    color: const Color(0xFF4E785E), // Seaweed Green
                    icon: Icons.eco,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                ],
              ),
            ),
    );
  }

  // 构建营养项显示 - 手绘蜡笔风格进度条
  Widget _buildNutritionItem({
    required String label,
    required String unit,
    required double current,
    required double target,
    required Color color,
    required IconData icon,
    required String targetPeriodLabel, // "daily" | "weekly"
  }) {
    // 修复：当 target 为 0 时，percentage 设为 0，避免 NaN
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    // 确保 percentage 不是 NaN
    final safePercentage = percentage.isNaN ? 0.0 : percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签和数值行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: _pangolin(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B4F4F), // River Deep Brown
                  ),
                ),
              ],
            ),
            Text(
              "${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit",
              style: _pangolin(
                fontSize: 14,
                color: const Color(0xFF6B4F4F).withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 手绘蜡笔风格进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // 背景容器（始终显示）
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF6B4F4F).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
              // 只在有进度时显示蜡笔填充
              if (safePercentage > 0)
                FractionallySizedBox(
                  widthFactor: safePercentage,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: _CrayonFillPainter(color: color),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 百分比文本
        Text(
          target > 0
              ? "${(safePercentage * 100).toStringAsFixed(0)}% of $targetPeriodLabel target"
              : "No target set",
          style: _pangolin(
            fontSize: 12,
            color: const Color(0xFF6B4F4F).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前时间段，简单的问候语逻辑
    final hour = DateTime.now().hour;
    String greeting = "Hello, Chef!";
    if (hour < 12) {
      greeting = "Good Morning, Chef!";
    } else if (hour < 18) {
      greeting = "Good Afternoon, Chef!";
    } else {
      greeting = "Good Evening, Chef!";
    }

    return SizedBox.expand(
      // 使用木纹海浪图片作为背景，确保填满整个页面
      child: Stack(
        children: [
          // 背景图层：填满整个屏幕
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.png',
              fit: BoxFit.cover,
              // 如果背景图路径不对/资源未打包，先用现有的 sketch.png 兜底，避免崩溃
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/sketch.png', fit: BoxFit.cover),
            ),
          ),
          // 可选：加一层轻薄的“纸张泛黄”蒙版，让内容更易读
          Positioned.fill(
            child: Container(color: const Color(0xFFF3E5AB).withOpacity(0.35)),
          ),
          // 内容层：可滚动的内容，包裹在网格纸中
          SingleChildScrollView(
            padding: EdgeInsets.zero, // 移除 padding，让 _GridPaper 自己控制边距
            child: Center(
              child: _GridPaper(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 欢迎标语 - 手绘风格
                      Text(
                        greeting,
                        style: _pangolin(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B4F4F), // River Deep Brown
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ready to cook something delicious?",
                        style: _pangolin(
                          fontSize: 16,
                          color: const Color(0xFF6B4F4F).withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 2. 今日饮食追踪按钮 - 使用程序化手绘胶带风格卡片
                      Row(
                        children: [
                          // 今日菜谱按钮
                          Expanded(
                            child: ProgrammaticSketchyCard(
                              icon: Icons.restaurant_menu,
                              label: "Daily Intake",
                              subtitle: "Track what you ate",
                              color: const Color(0xFFF0B27A), // Appetite Orange
                              fontFamily: _fontFamily,
                              onTap: () async {
                                await showTodaysRecipesDialog(context);
                                // 刷新营养数据
                                _loadNutritionData();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 额外食物按钮
                          Expanded(
                            child: ProgrammaticSketchyCard(
                              icon: Icons.add_circle,
                              label: "Add Food",
                              subtitle: "What else did you eat?",
                              color: const Color(0xFF4E785E), // Seaweed Green
                              fontFamily: _fontFamily,
                              onTap: () async {
                                await showAddFoodDialog(context);
                                // 刷新营养数据
                                _loadNutritionData();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 3. 营养仪表盘标题 - 手绘风格（可左右滑动：Daily <-> Weekly）
                      Text(
                        _nutritionPageIndex == 0
                            ? "Daily Nutrition Dashboard"
                            : "Weekly Nutrition Dashboard",
                        style: SketchyTextStyle.heading(context).copyWith(
                          color: const Color(0xFF6B4F4F), // River Deep Brown - 与 greeting 一致
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 4. 营养仪表盘（左右滑动卡片）
                      Column(
                        children: [
                          SizedBox(
                            // Ensure the last row (Carbohydrates) is visible without needing inner scrolling.
                            // This page itself is scrollable, so a taller card is safe.
                            height: 460,
                            child: PageView(
                              controller: _nutritionPageController,
                              onPageChanged: (idx) =>
                                  setState(() => _nutritionPageIndex = idx),
                              children: [
                                _buildNutritionDashboardCard(
                                  title: "Today's Intake",
                                  nutritionData: _dailyNutritionData,
                                  onRefresh: _loadNutritionData,
                                  targetPeriodLabel: "daily",
                                ),
                                _buildNutritionDashboardCard(
                                  title: "This Week's Intake",
                                  nutritionData: _nutritionData,
                                  onRefresh: _loadNutritionData,
                                  targetPeriodLabel: "weekly",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(isActive: _nutritionPageIndex == 0),
                              const SizedBox(width: 8),
                              _buildDot(isActive: _nutritionPageIndex == 1),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4E785E) // Seaweed Green
            : const Color(0xFF6B4F4F).withOpacity(0.3), // River Deep Brown 淡色
        shape: BoxShape.circle,
      ),
    );
  }
}

// ==================== 自定义画笔：蜡笔填充效果 ====================
class _CrayonFillPainter extends CustomPainter {
  final Color color;

  _CrayonFillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // 固定种子，确保每次渲染一致

    // 基础填充
    final basePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 手绘蜡笔笔触效果 - 斜线纹理
    final strokePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 绘制斜线纹理（模拟蜡笔笔触）
    for (double i = -size.height; i < size.width + size.height; i += 8) {
      // 添加轻微的随机偏移，模拟手绘效果
      final offset = random.nextDouble() * 2 - 1;
      canvas.drawLine(
        Offset(i + offset, 0),
        Offset(i + size.height + offset, size.height),
        strokePaint,
      );
    }

    // 添加点状纹理（模拟蜡笔颗粒感）
    final dotPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }

    // 高光效果
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 绘制顶部高光
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== 网格纸组件（白底、不规则边缘、悬浮效果）====================
class _GridPaper extends StatelessWidget {
  final Widget child;

  const _GridPaper({required this.child});

  @override
  Widget build(BuildContext context) {
    // 计算5mm对应的逻辑像素值
    // 假设标准DPI为160（Android标准），则 1mm ≈ 160/25.4 ≈ 6.3 逻辑像素
    // 5mm ≈ 31.5 逻辑像素，但考虑到不同设备，使用 MediaQuery 获取屏幕宽度
    // 5mm在不同设备上的近似值：使用屏幕宽度的比例来估算
    // 假设手机屏幕宽度约70mm，5mm约占屏幕宽度的7%
    // 但更准确的方法是直接使用固定值，大约18-20逻辑像素
    final margin5mm = 18.0; // 5mm的近似逻辑像素值

    return Container(
      width: double.infinity, // 占满父级宽度
      margin: EdgeInsets.symmetric(horizontal: margin5mm, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // constraints.maxWidth 已经是减去 margin 后的宽度
          return SizedBox(
            width: constraints.maxWidth, // 使用 LayoutBuilder 获取的实际可用宽度
            child: CustomPaint(painter: _GridPaperPainter(), child: child),
          );
        },
      ),
    );
  }
}

class _GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 调试：检查 size 是否正确
    if (size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      // 如果 size 无效，绘制一个简单的测试矩形
      final testPaint = Paint()
        ..color = const Color(0xFFFF6347)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), testPaint);
      return;
    }

    final random = math.Random(42); // 固定种子，确保每次渲染一致

    // 创建不规则边缘路径
    final path = _createIrregularPath(size, random);

    // 1. 先绘制阴影效果（让网格纸看起来悬浮）
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(6, 6));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. 绘制背景
    final backgroundPaint = Paint()
      ..color =
          const Color(0xFFF8F8F5) // 网格纸背景色
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, backgroundPaint);

    // 3. 绘制网格线（只在背景区域内）
    final gridPaint = Paint()
      ..color =
          const Color(0xFFE3E6E8) // 网格线颜色（浅蓝灰色）
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSpacing = 20.0;

    // 使用 clipPath 限制网格线只在纸张区域内
    canvas.save();
    canvas.clipPath(path);

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.restore();

    // 4. 绘制不规则边缘线（手绘风格，略有毛边）
    final edgePaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, edgePaint);
  }

  Path _createIrregularPath(Size size, math.Random random) {
    final path = Path();
    const double edgeNoise = 2.5; // 边缘不规则程度
    const double step = 8.0; // 路径点的间距

    // 确保路径在有效范围内
    final double effectiveWidth = size.width > 0 ? size.width : 100.0;
    final double effectiveHeight = size.height > 0 ? size.height : 100.0;

    // 顶部边缘：从左到右，带不规则偏移（限制在有效范围内）
    path.moveTo(0, 0);
    for (double x = step; x < effectiveWidth; x += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = noise
          .clamp(-edgeNoise, edgeNoise)
          .toDouble(); // 限制偏移范围并转换为 double
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, 0);

    // 右侧边缘：从上到下
    for (double y = step; y < effectiveHeight; y += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = (effectiveWidth + noise.clamp(-edgeNoise, edgeNoise))
          .toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, effectiveHeight);

    // 底部边缘：从右到左
    for (double x = effectiveWidth - step; x > 0; x -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = (effectiveHeight + noise.clamp(-edgeNoise, edgeNoise))
          .toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(0, effectiveHeight);

    // 左侧边缘：从下到上
    for (double y = effectiveHeight - step; y > 0; y -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = noise.clamp(-edgeNoise, edgeNoise).toDouble();
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
