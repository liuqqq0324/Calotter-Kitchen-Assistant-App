// lib/pages/recipes/recipes_home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/collected_recipes_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_generate_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_filter_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_instruction_page.dart';
import 'package:personal_sous_chef/services/household_service.dart';
import 'package:personal_sous_chef/widgets/generate_recipe_button.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';

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
      MaterialPageRoute(
        builder: (_) => const RecipeFilterPage(),
      ),
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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
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
                  label: Text(
                    'Filter',
                    style: GoogleFonts.kalam(fontSize: 16),
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune,
                      size: 18,
                      color: Colors.deepOrange,
                    ),
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  // 清理被移除的选择
                  _selectedFavoriteIds.removeWhere(
                      (id) => favorites.every((r) => r.id != id));

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
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 8, top: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final recipe = favorites[index];
                            final selected =
                                _selectedFavoriteIds.contains(recipe.id);
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
                                  .where((r) => _selectedFavoriteIds.contains(r.id))
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
                      builder: (_) => RecipeGeneratePage(
                        filter: _currentFilter,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCollectedCard(
    BuildContext context,
    RecipeModel recipe,
    ThemeData theme,
    {required bool selected, required VoidCallback onToggleSelect}
  ) {
    return GestureDetector(
      onTap: () {
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 拍立得相框样式（手绘风格）
          SketchyCard(
            backgroundColor: Colors.white,
            borderColor: Colors.black87,
            borderWidth: 2.5,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // 上部分：淡黄色图片区域
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D3), // 淡黄色背景
                      border: Border.all(
                        color: Colors.black87,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),
                // 下部分：白色区域显示菜名
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Center(
                      child: Text(
                        recipe.title,
                        style: GoogleFonts.kalam(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 回形针装饰（左上角）
          Positioned(
            top: -12,
            left: 8,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.attach_file,
                size: 38,
                color: Colors.grey.shade600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
            ),
          ),
          // 选择框（右上角）
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onToggleSelect,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.orange : Colors.grey.shade400,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  selected ? Icons.check : Icons.circle_outlined,
                  size: 20,
                  color: selected ? Colors.orange : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
