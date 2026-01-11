import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';
import 'package:personal_sous_chef/pages/home/todays_recipes_dialog.dart';
import 'package:personal_sous_chef/pages/home/add_food_dialog.dart';
import 'package:personal_sous_chef/services/homepage_api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  int _nutritionPageIndex = 0; // 0 = daily, 1 = weekly
  final PageController _nutritionPageController = PageController(initialPage: 0);

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
      // 1) Weekly summary + targets (existing behavior)
      final summaryResult = await HomepageApiService.getWeeklyNutritionSummary();

      if (!mounted) return;

      if (summaryResult['success'] == true && summaryResult['data'] != null) {
        final data = summaryResult['data'] as Map<String, dynamic>;
        final consumed = data['consumed'] as Map<String, dynamic>? ?? {};

        final targetResult = await HomepageApiService.getWeeklyNutritionTargets();

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

        // 2) Daily summary (client-side): sum today's intake effectiveNutrition; daily target = weeklyTarget/7
        await _loadDailyNutritionDataFromTodayIntakes(
          weeklyTargetEnergy: (weeklyTarget['energy'] as num?)?.toDouble(),
          weeklyTargetProtein: (weeklyTarget['protein'] as num?)?.toDouble(),
          weeklyTargetFat: (weeklyTarget['fat'] as num?)?.toDouble(),
          weeklyTargetCarbs: (weeklyTarget['carbohydrates'] as num?)?.toDouble(),
        );

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
                backgroundColor: Colors.orange,
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
                backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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

  Future<void> _loadDailyNutritionDataFromTodayIntakes({
    double? weeklyTargetEnergy,
    double? weeklyTargetProtein,
    double? weeklyTargetFat,
    double? weeklyTargetCarbs,
  }) async {
    try {
      final todayResult = await HomepageApiService.getTodayIntakes(source: 'all');
      if (!mounted) return;
      if (todayResult['success'] != true) return;

      final data = todayResult['data'] as Map<String, dynamic>?;
      final items = data?['items'] as List<dynamic>? ?? const [];

      double energy = 0;
      double protein = 0;
      double fat = 0;
      double carbs = 0;

      for (final e in items) {
        final item = (e as Map).cast<String, dynamic>();
        final effective = (item['effectiveNutrition'] as Map?)?.cast<String, dynamic>();
        if (effective == null) continue;
        energy += (effective['energy'] as num?)?.toDouble() ?? 0.0;
        protein += (effective['protein'] as num?)?.toDouble() ?? 0.0;
        fat += (effective['fat'] as num?)?.toDouble() ?? 0.0;
        carbs += (effective['carbohydrates'] as num?)?.toDouble() ?? 0.0;
      }

      final dailyEnergyTarget = (weeklyTargetEnergy ?? 14000.0) / 7.0;
      final dailyProteinTarget = (weeklyTargetProtein ?? 700.0) / 7.0;
      final dailyFatTarget = (weeklyTargetFat ?? 455.0) / 7.0;
      final dailyCarbsTarget = (weeklyTargetCarbs ?? 1750.0) / 7.0;

      setState(() {
        _dailyNutritionData = {
          'energy_current': energy,
          'energy_target': dailyEnergyTarget,
          'protein_current': protein,
          'protein_target': dailyProteinTarget,
          'fat_current': fat,
          'fat_target': dailyFatTarget,
          'carbs_current': carbs,
          'carbs_target': dailyCarbsTarget,
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
      backgroundColor: Colors.white,
      borderColor: Colors.teal.shade700,
      borderWidth: 2.5,
      padding: const EdgeInsets.all(18),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              // Prevent "bottom overflowed" on smaller screens by allowing vertical scroll inside the card.
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 22,
                        color: Colors.teal.shade700,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        targetPeriodLabel == 'daily' ? 'Daily' : 'Weekly',
                        style: GoogleFonts.caveat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
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
                    color: Colors.orange,
                    icon: Icons.local_fire_department,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Protein",
                    unit: "g",
                    current: nutritionData['protein_current'] ?? 0.0,
                    target: nutritionData['protein_target'] ?? 0.0,
                    color: Colors.blue,
                    icon: Icons.fitness_center,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Fat",
                    unit: "g",
                    current: nutritionData['fat_current'] ?? 0.0,
                    target: nutritionData['fat_target'] ?? 0.0,
                    color: Colors.amber,
                    icon: Icons.water_drop,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionItem(
                    label: "Carbohydrates",
                    unit: "g",
                    current: nutritionData['carbs_current'] ?? 0.0,
                    target: nutritionData['carbs_target'] ?? 0.0,
                    color: Colors.green,
                    icon: Icons.eco,
                    targetPeriodLabel: targetPeriodLabel,
                  ),
                ],
              ),
            ),
    );
  }

  // 构建营养项显示
  Widget _buildNutritionItem({
    required String label,
    required String unit,
    required double current,
    required double target,
    required Color color,
    required IconData icon,
    required String targetPeriodLabel, // "daily" | "weekly"
  }) {
    final percentage = (current / target).clamp(0.0, 1.0);

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
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Text(
              "${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit",
              style: GoogleFonts.kalam(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 百分比文本
        Text(
          "${(percentage * 100).toStringAsFixed(0)}% of $targetPeriodLabel target",
          style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // 构建追踪按钮
  Widget _buildTrackingButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SketchyCard(
        backgroundColor: color.shade50,
        borderColor: color.shade400,
        borderWidth: 2.0,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.caveat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.kalam(fontSize: 11, color: color.shade600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 欢迎标语 - 手绘风格
          Text(greeting, style: SketchyTextStyle.title(context)),
          const SizedBox(height: 8),
          Text(
            "Ready to cook something delicious?",
            style: SketchyTextStyle.body(
              context,
            ).copyWith(color: Colors.grey[700]),
          ),

          const SizedBox(height: 30),

          // 2. 今日饮食追踪按钮
          Row(
            children: [
              // 今日菜谱按钮
              Expanded(
                child: _buildTrackingButton(
                  context: context,
                  icon: Icons.restaurant_menu,
                  label: "Today's Dish Intake",
                  subtitle: "Track what you ate",
                  color: Colors.deepOrange,
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
                child: _buildTrackingButton(
                  context: context,
                  icon: Icons.add_circle,
                  label: "Add Food",
                  subtitle: "What else did you eat?",
                  color: Colors.teal,
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
            style: SketchyTextStyle.heading(context),
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
                  onPageChanged: (idx) => setState(() => _nutritionPageIndex = idx),
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
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.teal.shade700 : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
