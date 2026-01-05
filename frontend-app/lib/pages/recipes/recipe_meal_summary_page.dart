// lib/pages/recipes/recipe_meal_summary_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/consumption_history_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/services/cooking_api_service.dart';
import 'package:personal_sous_chef/main.dart';

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
    super.dispose();
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
        // 收集已完成的菜品 ID（如果 percentEaten > 0，认为已完成）
        final completedDishIds = <int>[];
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
          // 尝试解析 recipe.id 为 int（如果是后端返回的 Dish ID）
          // 注意：如果 recipe.id 不是数字格式，completedDishIds 可能为空
          // 这种情况下，后端会完成所有菜品（如果 completedDishIds 为空）
          final dishId = int.tryParse(recipe.id);
          if (dishId != null && dishId > 0) {
            completedDishIds.add(dishId);
          }

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

        // 调用finish cooking API
        // 注意：completedDishIds 可以为空，后端会自动完成所有菜品
        await CookingApiService.finishCooking(
          sessionId: widget.sessionId!,
          // 只有当能解析出真实后端 Dish ID 时才传；否则省略，让后端按"未指定=全部完成"处理。
          completedDishIds: completedDishIds.isEmpty ? null : completedDishIds,
          finalIngredients: finalIngredients,
          totalNutrition: {
            'calories': totalCalories,
            'protein': totalProtein,
            'fat': totalFat,
            'carbs': totalCarbs,
          },
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

    return Scaffold(
      appBar: AppBar(title: const Text('Meal summary')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Nice work! You finished this meal.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 卡路里卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories eaten (estimated)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalCalories.toStringAsFixed(0)} kcal total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (caloriesPerPerson != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '≈ ${caloriesPerPerson.toStringAsFixed(0)} kcal per person'
                        '${servings != null ? '  ($servings servings)' : ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    if (targetPerPerson != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Your target',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '≤ ${targetPerPerson.toStringAsFixed(0)} kcal per person',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (comparison != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          comparison,
                          style: theme.textTheme.bodySmall?.copyWith(
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
            ),

            const SizedBox(height: 20),

            Text(
              'Record what you used and ate',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust ingredient usage for the dishes you marked as done.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            ...completedRecipes.map((recipe) {
              final ingControllers = _ingredientControllers[recipe.id] ?? {};
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            recipe.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ingredients used',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (recipe.ingredients.isEmpty)
                        Text(
                          'No ingredients listed.',
                          style: theme.textTheme.bodySmall?.copyWith(
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
                                      style: theme.textTheme.bodyMedium,
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
                                      decoration: InputDecoration(
                                        labelText: 'Used',
                                        suffixText: ing.amountUnit,
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _saveConsumption(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save record',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
