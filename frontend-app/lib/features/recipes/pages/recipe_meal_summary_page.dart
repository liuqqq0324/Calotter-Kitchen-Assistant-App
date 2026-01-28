// lib/pages/recipes/recipe_meal_summary_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/stores/consumption_history_store.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/services/cooking/cooking_api_service.dart';
import 'package:personal_sous_chef/navigation/main_scaffold.dart'; // ⚠️ 已更新：MainScaffold 从 main.dart 移至 navigation/main_scaffold.dart
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_widgets.dart';

class RecipeMealSummaryPage extends StatefulWidget {
  final RecipeMenuModel menu;
  final Map<String, dynamic>? filter;
  final int? sessionId;
  final Set<int>? completedDishIndexes; // 已完成的菜品索引

  const RecipeMealSummaryPage({
    super.key,
    required this.menu,
    this.filter,
    this.sessionId,
    this.completedDishIndexes,
  });

  @override
  State<RecipeMealSummaryPage> createState() => _RecipeMealSummaryPageState();
}

class _RecipeMealSummaryPageState extends State<RecipeMealSummaryPage> {
  late final Map<String, double> _percentEaten; // recipeId -> percent
  late final Map<String, Map<String, TextEditingController>>
  _ingredientControllers; // recipeId -> ingredient name -> controller
  late final Map<String, TextEditingController>
      _totalWeightControllers; // recipeId -> total weight controller

  List<RecipeModel> get _completedRecipes {
    final recipes = widget.menu.recipes;
    final idx = widget.completedDishIndexes;
    if (idx == null || idx.isEmpty) return recipes;
    return idx
        .where((i) => i >= 0 && i < recipes.length)
        .map((i) => recipes[i])
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _percentEaten = {};
    _ingredientControllers = {};
    _totalWeightControllers = {};

    // 只为已完成的菜品初始化
    for (int i = 0; i < widget.menu.recipes.length; i++) {
      final recipe = widget.menu.recipes[i];
      // 如果提供了 completedDishIndexes，只初始化已完成的；否则初始化所有
      if (widget.completedDishIndexes == null ||
          widget.completedDishIndexes!.contains(i)) {
        _percentEaten[recipe.id] = 100;

        final controllers = <String, TextEditingController>{};
        for (final ing in recipe.ingredients) {
          controllers[ing.name] = TextEditingController(
            text: ing.amountValue.toString(),
          );
        }
        _ingredientControllers[recipe.id] = controllers;

        // 初始化总质量控制器，默认值为所有以g为单位的ingredients相加
        final defaultTotalWeight = _calculateDefaultTotalWeight(recipe);
        _totalWeightControllers[recipe.id] = TextEditingController(
          text: defaultTotalWeight.toStringAsFixed(0),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final entry in _ingredientControllers.values) {
      for (final controller in entry.values) {
        controller.dispose();
      }
    }
    for (final controller in _totalWeightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 计算默认总质量：将所有以g为单位的ingredients相加
  double _calculateDefaultTotalWeight(RecipeModel recipe) {
    double total = 0.0;
    for (final ing in recipe.ingredients) {
      if (ing.amountUnit.toLowerCase() == 'g' && ing.amountValue != null) {
        total += ing.amountValue;
      }
    }
    return total > 0 ? total : 1000.0; // 如果没有g单位的食材，默认1000g
  }

  double? get _targetCaloriesPerPerson {
    final filter = widget.filter;
    if (filter == null) return null;
    final raw = filter['calorie_target'];
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  int? get _servings {
    final filter = widget.filter;
    if (filter == null) return null;
    final raw = filter['servings'];
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  /// 判断是否为调料（基于后端标准调料库和标准食材库）
  /// 排除青椒/红椒等蔬菜类，只匹配明确的调料关键词
  bool _isSeasoning(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    // 明确排除的食材（青椒/红椒等蔬菜类）
    final vegetablePeppers = [
      'green pepper',
      'green-pepper',
      'red pepper',
      'red-pepper',
      'bell pepper',
      'sweet pepper',
      'capsicum',
    ];

    // 检查是否是青椒类食材（优先判断，避免误判）
    for (final veg in vegetablePeppers) {
      if (lowerName.contains(veg)) {
        return false; // 是青椒类食材，不是调料
      }
    }

    // 明确的调料关键词（基于标准调料库，仅英文）
    final seasoningKeywords = [
      'salt',
      'black pepper',
      'white pepper',
      'sichuan pepper',
      'chili powder',
      'pepper powder',
      'paprika',
      'soy sauce',
      'light soy sauce',
      'dark soy sauce',
      'oyster sauce',
      'bean paste',
      'vinegar',
      'cooking wine',
      'five spice powder',
      'star anise',
      'cinnamon',
      'bay leaf',
      'garlic powder',
      'ginger powder',
      'curry powder',
      'turmeric',
      'cumin',
      'coriander',
      'basil',
      'oregano',
      'thyme',
      'rosemary',
      'sesame oil',
      'olive oil',
      'vegetable oil',
      'oil',
      'sugar',
    ];

    for (final keyword in seasoningKeywords) {
      if (lowerName.contains(keyword)) {
        return true;
      }
    }

    // 如果只包含 "pepper" 但不匹配任何已知模式，默认视为食材（更安全）
    // 因为青椒类食材更常见，且标准食材库中有Green-Pepper和Red-Pepper
    return false;
  }

  Future<void> _saveConsumption(BuildContext context) async {
    // 如果有sessionId，调用后端API完成烹饪
    if (widget.sessionId != null) {
      try {
        final completedRecipes = _completedRecipes;
        final int completedDishCount = completedRecipes.length;
        final finalIngredients = <Map<String, dynamic>>[];
        double totalCalories = 0;
        double totalProtein = 0;
        double totalFat = 0;
        double totalCarbs = 0;

        // Summary 只处理"已标记 dish done"的菜品；不再显示/编辑 percent eaten，按 100% 处理
        for (final recipe in completedRecipes) {
          final percentEaten = 100.0;

          final ingControllers = _ingredientControllers[recipe.id] ?? {};

          // 只收集已完成的菜品用到的食材
          for (final ing in recipe.ingredients) {
            final controller = ingControllers[ing.name];
            final parsed = double.tryParse(controller?.text.trim() ?? '');
            final amount = parsed ?? ing.amountValue;

            finalIngredients.add({
              'name': ing.name,
              'amountValue': amount,
              'amountUnit': ing.amountUnit,
              'sourceType': _isSeasoning(ing.name) ? 'MANUAL_ADD' : 'INVENTORY',
            });
          }

          // 累加营养信息（按比例计算）
          totalCalories += (recipe.totalCaloriesEstimate * percentEaten / 100);
          totalProtein += (recipe.totalProtein ?? 0) * percentEaten / 100;
          totalFat += (recipe.totalFat ?? 0) * percentEaten / 100;
          totalCarbs += (recipe.totalCarb ?? 0) * percentEaten / 100;
        }

        // 这里要按"是否至少有一道菜被吃了/完成了"来校验，而不是按"是否能解析出数字 dishId"来校验。
        // 对于 AI/本地菜单，recipe.id 可能是 'm1_r1' 这种非数字，解析会失败，但仍应允许保存。
        if (completedDishCount == 0) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Please mark at least one dish as completed.'),
                duration: Duration(seconds: 2),
              ),
            );
          return;
        }

        // 收集每个dish的总质量
        final dishTotalWeights = <Map<String, dynamic>>[];
        for (final recipe in completedRecipes) {
          final weightController = _totalWeightControllers[recipe.id];
          if (weightController != null) {
            final totalWeight = double.tryParse(weightController.text.trim());
            if (totalWeight != null && totalWeight > 0) {
              // 使用recipe.title作为recipeId，后端会通过dish的name匹配
              dishTotalWeights.add({
                'recipeId': recipe.title, // 使用title，后端通过dish的name匹配
                'totalWeightGram': totalWeight.toInt(),
              });
            }
          }
        }

        // 调用finish cooking API
        // 注意：后端会自动完成 session 中的所有 dish，不再需要传递 completedDishIds
        await CookingApiService.finishCooking(
          sessionId: widget.sessionId!,
          finalIngredients: finalIngredients,
          totalNutrition: {
            'calories': totalCalories,
            'protein': totalProtein,
            'fat': totalFat,
            'carbs': totalCarbs,
          },
          dishTotalWeights: dishTotalWeights.isNotEmpty ? dishTotalWeights : null,
          // diners: 可选，后续可以添加用餐者信息输入
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Meal consumption recorded successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
      } catch (e) {
        print('[MealSummary] Failed to finish cooking: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Failed to save: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        return; // 如果API调用失败，不继续
      }
    }

    // 同时保存到本地（用于历史记录）
    final dishes = <DishConsumptionRecord>[];

    for (final recipe in _completedRecipes) {
      final percent = 100.0;
      final ingControllers = _ingredientControllers[recipe.id] ?? {};

      final ingredientUsage = recipe.ingredients.map((ing) {
        final controller = ingControllers[ing.name];
        final parsed = double.tryParse(controller?.text.trim() ?? '');
        final amount = parsed ?? ing.amountValue;
        return IngredientUsageRecord(
          name: ing.name,
          amountValue: amount,
          amountUnit: ing.amountUnit,
        );
      }).toList();

      dishes.add(
        DishConsumptionRecord(
          recipeId: recipe.id,
          recipeTitle: recipe.title,
          percentEaten: percent,
          ingredientsUsed: ingredientUsage,
        ),
      );
    }

    final record = MealConsumptionRecord(
      cookedAt: DateTime.now(),
      menuId: widget.menu.menuId,
      dishes: dishes,
    );

    ConsumptionHistoryStore.add(record);

    if (!mounted) return;
    // 保存记录后直接回到 My Recipes（Recipes tab），而不是弹回 LandingPage 或 InstructionPage。
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold(initialIndex: 1)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final completedRecipes = _completedRecipes;
    final totalCalories = completedRecipes.fold<double>(
      0,
      (sum, r) => sum + r.totalCaloriesEstimate,
    );
    final servings = _servings;
    final caloriesPerPerson = servings != null && servings > 0
        ? totalCalories / servings
        : null;
    final targetPerPerson = _targetCaloriesPerPerson;

    String? comparison;
    if (caloriesPerPerson != null && targetPerPerson != null) {
      if (caloriesPerPerson <= targetPerPerson) {
        comparison = 'Within your target per person.';
      } else {
        comparison = 'Above your target per person.';
      }
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Meal summary',
            style: GoogleFonts.caveat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true, // 标题居中
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: _GridPaper(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Nice work! You finished this meal.',
                  style: GoogleFonts.kalam(
                    fontSize: 20, // 增大字体
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // 卡路里卡片 - 便签样式（带胶带和锯齿边框）
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Background Layer: Sketchy paper container
                    Container(
                      width: double.infinity, // 确保宽度填满
                      margin: const EdgeInsets.only(top: 14), // Space for tape
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calories eaten (estimated)',
                            style: GoogleFonts.kalam(
                              fontSize: 18, // 增大字体
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalCalories.toStringAsFixed(0)} kcal total',
                            style: GoogleFonts.kalam(
                              fontSize: 24, // 增大字体
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          if (caloriesPerPerson != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '≈ ${caloriesPerPerson.toStringAsFixed(0)} kcal per person'
                              '${servings != null ? '  ($servings servings)' : ''}',
                              style: GoogleFonts.kalam(
                                fontSize: 16, // 增大字体
                                color: Colors.grey[700],
                              ),
                            ),
                          ],

                          if (targetPerPerson != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Your target',
                              style: GoogleFonts.kalam(
                                fontSize: 16, // 增大字体
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '≤ ${targetPerPerson.toStringAsFixed(0)} kcal per person',
                              style: GoogleFonts.kalam(
                                fontSize: 18, // 增大字体
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (comparison != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                comparison,
                                style: GoogleFonts.kalam(
                                  fontSize: 16, // 增大字体
                                  color: comparison.startsWith('Within')
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ],
                        ],
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
                            // Semi-transparent yellowish-white tape color
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

                const SizedBox(height: 20),

                Text(
                  'Record what you used and ate',
                  style: GoogleFonts.kalam(
                    fontSize: 20, // 增大字体
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust ingredient usage for the dishes you marked as done.',
                  style: GoogleFonts.kalam(
                    fontSize: 16, // 增大字体
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                ...completedRecipes.map((recipe) {
                  final ingControllers =
                      _ingredientControllers[recipe.id] ?? {};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Background Layer: Sketchy paper container
                        Container(
                          width: double.infinity, // 确保宽度填满，与卡路里便签对齐
                          margin: const EdgeInsets.only(
                            top: 14,
                          ), // Space for tape
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: const Color(
                              0xFFFFFFF0,
                            ), // Off-white/cream color
                            shape: const SketchyRectBorder(
                              borderWidth: 1.0,
                              wobbleAmount: 2.5,
                              seed: 43, // Different seed for variety
                            ),
                            shadows: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6B4F4F,
                                ).withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(2, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      recipe.title,
                                      style: GoogleFonts.kalam(
                                        fontSize: 20, // 增大字体
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ingredients used',
                                style: GoogleFonts.kalam(
                                  fontSize: 18, // 增大字体
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (recipe.ingredients.isEmpty)
                                Text(
                                  'No ingredients listed.',
                                  style: GoogleFonts.kalam(
                                    fontSize: 16, // 增大字体
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Column(
                                  children: recipe.ingredients.map((ing) {
                                    final controller = ingControllers[ing.name];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              ing.name,
                                              style: GoogleFonts.kalam(
                                                fontSize: 18, // 增大字体
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 110,
                                            child: TextField(
                                              controller: controller,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              style: GoogleFonts.kalam(
                                                fontSize: 16, // 增大字体
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Used',
                                                labelStyle: GoogleFonts.kalam(
                                                  fontSize: 14, // 增大字体
                                                ),
                                                suffixText: ing.amountUnit,
                                                suffixStyle: GoogleFonts.kalam(
                                                  fontSize: 14, // 增大字体
                                                ),
                                                isDense: true,
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                'Total weight',
                                style: GoogleFonts.kalam(
                                  fontSize: 18, // 增大字体
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total weight of this dish (default: sum of all ingredients in g)',
                                      style: GoogleFonts.kalam(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _totalWeightControllers[recipe.id],
                                      keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: GoogleFonts.kalam(
                                        fontSize: 16, // 增大字体
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Weight',
                                        labelStyle: GoogleFonts.kalam(
                                          fontSize: 14, // 增大字体
                                        ),
                                        suffixText: 'g',
                                        suffixStyle: GoogleFonts.kalam(
                                          fontSize: 14, // 增大字体
                                        ),
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                                // Semi-transparent yellowish-white tape color
                                color: const Color(0xFFFFF8DC).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(2),
                                // Add a subtle border to make it look more like tape
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
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
                              child: CustomPaint(
                                painter: _TapeTexturePainter(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Save record 按钮 - 使用手绘风格（棕色背景，无阴影）
                SizedBox(
                  height: 70,
                  child: _SketchyButtonWithAnimation(
                    backgroundColor: const Color(0xFFD2B48C), // 棕色背景
                    withShadow: false, // 关闭阴影
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onPressed: () => _saveConsumption(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_alt,
                          size: 22,
                          color: const Color(0xFF6B4F4F),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Save record',
                            style: GoogleFonts.kalam(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B4F4F),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 格纹纸背景组件
class _GridPaper extends StatelessWidget {
  final Widget child;

  const _GridPaper({required this.child});

  @override
  Widget build(BuildContext context) {
    final margin5mm = 18.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: margin5mm, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: CustomPaint(painter: _GridPaperPainter(), child: child),
          );
        },
      ),
    );
  }
}

/// 格子纸绘制器
class _GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      return;
    }

    final random = math.Random(42);

    // 创建不规则边缘路径
    final path = _createIrregularPath(size, random);

    // 1. 先绘制阴影效果
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

    // 3. 绘制网格线
    final gridPaint = Paint()
      ..color =
          const Color(0xFFE3E6E8) // 网格线颜色
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSpacing = 20.0;

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

    // 4. 绘制不规则边缘线
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
    const double edgeNoise = 2.5;
    const double step = 8.0;

    final double effectiveWidth = size.width > 0 ? size.width : 100.0;
    final double effectiveHeight = size.height > 0 ? size.height : 100.0;

    // 顶部边缘
    path.moveTo(0, 0);
    for (double x = step; x < effectiveWidth; x += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = noise.clamp(-edgeNoise, edgeNoise).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, 0);

    // 右侧边缘
    for (double y = step; y < effectiveHeight; y += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = (effectiveWidth + noise.clamp(-edgeNoise, edgeNoise))
          .toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, effectiveHeight);

    // 底部边缘
    for (double x = effectiveWidth - step; x > 0; x -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = (effectiveHeight + noise.clamp(-edgeNoise, edgeNoise))
          .toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(0, effectiveHeight);

    // 左侧边缘
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

/// 胶带纹理绘制器
class _TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 绘制水平线来模拟胶带纹理
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
  final Color? backgroundColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.backgroundColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);

    // 1. 先画背景（如果有）
    if (backgroundColor != null) {
      final fillPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // 2. 再画边框
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);
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

/// 带点击加深动画的手绘按钮
class _SketchyButtonWithAnimation extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool withShadow;

  const _SketchyButtonWithAnimation({
    required this.onPressed,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.withShadow = false,
  });

  @override
  State<_SketchyButtonWithAnimation> createState() =>
      _SketchyButtonWithAnimationState();
}

class _SketchyButtonWithAnimationState
    extends State<_SketchyButtonWithAnimation> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(
      0xFF6B4F4F,
    ).withOpacity(_isPressed ? 1.0 : 0.7);

    // 计算 Padding：如果有传入则用传入的，否则用默认较小的值
    final effectivePadding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_isPressed ? -0.05 : 0.0)
            ..scale(_isPressed ? 0.98 : 1.0),
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            // 只有当开启阴影且未按下时显示阴影（模拟按压感）
            boxShadow: (widget.withShadow && !_isPressed)
                ? [
                    BoxShadow(
                      color: const Color(0xFF6B4F4F).withOpacity(0.15),
                      offset: const Offset(2, 3),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              backgroundColor: widget.backgroundColor,
              borderWidth: _isPressed ? 2.0 : 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
