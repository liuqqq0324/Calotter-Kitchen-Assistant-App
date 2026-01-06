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

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);

    try {
      // 获取周营养摘要（包含已消费和剩余）
      final summaryResult =
          await HomepageApiService.getWeeklyNutritionSummary();

      if (!mounted) return;

      if (summaryResult['success'] == true && summaryResult['data'] != null) {
        final data = summaryResult['data'] as Map<String, dynamic>;
        final consumed = data['consumed'] as Map<String, dynamic>? ?? {};

        // 获取周营养目标（用于target值）
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
          _isLoading = false;
        });
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

  // 构建营养项显示
  Widget _buildNutritionItem({
    required String label,
    required String unit,
    required double current,
    required double target,
    required Color color,
    required IconData icon,
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
          "${(percentage * 100).toStringAsFixed(0)}% of weekly target",
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
        padding: const EdgeInsets.all(16),
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

          // 3. 营养仪表盘标题 - 手绘风格
          Text(
            "Weekly Nutrition Dashboard",
            style: SketchyTextStyle.heading(context),
          ),
          const SizedBox(height: 15),

          // 4. 营养仪表盘卡片 - 手绘风格
          SketchyCard(
            backgroundColor: Colors.white,
            borderColor: Colors.teal.shade700,
            borderWidth: 2.5,
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 28,
                            color: Colors.teal.shade700,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "This Week's Intake",
                            style: GoogleFonts.caveat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadNutritionData,
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 营养成分列表
                      _buildNutritionItem(
                        label: "Energy",
                        unit: "kcal",
                        current: _nutritionData['energy_current']!,
                        target: _nutritionData['energy_target']!,
                        color: Colors.orange,
                        icon: Icons.local_fire_department,
                      ),
                      const SizedBox(height: 15),
                      _buildNutritionItem(
                        label: "Protein",
                        unit: "g",
                        current: _nutritionData['protein_current']!,
                        target: _nutritionData['protein_target']!,
                        color: Colors.blue,
                        icon: Icons.fitness_center,
                      ),
                      const SizedBox(height: 15),
                      _buildNutritionItem(
                        label: "Fat",
                        unit: "g",
                        current: _nutritionData['fat_current']!,
                        target: _nutritionData['fat_target']!,
                        color: Colors.amber,
                        icon: Icons.water_drop,
                      ),
                      const SizedBox(height: 15),
                      _buildNutritionItem(
                        label: "Carbohydrates",
                        unit: "g",
                        current: _nutritionData['carbs_current']!,
                        target: _nutritionData['carbs_target']!,
                        color: Colors.green,
                        icon: Icons.eco,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
