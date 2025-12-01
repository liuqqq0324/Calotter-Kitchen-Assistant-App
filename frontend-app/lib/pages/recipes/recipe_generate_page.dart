// lib/pages/recipes/recipe_generate_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/mock_recipes.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_instruction_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_filter_page.dart';

class RecipeGeneratePage extends StatefulWidget {
  /// 从 RecipesHomePage 传过来的筛选条件（可为空）
  final Map<String, dynamic>? filter;

  const RecipeGeneratePage({
    super.key,
    this.filter,
  });

  @override
  State<RecipeGeneratePage> createState() => _RecipeGeneratePageState();
}

class _RecipeGeneratePageState extends State<RecipeGeneratePage> {
  late List<RecipeMenuModel> _menus;

  @override
  void initState() {
    super.initState();
    // 用你自己的 mock 菜单
    _menus = List.from(kMockRecipeMenus);
  }

  /// 点击 “Generate Again” 时，目前先简单打乱顺序，模拟重新生成
  void _regenerateMenus() {
    setState(() {
      _menus.shuffle(Random());
    });
  }

  /// 右上角 Filter 图标，先简单跳到过滤页面
  void _openFilter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecipeFilterPage(),
      ),
    );
  }

  /// 把传入的 filter 转成一行 summary 文本，显示在页面顶部
  String? get filterSummary {
    final filter = widget.filter;
    if (filter == null) return null;

    final servings = filter['servings'];
    final dishCount = filter['dish_count'];
    final calorieTarget = filter['calorie_target'];
    final maxTime = filter['max_cooking_time_min'];
    final difficulty = filter['difficulty_target'];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryText = filterSummary; // 顶部那条 summary 用

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Menus'),
        actions: [
          IconButton(
            onPressed: _openFilter,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // 如果有筛选条件，就在最上面显示一条橘色小条
          if (summaryText != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.deepOrange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 中间是列表，复用你原来的 ListView.builder
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final menu = _menus[index];
                return _buildMenuCard(context, menu, theme);
              },
            ),
          ),
        ],
      ),

      // 底部 “Generate Again” 按钮不变
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _regenerateMenus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Generate Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 单个菜单卡片 UI——保持你原来的实现
  Widget _buildMenuCard(
    BuildContext context,
    RecipeMenuModel menu,
    ThemeData theme,
  ) {
    final recipes = menu.recipes;
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
        // 点击整套菜单 -> 先打开第一道菜的 Instruction 页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeInstructionPage(
              menu: menu,
              initialRecipeIndex: 0,
              filter: widget.filter,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
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
                          style: theme.textTheme.titleMedium?.copyWith(
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
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 简短描述
                    Text(
                      primaryRecipe.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 菜名列表
                    if (recipeTitles.length == 1)
                      Text(
                        recipeTitles.first,
                        style: theme.textTheme.bodyMedium,
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
                                  style: theme.textTheme.bodyMedium,
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
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.local_fire_department,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${menu.totalCalories.toStringAsFixed(0)} kcal',
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
        ),
      ),
    );
  }
}
