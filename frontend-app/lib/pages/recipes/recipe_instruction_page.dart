// lib/pages/recipes/recipe_instruction_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/collected_recipes_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_meal_summary_page.dart';

class RecipeInstructionPage extends StatefulWidget {
  final RecipeMenuModel menu;
  final int initialRecipeIndex;
  final Map<String, dynamic>? filter;

  const RecipeInstructionPage({
    super.key,
    required this.menu,
    this.initialRecipeIndex = 0,
    this.filter,
  });

  @override
  State<RecipeInstructionPage> createState() => _RecipeInstructionPageState();
}

class _RecipeInstructionPageState extends State<RecipeInstructionPage> {
  late int _currentIndex;
  late Set<int> _completedDishes;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialRecipeIndex;
    _completedDishes = <int>{};
  }

  int get _totalDishes => widget.menu.recipes.length;

  bool get _isCurrentDishDone => _completedDishes.contains(_currentIndex);

  bool get _isWholeMealDone => _completedDishes.length == _totalDishes;

  void _toggleCollectRecipe() {
    final recipe = widget.menu.recipes[_currentIndex];
    final wasCollected = CollectedRecipesStore.isCollected(recipe);
    CollectedRecipesStore.toggle(recipe);

    final text = wasCollected
        ? 'Removed recipe from your collection.'
        : 'Saved recipe to your collection.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _toggleDishDone() {
    setState(() {
      if (_isCurrentDishDone) {
        _completedDishes.remove(_currentIndex);
      } else {
        _completedDishes.add(_currentIndex);
      }
    });
  }

  void _goToNextDish() {
    if (_currentIndex < _totalDishes - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _goToPrevDish() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _onMealDone() {
    if (!_isWholeMealDone) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeMealSummaryPage(
          menu: widget.menu,
          filter: widget.filter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.menu.recipes[_currentIndex];
    final theme = Theme.of(context);
    final steps = recipe.steps;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          ValueListenableBuilder<List<RecipeModel>>(
            valueListenable: CollectedRecipesStore.favorites,
            builder: (context, favorites, _) {
              final isCollected = favorites.any((r) => r.id == recipe.id);

              return IconButton(
                onPressed: _toggleCollectRecipe,
                icon: Icon(
                  isCollected ? Icons.favorite : Icons.favorite_outline,
                ),
                tooltip:
                    isCollected ? 'Remove from favorites' : 'Save this recipe',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：emoji + 简介 + 时间卡路里
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.shortDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookingTimeMin} min',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.local_fire_department,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.totalCaloriesEstimate.toStringAsFixed(0)} kcal',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Ingredients',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ing.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${ing.amountValue} ${ing.amountUnit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          if (ing.isOptional) ...[
                            const SizedBox(width: 8),
                            Text(
                              'optional',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              Text(
                'Steps',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: steps.isNotEmpty
                    ? ListView.builder(
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          final step = steps[index];
                          return _buildStepItem(step: step);
                        },
                      )
                    : ListView(
                        children: [
                          _buildStepItem(
                            step: const RecipeStepModel(
                              stepNumber: 1,
                              instruction:
                                  'Beat the eggs with a pinch of salt.',
                              stepTimeMin: 3,
                            ),
                          ),
                          _buildStepItem(
                            step: const RecipeStepModel(
                              stepNumber: 2,
                              instruction:
                                  'Stir-fry tomatoes until soft, then add eggs.',
                              stepTimeMin: 7,
                            ),
                          ),
                          _buildStepItem(
                            step: const RecipeStepModel(
                              stepNumber: 3,
                              instruction: 'Season to taste and serve hot.',
                              stepTimeMin: 5,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomControls(context),
    );
  }

  Widget _buildStepItem({
    required RecipeStepModel step,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左边圆圈步骤号
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.stepNumber.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 右边文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: theme.textTheme.bodyMedium,
                ),
                if (step.stepTimeMin > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '~ ${step.stepTimeMin} min',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                                'Start a ${step.stepTimeMin} min timer on your phone or watch.'),
                          ),
                        );
                    },
                    icon: const Icon(Icons.timer_outlined, size: 16),
                    label: const Text('Start timer'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final theme = Theme.of(context);

    final isCurrentDone = _isCurrentDishDone;
    final isMealDone = _isWholeMealDone;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上面一行：第几道菜 + 左右切换
            Row(
              children: [
                Text(
                  'Dish ${_currentIndex + 1} of $_totalDishes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _currentIndex > 0 ? _goToPrevDish : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed:
                      _currentIndex < _totalDishes - 1 ? _goToNextDish : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 下面一行：Dish done + Meal done
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleDishDone,
                    icon: Icon(
                      isCurrentDone
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    ),
                    label: Text(
                      isCurrentDone ? 'Dish done' : 'Mark dish done',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isMealDone ? _onMealDone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Meal done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
