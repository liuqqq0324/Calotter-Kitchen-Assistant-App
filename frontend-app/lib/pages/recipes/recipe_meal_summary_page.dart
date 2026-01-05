// lib/pages/recipes/recipe_meal_summary_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/consumption_history_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/services/cooking_api_service.dart';

class RecipeMealSummaryPage extends StatefulWidget {
  final RecipeMenuModel menu;
  final Map<String, dynamic>? filter;
  final int? sessionId;

  const RecipeMealSummaryPage({
    super.key,
    required this.menu,
    this.filter,
    this.sessionId,
  });

  @override
  State<RecipeMealSummaryPage> createState() => _RecipeMealSummaryPageState();
}

class _RecipeMealSummaryPageState extends State<RecipeMealSummaryPage> {
  late final Map<String, double> _percentEaten; // recipeId -> percent
  late final Map<String, Map<String, TextEditingController>>
      _ingredientControllers; // recipeId -> ingredient name -> controller

  @override
  void initState() {
    super.initState();
    _percentEaten = {};
    _ingredientControllers = {};

    for (final recipe in widget.menu.recipes) {
      _percentEaten[recipe.id] = 100;

      final controllers = <String, TextEditingController>{};
      for (final ing in recipe.ingredients) {
        controllers[ing.name] =
            TextEditingController(text: ing.amountValue.toString());
      }
      _ingredientControllers[recipe.id] = controllers;
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

  Future<void> _saveConsumption(BuildContext context) async {
    // 如果有sessionId，调用后端API完成烹饪
    if (widget.sessionId != null) {
      try {
        // 收集已完成的菜品 ID（如果 percentEaten > 0，认为已完成）
        final completedDishIds = <int>[];
        final finalIngredients = <Map<String, dynamic>>[];
        double totalCalories = 0;
        double totalProtein = 0;
        double totalFat = 0;
        double totalCarbs = 0;
        
        // 检查是否有任何菜品被标记为已吃（percentEaten > 0）
        bool hasAnyCompletedDish = false;

        for (final recipe in widget.menu.recipes) {
          final percentEaten = _percentEaten[recipe.id] ?? 0;
          
          // 如果吃了 > 0%，认为这道菜已完成
          if (percentEaten > 0) {
            hasAnyCompletedDish = true; // 标记有已完成的菜品
            
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
                'sourceType': ing.name.toLowerCase().contains('salt') || 
                             ing.name.toLowerCase().contains('oil') ||
                             ing.name.toLowerCase().contains('pepper')
                    ? 'MANUAL_ADD' : 'INVENTORY', // 简化判断，实际应该从recipe中获取
              });
            }

            // 累加营养信息（按比例计算）
            totalCalories += (recipe.totalCaloriesEstimate * percentEaten / 100);
            totalProtein += (recipe.totalProtein ?? 0) * percentEaten / 100;
            totalFat += (recipe.totalFat ?? 0) * percentEaten / 100;
            totalCarbs += (recipe.totalCarb ?? 0) * percentEaten / 100;
          }
        }

        // 修改：检查是否有任何已完成的菜品，而不是检查 completedDishIds 是否为空
        // 因为后端支持 completedDishIds 为空（表示完成所有菜品）
        if (!hasAnyCompletedDish) {
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

    for (final recipe in widget.menu.recipes) {
      final percent = _percentEaten[recipe.id] ?? 0;
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
    
    // 返回到 RecipesHomePage，而不是 LandingPage
    // 路由栈结构：MainScaffold -> RecipeInstructionPage -> MealSummaryPage
    // 注意：RecipesHomePage 是 MainScaffold 的一个 tab，不是独立路由
    // MainScaffold 是登录后 pushReplacement 的，所以它应该是第一个路由（isFirst = true）
    // 从 MealSummaryPage 返回到 MainScaffold，需要 pop 两次
    
    // 方案：直接 pop 两次，返回到 MainScaffold
    // 由于 MainScaffold 是登录后 pushReplacement 的，所以它应该是第一个路由
    // MainScaffold 会自动显示 RecipesHomePage（因为它是 MainScaffold 的一个 tab）
    
    // 返回到 RecipeInstructionPage
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // 再返回到 MainScaffold（RecipesHomePage 是 MainScaffold 的一个 tab）
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCalories = widget.menu.totalCalories;
    final servings = _servings;
    final caloriesPerPerson =
        servings != null && servings > 0 ? totalCalories / servings : null;
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
      appBar: AppBar(
        title: const Text('Meal summary'),
      ),
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
              'Adjust ingredient usage and how much of each dish was eaten. Data is stored locally until backend is ready.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            ...widget.menu.recipes.map((recipe) {
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
                          const Spacer(),
                          Text(
                            '${_percentEaten[recipe.id]?.toStringAsFixed(0) ?? 0}%',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Slider(
                        value: _percentEaten[recipe.id] ?? 0,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label:
                            '${_percentEaten[recipe.id]?.toStringAsFixed(0) ?? 0}%',
                        onChanged: (val) {
                          setState(() {
                            _percentEaten[recipe.id] = val;
                          });
                        },
                      ),
                      const SizedBox(height: 4),
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
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        )
                      else
                        Column(
                          children: recipe.ingredients.map((ing) {
                            final controller = ingControllers[ing.name];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
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
