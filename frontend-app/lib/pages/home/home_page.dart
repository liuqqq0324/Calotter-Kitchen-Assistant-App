import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';
import 'package:personal_sous_chef/pages/home/todays_recipes_dialog.dart';
import 'package:personal_sous_chef/pages/home/add_food_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              child: Icon(
                icon,
                size: 32,
                color: color.shade700,
              ),
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
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.kalam(
                fontSize: 11,
                color: color.shade600,
              ),
              textAlign: TextAlign.center,
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
                  label: "Today's Recipes",
                  subtitle: "Track what you cooked",
                  color: Colors.deepOrange,
                  onTap: () => showTodaysRecipesDialog(context),
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
                  onTap: () => showAddFoodDialog(context),
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
            child: Column(
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
                  ],
                ),
                const SizedBox(height: 20),

                // 营养成分列表
                _buildNutritionItem(
                  label: "Energy",
                  unit: "kcal",
                  current: 1250,
                  target: 2000,
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 15),
                _buildNutritionItem(
                  label: "Protein",
                  unit: "g",
                  current: 65,
                  target: 100,
                  color: Colors.blue,
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 15),
                _buildNutritionItem(
                  label: "Fat",
                  unit: "g",
                  current: 45,
                  target: 65,
                  color: Colors.amber,
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: 15),
                _buildNutritionItem(
                  label: "Carbohydrates",
                  unit: "g",
                  current: 180,
                  target: 250,
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
