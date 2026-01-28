import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/api/homepage_api_service.dart';
import 'dart:math' as math;
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';

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

  NutritionInfo _nutritionFromBackend(
    Map<String, dynamic>? effectiveNutrition,
  ) {
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
              items
                  .map((e) {
                    final item = (e as Map).cast<String, dynamic>();
                    final intakeId = (item['intakeId'] as num?)?.toInt();
                    final name = (item['manualFoodName'] as String?) ?? '';
                    final effectiveNutrition =
                        (item['effectiveNutrition'] as Map?)
                            ?.cast<String, dynamic>();
                    return ExtraFood(
                      intakeId: intakeId,
                      name: name,
                      nutrition: _nutritionFromBackend(effectiveNutrition),
                    );
                  })
                  .where((f) => f.name.trim().isNotEmpty),
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
          foods
              .map((e) {
                final item = (e as Map).cast<String, dynamic>();
                final intakeId = (item['intakeId'] as num?)?.toInt();
                final name = (item['manualFoodName'] as String?) ?? '';
                final effectiveNutrition = (item['effectiveNutrition'] as Map?)
                    ?.cast<String, dynamic>();
                return ExtraFood(
                  intakeId: intakeId,
                  name: name,
                  nutrition: _nutritionFromBackend(effectiveNutrition),
                );
              })
              .where((f) => f.name.trim().isNotEmpty),
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

  // 构建手绘边框按钮
  Widget _buildSketchyButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
  }) {
    final borderColor = const Color(
      0xFF6B4F4F,
    ).withOpacity(0.7); // Same as text color
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              borderWidth: 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5), // Account for border width
              child: Center(child: child), // Center the content
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Background Layer: Sketchy paper container
          Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
            margin: const EdgeInsets.only(top: 14), // Space for tape
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFFFF0), // Off-white/cream color
              shape: const SketchyRectBorder(
                borderWidth: 1.0,
                wobbleAmount: 2.5,
                seed: 42, // Fixed seed for consistent appearance
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0xFF6B4F4F).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: const Color(
                                0xFF6B4F4F,
                              ).withOpacity(0.7), // Lighter brown
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                "What Else Did You Eat?",
                                style: GoogleFonts.caveat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    0xFF6B4F4F,
                                  ).withOpacity(0.7), // Lighter brown
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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
                            hintStyle: GoogleFonts.kalam(
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFF6B4F4F,
                            ).withOpacity(0.05), // Light brown background
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF6B4F4F).withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF6B4F4F).withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF6B4F4F),
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
                      _buildSketchyButton(
                        onPressed: _isLoading ? null : _addFood,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6B4F4F),
                                ),
                              )
                            : Icon(
                                Icons.add,
                                size: 24,
                                color: const Color(0xFF6B4F4F).withOpacity(0.7),
                              ),
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

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: (_isLoadingTodayFoods && _addedFoods.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : _addedFoods.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _addedFoods.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
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
                  Center(
                    child: _buildSketchyButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop(_addedFoods);
                            },
                      width: 200, // Fixed width, not too long
                      child: Text(
                        "Done",
                        style: GoogleFonts.kalam(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B4F4F).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Tape Layer: Programmatic tape effect
          Positioned(
            top: 4, // Position tape slightly above the card
            child: Transform.rotate(
              angle: -0.05, // Slight rotation for natural look
              child: Container(
                width: 85, // Shortened tape length
                height: 18,
                decoration: BoxDecoration(
                  // Semi-transparent yellowish-white tape color - more transparent
                  color: const Color(0xFFFFF8DC).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                  // Add a subtle border to make it look more like tape
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 0.5,
                  ),
                  // Add a subtle shadow to make the tape pop
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // Add some texture lines to simulate tape texture
                child: CustomPaint(painter: _TapeTexturePainter()),
              ),
            ),
          ),
        ],
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
        color: const Color(
          0xFF6B4F4F,
        ).withOpacity(0.05), // Light brown background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B4F4F).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // 食物图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6B4F4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fastfood,
              color: const Color(0xFF6B4F4F),
              size: 22,
            ),
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
            icon: Icon(
              Icons.remove_circle_outline,
              color: const Color(0xFF6B4F4F).withOpacity(0.6),
            ),
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
        color: const Color(0xFF6B4F4F).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B4F4F).withOpacity(0.15)),
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
            color: const Color(0xFF6B4F4F), // River Deep Brown
          ),
        ),
        Text(
          "$label ($unit)",
          style: GoogleFonts.kalam(
            fontSize: 10,
            color: const Color(0xFF6B4F4F).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to add subtle texture lines to the tape
class _TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines to simulate tape texture
    for (double y = 2; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for sketchy button border
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  Path _createSketchyPath(Size size) {
    final path = Path();
    final random = math.Random(seed);
    final step = 8.0;
    final wobble = wobbleAmount;

    // Top edge: left to right
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, noise);
    }
    path.lineTo(size.width, 0);

    // Right edge: top to bottom
    for (double y = step; y < size.height; y += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(size.width + noise, y);
    }
    path.lineTo(size.width, size.height);

    // Bottom edge: right to left
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, size.height + noise);
    }
    path.lineTo(0, size.height);

    // Left edge: bottom to top
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(noise, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 显示添加食物弹窗的便捷方法
Future<List<ExtraFood>?> showAddFoodDialog(BuildContext context) {
  return showDialog<List<ExtraFood>>(
    context: context,
    builder: (context) => const AddFoodDialog(),
  );
}
