import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/homepage_api_service.dart';

/// 今日菜谱数据模型
class TodayRecipe {
  final int? intakeId;
  final String name;
  final String imageIcon;
  /// UI percentage relative to the ORIGINAL leftover (0.0 - 1.0).
  /// Example: if a leftover has only 36% remaining, slider max is 0.36.
  double consumedPercentage;

  /// Max consumable percentage relative to the ORIGINAL leftover (0.0 - 1.0).
  /// Typically computed as: baseGramsAtIntakeCreation / initialGrams.
  final double maxConsumablePercentage;

  TodayRecipe({
    this.intakeId,
    required this.name,
    required this.imageIcon,
    this.consumedPercentage = 0.5,
    this.maxConsumablePercentage = 1.0,
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
          _todaysRecipes = items.map((item) {
            // Backend: consumedPercentage is 0-100 relative to the leftover grams at intake creation.
            // Backend: maxConsumablePercentage is 0-100 relative to the ORIGINAL leftover.
            final backendConsumedPct =
                (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
            final maxConsumablePct =
                (item['maxConsumablePercentage'] as num?)?.toDouble() ?? 100.0;
            final maxFrac = (maxConsumablePct / 100.0).clamp(0.0, 1.0);
            // UI value = maxFrac * (backendConsumedPct/100)
            final uiFrac =
                (maxFrac * (backendConsumedPct / 100.0)).clamp(0.0, maxFrac);
            return TodayRecipe(
              intakeId: item['intakeId'] as int?,
              name: item['leftoverTitle'] as String? ?? 'Unknown Leftover',
              imageIcon: "🍽️", // 默认图标，可以根据recipe_id获取真实图标
              consumedPercentage: uiFrac,
              maxConsumablePercentage: maxFrac,
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
        if (recipe.intakeId != null) {
          // Convert UI percentage (0..maxConsumablePercentage) to backend percentage (0..100)
          // relative to the grams at intake creation.
          final max = recipe.maxConsumablePercentage;
          final ui = recipe.consumedPercentage.clamp(0.0, max);
          final percentage = (max > 0)
              ? ((ui / max) * 100.0).clamp(0.0, 100.0)
              : 0.0;
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select leftovers',
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
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final opt = options[index] as Map<String, dynamic>;
                              final id = (opt['id'] as num?)?.toInt();
                              final title = (opt['title'] as String?) ?? 'Unknown';
                              final subtitle = (opt['subtitle'] as String?) ?? '';

                              final selected = id != null && selectedIds.contains(id);
                              return ListTile(
                                leading: const Text('🥡', style: TextStyle(fontSize: 22)),
                                title: Text(title, style: GoogleFonts.kalam()),
                                subtitle: subtitle.isNotEmpty
                                    ? Text(subtitle, style: GoogleFonts.kalam(fontSize: 12))
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
                          child: ElevatedButton(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () async {
                                    Navigator.of(context).pop();
                                    await _addDishes(ids: selectedIds.toList());
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Confirm (${selectedIds.length})',
                              style: GoogleFonts.kalam(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    setState(() => _isAdding = true);
    try {
      final result = await HomepageApiService.addDishIntake(ids: ids);
      setState(() => _isAdding = false);

      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        // Prefer backend-provided list to refresh UI immediately
        final data = result['data'] as Map<String, dynamic>;
        final todayItems = data['todayDishIntakes'] as List<dynamic>? ?? [];

        setState(() {
          _todaysRecipes = todayItems.map((item) {
            final backendConsumedPct =
                (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
            final maxConsumablePct =
                (item['maxConsumablePercentage'] as num?)?.toDouble() ?? 100.0;
            final maxFrac = (maxConsumablePct / 100.0).clamp(0.0, 1.0);
            final uiFrac =
                (maxFrac * (backendConsumedPct / 100.0)).clamp(0.0, maxFrac);
            return TodayRecipe(
              intakeId: item['intakeId'] as int?,
              name: item['leftoverTitle'] as String? ?? 'Unknown Leftover',
              imageIcon: "🥡",
              consumedPercentage: uiFrac,
              maxConsumablePercentage: maxFrac,
            );
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final errorMsg = result['error'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: $errorMsg'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
                        color: Colors.deepOrange.shade600,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Today's Dish Intake",
                          style: GoogleFonts.caveat(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade800,
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
                      onPressed: _isLoading || _isSaving || _isAdding ? null : _showAddDishSheet,
                      icon: _isAdding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.add, color: Colors.deepOrange.shade600),
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
              style: GoogleFonts.kalam(fontSize: 14, color: Colors.grey[600]),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildRecipeItem(_todaysRecipes[index]);
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Save Changes",
                        style: GoogleFonts.kalam(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
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
    final max = recipe.maxConsumablePercentage.clamp(0.0, 1.0);
    final value = recipe.consumedPercentage.clamp(0.0, max);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
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
                  color: Colors.deepOrange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(value * 100).toInt()}%",
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 可调节进度条
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.deepOrange.shade400,
              inactiveTrackColor: Colors.orange.shade100,
              thumbColor: Colors.deepOrange.shade600,
              overlayColor: Colors.deepOrange.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              onChanged: (value) {
                setState(() {
                  recipe.consumedPercentage = value.clamp(0.0, max);
                });
              },
              min: 0.0,
              max: max > 0 ? max : 1.0,
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
