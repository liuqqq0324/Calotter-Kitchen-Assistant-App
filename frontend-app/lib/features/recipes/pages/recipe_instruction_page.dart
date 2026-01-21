// lib/pages/recipes/recipe_instruction_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personal_sous_chef/data/stores/collected_recipes_store.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_meal_summary_page.dart';
import 'package:personal_sous_chef/services/cooking/cooking_api_service.dart';
import 'package:personal_sous_chef/services/cooking/cooking_voice_assistant.dart';
import 'package:personal_sous_chef/services/cooking/cooking_gesture_control.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';

class RecipeInstructionPage extends StatefulWidget {
  final RecipeMenuModel menu;
  final int initialRecipeIndex;
  final Map<String, dynamic>? filter;
  final bool isViewMode; // true: 只看模式, false: 烹饪模式

  const RecipeInstructionPage({
    super.key,
    required this.menu,
    this.initialRecipeIndex = 0,
    this.filter,
    this.isViewMode = false, // 默认为烹饪模式
  });

  @override
  State<RecipeInstructionPage> createState() => _RecipeInstructionPageState();
}

class _RecipeInstructionPageState extends State<RecipeInstructionPage>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late Set<int> _completedDishes;
  late TabController _tabController;
  // Timers/steps must be keyed per dish + per step.
  // Otherwise stepNumber=1 in dish A collides with stepNumber=1 in dish B/C and all appear to start together.
  final Map<String, int> _remainingSeconds = {};
  final Map<String, Timer> _runningTimers = {};
  final Map<String, bool> _pausedSteps = {};
  final Set<String> _completedSteps = {};
  int? _sessionId;
  bool _sessionCreated = false;

  int _currentFocusedStepNumber = 1; // Current focused step number

  // Voice assistant
  final CookingVoiceAssistant _voiceAssistant = CookingVoiceAssistant();
  bool _isVoiceModeActive = false;

  // Gesture control
  final CookingGestureControl _gestureControl = CookingGestureControl();
  bool _isGestureModeActive = false;

  // Ingredients list expansion state
  bool _isIngredientsExpanded = true; // 默认展开

  String _stepKey(int dishIndex, int stepNumber) => '$dishIndex:$stepNumber';

  @override
  void initState() {
    super.initState();
    debugPrint('[RecipePage] Recipe instruction page initialized');
    _currentIndex = widget.initialRecipeIndex;
    _completedDishes = <int>{};

    // ✅ Initialize TabController for multi-dish navigation
    _tabController = TabController(
      length: widget.menu.recipes.length,
      vsync: this,
      initialIndex: widget.initialRecipeIndex,
    );

    // Listen to tab changes and update current index
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return; // Skip during animation
      }
      if (_tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
          _currentFocusedStepNumber = 1; // Reset to first step
        });
      }
    });

    // 只在烹饪模式下创建会话和初始化控制
    if (!widget.isViewMode) {
      debugPrint('[RecipePage] 创建烹饪会话...');
      _createCookingSession();
      debugPrint('[RecipePage] 初始化语音助手...');
      _initializeVoiceAssistant();
    } else {
      debugPrint('[RecipePage] View Mode: 跳过会话创建和语音初始化');
    }
    debugPrint('[RecipePage] ===== initState() 完成 =====');
  }

  Future<void> _initializeVoiceAssistant() async {
    debugPrint('[RecipePage] _initializeVoiceAssistant() 开始');
    try {
      final result = await _voiceAssistant.initialize();
      debugPrint('[RecipePage] 语音助手初始化结果: $result');
      if (result) {
        debugPrint('[RecipePage] ✅ 语音助手初始化成功');
      } else {
        debugPrint('[RecipePage] ❌ 语音助手初始化失败');
      }
    } catch (e, stackTrace) {
      debugPrint('[RecipePage] ❌ 语音助手初始化异常: $e');
      debugPrint('[RecipePage] 异常类型: ${e.runtimeType}');
      debugPrint('[RecipePage] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
    }
    debugPrint('[RecipePage] _initializeVoiceAssistant() 完成');
  }

  Future<void> _initializeGestureControl() async {
    await _gestureControl.initialize();
    // 设置手势检测回调
    _gestureControl.onGestureDetected = (gestureType) {
      debugPrint('[RecipePage] Gesture detected: $gestureType');
      // TODO: 实现手势处理逻辑
    };
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
    _voiceAssistant.dispose();
    _tabController.dispose(); // ✅ Dispose TabController
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
      _tabController.animateTo(_currentIndex + 1);
    }
  }

  void _goToPrevDish() {
    if (_currentIndex > 0) {
      _tabController.animateTo(_currentIndex - 1);
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
    // ✅ Pause timer instead of stopping it (preserve the time)
    if (_runningTimers.containsKey(key)) {
      _runningTimers[key]?.cancel();
      _runningTimers.remove(key);
      _pausedSteps[key] = true; // Mark as paused, not reset
    }
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

  /// 处理语音命令
  Future<void> _handleVoiceCommand(String commandText) async {
    final commandType = _voiceAssistant.recognizeCommand(commandText);
    final recipe = widget.menu.recipes[_currentIndex];

    switch (commandType) {
      case VoiceCommandType.nextStep:
        final nextStep = _getNextStep();
        if (nextStep != null) {
          setState(() {
            _currentFocusedStepNumber = nextStep.stepNumber;
          });
          await _voiceAssistant.speakStep(nextStep);
        } else {
          await _voiceAssistant.speak('This is already the last step');
        }
        break;

      case VoiceCommandType.previousStep:
        final prevStep = _getPreviousStep();
        if (prevStep != null) {
          setState(() {
            _currentFocusedStepNumber = prevStep.stepNumber;
          });
          await _voiceAssistant.speakStep(prevStep);
        } else {
          await _voiceAssistant.speak('This is already the first step');
        }
        break;

      case VoiceCommandType.repeatStep:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          await _voiceAssistant.speakStep(currentStep);
        }
        break;

      case VoiceCommandType.jumpToStep:
        final stepNumber = _voiceAssistant.extractStepNumber(commandText);
        if (stepNumber != null &&
            stepNumber >= 1 &&
            stepNumber <= _currentSteps.length) {
          final targetStep = _currentSteps[stepNumber - 1];
          setState(() {
            _currentFocusedStepNumber = stepNumber;
          });
          await _voiceAssistant.speakStep(targetStep);
        } else {
          await _voiceAssistant.speak('Invalid step number');
        }
        break;

      case VoiceCommandType.startTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null && currentStep.stepTimeMin > 0) {
          _startTimerForStep(
            _currentIndex,
            currentStep.stepNumber,
            currentStep.stepTimeMin,
          );
          await _voiceAssistant.speak(
            'Timer started, ${currentStep.stepTimeMin} minutes',
          );
        } else {
          await _voiceAssistant.speak('No time set for current step');
        }
        break;

      case VoiceCommandType.pauseTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _pauseTimer(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('Timer paused');
        }
        break;

      case VoiceCommandType.resumeTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null && currentStep.stepTimeMin > 0) {
          final key = _stepKey(_currentIndex, currentStep.stepNumber);
          if (_pausedSteps[key] == true) {
            _startTimerForStep(
              _currentIndex,
              currentStep.stepNumber,
              currentStep.stepTimeMin,
            );
            await _voiceAssistant.speak('Timer resumed');
          } else {
            await _voiceAssistant.speak('Timer is not paused');
          }
        }
        break;

      case VoiceCommandType.stopTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopTimerForStep(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('Timer stopped');
        }
        break;

      case VoiceCommandType.completeStep:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopAndCompleteStep(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('Step completed');
        }
        break;

      case VoiceCommandType.nextDish:
        if (_currentIndex < _totalDishes - 1) {
          setState(() {
            _currentIndex++;
            _currentFocusedStepNumber = 1;
          });
          await _voiceAssistant.speak(
            'Switched to next dish: ${widget.menu.recipes[_currentIndex].title}',
          );
        } else {
          await _voiceAssistant.speak('This is already the last dish');
        }
        break;

      case VoiceCommandType.previousDish:
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex--;
            _currentFocusedStepNumber = 1;
          });
          await _voiceAssistant.speak(
            'Switched to previous dish: ${widget.menu.recipes[_currentIndex].title}',
          );
        } else {
          await _voiceAssistant.speak('This is already the first dish');
        }
        break;

      case VoiceCommandType.currentStepInfo:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          await _voiceAssistant.speakStep(currentStep);
        }
        break;

      case VoiceCommandType.timerStatus:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          final key = _stepKey(_currentIndex, currentStep.stepNumber);
          final remaining = _remainingSeconds[key];
          if (remaining != null) {
            final minutes = remaining ~/ 60;
            final seconds = remaining % 60;
            if (remaining >= 0) {
              await _voiceAssistant.speak(
                '$minutes minutes $seconds seconds remaining',
              );
            } else {
              await _voiceAssistant.speak(
                'Overdue by ${-minutes} minutes ${-seconds} seconds',
              );
            }
          } else {
            await _voiceAssistant.speak('No running timer for current step');
          }
        }
        break;

      case VoiceCommandType.ingredientsList:
        final ingredients = recipe.ingredients;
        if (ingredients.isEmpty) {
          await _voiceAssistant.speak('No ingredients list');
        } else {
          String text = 'You need the following ingredients: ';
          for (var ing in ingredients) {
            text += '${ing.name} ${ing.amountValue} ${ing.amountUnit}, ';
          }
          await _voiceAssistant.speak(text);
        }
        break;

      case VoiceCommandType.exitVoiceMode:
        _toggleVoiceMode();
        await _voiceAssistant.speak('Voice mode exited');
        break;

      case VoiceCommandType.help:
        await _voiceAssistant.speak(_voiceAssistant.getHelpText());
        break;

      case VoiceCommandType.unknown:
        await _voiceAssistant.speak(
          'Sorry, I did not understand. Please say again',
        );
        break;
    }
  }

  /// 切换语音模式（带权限检查）
  Future<void> _toggleVoiceMode() async {
    // 如果开启语音模式，先检查权限
    if (!_isVoiceModeActive) {
      // 检查权限
      final hasPermission = await _voiceAssistant.checkAndRequestPermission();
      if (!hasPermission) {
        if (mounted) {
          // 检查是否被永久拒绝
          final status = await Permission.microphone.status;
          final isPermanentlyDenied = status.isPermanentlyDenied;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  isPermanentlyDenied
                      ? 'Microphone permission is required for voice control. Please enable it in settings'
                      : 'Microphone permission is required for voice control',
                ),
                action: isPermanentlyDenied
                    ? SnackBarAction(
                        label: 'Go to Settings',
                        onPressed: () {
                          openAppSettings();
                        },
                      )
                    : null,
                duration: const Duration(seconds: 5),
              ),
            );
        }
        return;
      }
    }

    setState(() {
      _isVoiceModeActive = !_isVoiceModeActive;
      if (_isVoiceModeActive) {
        // 如果之前初始化失败，先重置状态再尝试
        if (_voiceAssistant.isInitializationFailed) {
          debugPrint('[RecipePage] 检测到之前的初始化失败，重置状态后重试');
          _voiceAssistant.resetInitializationState();
        }
        _startVoiceListening();
      } else {
        _stopVoiceListening();
      }
    });
  }

  void _toggleGestureMode() {
    debugPrint('[RecipePage] Gesture mode toggle - stub implementation');
  }

  /// 开始语音监听
  void _startVoiceListening() {
    _voiceAssistant.startListening(
      onResult: (text) {
        debugPrint('[RecipePage] 识别到语音: $text');
        _handleVoiceCommand(text);
      },
      onError: (error) {
        debugPrint('[RecipePage] 语音识别错误: $error');
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Voice recognition error: $error'),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
    );
  }

  /// 停止语音监听
  void _stopVoiceListening() {
    _voiceAssistant.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.menu.recipes[_currentIndex];
    final theme = Theme.of(context);
    final steps = recipe.steps;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(recipe.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          // ✅ Add TabBar below title when there are multiple dishes
          bottom: _totalDishes > 1
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.orange,
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.grey,
                  tabs: widget.menu.recipes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final r = entry.value;
                    final isDone = _completedDishes.contains(index);
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDone)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            )
                          else
                            Text('${r.emoji}'),
                          const SizedBox(width: 6),
                          Text(
                            r.title.length > 20
                                ? '${r.title.substring(0, 20)}...'
                                : r.title,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : null,
          actions: [
            // View Mode: 只显示收藏按钮
            // Cooking Mode: 显示语音/手势控制 + 收藏按钮
            if (!widget.isViewMode) ...[
              // Gesture control button
              IconButton(
                onPressed: _toggleGestureMode,
                icon: Icon(
                  _isGestureModeActive ? Icons.gesture : Icons.gesture_outlined,
                  color: _isGestureModeActive ? Colors.blue : null,
                ),
                tooltip: _isGestureModeActive ? '退出手势模式' : '开启手势模式',
              ),
              // Voice control button
              IconButton(
                onPressed: _toggleVoiceMode,
                icon: Icon(
                  _isVoiceModeActive ? Icons.mic : Icons.mic_none,
                  color: _isVoiceModeActive ? Colors.red : null,
                ),
                tooltip: _isVoiceModeActive ? '退出语音模式' : '开启语音模式',
              ),
            ],
            // 收藏按钮（两种模式都显示）
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

              // 可折叠的原材料列表
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: _isIngredientsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isIngredientsExpanded = expanded;
                      });
                    },
                    leading: Icon(
                      Icons.restaurant_menu,
                      color: Colors.orange.shade600,
                    ),
                    title: Text(
                      'Ingredients',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: _isIngredientsExpanded
                        ? null
                        : Text(
                            '${recipe.ingredients.length} items',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                    children: [
                      if (recipe.ingredients.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No ingredients listed.'),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: recipe.ingredients.map((ing) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
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
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[700]),
                                    ),
                                    if (ing.isOptional) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'optional',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.orange),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
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
        // View Mode: 不显示底部控制栏
        // Cooking Mode: 显示完整的底部控制栏
        bottomNavigationBar: widget.isViewMode
            ? null
            : _buildBottomControls(context),
      ),
    );
  }

  Widget _buildStepItem({required RecipeStepModel step}) {
    final theme = Theme.of(context);
    final key = _stepKey(_currentIndex, step.stepNumber);
    final remaining = _remainingSeconds[key];
    final isRunning = _runningTimers.containsKey(key);
    final isOvertime = remaining != null && remaining <= 0;
    final isPaused =
        _pausedSteps[key] == true && remaining != null && remaining > 0;
    final isCompleted = _completedSteps.contains(key);

    // Determine timer state for visual styling
    String timerState =
        'inactive'; // inactive, running, paused, overtime, completed
    if (isCompleted) {
      // ✅ Show frozen state when completed
      if (remaining != null) {
        timerState = 'completed'; // Has recorded time
      } else {
        timerState = 'inactive'; // Never started
      }
    } else if (remaining != null) {
      if (remaining <= 0) {
        timerState = 'overtime';
      } else if (isRunning) {
        timerState = 'running';
      } else if (isPaused) {
        timerState = 'paused';
      }
    }

    // Handler for toggling completion
    void toggleCompletion() {
      if (widget.isViewMode) return;

      if (isCompleted) {
        setState(() {
          _completedSteps.remove(key);
        });
      } else {
        _stopAndCompleteStep(_currentIndex, step.stepNumber);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Target A: Circle - Tappable for toggling completion
            GestureDetector(
              onTap: toggleCompletion,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          step.stepNumber.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isCompleted ? Colors.white : Colors.black87,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right side: Instruction text + Timer chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Target A: Text Area - Tappable for toggling completion
                  GestureDetector(
                    onTap: toggleCompletion,
                    child: Text(
                      step.instruction,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCompleted ? Colors.grey[400] : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ✅ Target B: Timer Chip - Independent interaction
                  if (!widget.isViewMode && step.stepTimeMin > 0)
                    _buildTimerChip(
                      step: step,
                      timerState: timerState,
                      remaining: remaining,
                      theme: theme,
                      isCompleted: isCompleted,
                    ),
                  // View Mode: 只显示时间信息
                  if (widget.isViewMode && step.stepTimeMin > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '⏱️ ~ ${step.stepTimeMin} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Timer Chip with 4 States: Running, Paused, Overtime, Completed
  Widget _buildTimerChip({
    required RecipeStepModel step,
    required String timerState,
    required int? remaining,
    required ThemeData theme,
    required bool isCompleted,
  }) {
    // State-specific styling
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String displayText;
    bool isInteractive = true;

    switch (timerState) {
      case 'running':
        // State 1: Running (Counting Down)
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade600;
        iconColor = Colors.green.shade700;
        textColor = Colors.green.shade700;
        icon = Icons.pause;
        final minutes = (remaining ?? 0) ~/ 60;
        final seconds = (remaining ?? 0) % 60;
        displayText = '$minutes:${seconds.toString().padLeft(2, '0')}';
        break;

      case 'paused':
        // State 2: Paused (User Interrupted)
        backgroundColor = Colors.amber.shade50;
        borderColor = Colors.amber.shade600;
        iconColor = Colors.amber.shade700;
        textColor = Colors.amber.shade700;
        icon = Icons.play_arrow;
        final minutes = (remaining ?? 0) ~/ 60;
        final seconds = (remaining ?? 0) % 60;
        displayText = '$minutes:${seconds.toString().padLeft(2, '0')}';
        break;

      case 'overtime':
        // State 3: Overtime (Counting Up)
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade600;
        iconColor = Colors.red.shade700;
        textColor = Colors.red.shade700;
        icon = Icons.alarm;
        final overtimeSeconds = -(remaining ?? 0);
        final minutes = overtimeSeconds ~/ 60;
        final seconds = overtimeSeconds % 60;
        displayText = '+ $minutes:${seconds.toString().padLeft(2, '0')}';
        break;

      case 'completed':
        // ✅ State 4: Completed (Frozen/Finalized)
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade400;
        iconColor = Colors.grey.shade600;
        textColor = Colors.grey.shade700;
        icon = Icons.timer_off;
        isInteractive = false; // No more interaction when completed

        if (remaining != null) {
          if (remaining <= 0) {
            // Was overtime when completed
            final overtimeSeconds = -remaining;
            final minutes = overtimeSeconds ~/ 60;
            final seconds = overtimeSeconds % 60;
            displayText = '+ $minutes:${seconds.toString().padLeft(2, '0')}';
          } else {
            // Was paused/running when completed
            final minutes = remaining ~/ 60;
            final seconds = remaining % 60;
            displayText = '$minutes:${seconds.toString().padLeft(2, '0')}';
          }
        } else {
          displayText = '~ ${step.stepTimeMin} min';
        }
        break;

      default:
        // Inactive state (not started yet)
        backgroundColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade400;
        iconColor = Colors.grey.shade700;
        textColor = Colors.grey.shade700;
        icon = Icons.timer_outlined;
        displayText = '~ ${step.stepTimeMin} min';
    }

    Widget chipContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    // Add pulse animation for overtime state (only when not completed)
    if (timerState == 'overtime' && !isCompleted) {
      chipContent = TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        onEnd: () {
          // Trigger rebuild to restart animation (creates pulsing effect)
          if (mounted && timerState == 'overtime' && !isCompleted) {
            setState(() {});
          }
        },
        child: chipContent,
      );
    }

    // ✅ Wrap in GestureDetector with behavior to prevent event propagation
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Capture events, don't propagate
      onTap: isInteractive
          ? () {
              if (timerState == 'overtime') {
                // In overtime, tapping stops and completes the step
                _stopAndCompleteStep(_currentIndex, step.stepNumber);
              } else if (timerState == 'running') {
                // Pause the timer
                _pauseTimer(_currentIndex, step.stepNumber);
              } else {
                // Start or resume the timer
                _startTimerForStep(
                  _currentIndex,
                  step.stepNumber,
                  step.stepTimeMin,
                );
              }
            }
          : null,
      child: chipContent,
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
