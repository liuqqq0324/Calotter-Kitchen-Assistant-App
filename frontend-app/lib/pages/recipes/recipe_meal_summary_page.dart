// lib/pages/recipes/recipe_meal_summary_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

class RecipeMealSummaryPage extends StatelessWidget {
  final RecipeMenuModel menu;
  final Map<String, dynamic>? filter;

  const RecipeMealSummaryPage({
    super.key,
    required this.menu,
    this.filter,
  });

  double? get _targetCaloriesPerPerson {
    if (filter == null) return null;
    final raw = filter!['calorie_target'];
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  int? get _servings {
    if (filter == null) return null;
    final raw = filter!['servings'];
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCalories = menu.totalCalories;
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

                      // ✅ 只有用户真的设了 target 才显示下面这一块
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

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 简单版本：直接返回栈底（比如首页）
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
