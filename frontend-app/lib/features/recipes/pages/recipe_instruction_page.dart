// lib/pages/recipes/recipe_instruction_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/stores/collected_recipes_store.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_meal_summary_page.dart';
import 'package:personal_sous_chef/services/cooking/cooking_api_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';

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
  // Timers/steps must be keyed per dish + per step.
  // Otherwise stepNumber=1 in dish A collides with stepNumber=1 in dish B/C and all appear to start together.
  final Map<String, int> _remainingSeconds = {};
  final Map<String, Timer> _runningTimers = {};
  final Map<String, bool> _pausedSteps = {};
  final Set<String> _completedSteps = {};
  int? _sessionId;
  bool _sessionCreated = false;

  int _currentFocusedStepNumber = 1; // Current focused step number

  String _stepKey(int dishIndex, int stepNumber) => '$dishIndex:$stepNumber';

  @override
  void initState() {
    super.initState();
    debugPrint('[RecipePage] Recipe instruction page initialized');
    _currentIndex = widget.initialRecipeIndex;
    _completedDishes = <int>{};
    _createCookingSession();
  }

  /// 创建烹饪session（传入整个 Menu）
  Future<void> _createCookingSession() async {
    try {
      final householdId = await HouseholdService.getHouseholdId();
      final initiatorId = await HouseholdService.getInitiatorId();

      if (householdId == null || initiatorId == null) {
        print('[RecipePage] Failed to get householdId or initiatorId');
        return;
      }

      // 将整个 Menu 的所有菜品转换为后端需要的格式（使用驼峰命名）
      final recipesJson = widget.menu.recipes
          .map(
            (recipe) => {
              'title': recipe.title,
              'shortDescription': recipe.shortDescription,
              'servings': recipe.servings,
              'cookingTimeMin': recipe.cookingTimeMin,
              'difficulty': recipe.difficulty,
              'nutritionEstimate': {
                'calories': recipe.totalCaloriesEstimate,
                'proteinG': recipe.totalProtein ?? 0.0,
                'fatG': recipe.totalFat ?? 0.0,
                'carbsG': recipe.totalCarb ?? 0.0,
              },
              'ingredients': recipe.ingredients
                  .map(
                    (ing) => {
                      'name': ing.name,
                      'amountValue': ing.amountValue,
                      'amountUnit': ing.amountUnit,
                      'isOptional': ing.isOptional,
                      'sourceType': 'MANUAL_ADD',
                    },
                  )
                  .toList(),
              'steps': recipe.steps
                  .map(
                    (step) => {
                      'stepNumber': step.stepNumber,
                      'instruction': step.instruction,
                      'stepTimeMin': step.stepTimeMin,
                    },
                  )
                  .toList(),
            },
          )
          .toList();

      final sessionId = await CookingApiService.startCooking(
        householdId: householdId,
        initiatorId: initiatorId,
        recipes: recipesJson, // 传入整个 Menu
        menuId: widget.menu.menuId,
      );

      if (mounted) {
        setState(() {
          _sessionId = sessionId;
          _sessionCreated = true;
        });
        print(
          '[RecipePage] Created cooking session: $sessionId for menu with ${widget.menu.recipes.length} dishes',
        );
      }
    } catch (e) {
      print('[RecipePage] Failed to create cooking session: $e');
      // 不阻止用户继续使用，只是记录错误
    }
  }

  @override
  void dispose() {
    for (final t in _runningTimers.values) {
      t.cancel();
    }
    debugPrint('[RecipePage] Recipe instruction page disposed');
    super.dispose();
  }

  int get _totalDishes => widget.menu.recipes.length;

  bool get _isCurrentDishDone => _completedDishes.contains(_currentIndex);

  bool get _isWholeMealDone => _completedDishes.length == _totalDishes;

  Future<void> _toggleCollectRecipe() async {
    final recipe = widget.menu.recipes[_currentIndex];
    final wasCollected = CollectedRecipesStore.isCollected(recipe);
    try {
      final householdId = await HouseholdService.getHouseholdId();
      if (householdId == null) {
        throw Exception('Failed to get householdId');
      }

      final saved = await CollectedRecipesStore.toggle(
        recipe,
        householdId: householdId,
      );
      if (!wasCollected && saved != null) {
        setState(() {
          widget.menu.recipes[_currentIndex] = saved;
        });
        print(
          '[RecipePage] Updated recipe id after saving: ${saved.id} (${saved.title})',
        );
      }
      final text = wasCollected
          ? 'Removed recipe from your collection.'
          : 'Saved recipe to your collection.';
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
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
        _currentFocusedStepNumber = 1; // 重置到第一步
      });
    }
  }

  void _goToPrevDish() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentFocusedStepNumber = 1; // 重置到第一步
      });
    }
  }

  void _onMealDone() {
    // 支持部分完成：即使不是全部完成也可以保存
    if (_completedDishes.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please mark at least one dish as done.'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeMealSummaryPage(
          menu: widget.menu,
          filter: widget.filter,
          sessionId: _sessionId,
          completedDishIndexes: _completedDishes, // 传递已完成的菜品索引
        ),
      ),
    );
  }

  void _startTimerForStep(int dishIndex, int stepNumber, int minutes) {
    final key = _stepKey(dishIndex, stepNumber);
    final totalSeconds = (minutes <= 0 ? 1 : minutes) * 60;
    final startFrom = _remainingSeconds[key] ?? totalSeconds;
    _pausedSteps[key] = false;
    _completedSteps.remove(key);
    _runningTimers[key]?.cancel();
    _remainingSeconds[key] = startFrom;
    _runningTimers[key] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final next = (_remainingSeconds[key] ?? startFrom) - 1;
        _remainingSeconds[key] = next;
        if (next <= -totalSeconds) {
          // auto stop after超时同长度
          timer.cancel();
          _runningTimers.remove(key);
        }
      });
    });
  }

  void _stopTimerForStep(int dishIndex, int stepNumber) {
    final key = _stepKey(dishIndex, stepNumber);
    _runningTimers[key]?.cancel();
    _runningTimers.remove(key);
    setState(() {
      _remainingSeconds.remove(key);
      _pausedSteps.remove(key);
    });
  }

  void _pauseTimer(int dishIndex, int stepNumber) {
    final key = _stepKey(dishIndex, stepNumber);
    _runningTimers[key]?.cancel();
    _runningTimers.remove(key);
    _pausedSteps[key] = true;
    setState(() {});
  }

  void _stopAndCompleteStep(int dishIndex, int stepNumber) {
    final key = _stepKey(dishIndex, stepNumber);
    _stopTimerForStep(dishIndex, stepNumber);
    setState(() {
      _completedSteps.add(key);
    });
  }

  // ========== Voice Control Methods ==========

  /// 获取当前菜品的步骤列表
  List<RecipeStepModel> get _currentSteps =>
      widget.menu.recipes[_currentIndex].steps;

  /// 获取当前聚焦的步骤
  RecipeStepModel? _getFocusedStep() {
    if (_currentFocusedStepNumber < 1 ||
        _currentFocusedStepNumber > _currentSteps.length) {
      return _currentSteps.isNotEmpty ? _currentSteps[0] : null;
    }
    return _currentSteps[_currentFocusedStepNumber - 1];
  }

  /// 获取下一个步骤
  RecipeStepModel? _getNextStep() {
    if (_currentFocusedStepNumber < _currentSteps.length) {
      return _currentSteps[_currentFocusedStepNumber]; // _currentFocusedStepNumber 是 1-based，数组是 0-based，所以这里直接使用
    }
    return null;
  }

  /// 获取上一个步骤
  RecipeStepModel? _getPreviousStep() {
    if (_currentFocusedStepNumber > 1) {
      return _currentSteps[_currentFocusedStepNumber - 2];
    }
    return null;
  }

  /// 切换到指定步骤
  void _jumpToStep(int stepNumber) {
    if (stepNumber >= 1 && stepNumber <= _currentSteps.length) {
      setState(() {
        _currentFocusedStepNumber = stepNumber;
      });
    }
  }

  void _toggleVoiceMode() {
    debugPrint('[RecipePage] Voice mode toggle - stub implementation');
  }

  void _toggleGestureMode() {
    debugPrint('[RecipePage] Gesture mode toggle - stub implementation');
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
                tooltip: isCollected
                    ? 'Remove from favorites'
                    : 'Save this recipe',
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
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookingTimeMin} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.totalCaloriesEstimate.toStringAsFixed(0)} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
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
                          ],
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

  Widget _buildStepItem({required RecipeStepModel step}) {
    final theme = Theme.of(context);
    final key = _stepKey(_currentIndex, step.stepNumber);
    final remaining = _remainingSeconds[key];
    final isRunning = _runningTimers.containsKey(key);
    final isOvertime = remaining != null && remaining < 0;
    final isPaused = _pausedSteps[key] == true;
    final isCompleted = _completedSteps.contains(key);

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
                Text(step.instruction, style: theme.textTheme.bodyMedium),
                if (step.stepTimeMin > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '~ ${step.stepTimeMin} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                            ? () => _pauseTimer(_currentIndex, step.stepNumber)
                            : () => _startTimerForStep(
                                _currentIndex,
                                step.stepNumber,
                                step.stepTimeMin,
                              ),
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
                        onPressed: () => _stopAndCompleteStep(
                          _currentIndex,
                          step.stepNumber,
                        ),
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
    final completedCount = _completedDishes.length;
    final hasCompleted = completedCount > 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上面一行：第几道菜 + 进度 + 左右切换
            Row(
              children: [
                Text(
                  'Dish ${_currentIndex + 1} of $_totalDishes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasCompleted) ...[
                  const SizedBox(width: 8),
                  Text(
                    '($completedCount/$_totalDishes completed)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: _currentIndex > 0 ? _goToPrevDish : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: _currentIndex < _totalDishes - 1
                      ? _goToNextDish
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 下面一行：Dish done + Save progress
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
                    label: Text(isCurrentDone ? 'Dish done' : 'Mark dish done'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasCompleted ? _onMealDone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _isWholeMealDone
                          ? 'Meal done'
                          : 'Save progress ($completedCount dishes)',
                    ),
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
