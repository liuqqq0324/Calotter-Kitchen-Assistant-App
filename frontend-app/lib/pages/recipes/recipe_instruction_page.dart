// lib/pages/recipes/recipe_instruction_page.dart
import 'dart:async';
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
  final Map<int, int> _remainingSeconds = {};
  final Map<int, Timer> _runningTimers = {};
  final Map<int, bool> _pausedSteps = {};
  final Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialRecipeIndex;
    _completedDishes = <int>{};
  }

  @override
  void dispose() {
    for (final t in _runningTimers.values) {
      t.cancel();
    }
    super.dispose();
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

  void _startTimerForStep(int stepNumber, int minutes) {
    final totalSeconds = (minutes <= 0 ? 1 : minutes) * 60;
    final startFrom = _remainingSeconds[stepNumber] ?? totalSeconds;
    _pausedSteps[stepNumber] = false;
    _completedSteps.remove(stepNumber);
    _runningTimers[stepNumber]?.cancel();
    _remainingSeconds[stepNumber] = startFrom;
    _runningTimers[stepNumber] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final next = (_remainingSeconds[stepNumber] ?? startFrom) - 1;
        _remainingSeconds[stepNumber] = next;
        if (next <= -totalSeconds) {
          // auto stop after超时同长度
          timer.cancel();
          _runningTimers.remove(stepNumber);
        }
      });
    });
  }

  void _stopTimerForStep(int stepNumber) {
    _runningTimers[stepNumber]?.cancel();
    _runningTimers.remove(stepNumber);
    setState(() {
      _remainingSeconds.remove(stepNumber);
      _pausedSteps.remove(stepNumber);
    });
  }

  void _pauseTimer(int stepNumber) {
    _runningTimers[stepNumber]?.cancel();
    _runningTimers.remove(stepNumber);
    _pausedSteps[stepNumber] = true;
    setState(() {});
  }

  void _stopAndCompleteStep(int stepNumber) {
    _stopTimerForStep(stepNumber);
    setState(() {
      _completedSteps.add(stepNumber);
    });
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
    final remaining = _remainingSeconds[step.stepNumber];
    final isRunning = _runningTimers.containsKey(step.stepNumber);
    final isOvertime = remaining != null && remaining < 0;
    final isPaused = _pausedSteps[step.stepNumber] == true;
    final isCompleted = _completedSteps.contains(step.stepNumber);

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
                  Row(
                    children: [
                      Text(
                        '~ ${step.stepTimeMin} min',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      if (remaining != null)
                        Text(
                          remaining >= 0
                              ? 'Left ${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}'
                              : 'Over by ${(-remaining) ~/ 60}:${((-remaining) % 60).toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOvertime ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isRunning
                            ? () => _pauseTimer(step.stepNumber)
                            : () => _startTimerForStep(
                                step.stepNumber, step.stepTimeMin),
                        icon: Icon(
                          isRunning
                              ? Icons.pause_circle
                              : (isPaused
                                  ? Icons.play_circle
                                  : Icons.timer_outlined),
                          size: 16,
                          color: isRunning
                              ? Colors.orange
                              : (isOvertime ? Colors.red : Colors.orange),
                        ),
                        label: Text(
                          isRunning
                              ? 'Pause'
                              : (isPaused ? 'Resume' : 'Start timer'),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isOvertime ? Colors.red : Colors.orange,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _stopAndCompleteStep(step.stepNumber),
                        icon: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        label: const Text('Mark step done'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Step completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
