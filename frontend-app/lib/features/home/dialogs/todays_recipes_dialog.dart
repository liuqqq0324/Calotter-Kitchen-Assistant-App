import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/api/homepage_api_service.dart';
import 'dart:math' as math;
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';

/// 今日菜谱数据模型
class TodayRecipe {
  int? intakeId; // ✅ 改为可变，保存后更新
  final int? leftoverId; // ✅ 新增：用于标识 leftover dish
  final String name;
  final String? category; // ✅ 烹饪分类（如：STIR_FRY_PAN_FRY, STEAM_BOIL等）
  final String emoji; // ✅ emoji 作为后备图标

  /// UI percentage relative to the ORIGINAL leftover (0.0 - 1.0).
  /// Example: if a leftover has only 36% remaining, slider max is 0.36.
  double consumedPercentage;

  /// Max consumable percentage relative to the ORIGINAL leftover (0.0 - 1.0).
  /// Typically computed as: baseGramsAtIntakeCreation / initialGrams.
  final double maxConsumablePercentage;

  /// ✅ 初始质量（克）
  final double? initialGrams;

  /// ✅ 当前质量（克）
  final double? currentGrams;

  TodayRecipe({
    this.intakeId,
    this.leftoverId, // ✅ 新增
    required this.name,
    this.category,
    this.emoji = '🍽️', // ✅ 默认 emoji
    this.consumedPercentage = 0.0, // ✅ 改为0.0（最低值）
    this.maxConsumablePercentage = 1.0,
    this.initialGrams,
    this.currentGrams,
  });

  /// ✅ 根据分类获取对应的配图路径（与 RecipeModel 逻辑一致）
  String get categoryImagePath {
    if (category == null || category!.isEmpty) {
      print('[TodayRecipe.categoryImagePath] category 为空，使用默认图标: name=$name');
      return 'assets/dish_category/STIR_FRY_PAN_FRY.png'; // 默认图标
    }
    // trim() 防止后端返回带空格的字符串
    final path = 'assets/dish_category/${category!.trim()}.png';
    print('[TodayRecipe.categoryImagePath] 使用分类图标: name=$name, category=$category, path=$path');
    return path;
  }
}

/// 今日已做菜谱记录弹窗
class TodaysRecipesDialog extends StatefulWidget {
  const TodaysRecipesDialog({super.key});

  @override
  State<TodaysRecipesDialog> createState() => _TodaysRecipesDialogState();
}

class _TodaysRecipesDialogState extends State<TodaysRecipesDialog> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<TodayRecipe> _todaysRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadTodayRecipes();
  }

  Future<void> _loadTodayRecipes() async {
    setState(() => _isLoading = true);

    try {
      // ✅ 同时加载今日已记录的 intake 和所有可用的 leftover 选项
      final intakeResult = await HomepageApiService.getTodayIntakes(source: 'recipe');
      final optionsResult = await HomepageApiService.getDishOptions();

      if (intakeResult['success'] == true && optionsResult['success'] == true) {
        final intakeData = intakeResult['data'] as Map<String, dynamic>?;
        final optionsData = optionsResult['data'] as Map<String, dynamic>?;
        
        final intakeItems = intakeData?['items'] as List<dynamic>? ?? [];
        final rawOptions = optionsData?['options'] as List<dynamic>? ?? [];
        
        // ✅ 只保留 leftover 类型的选项
        final leftoverOptions = rawOptions.where((o) {
          final opt = o as Map<String, dynamic>;
          return (opt['type'] as String?) == 'leftover';
        }).toList();

        setState(() {
          // ✅ 将值对齐到最近的 10% 倍数（步长为 0.1）
          double snapToStep(double val) {
            return (val / 0.1).round() * 0.1;
          }

          // ✅ 创建已记录的 intake 映射（按 leftoverId）
          final Map<int, TodayRecipe> intakeMap = {};
          for (final item in intakeItems) {
            final leftoverId = (item['leftoverId'] as num?)?.toInt();
            if (leftoverId == null) continue;

            final backendConsumedPct =
                (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
            final uiFrac = (backendConsumedPct / 100.0).clamp(0.0, 1.0);
            final snappedFrac = snapToStep(uiFrac).clamp(0.0, 1.0);

            final category = item['category'] as String?;
            // ✅ 调试日志：检查 category 是否被正确获取
            print('[TodaysRecipesDialog] 从 intake 加载: name=${item['leftoverTitle']}, leftoverId=$leftoverId, category=$category');

            intakeMap[leftoverId] = TodayRecipe(
              intakeId: (item['intakeId'] as num?)?.toInt(),
              leftoverId: leftoverId,
              name: item['leftoverTitle'] as String? ?? 'Unknown Leftover',
              category: category, // ✅ 从后端获取分类
              emoji: "🍽️",
              consumedPercentage: snappedFrac,
              maxConsumablePercentage: 1.0,
              initialGrams: (item['initialGrams'] as num?)?.toDouble(),
              currentGrams: (item['currentGrams'] as num?)?.toDouble(),
            );
          }

          // ✅ 合并所有 leftover 选项，已记录的保留 intakeId，未记录的创建新项
          _todaysRecipes = leftoverOptions.map((opt) {
            final optMap = opt as Map<String, dynamic>;
            final leftoverId = (optMap['id'] as num?)?.toInt();
            if (leftoverId == null) return null;

            // ✅ 如果已存在 intake 记录，使用已有数据
            if (intakeMap.containsKey(leftoverId)) {
              return intakeMap[leftoverId];
            }

            // ✅ 否则创建新项（intakeId 为 null）
            final title = optMap['title'] as String? ?? 'Unknown Leftover';
            final category = optMap['category'] as String?; // ✅ 从选项获取分类
            // ✅ 调试日志：检查 category 是否被正确获取
            print('[TodaysRecipesDialog] 从选项创建: name=$title, leftoverId=$leftoverId, category=$category');
            final initialGrams = (optMap['initialGrams'] as num?)?.toDouble();
            final currentGrams = (optMap['currentGrams'] as num?)?.toDouble();

            // ✅ 计算最低值（已消费的部分）
            double minValue = 0.0;
            if (initialGrams != null &&
                currentGrams != null &&
                initialGrams > 0) {
              final minPercentage = (initialGrams - currentGrams) / initialGrams;
              minValue = minPercentage.clamp(0.0, 1.0);
            }

            final initialConsumedPct = snapToStep(minValue).clamp(0.0, 1.0);

            return TodayRecipe(
              intakeId: null, // ✅ 未保存
              leftoverId: leftoverId,
              name: title,
              category: category, // ✅ 从选项获取分类
              emoji: "🥡",
              consumedPercentage: initialConsumedPct,
              maxConsumablePercentage: 1.0,
              initialGrams: initialGrams,
              currentGrams: currentGrams,
            );
          }).whereType<TodayRecipe>().toList();
          
          _isLoading = false;
        });
      } else {
        // ✅ 即使其中一个失败，也尝试显示另一个的结果
        final intakeSuccess = intakeResult['success'] == true;
        final optionsSuccess = optionsResult['success'] == true;
        
        if (intakeSuccess || optionsSuccess) {
          // ✅ 至少有一个成功，尝试显示数据
          final intakeData = intakeSuccess ? (intakeResult['data'] as Map<String, dynamic>?) : null;
          final optionsData = optionsSuccess ? (optionsResult['data'] as Map<String, dynamic>?) : null;
          
          final intakeItems = intakeData?['items'] as List<dynamic>? ?? [];
          final rawOptions = optionsData?['options'] as List<dynamic>? ?? [];
          
          final leftoverOptions = rawOptions.where((o) {
            final opt = o as Map<String, dynamic>;
            return (opt['type'] as String?) == 'leftover';
          }).toList();

          setState(() {
            double snapToStep(double val) {
              return (val / 0.1).round() * 0.1;
            }

            final Map<int, TodayRecipe> intakeMap = {};
            for (final item in intakeItems) {
              final leftoverId = (item['leftoverId'] as num?)?.toInt();
              if (leftoverId == null) continue;

              final backendConsumedPct =
                  (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
              final uiFrac = (backendConsumedPct / 100.0).clamp(0.0, 1.0);
              final snappedFrac = snapToStep(uiFrac).clamp(0.0, 1.0);

              intakeMap[leftoverId] = TodayRecipe(
                intakeId: (item['intakeId'] as num?)?.toInt(),
                leftoverId: leftoverId,
                name: item['leftoverTitle'] as String? ?? 'Unknown Leftover',
                category: item['category'] as String?, // ✅ 从后端获取分类
                emoji: "🍽️",
                consumedPercentage: snappedFrac,
                maxConsumablePercentage: 1.0,
                initialGrams: (item['initialGrams'] as num?)?.toDouble(),
                currentGrams: (item['currentGrams'] as num?)?.toDouble(),
              );
            }

            _todaysRecipes = leftoverOptions.map((opt) {
              final optMap = opt as Map<String, dynamic>;
              final leftoverId = (optMap['id'] as num?)?.toInt();
              if (leftoverId == null) return null;

              if (intakeMap.containsKey(leftoverId)) {
                return intakeMap[leftoverId];
              }

              final title = optMap['title'] as String? ?? 'Unknown Leftover';
              final category = optMap['category'] as String?; // ✅ 从选项获取分类
              final initialGrams = (optMap['initialGrams'] as num?)?.toDouble();
              final currentGrams = (optMap['currentGrams'] as num?)?.toDouble();

              double minValue = 0.0;
              if (initialGrams != null &&
                  currentGrams != null &&
                  initialGrams > 0) {
                final minPercentage = (initialGrams - currentGrams) / initialGrams;
                minValue = minPercentage.clamp(0.0, 1.0);
              }

              final initialConsumedPct = snapToStep(minValue).clamp(0.0, 1.0);

              return TodayRecipe(
                intakeId: null,
                leftoverId: leftoverId,
                name: title,
                category: category, // ✅ 从选项获取分类
                emoji: "🥡",
                consumedPercentage: initialConsumedPct,
                maxConsumablePercentage: 1.0,
                initialGrams: initialGrams,
                currentGrams: currentGrams,
              );
            }).whereType<TodayRecipe>().toList();
            
            _isLoading = false;
          });
          
          // ✅ 如果其中一个失败，显示警告但不阻止显示
          if (!intakeSuccess || !optionsSuccess) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('部分数据加载失败，显示可用数据'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          // ✅ 两个都失败
          setState(() => _isLoading = false);
          if (mounted) {
            final errorCode = intakeResult['code'] as int? ?? optionsResult['code'] as int?;
            final errorMsg = intakeResult['error'] as String? ?? 
                            optionsResult['error'] as String? ?? 'Unknown error';

            if (errorCode == 401 || errorCode == 403) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please login again: $errorMsg'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load data: $errorMsg'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: _loadTodayRecipes,
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadTodayRecipes,
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      bool allSuccess = true;
      String? errorMessage;
      int? errorCode;

      for (final recipe in _todaysRecipes) {
        if (recipe.intakeId == null) {
          // ✅ 新添加的菜品：调用 addDishIntake
          if (recipe.leftoverId == null) {
            continue; // 跳过无效数据
          }

          // ✅ consumedPercentage 直接表示总消耗量（0-1范围），转换为后端百分比（0-100）
          final percentage = (recipe.consumedPercentage * 100.0).clamp(
            0.0,
            100.0,
          );

          final result = await HomepageApiService.addDishIntake(
            ids: [recipe.leftoverId!],
            consumedPercentage: percentage,
          );

          if (result['success'] != true) {
            allSuccess = false;
            errorMessage = result['error'] ?? 'Failed to add recipe';
            errorCode = result['code'] as int?;
            break;
          }

          // ✅ 更新本地数据：从后端返回的数据中获取 intakeId
          final data = result['data'] as Map<String, dynamic>?;
          final addedIntakes = data?['addedIntakes'] as List<dynamic>? ?? [];
          if (addedIntakes.isNotEmpty) {
            final item = addedIntakes.first as Map<String, dynamic>;
            recipe.intakeId = (item['intakeId'] as num?)?.toInt();
          }
        } else {
          // ✅ 已存在的菜品：调用 updateIntakePercentage
          // ✅ consumedPercentage 直接表示总消耗量（0-1范围），转换为后端百分比（0-100）
          final percentage = (recipe.consumedPercentage * 100.0).clamp(
            0.0,
            100.0,
          );

          final result = await HomepageApiService.updateIntakePercentage(
            intakeId: recipe.intakeId!,
            consumedPercentage: percentage,
          );

          if (result['success'] != true) {
            allSuccess = false;
            errorMessage = result['error'] ?? 'Failed to update recipe';
            errorCode = result['code'] as int?;
            break;
          }
        }
      }

      setState(() => _isSaving = false);

      if (allSuccess) {
        // ✅ 重新加载数据，确保 UI 显示最新的后端数据
        await _loadTodayRecipes();

        if (mounted) {
          Navigator.of(context).pop(_todaysRecipes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          if (errorCode == 401 || errorCode == 403) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please login again: $errorMessage'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: $errorMessage'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _saveChanges,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveChanges,
            ),
          ),
        );
      }
    }
  }


  // 构建手绘边框按钮
  Widget _buildSketchyButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
  }) {
    final borderColor = const Color(
      0xFF6B4F4F,
    ).withOpacity(0.7); // Same as text color
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              borderWidth: 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5), // Account for border width
              child: Center(child: child), // Center the content
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Background Layer: Sketchy paper container
          Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            margin: const EdgeInsets.only(top: 14), // Space for tape
            padding: const EdgeInsets.all(24),
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
                // 标题栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: const Color(
                              0xFF6B4F4F,
                            ).withOpacity(0.7), // Lighter brown
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "Today's Dish Intake",
                              style: GoogleFonts.caveat(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF6B4F4F,
                                ).withOpacity(0.7), // Lighter brown
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Adjust how much you ate for each leftover dish",
                  style: GoogleFonts.kalam(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // 菜谱列表
                Flexible(
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _todaysRecipes.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _todaysRecipes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildRecipeItem(_todaysRecipes[index]);
                          },
                        ),
                ),

                const SizedBox(height: 20),

                // 确认按钮
                Center(
                  child: _buildSketchyButton(
                    onPressed: _isLoading || _isSaving ? null : _saveChanges,
                    width: 220, // Fixed width, not too long
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF6B4F4F).withOpacity(0.7),
                            ),
                          )
                        : Text(
                            "Save Changes",
                            style: GoogleFonts.kalam(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B4F4F).withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
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
                  // Semi-transparent yellowish-white tape color - more transparent
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            "No leftover dishes available",
            style: GoogleFonts.kalam(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            "All leftover dishes will appear here automatically",
            style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(TodayRecipe recipe) {
    // ✅ 进度条始终以原始100%为基础（0% 到 100%）
    // 无论当前还剩多少，进度条都从0%开始，到100%结束
    double minValue = 0.0; // ✅ 始终从0%开始
    double maxValue = 1.0; // ✅ 始终到100%结束
    
    // ✅ 计算当前已消耗的百分比（用于限制用户不能拖到低于这个值）
    double currentConsumedPercentage = 0.0;
    if (recipe.initialGrams != null &&
        recipe.currentGrams != null &&
        recipe.initialGrams! > 0) {
      final initial = recipe.initialGrams!;
      final current = recipe.currentGrams!;
      // 当前已消耗的百分比 = (初始质量 - 当前质量) / 初始质量
      currentConsumedPercentage = ((initial - current) / initial).clamp(0.0, 1.0);
    }

    // ✅ 将值对齐到最近的 10% 倍数（步长为 0.1）
    double snapToStep(double val) {
      // 对齐到 0.1 的倍数
      return (val / 0.1).round() * 0.1;
    }

    // ✅ 确保 consumedPercentage 不低于当前已消耗的百分比
    final clampedConsumedPercentage = recipe.consumedPercentage.clamp(
      currentConsumedPercentage, // ✅ 不能低于当前已消耗的百分比
      maxValue,
    );
    final rawValue = clampedConsumedPercentage;
    final value = snapToStep(rawValue).clamp(minValue, maxValue);
    
    // ✅ 更新 recipe.consumedPercentage 以确保一致性
    if (recipe.consumedPercentage < currentConsumedPercentage) {
      recipe.consumedPercentage = currentConsumedPercentage;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF6B4F4F,
        ).withOpacity(0.05), // Light brown background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B4F4F).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 菜名和图标
          Row(
            children: [
              // ✅ 使用 recipes 中的分类图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    recipe.categoryImagePath, // ✅ 使用分类图标路径
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // ✅ 如果图片加载失败，显示 emoji
                      print('[TodaysRecipesDialog] 图片加载失败: name=${recipe.name}, path=${recipe.categoryImagePath}, error=$error');
                      return Center(
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recipe.name,
                  style: GoogleFonts.kalam(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              // 百分比显示
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4F4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(value * 100).toInt()}%",
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B4F4F), // River Deep Brown
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ 可调节进度条（阶梯式，步长 10%）
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6B4F4F), // River Deep Brown
              inactiveTrackColor: const Color(0xFF6B4F4F).withOpacity(0.2),
              thumbColor: const Color(0xFF6B4F4F), // River Deep Brown
              overlayColor: const Color(0xFF6B4F4F).withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              onChanged: (newValue) {
                setState(() {
                  // ✅ 对齐到最近的 10% 倍数
                  final snapped = snapToStep(newValue);
                  // ✅ 限制在范围内：不能低于当前已消耗的百分比，不能高于100%
                  recipe.consumedPercentage = snapped.clamp(
                    currentConsumedPercentage, // ✅ 不能低于当前已消耗的百分比
                    maxValue, // ✅ 不能高于100%
                  );
                });
              },
              min: minValue, // ✅ 进度条从0%开始（视觉上）
              max: maxValue, // ✅ 进度条到100%结束（视觉上）
              divisions: 10, // ✅ 固定为10个步长（0% 到 100%，每10%一个步长）
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示今日菜谱弹窗的便捷方法
Future<List<TodayRecipe>?> showTodaysRecipesDialog(BuildContext context) {
  return showDialog<List<TodayRecipe>>(
    context: context,
    builder: (context) => const TodaysRecipesDialog(),
  );
}

/// Custom painter to add subtle texture lines to the tape
class _TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines to simulate tape texture
    for (double y = 2; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for sketchy button border
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
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
