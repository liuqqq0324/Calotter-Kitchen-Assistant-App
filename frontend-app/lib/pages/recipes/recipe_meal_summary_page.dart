// lib/pages/recipes/recipe_meal_summary_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/consumption_history_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

class RecipeMealSummaryPage extends StatefulWidget {
  final RecipeMenuModel menu;
  final Map<String, dynamic>? filter;

  const RecipeMealSummaryPage({
    super.key,
    required this.menu,
    this.filter,
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

  void _saveConsumption(BuildContext context) {
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Meal consumption recorded locally.'),
          duration: Duration(seconds: 2),
        ),
      );

    Navigator.popUntil(context, (route) => route.isFirst);
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
                  'Save record & back to home',
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
