// lib/pages/recipes/recipe_instruction_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personal_sous_chef/data/collected_recipes_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_meal_summary_page.dart';
import 'package:personal_sous_chef/services/cooking_api_service.dart';
import 'package:personal_sous_chef/services/household_service.dart';
import 'package:personal_sous_chef/services/cooking_voice_assistant.dart';
import 'package:personal_sous_chef/services/cooking_gesture_control.dart';

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
  
  // Voice control
  final CookingVoiceAssistant _voiceAssistant = CookingVoiceAssistant();
  bool _isVoiceModeActive = false;
  int _currentFocusedStepNumber = 1; // 当前聚焦的步骤编号
  
  // Gesture control
  final CookingGestureControl _gestureControl = CookingGestureControl();
  bool _isGestureModeActive = false;

  String _stepKey(int dishIndex, int stepNumber) => '$dishIndex:$stepNumber';

  @override
  void initState() {
    super.initState();
    debugPrint('[RecipePage] ===== initState() 开始 =====');
    _currentIndex = widget.initialRecipeIndex;
    _completedDishes = <int>{};
    debugPrint('[RecipePage] 创建烹饪会话...');
    _createCookingSession();
    debugPrint('[RecipePage] 初始化语音助手...');
    _initializeVoiceAssistant();
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
    _gestureControl.onGestureDetected = _handleGesture;
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
      final recipesJson = widget.menu.recipes.map((recipe) => {
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
        'ingredients': recipe.ingredients.map((ing) => {
          'name': ing.name,
          'amountValue': ing.amountValue,
          'amountUnit': ing.amountUnit,
          'isOptional': ing.isOptional,
          'sourceType': 'MANUAL_ADD',
        }).toList(),
        'steps': recipe.steps.map((step) => {
          'stepNumber': step.stepNumber,
          'instruction': step.instruction,
          'stepTimeMin': step.stepTimeMin,
        }).toList(),
      }).toList();

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
        print('[RecipePage] Created cooking session: $sessionId for menu with ${widget.menu.recipes.length} dishes');
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

      final saved = await CollectedRecipesStore.toggle(recipe, householdId: householdId);
      if (!wasCollected && saved != null) {
        setState(() {
          widget.menu.recipes[_currentIndex] = saved;
        });
        print(
            '[RecipePage] Updated recipe id after saving: ${saved.id} (${saved.title})');
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
    _runningTimers[key] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
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
  List<RecipeStepModel> get _currentSteps => widget.menu.recipes[_currentIndex].steps;
  
  /// 获取当前聚焦的步骤
  RecipeStepModel? _getFocusedStep() {
    if (_currentFocusedStepNumber < 1 || _currentFocusedStepNumber > _currentSteps.length) {
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
          await _voiceAssistant.speak('已经是最后一步了');
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
          await _voiceAssistant.speak('已经是第一步了');
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
        if (stepNumber != null && stepNumber >= 1 && stepNumber <= _currentSteps.length) {
          final targetStep = _currentSteps[stepNumber - 1];
          setState(() {
            _currentFocusedStepNumber = stepNumber;
          });
          await _voiceAssistant.speakStep(targetStep);
        } else {
          await _voiceAssistant.speak('步骤编号无效');
        }
        break;
        
      case VoiceCommandType.startTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null && currentStep.stepTimeMin > 0) {
          _startTimerForStep(_currentIndex, currentStep.stepNumber, currentStep.stepTimeMin);
          await _voiceAssistant.speak('计时器已启动，${currentStep.stepTimeMin}分钟');
        } else {
          await _voiceAssistant.speak('当前步骤没有设置时间');
        }
        break;
        
      case VoiceCommandType.pauseTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _pauseTimer(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('计时器已暂停');
        }
        break;
        
      case VoiceCommandType.resumeTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null && currentStep.stepTimeMin > 0) {
          final key = _stepKey(_currentIndex, currentStep.stepNumber);
          if (_pausedSteps[key] == true) {
            _startTimerForStep(_currentIndex, currentStep.stepNumber, currentStep.stepTimeMin);
            await _voiceAssistant.speak('计时器已继续');
          } else {
            await _voiceAssistant.speak('计时器未暂停');
          }
        }
        break;
        
      case VoiceCommandType.stopTimer:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopTimerForStep(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('计时器已停止');
        }
        break;
        
      case VoiceCommandType.completeStep:
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopAndCompleteStep(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('步骤已完成');
        }
        break;
        
      case VoiceCommandType.nextDish:
        if (_currentIndex < _totalDishes - 1) {
          setState(() {
            _currentIndex++;
            _currentFocusedStepNumber = 1;
          });
          await _voiceAssistant.speak('已切换到下一道菜：${widget.menu.recipes[_currentIndex].title}');
        } else {
          await _voiceAssistant.speak('已经是最后一道菜了');
        }
        break;
        
      case VoiceCommandType.previousDish:
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex--;
            _currentFocusedStepNumber = 1;
          });
          await _voiceAssistant.speak('已切换到上一道菜：${widget.menu.recipes[_currentIndex].title}');
        } else {
          await _voiceAssistant.speak('已经是第一道菜了');
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
              await _voiceAssistant.speak('还剩${minutes}分${seconds}秒');
            } else {
              await _voiceAssistant.speak('已超时${-minutes}分${-seconds}秒');
            }
          } else {
            await _voiceAssistant.speak('当前步骤没有运行中的计时器');
          }
        }
        break;
        
      case VoiceCommandType.ingredientsList:
        final ingredients = recipe.ingredients;
        if (ingredients.isEmpty) {
          await _voiceAssistant.speak('没有食材列表');
        } else {
          String text = '需要以下食材：';
          for (var ing in ingredients) {
            text += '${ing.name}${ing.amountValue}${ing.amountUnit}，';
          }
          await _voiceAssistant.speak(text);
        }
        break;
        
      case VoiceCommandType.exitVoiceMode:
        _toggleVoiceMode();
        await _voiceAssistant.speak('已退出语音模式');
        break;
        
      case VoiceCommandType.help:
        await _voiceAssistant.speak(_voiceAssistant.getHelpText());
        break;
        
      case VoiceCommandType.unknown:
        await _voiceAssistant.speak('抱歉，我没有理解，请再说一遍');
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
                      ? '需要麦克风权限才能使用语音控制，请在设置中开启'
                      : '需要麦克风权限才能使用语音控制',
                ),
                action: isPermanentlyDenied
                    ? SnackBarAction(
                        label: '去设置',
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
  
  /// 开始语音监听
  void _startVoiceListening() {
    debugPrint('[RecipePage] _startVoiceListening() 被调用');
    
    _voiceAssistant.startListening(
      onResult: (recognizedText) async {
        await _handleVoiceCommand(recognizedText);
        // 如果语音模式仍然激活，继续监听下一个命令
        if (_isVoiceModeActive && mounted) {
          // 等待语音播放完成后再继续监听（避免语音播放时识别干扰）
          await Future.delayed(const Duration(milliseconds: 500));
          if (_isVoiceModeActive && mounted) {
            _startVoiceListening();
          }
        }
      },
      onError: (error) {
        debugPrint('[RecipePage] 语音监听错误: $error');
        
        if (mounted) {
          // 检查是否是初始化失败的错误
          final isInitializationError = error.contains('语音助手未初始化') || 
                                       error.contains('not available');
          
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(isInitializationError 
                  ? '语音识别不可用，请检查设备设置或安装语音服务' 
                  : '语音识别错误: $error'),
                duration: const Duration(seconds: 3),
              ),
            );
          
          // 如果是初始化错误，关闭语音模式，不再继续尝试
          if (isInitializationError) {
            debugPrint('[RecipePage] 检测到初始化失败，关闭语音模式');
            if (mounted) {
              setState(() {
                _isVoiceModeActive = false;
              });
            }
            return; // 不再继续监听
          }
          
          // 其他错误（如临时错误），可以继续尝试监听
          debugPrint('[RecipePage] 临时错误，延迟后重试监听');
          if (_isVoiceModeActive && mounted) {
            Future.delayed(const Duration(seconds: 1), () {
              if (_isVoiceModeActive && mounted) {
                debugPrint('[RecipePage] 重试开始监听');
                _startVoiceListening();
              }
            });
          }
        }
      },
    );
  }
  
  /// 停止语音监听
  void _stopVoiceListening() {
    _voiceAssistant.stopListening();
  }
  
  // ========== Gesture Control Methods ==========
  
  /// 处理手势命令
  Future<void> _handleGesture(GestureType gesture) async {
    // 智能切换：检测到手势时，暂停语音识别
    if (_isVoiceModeActive && _voiceAssistant.isListening) {
      _voiceAssistant.pauseListening();
    }
    
    // 根据手势类型执行相应操作
    switch (gesture) {
      case GestureType.handUp:
        // 下一步
        final nextStep = _getNextStep();
        if (nextStep != null) {
          setState(() {
            _currentFocusedStepNumber = nextStep.stepNumber;
          });
          await _voiceAssistant.speakStep(nextStep);
        } else {
          await _voiceAssistant.speak('已经是最后一步了');
        }
        break;
        
      case GestureType.handDown:
        // 上一步
        final prevStep = _getPreviousStep();
        if (prevStep != null) {
          setState(() {
            _currentFocusedStepNumber = prevStep.stepNumber;
          });
          await _voiceAssistant.speakStep(prevStep);
        } else {
          await _voiceAssistant.speak('已经是第一步了');
        }
        break;
        
      case GestureType.fist:
        // 重复当前步骤
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          await _voiceAssistant.speakStep(currentStep);
        }
        break;
        
      case GestureType.openHand:
        // 暂停计时
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _pauseTimer(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('计时器已暂停');
        }
        break;
        
      case GestureType.okSign:
        // 完成步骤
        final currentStep = _getFocusedStep();
        if (currentStep != null) {
          _stopAndCompleteStep(_currentIndex, currentStep.stepNumber);
          await _voiceAssistant.speak('步骤已完成');
        }
        break;
        
      case GestureType.none:
        // 无手势，不做处理
        break;
    }
    
    // 智能切换：手势识别结束后，恢复语音识别
    if (_isVoiceModeActive) {
      await Future.delayed(const Duration(milliseconds: 300)); // 短暂延迟，确保手势处理完成
      await _voiceAssistant.resumeListening();
    }
  }
  
  /// 切换手势模式
  void _toggleGestureMode() async {
    setState(() {
      _isGestureModeActive = !_isGestureModeActive;
    });
    
    if (_isGestureModeActive) {
      await _initializeGestureControl();
      await _gestureControl.startDetection();
    } else {
      await _gestureControl.stopDetection();
      // 如果语音模式也激活，确保语音识别恢复
      if (_isVoiceModeActive) {
        await _voiceAssistant.resumeListening();
      }
    }
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
                            ? () => _pauseTimer(_currentIndex, step.stepNumber)
                            : () => _startTimerForStep(
                                _currentIndex, step.stepNumber, step.stepTimeMin),
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
                        onPressed: () =>
                            _stopAndCompleteStep(_currentIndex, step.stepNumber),
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
                  onPressed:
                      _currentIndex < _totalDishes - 1 ? _goToNextDish : null,
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
                    label: Text(
                      isCurrentDone ? 'Dish done' : 'Mark dish done',
                    ),
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
