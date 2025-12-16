import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/homepage_api_service.dart';

/// 额外食物数据模型
class ExtraFood {
  final int? intakeId;
  final String name;
  final NutritionInfo nutrition;

  ExtraFood({this.intakeId, required this.name, required this.nutrition});
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
  bool _isLoadingTodayFoods = false;
  final ScrollController _foodsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshTodayManualFoods();
  }

  @override
  void dispose() {
    _foodController.dispose();
    _foodsScrollController.dispose();
    super.dispose();
  }

  NutritionInfo _nutritionFromBackend(Map<String, dynamic>? effectiveNutrition) {
    if (effectiveNutrition == null) {
      return NutritionInfo(calories: 0, protein: 0, fat: 0, carbs: 0);
    }
    return NutritionInfo(
      calories: (effectiveNutrition['energy'] as num?)?.toDouble() ?? 0,
      protein: (effectiveNutrition['protein'] as num?)?.toDouble() ?? 0,
      fat: (effectiveNutrition['fat'] as num?)?.toDouble() ?? 0,
      carbs: (effectiveNutrition['carbohydrates'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> _refreshTodayManualFoods() async {
    if (_isLoadingTodayFoods) return;
    setState(() => _isLoadingTodayFoods = true);

    try {
      final result = await HomepageApiService.getTodayIntakes(source: 'manual');

      if (!mounted) return;
      setState(() => _isLoadingTodayFoods = false);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        final items = data?['items'] as List<dynamic>? ?? const [];

        setState(() {
          _addedFoods
            ..clear()
            ..addAll(
              items.map((e) {
                final item = (e as Map).cast<String, dynamic>();
                final intakeId = (item['intakeId'] as num?)?.toInt();
                final name = (item['manualFoodName'] as String?) ?? '';
                final effectiveNutrition =
                    (item['effectiveNutrition'] as Map?)?.cast<String, dynamic>();
                return ExtraFood(
                  intakeId: intakeId,
                  name: name,
                  nutrition: _nutritionFromBackend(effectiveNutrition),
                );
              }).where((f) => f.name.trim().isNotEmpty),
            );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTodayFoods = false);
    }
  }

  void _applyTodayManualFoodsList(List<dynamic> foods) {
    setState(() {
      _addedFoods
        ..clear()
        ..addAll(
          foods.map((e) {
            final item = (e as Map).cast<String, dynamic>();
            final intakeId = (item['intakeId'] as num?)?.toInt();
            final name = (item['manualFoodName'] as String?) ?? '';
            final effectiveNutrition =
                (item['effectiveNutrition'] as Map?)?.cast<String, dynamic>();
            return ExtraFood(
              intakeId: intakeId,
              name: name,
              nutrition: _nutritionFromBackend(effectiveNutrition),
            );
          }).where((f) => f.name.trim().isNotEmpty),
        );
    });
  }

  void _applyTodayManualFoodsFromAddResponse(Map<String, dynamic> data) {
    final foods = data['todayManualFoods'] as List<dynamic>?;
    if (foods == null) return;
    _applyTodayManualFoodsList(foods);
  }

  void _addFood() async {
    final foodName = _foodController.text.trim();
    if (foodName.isEmpty) return;

    // Optimistic UI: show immediately in the list
    final optimisticFood = ExtraFood(
      intakeId: null,
      name: foodName,
      nutrition: NutritionInfo(calories: 0, protein: 0, fat: 0, carbs: 0),
    );
    setState(() {
      _isLoading = true;
      _addedFoods.insert(0, optimisticFood);
      _foodController.clear();
    });

    try {
      // 调用API添加手动摄入
      final result = await HomepageApiService.addManualIntake(
        foodName: foodName,
        portionDescription: null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        if (data != null) {
          _applyTodayManualFoodsFromAddResponse(data);
        } else {
          await _refreshTodayManualFoods();
        }
      } else {
        // revert optimistic UI
        if (mounted) {
          setState(() {
            _addedFoods.remove(optimisticFood);
          });
        }
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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _addedFoods.remove(optimisticFood);
      });
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

  Future<void> _deleteFood(ExtraFood food, int index) async {
    final intakeId = food.intakeId;
    if (intakeId == null) {
      // Not persisted yet (optimistic item); local remove only.
      setState(() => _addedFoods.removeAt(index));
      return;
    }

    final removed = food;
    setState(() {
      _addedFoods.removeAt(index);
      _isLoading = true;
    });

    try {
      final result = await HomepageApiService.deleteIntake(intakeId: intakeId);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        final foods = data?['todayManualFoods'] as List<dynamic>?;
        if (foods != null) {
          _applyTodayManualFoodsList(foods);
        } else {
          await _refreshTodayManualFoods();
        }
      } else {
        // revert on failure
        setState(() {
          _addedFoods.insert(index.clamp(0, _addedFoods.length), removed);
        });
        final errorMsg = result['error'] as String? ?? 'Unknown error';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete food: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _addedFoods.insert(index.clamp(0, _addedFoods.length), removed);
      });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
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
              child: (_isLoadingTodayFoods && _addedFoods.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : _addedFoods.isEmpty
                  ? _buildEmptyState()
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                          PointerDeviceKind.stylus,
                          PointerDeviceKind.unknown,
                        },
                      ),
                      child: Scrollbar(
                        controller: _foodsScrollController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _foodsScrollController,
                          itemCount: _addedFoods.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildFoodItem(_addedFoods[index], index);
                          },
                        ),
                      ),
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
            onPressed: _isLoading ? null : () => _deleteFood(food, index),
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