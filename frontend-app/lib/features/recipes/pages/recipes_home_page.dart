// lib/pages/recipes/recipes_home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/stores/collected_recipes_store.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_generate_page.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_filter_page.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_instruction_page.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/shared/widgets/buttons/generate_recipe_button.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  Map<String, dynamic>? _currentFilter; // 保存最近一次的 filter 设置
  final Set<String> _selectedFavoriteIds = {};
  bool _loadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loadingFavorites = true);
    try {
      // 获取householdId
      final householdId = await HouseholdService.getHouseholdId();
      if (householdId != null) {
        await CollectedRecipesStore.fetchFromServer(householdId: householdId);
      } else {
        debugPrint('Failed to get householdId, cannot load favorites');
      }
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingFavorites = false);
      }
    }
  }

  // 把 Map 变成一行 summary 文案
  String? get _filterSummary {
    if (_currentFilter == null) return null;

    final servings = _currentFilter?['servings'];
    final dishCount = _currentFilter?['dish_count'];
    final calorieTarget = _currentFilter?['calorie_target'];
    final maxTime = _currentFilter?['max_cooking_time_min'];
    final difficulty = _currentFilter?['difficulty_target'];

    final parts = <String>[];

    if (servings != null) {
      parts.add('$servings servings');
    }
    if (dishCount != null) {
      parts.add('$dishCount dishes');
    }
    if (calorieTarget != null) {
      parts.add('≤ $calorieTarget kcal / person');
    }
    if (maxTime != null) {
      parts.add('≤ $maxTime min / dish');
    }
    if (difficulty != null) {
      if (difficulty is List && difficulty.isNotEmpty) {
        parts.add('difficulty: ${difficulty.join("/")}');
      } else if (difficulty.toString().isNotEmpty) {
        parts.add('difficulty: $difficulty');
      }
    }

    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  Future<void> _openFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecipeFilterPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _currentFilter = result;
      });

      // 小提示：让你知道已经保存了
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Filter settings updated.'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryText = _filterSummary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部标题 + Filter 按钮 - 手绘风格
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Recipes',
                  style: GoogleFonts.caveat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openFilterPage,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                  ),
                  icon: const Icon(Icons.filter_list),
                  label: Text('Filter', style: GoogleFonts.kalam(fontSize: 16)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 如果有 filter，总结一下当前条件 - 手绘风格
            if (summaryText != null) ...[
              SketchyCard(
                backgroundColor: Colors.orange.withOpacity(0.1),
                borderColor: Colors.deepOrange.shade700,
                borderWidth: 2.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 18, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summaryText,
                        style: GoogleFonts.kalam(
                          fontSize: 14,
                          color: Colors.deepOrange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = null;
                        });
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.kalam(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 16),

            // 收藏食谱区域 + 选择后统一 Start cooking
            Expanded(
              child: ValueListenableBuilder<List<RecipeModel>>(
                valueListenable: CollectedRecipesStore.favorites,
                builder: (context, favorites, _) {
                  if (_loadingFavorites && favorites.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // 清理被移除的选择
                  _selectedFavoriteIds.removeWhere(
                    (id) => favorites.every((r) => r.id != id),
                  );

                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "You haven't saved any recipes yet.",
                            style: GoogleFonts.kalam(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap the button below to generate your first menu.",
                            style: GoogleFonts.kalam(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: favorites.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'Collected recipes',
                                  style: GoogleFonts.caveat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            final recipe = favorites[index - 1];
                            final selected = _selectedFavoriteIds.contains(
                              recipe.id,
                            );
                            return _buildCollectedCard(
                              context,
                              recipe,
                              theme,
                              selected: selected,
                              onToggleSelect: () {
                                setState(() {
                                  if (selected) {
                                    _selectedFavoriteIds.remove(recipe.id);
                                  } else {
                                    _selectedFavoriteIds.add(recipe.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      if (_selectedFavoriteIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final selectedRecipes = favorites
                                  .where(
                                    (r) => _selectedFavoriteIds.contains(r.id),
                                  )
                                  .toList();
                              if (selectedRecipes.isEmpty) return;
                              final tempMenu = RecipeMenuModel(
                                menuId: -1,
                                recipes: selectedRecipes,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeInstructionPage(
                                    menu: tempMenu,
                                    initialRecipeIndex: 0,
                                    filter: _currentFilter,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'Start cooking (${_selectedFavoriteIds.length} selected)',
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 生成食谱按钮
            SizedBox(
              width: double.infinity,
              child: GenerateRecipeButton(
                isFullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RecipeGeneratePage(filter: _currentFilter),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectedCard(
    BuildContext context,
    RecipeModel recipe,
    ThemeData theme, {
    required bool selected,
    required VoidCallback onToggleSelect,
  }) {
    String difficultyLabel = recipe.difficulty;
    Color difficultyColor;
    switch (difficultyLabel) {
      case 'hard':
        difficultyColor = Colors.redAccent;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      default:
        difficultyColor = Colors.green;
    }

    return GestureDetector(
      child: SketchyCard(
        backgroundColor: Colors.white,
        borderColor: Colors.black87,
        borderWidth: 2.0,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：emoji 圆卡片
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(width: 12),

            // 右侧：菜单信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：菜单名 + 难度标签
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              recipe.title,
                              style: GoogleFonts.caveat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                difficultyLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: difficultyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        child: InkWell(
                          onTap: onToggleSelect,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 18,
                                color: selected
                                    ? Colors.orange
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  selected ? 'Selected' : 'Select',
                                  style: GoogleFonts.kalam(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.orange
                                        : Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 简短描述
                  Text(
                    recipe.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 底部：时间 + 卡路里
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
                        style: GoogleFonts.kalam(
                          fontSize: 12,
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
                        style: GoogleFonts.kalam(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final tempMenu = RecipeMenuModel(
                          menuId: 0,
                          recipes: [recipe],
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeInstructionPage(
                              menu: tempMenu,
                              initialRecipeIndex: 0,
                              filter: _currentFilter,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('View steps'),
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
}
