// lib/pages/recipes/recipe_instruction_page.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:personal_sous_chef/app/app_keys.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/stores/collected_recipes_store.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_meal_summary_page.dart';
import 'package:personal_sous_chef/navigation/otter_floating_nav.dart';
import 'package:personal_sous_chef/navigation/otter_tooltip.dart';
import 'package:personal_sous_chef/services/cooking/cooking_api_service.dart';
import 'package:personal_sous_chef/services/cooking/cooking_voice_assistant.dart';
import 'package:personal_sous_chef/services/cooking/cooking_gesture_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_widgets.dart';

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
  PageController? _pageController; // 用于 PageView 滑动（可空类型，避免初始化错误）
  // Timers/steps must be keyed per dish + per step.
  // Otherwise stepNumber=1 in dish A collides with stepNumber=1 in dish B/C and all appear to start together.
  final Map<String, int> _remainingSeconds = {};
  final Map<String, Timer> _runningTimers = {};
  final Map<String, bool> _pausedSteps = {};
  final Set<String> _completedSteps = {};
  int? _sessionId;

  int _currentFocusedStepNumber = 1; // Current focused step number

  // Voice assistant
  final CookingVoiceAssistant _voiceAssistant = CookingVoiceAssistant();
  bool _isVoiceModeActive = false;
  final GlobalKey<OtterFloatingNavState> _localOtterKey =
      GlobalKey<OtterFloatingNavState>();
  String _lastRecognizedWords = "";
  double _currentSoundLevel = 0.0; // 实时音量分贝
  IconData? _feedbackIcon;
  Color? _feedbackColor;
  Timer? _feedbackTimer;
  Timer? _voiceReconnectTimer;
  Timer? _voiceHeartbeatTimer; // 语音守护进程计时器
  DateTime? _lastSpeechTime; // 最后一次听到声音/结果的时间（用于守护进程静默超时）

  // Gesture control (Update)
  final CookingGestureService _gestureService = CookingGestureService();
  bool _isGestureModeActive = false;
  bool _isGestureServiceInitialized = false; // 标记服务是否已经初始化
  // 手势防抖冷却：两次有效手势之间最小间隔（可改为 1000/2000 微调）
  final Duration _gestureCooldown = const Duration(milliseconds: 1500);
  DateTime? _lastGestureTime;

  // Total cooking duration timer (Per-dish)
  final Map<int, Duration> _dishTotalDurations = {};
  final Map<int, Timer> _dishTotalTimers = {};
  final Map<int, bool> _isDishTotalTimerRunning = {};

  // Ingredients list expansion state, per recipe index (default: expanded)
  final Map<int, bool> _ingredientsExpandedByIndex = {};

  // Map 来存储每个步骤的 GlobalKey，用于自动滚动
  // 使用复合key (dishIndex:stepNumber) 确保每个recipe的步骤都有唯一的key
  final Map<String, GlobalKey> _stepKeys = {};

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

    // ✅ Initialize PageController for swipe navigation
    _pageController = PageController(initialPage: widget.initialRecipeIndex);

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
        // 烹饪模式：翻食谱后自动滚动到第一个步骤
        if (!widget.isViewMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(1);
          });
        }
        // 同步 PageController（确保已初始化）
        if (_pageController != null &&
            _pageController!.hasClients &&
            _pageController!.page != null &&
            _pageController!.page!.round() != _currentIndex) {
          _pageController!.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    // 只在烹饪模式下创建会话、初始化控制、并保持屏幕常亮
    if (!widget.isViewMode) {
      debugPrint('[RecipePage] 创建烹饪会话...');
      _createCookingSession();
      debugPrint('[RecipePage] 初始化语音助手...');
      _initializeVoiceAssistant();
      debugPrint('[RecipePage] 启用屏幕常亮...');
      _enableWakelock();
    } else {
      debugPrint('[RecipePage] View Mode: 跳过会话创建和语音初始化');
    }
    debugPrint('[RecipePage] ===== initState() 完成 =====');
  }

  /// 启用屏幕常亮（只在烹饪模式下）
  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      debugPrint('[RecipePage] ✅ 屏幕常亮已启用');

      // 延迟显示Toast，确保页面已经完全加载
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Screen will stay on while cooking',
                      style: GoogleFonts.kalam(fontSize: 15),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF6B4F4F).withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('[RecipePage] ❌ 屏幕常亮启用失败: $e');
    }
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
      // ✅ 必须包含 category，否则 LeftoverDish 的 category 会为 null
      final recipesJson = widget.menu.recipes
          .map(
            (recipe) => {
              'title': recipe.title,
              'shortDescription': recipe.shortDescription,
              'servings': recipe.servings,
              'cookingTimeMin': recipe.cookingTimeMin,
              'difficulty': recipe.difficulty,
              'category': recipe.category, // 烹饪分类（与后端 CookingCategory 一致）
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
    // ✅ [新增] 离开页面时，务必关闭屏幕常亮，恢复系统默认息屏策略
    WakelockPlus.disable();

    for (final t in _runningTimers.values) {
      t.cancel();
    }
    _voiceAssistant.dispose();
    _gestureService.dispose(); // ✅ 释放手势服务资源
    _tabController.dispose(); // ✅ Dispose TabController
    _pageController?.dispose(); // ✅ Dispose PageController（可空类型，需要安全调用）

    // ✅ 取消所有菜品的总计时器
    for (final timer in _dishTotalTimers.values) {
      timer.cancel();
    }
    _dishTotalTimers.clear();

    // 清理所有 GlobalKeys
    _stepKeys.clear();

    // 只在烹饪模式下禁用屏幕常亮
    if (!widget.isViewMode) {
      _disableWakelock();
    }

    debugPrint('[RecipePage] Recipe instruction page disposed');
    super.dispose();
  }

  /// 禁用屏幕常亮
  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
      debugPrint('[RecipePage] ✅ 屏幕常亮已禁用');
    } catch (e) {
      debugPrint('[RecipePage] ❌ 屏幕常亮禁用失败: $e');
    }
  }

  int get _totalDishes => widget.menu.recipes.length;

  bool get _isCurrentDishDone => _completedDishes.contains(_currentIndex);

  bool get _isWholeMealDone => _completedDishes.length == _totalDishes;

  Future<void> _toggleCollectRecipeForDish(RecipeModel recipe) async {
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
          SnackBar(
            content: Text(text),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
    }
  }

  void _toggleDishDone() {
    setState(() {
      if (_isCurrentDishDone) {
        // 取消完成状态
        _completedDishes.remove(_currentIndex);
      } else {
        // 标记为完成，停止该菜品所有步骤的计时器
        _completedDishes.add(_currentIndex);

        // 停止当前菜品所有步骤的计时器
        final recipe = widget.menu.recipes[_currentIndex];
        for (final step in recipe.steps) {
          final key = _stepKey(_currentIndex, step.stepNumber);
          if (_runningTimers.containsKey(key)) {
            _runningTimers[key]?.cancel();
            _runningTimers.remove(key);
            _pausedSteps[key] = true; // 标记为暂停状态，保留时间
          }
        }
      }
    });
  }

  void _onMealDone() {
    // 支持部分完成：即使不是全部完成也可以保存
    if (_completedDishes.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Please mark at least one dish as done.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
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
    // 如果当前菜品已完成，不允许启动计时器
    if (_completedDishes.contains(dishIndex)) {
      return;
    }

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
      // ✅ 触发自动滚动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToStep(stepNumber);
        }
      });
    }
  }

  /// 滚动到指定步骤
  void _scrollToStep(int stepNumber) {
    // 检查widget是否仍然mounted
    if (!mounted) return;

    // 使用当前dishIndex和stepNumber构建唯一key
    final keyString = _stepKey(_currentIndex, stepNumber);
    final key = _stepKeys[keyString];

    if (key != null && key.currentContext != null) {
      final context = key.currentContext!;

      // 检查context是否仍然有效
      if (!context.mounted) return;

      // 尝试获取Scrollable，如果不存在则返回
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable == null) return;

      try {
        // 使用try-catch捕获所有可能的滚动错误
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // 0.0=顶部, 0.5=中间, 1.0=底部. 0.1表示稍微留点顶距
        );
      } catch (e) {
        // 忽略滚动错误，避免崩溃（包括position未attached等错误）
        debugPrint('[RecipeInstructionPage] 滚动到步骤失败: $e');
      }
    }
  }

  Widget _buildVoiceControlButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (_isVoiceModeActive)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.8),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Container(
                    width: 36 * value,
                    height: 36 * value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(2.0 - value),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted && _isVoiceModeActive) {
                    setState(() {});
                  }
                },
              ),
            IconButton(
              onPressed: _toggleVoiceMode,
              icon: Icon(
                _isVoiceModeActive ? Icons.mic : Icons.mic_none,
                color: _isVoiceModeActive ? Colors.red : null,
              ),
              tooltip: _isVoiceModeActive
                  ? 'Exit Voice Mode'
                  : 'Enter Voice Mode',
            ),
          ],
        );
      },
    );
  }

  /// 处理语音命令
  Future<void> _handleVoiceCommand(String commandText) async {
    final commandType = _voiceAssistant.recognizeCommand(commandText);
    // HUD 文字由 onResult 统一更新为最终识别结果，此处不再清除

    switch (commandType) {
      case VoiceCommandType.nextStep:
        final nextStep = _getNextStep();
        if (nextStep != null) {
          setState(() {
            _currentFocusedStepNumber = nextStep.stepNumber;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(nextStep.stepNumber);
          });
          _showActionFeedback(Icons.arrow_forward);
          _showOtterMessage("Next step! ➔");
        }
        break;

      case VoiceCommandType.previousStep:
        final prevStep = _getPreviousStep();
        if (prevStep != null) {
          setState(() {
            _currentFocusedStepNumber = prevStep.stepNumber;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(prevStep.stepNumber);
          });
          _showActionFeedback(Icons.arrow_back);
          _showOtterMessage("Going back! ⬅");
        }
        break;

      case VoiceCommandType.repeatStep:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _showActionFeedback(Icons.replay);
          _showOtterMessage("Repeating step... 🔁");
          // 如果需要，这里可以保留 speakStep，但根据需求这里也不播报，只高亮显示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(currentStep.stepNumber);
          });
        }
        break;

      case VoiceCommandType.jumpToStep:
        final stepNumber = _voiceAssistant.extractStepNumber(commandText);
        if (stepNumber != null &&
            stepNumber >= 1 &&
            stepNumber <= _currentSteps.length) {
          setState(() {
            _currentFocusedStepNumber = stepNumber;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(stepNumber);
          });
          _showActionFeedback(Icons.directions_run);
          _showOtterMessage("Jumping to step $stepNumber! 🏃");
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
          _showActionFeedback(Icons.play_arrow, color: Colors.green);
          _showOtterMessage("Timer started! ⏳");
        }
        break;

      case VoiceCommandType.pauseTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _pauseTimer(_currentIndex, currentStep.stepNumber);
          _showActionFeedback(Icons.pause, color: Colors.amber);
          _showOtterMessage("Timer paused! ⏸");
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
            _showActionFeedback(Icons.play_arrow, color: Colors.green);
            _showOtterMessage("Timer resumed! ▶");
          }
        }
        break;

      case VoiceCommandType.stopTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopTimerForStep(_currentIndex, currentStep.stepNumber);
          _showActionFeedback(Icons.stop, color: Colors.red);
          _showOtterMessage("Timer stopped! ⏹");
        }
        break;

      case VoiceCommandType.completeStep:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopAndCompleteStep(_currentIndex, currentStep.stepNumber);
          _showActionFeedback(Icons.check_circle, color: Colors.green);
          _showOtterMessage("Step done! ✅");
        }
        break;

      case VoiceCommandType.startTotalTimer:
        final isRunning = _isDishTotalTimerRunning[_currentIndex] ?? false;
        if (!isRunning) {
          _toggleTotalTimer(_currentIndex);
          _showActionFeedback(Icons.timer, color: Colors.blue);
          _showOtterMessage("Cooking started! 👨‍🍳");
        }
        break;

      case VoiceCommandType.pauseTotalTimer:
        final isRunning = _isDishTotalTimerRunning[_currentIndex] ?? false;
        if (isRunning) {
          _toggleTotalTimer(_currentIndex);
          _showActionFeedback(Icons.pause, color: Colors.amber);
          _showOtterMessage("Cooking paused! ⏸");
        }
        break;

      case VoiceCommandType.resumeTotalTimer:
        final isRunning = _isDishTotalTimerRunning[_currentIndex] ?? false;
        if (!isRunning) {
          _toggleTotalTimer(_currentIndex);
          _showActionFeedback(Icons.play_arrow, color: Colors.green);
          _showOtterMessage("Cooking resumed! ▶");
        }
        break;

      case VoiceCommandType.stopTotalTimer:
        final isRunning = _isDishTotalTimerRunning[_currentIndex] ?? false;
        if (isRunning) {
          _toggleTotalTimer(_currentIndex);
          _showActionFeedback(Icons.stop, color: Colors.red);
          _showOtterMessage("Cooking stopped! ⏹");
        }
        break;

      case VoiceCommandType.nextDish:
        if (_currentIndex < _totalDishes - 1) {
          _pageController?.animateToPage(
            _currentIndex + 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          _showActionFeedback(Icons.skip_next);
          _showOtterMessage("Next recipe! 🍲");
        }
        break;

      case VoiceCommandType.previousDish:
        if (_currentIndex > 0) {
          _pageController?.animateToPage(
            _currentIndex - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          _showActionFeedback(Icons.skip_previous);
          _showOtterMessage("Previous recipe! 🥗");
        }
        break;

      case VoiceCommandType.currentStepInfo:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _showActionFeedback(Icons.info_outline);
          _showOtterMessage("Current step info! ℹ️");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToStep(currentStep.stepNumber);
          });
        }
        break;

      case VoiceCommandType.timerStatus:
        _showActionFeedback(Icons.timer);
        _showOtterMessage("Checking timer... ⏱️");
        break;

      case VoiceCommandType.ingredientsList:
        _showActionFeedback(Icons.shopping_basket);
        _showOtterMessage("Here are ingredients! 🛒");
        break;

      case VoiceCommandType.exitVoiceMode:
        _toggleVoiceMode();
        _showActionFeedback(Icons.exit_to_app);
        break;

      case VoiceCommandType.help:
        _showActionFeedback(Icons.help_outline);
        _showOtterMessage("How can I help? 🦦");
        break;

      case VoiceCommandType.unknown:
        // 未知指令，可以显示一个问号
        _showActionFeedback(Icons.help_outline, color: Colors.grey);
        _showOtterMessage("I didn't catch that... ❓");
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
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
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
        _startVoiceHeartbeat(); // 启动守护进程
        _showOtterMessage(
          "I'm listening! 🦦\nTry saying 'Next' or 'Start'",
          type: OtterTooltipType.welcome,
        );
      } else {
        _stopVoiceListening();
        _showOtterMessage("Voice mode off. Bye! 👋");
      }
    });
  }

  Future<void> _toggleGestureMode() async {
    // 1. 如果是想要开启手势模式 (当前是 false)
    if (!_isGestureModeActive) {
      // 显示一个提示，因为相机启动可能有 0.5~1秒 的延迟
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Starting camera for gestures...'),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      }

      // 2. 懒加载：如果服务还没初始化，现在才初始化
      if (!_isGestureServiceInitialized) {
        try {
          await _gestureService.initialize();
          _isGestureServiceInitialized = true;
          debugPrint('[RecipePage] 手势服务初始化成功（懒加载）');
        } catch (e) {
          debugPrint('[RecipePage] Gesture init failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Camera error: $e'),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              ),
            );
          }
          return; // 初始化失败，直接返回，不改变状态
        }
      }

      // 3. 启动监听
      _gestureService.startListening((type) {
        if (!mounted) return;

        // 防抖：距上次有效手势不足冷却时间则忽略，防止一次挥手触发多次
        final now = DateTime.now();
        if (_lastGestureTime != null) {
          final difference = now.difference(_lastGestureTime!);
          if (difference < _gestureCooldown) {
            debugPrint(
              '[RecipePage] Gesture ignored (Cooling down): ${difference.inMilliseconds}ms',
            );
            return;
          }
        }
        _lastGestureTime = now;

        switch (type) {
          case GestureType.nextStep:
            // ➡️ 右挥：下一步
            final nextStep = _getNextStep();
            if (nextStep != null) {
              _jumpToStep(nextStep.stepNumber);
              debugPrint('[RecipePage] Gesture: Next Step');
            }
            break;

          case GestureType.previousStep:
            // ⬅️ 左挥：上一步
            final prevStep = _getPreviousStep();
            if (prevStep != null) {
              _jumpToStep(prevStep.stepNumber);
              debugPrint('[RecipePage] Gesture: Prev Step');
            }
            break;

          case GestureType.startTimer:
            // 👆 上抬：开始/暂停计时器
            final currentStep = _getFocusedStep();
            if (currentStep != null && currentStep.stepTimeMin > 0) {
              // 简单逻辑：如果有计时器在跑就暂停，否则就开始
              final key = _stepKey(_currentIndex, currentStep.stepNumber);
              if (_runningTimers.containsKey(key)) {
                _pauseTimer(_currentIndex, currentStep.stepNumber);
                debugPrint('[RecipePage] Gesture: Pause Timer');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('⏸️ Timer Paused'),
                    duration: const Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  ),
                );
              } else {
                // 如果是暂停状态，继续；否则重新开始
                // 这里简单处理为开始
                _startTimerForStep(
                  _currentIndex,
                  currentStep.stepNumber,
                  currentStep.stepTimeMin,
                );
                debugPrint('[RecipePage] Gesture: Start Timer');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('⏳ Timer Started'),
                    duration: const Duration(milliseconds: 500),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No timer for this step'),
                  duration: const Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                ),
              );
            }
            break;

          case GestureType.markDone:
            // 👇 下切：标记完成
            final currentStep = _getFocusedStep();
            if (currentStep != null) {
              _stopAndCompleteStep(_currentIndex, currentStep.stepNumber);
              debugPrint('[RecipePage] Gesture: Mark Done');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Step Completed'),
                  duration: const Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                ),
              );

              // 自动跳到下一步? 可选
              // final next = _getNextStep();
              // if (next != null) _jumpToStep(next.stepNumber);
            }
            break;
        }
      });
    } else {
      // 4. 如果是想要关闭
      _gestureService.stopListening();
      // 注意：这里我们只停止监听流，不 dispose 服务。
      // 这样用户如果再次点击开启，就不需要等待相机重新初始化了（热启动）。
    }

    // 5. 更新 UI 状态
    setState(() {
      _isGestureModeActive = !_isGestureModeActive;
    });
  }

  /// 开始语音监听
  void _startVoiceListening() {
    if (!_isVoiceModeActive) return;

    _voiceAssistant.startListening(
      onResult: (text) {
        debugPrint('[RecipePage] ✅ 监听到最终结果: $text');
        _lastSpeechTime = DateTime.now();

        // 1. 先处理业务逻辑
        _handleVoiceCommand(text);

        // 2. 再更新 UI 状态（放在逻辑处理后）
        if (mounted) {
          setState(() {
            _lastRecognizedWords = text;
            _currentSoundLevel = 0.0;
          });
        }
        // 重连由 onStatus('done'/'notListening') 统一触发，此处不再调用
      },
      onPartialResult: (text) {
        _lastSpeechTime = DateTime.now();
        if (mounted && _lastRecognizedWords != text) {
          setState(() {
            _lastRecognizedWords = text;
          });
        }
      },
      onSoundLevelUpdate: (level) {
        if (mounted && _isVoiceModeActive) {
          if ((_currentSoundLevel - level).abs() > 0.5) {
            setState(() {
              _currentSoundLevel = level;
            });
          }
        }
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted && _isVoiceModeActive) {
            debugPrint('[RecipePage] ⚡ 检测到会话结束，立即安排无缝重启...');
            _reconnectVoiceDelayed();
          }
        }
      },
      onError: (error) {
        debugPrint('[RecipePage] 语音识别错误: $error');
        if (!_isVoiceModeActive) return;
        if (error.contains('error_permission')) {
          if (mounted) _toggleVoiceMode();
          _showOtterMessage("Mic permission lost! 🚫");
        } else {
          _reconnectVoiceDelayed();
        }
      },
    );
  }

  /// 延迟重连：onStatus 触发后极短延迟重启，消灭空窗期
  void _reconnectVoiceDelayed() {
    _voiceReconnectTimer?.cancel();
    if (!_isVoiceModeActive) return;

    _voiceReconnectTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted || !_isVoiceModeActive) return;
      if (!_voiceAssistant.isListening) {
        debugPrint('[RecipePage] 🔄 正在执行无缝重启...');
        _startVoiceListening();
      }
    });
  }

  /// 语音守护进程：每 5 秒检查一次状态，防止插件进入假死状态
  void _startVoiceHeartbeat() {
    _voiceHeartbeatTimer?.cancel();
    _voiceHeartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_isVoiceModeActive) {
        timer.cancel();
        return;
      }

      final bool isActuallyListening = _voiceAssistant.isListening;

      // 策略 1：插件报告未在听 -> 使用带 stop 的安全重连
      if (!isActuallyListening) {
        debugPrint('[VoiceHeartbeat] 💓 检测到麦克风状态为关闭，正在强制唤醒...');
        _reconnectVoiceDelayed();
        return;
      }

      // 策略 2（可选）：长时间无响应时主动重启以防假死
      final diff = DateTime.now().difference(_lastSpeechTime ?? DateTime.now());
      if (diff.inSeconds > 20) {
        debugPrint('[VoiceHeartbeat] 💓 20秒无响应，主动重启服务以防假死...');
        _reconnectVoiceDelayed();
        _lastSpeechTime = DateTime.now();
      }
    });
  }

  /// 停止语音监听
  void _stopVoiceListening() {
    _voiceReconnectTimer?.cancel();
    _voiceHeartbeatTimer?.cancel();
    _voiceAssistant.stopListening();
    setState(() {
      _currentSoundLevel = 0.0;
    });
  }

  /// 切换指定菜品的总计时器状态
  void _toggleTotalTimer(int index) {
    setState(() {
      final isRunning = _isDishTotalTimerRunning[index] ?? false;
      _isDishTotalTimerRunning[index] = !isRunning;

      if (_isDishTotalTimerRunning[index] == true) {
        _dishTotalTimers[index]?.cancel();
        _dishTotalTimers[index] = Timer.periodic(const Duration(seconds: 1), (
          timer,
        ) {
          if (mounted) {
            setState(() {
              final currentDuration =
                  _dishTotalDurations[index] ?? Duration.zero;
              _dishTotalDurations[index] =
                  currentDuration + const Duration(seconds: 1);
            });
          } else {
            timer.cancel();
          }
        });
      } else {
        _dishTotalTimers[index]?.cancel();
        _dishTotalTimers.remove(index);
      }
    });
  }

  /// 格式化 Duration 为 HH:mm:ss
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  /// 显示动作反馈
  void _showActionFeedback(
    IconData icon, {
    Color color = const Color(0xFF6B4F4F),
  }) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackIcon = icon;
      _feedbackColor = color;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _feedbackIcon = null;
        });
      }
    });
  }

  /// ✅ 让小 Otter 说话
  void _showOtterMessage(
    String message, {
    OtterTooltipType type = OtterTooltipType.actionHint,
  }) {
    _localOtterKey.currentState?.showMessage(message, type: type);
  }

  /// 构建总计时器便签
  Widget _buildTotalTimerNote(int index) {
    final theme = Theme.of(context);
    final duration = _dishTotalDurations[index] ?? Duration.zero;
    final isRunning = _isDishTotalTimerRunning[index] ?? false;
    final ink = const Color(0xFF6B4F4F);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: ink.withOpacity(0.8), size: 24),
          const SizedBox(width: 12),
          Text(
            'Cooking Time: ${_formatDuration(duration)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: ink,
            ),
          ),
          const Spacer(),
          // 开始/暂停按钮
          GestureDetector(
            onTap: () => _toggleTotalTimer(index),
            child: Icon(
              isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: isRunning ? Colors.orange : ink.withOpacity(0.8),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // 构建单个菜谱的内容页面
  Widget _buildRecipePage(int index) {
    final recipe = widget.menu.recipes[index];
    final steps = recipe.steps;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：emoji + 简介 + 时间卡路里
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: recipe.category != null
                      ? Image.asset(
                          recipe.categoryImagePath,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // 如果图片加载失败，显示 emoji
                            return Center(
                              child: Text(
                                recipe.emoji,
                                style: const TextStyle(fontSize: 34),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            recipe.emoji,
                            style: const TextStyle(fontSize: 34),
                          ),
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
                        fontSize: 24, // 增大标题字体
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16, // 增大图标
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMin} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 15, // 增大字体
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.local_fire_department,
                          size: 16, // 增大图标
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalCaloriesEstimate.toStringAsFixed(0)} kcal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 15, // 增大字体
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

          // 可折叠的原材料列表 - 使用与 home 页一致的便签样式（带胶带和锯齿边框）
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // 1. Background Layer: Sketchy paper container
              Container(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏（可点击展开/收起）- 每个食谱独立状态
                    InkWell(
                      onTap: () {
                        setState(() {
                          final current =
                              _ingredientsExpandedByIndex[index] ?? true;
                          _ingredientsExpandedByIndex[index] = !current;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: const Color(0xFF6B4F4F).withOpacity(0.7),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ingredients',
                              style: GoogleFonts.kalam(
                                fontSize: 20, // 增大标题字体
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          if (!(_ingredientsExpandedByIndex[index] ?? true))
                            Text(
                              '${recipe.ingredients.length} items',
                              style: GoogleFonts.kalam(
                                fontSize: 16, // 增大字体
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            (_ingredientsExpandedByIndex[index] ?? true)
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: const Color(0xFF6B4F4F).withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    // 展开的内容
                    if (_ingredientsExpandedByIndex[index] ?? true) ...[
                      const SizedBox(height: 12),
                      if (recipe.ingredients.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No ingredients listed.',
                            style: GoogleFonts.kalam(
                              fontSize: 16, // 增大字体
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      else
                        // 使用 Wrap 实现每行三个食材的布局
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 计算每项宽度：容器宽度减去间距后除以3
                            final itemWidth =
                                (constraints.maxWidth - 8 * 2) / 3;
                            return Wrap(
                              spacing: 8, // 水平间距
                              runSpacing: 8, // 垂直间距
                              children: recipe.ingredients.map((ing) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ing.name,
                                        style: GoogleFonts.kalam(
                                          fontSize: 16, // 增大字体
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${ing.amountValue} ${ing.amountUnit}${ing.isOptional ? ' • opt' : ''}',
                                        style: GoogleFonts.kalam(
                                          fontSize: 13, // 增大字体
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
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

          const SizedBox(height: 16),

          // 总计时器便签 - 仅在烹饪模式显示
          if (!widget.isViewMode) ...[
            _buildTotalTimerNote(index),
            const SizedBox(height: 16),
          ],

          Text(
            'Steps',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20, // 增大标题字体
            ),
          ),
          const SizedBox(height: 8),

          // 使用 Column 直接渲染步骤，而不是 ListView，避免嵌套滚动问题
          ...steps.map((step) => _buildStepItem(step: step, dishIndex: index)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            widget.isViewMode ? 'View Mode' : 'Cook Mode',
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
          // 移除 TabBar，使用 PageView 滑动切换
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
              _buildVoiceControlButton(),
            ],
            // 收藏按钮（两种模式都显示）
            ValueListenableBuilder<List<RecipeModel>>(
              valueListenable: CollectedRecipesStore.favorites,
              builder: (context, favorites, _) {
                final currentRecipe = widget.menu.recipes[_currentIndex];
                final isCollected = favorites.any(
                  (r) => r.id == currentRecipe.id,
                );

                return IconButton(
                  onPressed: () {
                    // 使用当前索引的菜谱
                    final currentRecipe = widget.menu.recipes[_currentIndex];
                    _toggleCollectRecipeForDish(currentRecipe);
                  },
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
        body: Stack(
          children: [
            _GridPaper(
              child: SafeArea(
                child: widget.menu.recipes.length > 1 && _pageController != null
                    ? PageView.builder(
                        controller: _pageController!,
                        itemCount: widget.menu.recipes.length,
                        allowImplicitScrolling: false,
                        // 不缓存页面，避免GlobalKey冲突
                        physics: const PageScrollPhysics(),
                        onPageChanged: (index) {
                          // 清理旧recipe的keys，避免GlobalKey冲突
                          _stepKeys.removeWhere(
                            (key, _) => key.startsWith('${_currentIndex}:'),
                          );

                          setState(() {
                            _currentIndex = index;
                            _currentFocusedStepNumber =
                                1; // Reset to first step
                          });
                          // 烹饪模式：滑动食谱后自动滚动到第一个步骤
                          if (!widget.isViewMode) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _scrollToStep(1);
                            });
                          }
                          // 同步 TabController
                          if (_tabController.index != index) {
                            _tabController.animateTo(index);
                          }
                        },
                        itemBuilder: (context, index) {
                          return _buildRecipePage(index);
                        },
                      )
                    : _buildRecipePage(0), // 如果只有一个菜谱或 PageController 未初始化，直接显示
              ),
            ),
            // Action Flash Overlay
            if (_feedbackIcon != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black12,
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.5 + 1.5 * value,
                          child: Opacity(
                            opacity: (1.0 - value).clamp(0.0, 1.0),
                            child: Icon(
                              _feedbackIcon,
                              size: 150,
                              color: _feedbackColor ?? const Color(0xFF6B4F4F),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Visual HUD (Listening words)
            if (_isVoiceModeActive)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100, // 稍微上提一点，避开底部按钮
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mic,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        _VoiceWaveform(
                          isListening: _isVoiceModeActive,
                          soundLevel: _currentSoundLevel,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _lastRecognizedWords.isEmpty
                              ? "Listening..."
                              : _lastRecognizedWords,
                          style: GoogleFonts.kalam(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        // View Mode: 只显示分页指示器（如果有多个菜谱）
        // Cooking Mode: 显示完整的底部控制栏（包括分页指示器和按钮）
        bottomNavigationBar: widget.isViewMode
            ? (widget.menu.recipes.length > 1
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SketchyPageIndicator(
                          count: widget.menu.recipes.length,
                          currentIndex: _currentIndex,
                        ),
                      ),
                    )
                  : null)
            : _buildBottomControls(context),
        floatingActionButton: !widget.isViewMode
            ? OtterFloatingNav(
                key: _localOtterKey,
                selectedIndex: 1, // Cooking is in Recipes tab
                isListening: _isVoiceModeActive,
                onItemTapped: (index) {
                  // 在烹饪模式点击导航，通常是想切换页面
                  Navigator.pop(context);
                  mainScaffoldKey.currentState?.switchTab(index);
                },
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildStepItem({required RecipeStepModel step, int? dishIndex}) {
    final theme = Theme.of(context);
    final effectiveDishIndex = dishIndex ?? _currentIndex;
    final key = _stepKey(effectiveDishIndex, step.stepNumber);
    final remaining = _remainingSeconds[key];
    final isRunning = _runningTimers.containsKey(key);
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

    // 烹饪模式才显示指针（当前步骤高亮）；View Mode 模式不显示
    final showPointer = !widget.isViewMode;
    final isFocused =
        showPointer && _currentFocusedStepNumber == step.stepNumber;

    // 为每个步骤分配或获取一个 GlobalKey (用于语音/跳转时的滚动)
    final stepKeyString = _stepKey(effectiveDishIndex, step.stepNumber);

    final existingKey = _stepKeys[stepKeyString];
    if (existingKey == null) {
      _stepKeys[stepKeyString] = GlobalKey();
    } else {
      final ctx = existingKey.currentContext;
      if (ctx == null || !ctx.mounted) {
        _stepKeys[stepKeyString] = GlobalKey();
      }
    }

    void toggleCompletion() {
      if (widget.isViewMode) return;

      if (isCompleted) {
        setState(() {
          _completedSteps.remove(key);
        });
      } else {
        _stopAndCompleteStep(effectiveDishIndex, step.stepNumber);
      }
    }

    void setFocus() {
      if (!showPointer) return;
      if (_currentFocusedStepNumber != step.stepNumber) {
        setState(() {
          _currentFocusedStepNumber = step.stepNumber;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToStep(step.stepNumber);
        });
      }
    }

    return GestureDetector(
      onTap: setFocus,
      child: AnimatedContainer(
        key: _stepKeys[stepKeyString],
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isFocused
              ? const Color(0xFFFFF9C4).withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isFocused
              ? Border.all(
                  color: const Color(0xFF6B4F4F).withOpacity(0.3),
                  width: 1,
                )
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 烹饪模式：当前步骤左侧显示箭头；View Mode 不显示
            if (showPointer)
              SizedBox(
                width: 24,
                height: 32,
                child: isFocused
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 12,
                          child: CustomPaint(painter: _SketchyArrowPainter()),
                        ),
                      )
                    : null,
              ),
            if (showPointer) const SizedBox(width: 8),

            // 圆形序号
            GestureDetector(
              onTap: toggleCompletion,
              child: SizedBox(
                width: 32,
                height: 32,
                child: CustomPaint(
                  painter: _SketchyCirclePainter(
                    borderColor: isFocused
                        ? const Color(0xFF6B4F4F)
                        : const Color(0xFF6B4F4F).withOpacity(0.7),
                    backgroundColor: Colors.transparent,
                    borderWidth: isFocused ? 2.0 : 1.5,
                    seed: step.stepNumber,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: const Color(0xFF6B4F4F),
                          )
                        : Text(
                            step.stepNumber.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // 增大字体
                              color: const Color(0xFF6B4F4F),
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 右侧内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: toggleCompletion,
                    child: Text(
                      step.instruction,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCompleted ? Colors.grey[400] : null,
                        fontSize: 16,
                        fontWeight: isFocused
                            ? FontWeight.w600
                            : FontWeight.normal,
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
                      dishIndex: effectiveDishIndex, // 传递菜谱索引
                    ),
                  // View Mode: 只显示时间信息
                  if (widget.isViewMode && step.stepTimeMin > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '⏱️ ~ ${step.stepTimeMin} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14, // 增大字体
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
    required int dishIndex, // 添加菜谱索引参数
  }) {
    // 如果菜品已完成，计时器不可交互
    final isDishCompleted = _completedDishes.contains(dishIndex);

    // State-specific styling
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String displayText;
    bool isInteractive = !isDishCompleted; // 菜品完成时不可交互

    // 如果菜品已完成，强制显示为灰色禁用状态
    if (isDishCompleted) {
      backgroundColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade400;
      iconColor = Colors.grey.shade600;
      textColor = Colors.grey.shade700;
      icon = Icons.timer_off;

      if (remaining != null) {
        if (remaining <= 0) {
          final overtimeSeconds = -remaining;
          final minutes = overtimeSeconds ~/ 60;
          final seconds = overtimeSeconds % 60;
          displayText = '+ $minutes:${seconds.toString().padLeft(2, '0')}';
        } else {
          final minutes = remaining ~/ 60;
          final seconds = remaining % 60;
          displayText = '$minutes:${seconds.toString().padLeft(2, '0')}';
        }
      } else {
        displayText = '~ ${step.stepTimeMin} min';
      }
    } else {
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
          Icon(icon, size: 16, color: iconColor), // 增大图标
          const SizedBox(width: 4),
          Text(
            displayText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14, // 增大字体
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
                _stopAndCompleteStep(dishIndex, step.stepNumber);
              } else if (timerState == 'running') {
                // Pause the timer
                _pauseTimer(dishIndex, step.stepNumber);
              } else {
                // Start or resume the timer
                _startTimerForStep(
                  dishIndex,
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
    final isCurrentDone = _isCurrentDishDone;
    final completedCount = _completedDishes.length;
    final hasCompleted = completedCount > 0;
    final canSave = hasCompleted;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 分页指示器 (替代原来的 Dish 1 of 1 文本)
          if (widget.menu.recipes.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SketchyPageIndicator(
                count: widget.menu.recipes.length,
                currentIndex: _currentIndex,
              ),
            ),

          // 2. 新的按钮区域 (复刻 Generated Menus 样式)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // 左侧按钮: Mark Done
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: _SketchyButtonWithAnimation(
                      backgroundColor: const Color(0xFFFFFFF0),
                      withShadow: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      onPressed: _toggleDishDone,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCurrentDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: const Color(0xFF6B4F4F),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isCurrentDone ? 'Completed' : 'Mark Done',
                              style: GoogleFonts.kalam(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B4F4F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16), // 按钮间距
                // 右侧按钮: Save Progress
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: Opacity(
                      // 如果不可点击，降低透明度以示禁用
                      opacity: canSave ? 1.0 : 0.5,
                      child: _SketchyButtonWithAnimation(
                        backgroundColor: const Color(0xFFFFFFF0),
                        withShadow: canSave, // 禁用时不要阴影
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        onPressed: canSave ? _onMealDone : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isWholeMealDone
                                  ? Icons.check_circle
                                  : Icons.save_alt,
                              size: 20,
                              color: const Color(0xFF6B4F4F),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isWholeMealDone
                                    ? 'Meal Done'
                                    : 'Save Progress',
                                style: GoogleFonts.kalam(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6B4F4F),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

/// 手绘风格分页指示器
class SketchyPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const SketchyPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = const Color(0xFF6B4F4F), // 深褐色墨水
    this.inactiveColor = const Color(0xFF6B4F4F),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 12 : 8, // 选中时稍微大一点
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : Colors.transparent, // 选中实心，未选中空心
            border: Border.all(color: inactiveColor, width: 1.5),
          ),
        );
      }),
    );
  }
}

/// 手绘风格按钮边框绘制器
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

/// 带点击动画的手绘按钮
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

/// 手绘风格圆形边框绘制器（用于步骤编号标签）
class _SketchyCirclePainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;
  final double borderWidth;
  final int seed;

  _SketchyCirclePainter({
    required this.borderColor,
    required this.backgroundColor,
    this.borderWidth = 1.5,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - borderWidth / 2;
    final random = math.Random(seed);
    final wobble = 1.5;
    final step = 8.0;

    // 创建手绘风格的圆形路径
    final path = Path();
    final angleStep =
        (2 * math.pi) / (2 * math.pi * radius / step).round().clamp(16, 32);

    // 从顶部开始绘制
    double startAngle = -math.pi / 2;
    path.moveTo(
      center.dx +
          (radius + (random.nextDouble() * 2 - 1) * wobble) *
              math.cos(startAngle),
      center.dy +
          (radius + (random.nextDouble() * 2 - 1) * wobble) *
              math.sin(startAngle),
    );

    // 绘制圆形，添加随机抖动
    for (
      double angle = startAngle + angleStep;
      angle <= startAngle + 2 * math.pi + angleStep;
      angle += angleStep
    ) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      final currentRadius = radius + noise;
      path.lineTo(
        center.dx + currentRadius * math.cos(angle),
        center.dy + currentRadius * math.sin(angle),
      );
    }

    path.close();

    // 1. 先画背景
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. 再画边框
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 手绘风格箭头绘制器 (用于指示当前步骤)
class _SketchyArrowPainter extends CustomPainter {
  final Color color;

  _SketchyArrowPainter({this.color = const Color(0xFF6B4F4F)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final random = math.Random(42); // 固定种子保持形状一致

    // 箭身 (带一点微小的波浪)
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 - 2 + random.nextDouble() * 4,
      size.width,
      size.height / 2,
    );

    // 箭头上方翼
    path.moveTo(size.width, size.height / 2);
    path.lineTo(size.width - 8, size.height / 2 - 6);

    // 箭头下方翼
    path.moveTo(size.width, size.height / 2);
    path.lineTo(size.width - 8, size.height / 2 + 6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 语音声波动画组件 - 真实分贝感应版
class _VoiceWaveform extends StatelessWidget {
  final bool isListening;
  final double soundLevel; // 真实音量分贝
  final Color color;

  const _VoiceWaveform({
    required this.isListening,
    required this.soundLevel,
    this.color = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    const int barCount = 7;

    // 将插件返回的 soundLevel (一般是 -2 到 10) 映射到 0.0 - 1.0 的比例
    // 基础补偿，确保有微弱跳动
    final double normalizedLevel = isListening
        ? ((soundLevel + 2) / 12).clamp(0.05, 1.0)
        : 0.0;

    return Container(
      height: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          // 为不同位置的条设置不同的灵敏度权重，形成中间高两边低的波浪感
          final double weight =
              1.0 - ((index - (barCount - 1) / 2).abs() / (barCount / 2));
          final double heightScale = normalizedLevel * weight;

          // 基础高度 4，最大跳动高度 24
          final double height = 4 + (24 * heightScale);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 80), // 极短的延迟实现灵敏响应
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: isListening
                  ? color.withOpacity(0.6 + 0.4 * heightScale)
                  : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isListening && heightScale > 0.3
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
