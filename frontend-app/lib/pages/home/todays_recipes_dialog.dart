import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/homepage_api_service.dart';

/// 今日菜谱数据模型
class TodayRecipe {
  final int? intakeId;
  final String name;
  final String imageIcon;
  double consumedPercentage; // 0.0 - 1.0

  TodayRecipe({
    this.intakeId,
    required this.name,
    required this.imageIcon,
    this.consumedPercentage = 0.5,
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
            final consumedPercentage =
                (item['consumedPercentage'] as num?)?.toDouble() ?? 0.0;
            return TodayRecipe(
              intakeId: item['intakeId'] as int?,
              name: item['recipeTitle'] as String? ?? 'Unknown Recipe',
              imageIcon: "🍽️", // 默认图标，可以根据recipe_id获取真实图标
              consumedPercentage: consumedPercentage / 100.0, // 转换为0-1范围
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
          final percentage = (recipe.consumedPercentage * 100).toDouble();
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
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Colors.deepOrange.shade600,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Today's Recipes",
                      style: GoogleFonts.caveat(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Adjust how much you ate of each dish",
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
            "No recipes cooked today",
            style: GoogleFonts.kalam(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(TodayRecipe recipe) {
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
                  "${(recipe.consumedPercentage * 100).toInt()}%",
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
              value: recipe.consumedPercentage,
              onChanged: (value) {
                setState(() {
                  recipe.consumedPercentage = value;
                });
              },
              min: 0.0,
              max: 1.0,
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
