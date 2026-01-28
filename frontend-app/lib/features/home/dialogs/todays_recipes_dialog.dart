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
  final String imageIcon;

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
    required this.imageIcon,
    this.consumedPercentage = 0.0, // ✅ 改为0.0（最低值）
    this.maxConsumablePercentage = 1.0,
    this.initialGrams,
    this.currentGrams,
  });
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
  bool _isAdding = false;
  List<TodayRecipe> _todaysRecipes = [];
  List<Map<String, dynamic>>? _cachedDishOptions; // ✅ 新增：缓存菜品选项

  @override
  void initState() {
    super.initState();
    _loadTodayRecipes();
  }

  Future<void> _loadTodayRecipes() async {
    setState(() => _isLoading = true);

    try {
      final result = await HomepageApiService.getTodayIntakes(source: 'recipe');

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        setState(() {
          // ✅ 将值对齐到最近的 10% 倍数（步长为 0.1）
          double snapToStep(double val) {
            return (val / 0.1).round() * 0.1;
          }

          _todaysRecipes = items.map((item) {
            // ✅ Backend: consumedPercentage 是 0-100，表示总消耗量（相对于初始质量）
            final backendConsumedPct =
                (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
            // ✅ 转换为 0-1 范围（UI 值），然后对齐到 10% 倍数
            final uiFrac = (backendConsumedPct / 100.0).clamp(0.0, 1.0);
            final snappedFrac = snapToStep(uiFrac).clamp(0.0, 1.0);

            return TodayRecipe(
              intakeId: (item['intakeId'] as num?)?.toInt(),
              leftoverId: (item['leftoverId'] as num?)?.toInt(),
              name: item['leftoverTitle'] as String? ?? 'Unknown Leftover',
              imageIcon: "🍽️", // 默认图标，可以根据recipe_id获取真实图标
              consumedPercentage: snappedFrac, // ✅ 对齐到 10% 倍数
              maxConsumablePercentage: 1.0, // ✅ 固定为1.0（100%）
              // ✅ 解析初始质量和当前质量
              initialGrams: (item['initialGrams'] as num?)?.toDouble(),
              currentGrams: (item['currentGrams'] as num?)?.toDouble(),
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          final errorCode = result['code'] as int?;
          final errorMsg = result['error'] as String? ?? 'Unknown error';

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
                content: Text('Failed to load recipes: $errorMsg'),
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

  Future<void> _showAddDishSheet() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    try {
      final result = await HomepageApiService.getDishOptions();
      setState(() => _isAdding = false);

      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final rawOptions = data['options'] as List<dynamic>? ?? [];
        // 只允许 leftover
        final options = rawOptions.where((o) {
          final opt = o as Map<String, dynamic>;
          return (opt['type'] as String?) == 'leftover';
        }).toList();

        // ✅ 缓存 options 数据
        _cachedDishOptions = options.cast<Map<String, dynamic>>();

        await showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            final selectedIds = <int>{};
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select dishes',
                              style: GoogleFonts.kalam(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final opt =
                                  options[index] as Map<String, dynamic>;
                              final id = (opt['id'] as num?)?.toInt();
                              final title =
                                  (opt['title'] as String?) ?? 'Unknown';
                              final subtitle =
                                  (opt['subtitle'] as String?) ?? '';

                              final selected =
                                  id != null && selectedIds.contains(id);
                              return ListTile(
                                leading: const Text(
                                  '🥡',
                                  style: TextStyle(fontSize: 22),
                                ),
                                title: Text(title, style: GoogleFonts.kalam()),
                                subtitle: subtitle.isNotEmpty
                                    ? Text(
                                        subtitle,
                                        style: GoogleFonts.kalam(fontSize: 12),
                                      )
                                    : null,
                                trailing: Checkbox(
                                  value: selected,
                                  onChanged: id == null
                                      ? null
                                      : (checked) {
                                          setSheetState(() {
                                            if (checked == true) {
                                              selectedIds.add(id);
                                            } else {
                                              selectedIds.remove(id);
                                            }
                                          });
                                        },
                                ),
                                onTap: id == null
                                    ? null
                                    : () {
                                        setSheetState(() {
                                          if (selected) {
                                            selectedIds.remove(id);
                                          } else {
                                            selectedIds.add(id);
                                          }
                                        });
                                      },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _buildSketchyButton(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () async {
                                    Navigator.of(context).pop();
                                    await _addDishes(ids: selectedIds.toList());
                                  },
                            child: Text(
                              'Confirm (${selectedIds.length})',
                              style: GoogleFonts.kalam(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B4F4F).withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      } else {
        final errorMsg = result['error'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dish options: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isAdding = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addDishes({required List<int> ids}) async {
    // ✅ 不再调用后端API，只添加到本地列表
    setState(() {
      for (final id in ids) {
        // 检查是否已经添加过（避免重复）
        if (_todaysRecipes.any((r) => r.leftoverId == id)) {
          continue;
        }

        // 从缓存的 options 中查找
        Map<String, dynamic>? opt;
        if (_cachedDishOptions != null) {
          try {
            opt =
                _cachedDishOptions!.firstWhere(
                      (o) => (o['id'] as num?)?.toInt() == id,
                    )
                    as Map<String, dynamic>?;
          } catch (e) {
            opt = null;
          }
        }

        if (opt != null) {
          final title = opt['title'] as String? ?? 'Unknown Leftover';
          final initialGrams = (opt['initialGrams'] as num?)?.toDouble();
          final currentGrams = (opt['currentGrams'] as num?)?.toDouble();

          // ✅ 计算最低值（已消费的部分）
          double minValue = 0.0;
          if (initialGrams != null &&
              currentGrams != null &&
              initialGrams > 0) {
            final minPercentage = (initialGrams - currentGrams) / initialGrams;
            minValue = minPercentage.clamp(0.0, 1.0);
          }

          // ✅ 将初始值对齐到最近的 10% 倍数（步长为 0.1）
          double snapToStep(double val) {
            return (val / 0.1).round() * 0.1;
          }

          final initialConsumedPct = snapToStep(minValue).clamp(0.0, 1.0);

          // ✅ 创建本地对象，intakeId 为 null（表示未保存）
          _todaysRecipes.add(
            TodayRecipe(
              intakeId: null, // ✅ 新添加的，还未保存
              leftoverId: id,
              name: title,
              imageIcon: "🥡",
              consumedPercentage:
                  initialConsumedPct, // ✅ 初始值设为最低值（已消费的部分），对齐到 10% 倍数
              maxConsumablePercentage: 1.0, // ✅ 固定为1.0（100%）
              initialGrams: initialGrams,
              currentGrams: currentGrams,
            ),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to list (not saved yet)'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _isLoading || _isSaving || _isAdding
                              ? null
                              : _showAddDishSheet,
                          icon: _isAdding
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.add,
                                  color: const Color(
                                    0xFF6B4F4F,
                                  ).withOpacity(0.7),
                                ), // Lighter brown
                          tooltip: 'Add leftover',
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Add dishes and adjust how much you ate",
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
            "No dish intake yet",
            style: GoogleFonts.kalam(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add a leftover dish",
            style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(TodayRecipe recipe) {
    // ✅ 计算滑动条的最小值和最大值
    // 滑动条表示总消耗量（相对于初始质量的百分比）
    double minValue = 0.0;
    double maxValue = 1.0; // ✅ 上限固定为100%

    // 如果有初始质量和当前质量，计算最低值（已消费的部分）
    if (recipe.initialGrams != null &&
        recipe.currentGrams != null &&
        recipe.initialGrams! > 0) {
      final initial = recipe.initialGrams!;
      final current = recipe.currentGrams!;

      // ✅ 最低值：已消费的部分 = (初始质量 - 当前质量) / 初始质量
      final minPercentage = (initial - current) / initial;
      minValue = minPercentage.clamp(0.0, 1.0);

      // ✅ 最高值：固定为100%（最多只能消耗100%的初始质量）
      maxValue = 1.0;
    }

    // ✅ 确保 maxValue >= minValue
    if (maxValue < minValue) {
      maxValue = minValue;
    }
    if (maxValue <= 0) {
      maxValue = minValue > 0 ? minValue : 0.01;
    }

    // ✅ 将值对齐到最近的 10% 倍数（步长为 0.1）
    double snapToStep(double val) {
      // 对齐到 0.1 的倍数
      return (val / 0.1).round() * 0.1;
    }

    final rawValue = recipe.consumedPercentage.clamp(minValue, maxValue);
    final value = snapToStep(rawValue).clamp(minValue, maxValue);

    // ✅ 计算 divisions（步长为 10%，即 0.1）
    // divisions = (maxValue - minValue) / 0.1，但至少为 1
    final range = maxValue - minValue;
    final divisions = (range / 0.1).round().clamp(
      1,
      10,
    ); // 最多 10 个步长（0% 到 100%）

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
              Text(recipe.imageIcon, style: const TextStyle(fontSize: 32)),
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
                  // ✅ 对齐到最近的 10% 倍数，然后限制在范围内
                  final snapped = snapToStep(newValue);
                  recipe.consumedPercentage = snapped.clamp(minValue, maxValue);
                });
              },
              min: minValue,
              max: maxValue,
              divisions: divisions, // ✅ 阶梯式，步长为 10%
            ),
          ),

          // 标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "None",
                style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                "All eaten",
                style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
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
