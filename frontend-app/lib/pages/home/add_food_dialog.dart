import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/homepage_api_service.dart';

/// 额外食物数据模型
class ExtraFood {
  final String name;
  final NutritionInfo nutrition;

  ExtraFood({required this.name, required this.nutrition});
}

/// 营养信息
class NutritionInfo {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

/// 今日还吃了什么弹窗
class AddFoodDialog extends StatefulWidget {
  const AddFoodDialog({super.key});

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _foodController = TextEditingController();
  final List<ExtraFood> _addedFoods = [];
  bool _isLoading = false;

  // 模拟食物营养数据库 (以后接真实API)
  final Map<String, NutritionInfo> _foodDatabase = {
    'apple': NutritionInfo(calories: 95, protein: 0.5, fat: 0.3, carbs: 25),
    'banana': NutritionInfo(calories: 105, protein: 1.3, fat: 0.4, carbs: 27),
    'bread': NutritionInfo(calories: 79, protein: 2.7, fat: 1.0, carbs: 15),
    'rice': NutritionInfo(calories: 206, protein: 4.3, fat: 0.4, carbs: 45),
    'chicken': NutritionInfo(calories: 165, protein: 31, fat: 3.6, carbs: 0),
    'egg': NutritionInfo(calories: 78, protein: 6, fat: 5, carbs: 0.6),
    'milk': NutritionInfo(calories: 149, protein: 8, fat: 8, carbs: 12),
    'pizza': NutritionInfo(calories: 285, protein: 12, fat: 10, carbs: 36),
    'burger': NutritionInfo(calories: 354, protein: 20, fat: 17, carbs: 29),
    'salad': NutritionInfo(calories: 65, protein: 2.5, fat: 3.5, carbs: 6),
    'pasta': NutritionInfo(calories: 220, protein: 8, fat: 1.3, carbs: 43),
    'coffee': NutritionInfo(calories: 2, protein: 0.3, fat: 0, carbs: 0),
    'orange juice': NutritionInfo(
      calories: 112,
      protein: 1.7,
      fat: 0.5,
      carbs: 26,
    ),
  };

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  void _addFood() async {
    final foodName = _foodController.text.trim();
    if (foodName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 查找本地食物营养信息（用于显示）
      final foodNameLower = foodName.toLowerCase();
      NutritionInfo? nutrition = _foodDatabase[foodNameLower];

      // 如果没找到，生成默认营养信息（仅用于显示）
      nutrition ??= NutritionInfo(calories: 150, protein: 5, fat: 5, carbs: 20);

      // 调用API添加手动摄入
      final result = await HomepageApiService.addManualIntake(
        foodName: foodName,
        portionDescription: null,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // 如果API返回了营养信息，使用API的数据
        final data = result['data'] as Map<String, dynamic>?;
        if (data != null && data['intake'] != null) {
          final intake = data['intake'] as Map<String, dynamic>;
          final effectiveNutrition =
              intake['effectiveNutrition'] as Map<String, dynamic>?;
          if (effectiveNutrition != null) {
            nutrition = NutritionInfo(
              calories:
                  (effectiveNutrition['energy'] as num?)?.toDouble() ??
                  nutrition.calories,
              protein:
                  (effectiveNutrition['protein'] as num?)?.toDouble() ??
                  nutrition.protein,
              fat:
                  (effectiveNutrition['fat'] as num?)?.toDouble() ??
                  nutrition.fat,
              carbs:
                  (effectiveNutrition['carbohydrates'] as num?)?.toDouble() ??
                  nutrition.carbs,
            );
          }
        }

        setState(() {
          _addedFoods.add(ExtraFood(name: foodName, nutrition: nutrition!));
          _foodController.clear();
        });
      } else {
        final errorCode = result['code'] as int?;
        final errorMsg = result['error'] as String? ?? 'Unknown error';

        if (mounted) {
          if (errorCode == 401 || errorCode == 403) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please login again: $errorMsg'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add food: $errorMsg'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _removeFood(int index) {
    setState(() {
      _addedFoods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.teal.shade600,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "What Else Did You Eat?",
                      style: GoogleFonts.caveat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Add any extra food you ate today",
              style: GoogleFonts.kalam(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // 输入框
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _foodController,
                    decoration: InputDecoration(
                      hintText: "Enter food name...",
                      hintStyle: GoogleFonts.kalam(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.teal.shade500,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.kalam(fontSize: 16),
                    onSubmitted: (_) => _addFood(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 已添加食物列表
            Text(
              "Added Foods",
              style: GoogleFonts.kalam(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),

            Flexible(
              child: _addedFoods.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _addedFoods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildFoodItem(_addedFoods[index], index);
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // 总计营养
            if (_addedFoods.isNotEmpty) _buildNutritionSummary(),

            const SizedBox(height: 16),

            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop(_addedFoods);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Done",
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              "No extra foods added yet",
              style: GoogleFonts.kalam(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(ExtraFood food, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        children: [
          // 食物图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fastfood, color: Colors.teal.shade600, size: 22),
          ),
          const SizedBox(width: 12),

          // 食物名称和营养
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${food.nutrition.calories.toInt()} kcal • P: ${food.nutrition.protein.toInt()}g • F: ${food.nutrition.fat.toInt()}g • C: ${food.nutrition.carbs.toInt()}g",
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 删除按钮
          IconButton(
            onPressed: () => _removeFood(index),
            icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
            iconSize: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (var food in _addedFoods) {
      totalCalories += food.nutrition.calories;
      totalProtein += food.nutrition.protein;
      totalFat += food.nutrition.fat;
      totalCarbs += food.nutrition.carbs;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionBadge("Calories", "${totalCalories.toInt()}", "kcal"),
          _buildNutritionBadge("Protein", "${totalProtein.toInt()}", "g"),
          _buildNutritionBadge("Fat", "${totalFat.toInt()}", "g"),
          _buildNutritionBadge("Carbs", "${totalCarbs.toInt()}", "g"),
        ],
      ),
    );
  }

  Widget _buildNutritionBadge(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.caveat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        Text(
          "$label ($unit)",
          style: GoogleFonts.kalam(fontSize: 10, color: Colors.teal.shade700),
        ),
      ],
    );
  }
}

/// 显示添加食物弹窗的便捷方法
Future<List<ExtraFood>?> showAddFoodDialog(BuildContext context) {
  return showDialog<List<ExtraFood>>(
    context: context,
    builder: (context) => const AddFoodDialog(),
  );
}
