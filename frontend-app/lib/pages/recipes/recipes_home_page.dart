// lib/pages/recipes/recipes_home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_sous_chef/data/collected_recipes_store.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_generate_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_filter_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_instruction_page.dart';
import 'package:personal_sous_chef/widgets/generate_recipe_button.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  Map<String, dynamic>? _currentFilter; // 保存最近一次的 filter 设置

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
    if (difficulty != null && difficulty.toString().isNotEmpty) {
      parts.add('difficulty: $difficulty');
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

            // 收藏食谱区域
            Expanded(
              child: ValueListenableBuilder<List<RecipeMenuModel>>(
                valueListenable: CollectedRecipesStore.favorites,
                builder: (context, favorites, _) {
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

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: favorites.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Collected menus',
                          style: GoogleFonts.caveat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                      }

                      final menu = favorites[index - 1];
                      return _buildCollectedCard(context, menu, theme);
                    },
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
    );
  }

  Widget _buildCollectedCard(
    BuildContext context,
    RecipeMenuModel menu,
    ThemeData theme,
  ) {
    final recipes = menu.recipes;
    if (recipes.isEmpty) return const SizedBox.shrink();

    final primaryRecipe = recipes.first;
    final recipeTitles = recipes.map((r) => r.title).toList();

    String difficultyLabel = menu.difficultySummary;
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeInstructionPage(
              menu: menu,
              initialRecipeIndex: 0,
              filter: _currentFilter,
            ),
          ),
        );
      },
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
                  child: Text(
                    primaryRecipe.emoji,
                    style: const TextStyle(fontSize: 34),
                  ),
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
                      children: [
                        Text(
                          'Menu ${menu.menuId}',
                          style: GoogleFonts.caveat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 16),
                            const SizedBox(width: 4),
                            Text('${recipes.length} dish'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 简短描述
                    Text(
                      primaryRecipe.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.kalam(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 菜名列表
                    if (recipeTitles.length == 1)
                      Text(
                        recipeTitles.first,
                        style: GoogleFonts.kalam(fontSize: 16),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: recipeTitles.map((title) {
                          return Row(
                            children: [
                              const Icon(Icons.circle, size: 6),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.kalam(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 8),

                    // 底部：时间 + 卡路里
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '~ ${menu.totalCookingTimeMin} min',
                          style: GoogleFonts.kalam(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.local_fire_department,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${menu.totalCalories.toStringAsFixed(0)} kcal',
                          style: GoogleFonts.kalam(
                            fontSize: 12,
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
      ),
    );
  }
}
