// lib/pages/recipes/recipes_home_page.dart
import 'dart:math' as math;
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

// ========== CustomPainter: 绘制复古索引卡的红蓝线 ==========
class VintageCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // 红线（标题线）
    linePaint.color = Colors.red.withOpacity(0.4);
    canvas.drawLine(const Offset(0, 48), Offset(size.width, 48), linePaint);
    
    // 蓝线循环（内容线）
    linePaint.color = Colors.blue.withOpacity(0.15);
    double startY = 88.0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(size.width, startY), linePaint);
      startY += 32.0;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ========== CustomClipper: 锯齿边缘（和纸胶带效果 - 更随机）==========
class JaggedEdgeClipper extends CustomClipper<Path> {
  final int seed;
  
  JaggedEdgeClipper({this.seed = 0});
  
  @override
  Path getClip(Size size) {
    final random = math.Random(seed);
    final Path path = Path()..lineTo(0, size.height);
    double x = 0;
    
    // 底部锯齿 - 随机高度
    while (x < size.width) {
      x += 3 + random.nextDouble() * 4; // 3-7像素随机间隔
      final jagHeight = 2 + random.nextDouble() * 3; // 2-5像素随机高度
      path.lineTo(x, size.height - jagHeight);
    }
    path.lineTo(size.width, 0);
    
    // 顶部锯齿 - 随机高度
    while (x > 0) {
      x -= 3 + random.nextDouble() * 4;
      final jagHeight = 2 + random.nextDouble() * 3;
      path.lineTo(x, jagHeight);
    }
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ========== CustomClipper: 卡片边缘撕裂效果 ==========
class TornEdgeClipper extends CustomClipper<Path> {
  final int seed;
  
  TornEdgeClipper({this.seed = 0});
  
  @override
  Path getClip(Size size) {
    final random = math.Random(seed);
    final Path path = Path();
    
    // 左边缘 - 轻微撕裂
    double y = 0;
    path.moveTo(2 + random.nextDouble() * 2, 0);
    while (y < size.height) {
      y += 8 + random.nextDouble() * 8;
      path.lineTo(1 + random.nextDouble() * 3, y);
    }
    
    // 底边
    double x = 0;
    while (x < size.width) {
      x += 8 + random.nextDouble() * 8;
      path.lineTo(x, size.height - 1 - random.nextDouble() * 3);
    }
    
    // 右边缘 - 轻微撕裂
    y = size.height;
    while (y > 0) {
      y -= 8 + random.nextDouble() * 8;
      path.lineTo(size.width - 1 - random.nextDouble() * 3, y);
    }
    
    // 顶边
    x = size.width;
    while (x > 0) {
      x -= 8 + random.nextDouble() * 8;
      path.lineTo(x, 1 + random.nextDouble() * 3);
    }
    
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

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
    // 只在 difficulty 有效且非空时才显示
    if (difficulty != null) {
      if (difficulty is List) {
        if (difficulty.isNotEmpty) {
          parts.add('difficulty: ${difficulty.join("/")}');
        }
      } else if (difficulty.toString().trim().isNotEmpty) {
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
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 8, top: 12),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final recipe = favorites[index];
                            final selected =
                                _selectedFavoriteIds.contains(recipe.id);
                            return _buildCollectedCard(
                              context,
                              recipe,
                              theme,
                              index: index,
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
                                    isViewMode: false, // 批量烹饪模式
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
    {required int index, required bool selected, required VoidCallback onToggleSelect}
  ) {
    // 错落布局逻辑
    final isEven = index % 2 == 0;
    final double rotation = isEven ? -0.025 : 0.03;
    final EdgeInsets margin = EdgeInsets.only(
      top: 16,
      bottom: 16,
      left: isEven ? 12 : 40,
      right: isEven ? 40 : 12,
    );
    
    // 海浪色胶带和位置 - 更接近背景图的海浪颜色
    final tapeColor = const Color(0xFF8CB4D4).withOpacity(0.5); // 柔和的海洋蓝绿色
    final tapeLeft = isEven ? 20.0 : 60.0;
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: margin,
        child: GestureDetector(
          onTap: () {
            // 如果已经选中了某些卡片，点击切换选择状态
            if (_selectedFavoriteIds.isNotEmpty) {
              onToggleSelect();
            } else {
              // 否则弹出菜单
              _showRecipeOptions(context, recipe);
            }
          },
          onLongPress: () {
            // 长按切换选择状态
            onToggleSelect();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 索引卡主体 - 添加撕裂边缘效果
              ClipPath(
                clipper: TornEdgeClipper(seed: index),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    // 更做旧的背景色 - 带纹理
                    color: const Color(0xFFF5F1E8), // 更暗的米黄色
                    border: selected
                        ? Border.all(color: Colors.orange, width: 3)
                        : null,
                    boxShadow: [
                      // 主阴影 - 模拟书桌上的阴影
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(3, 6),
                      ),
                      // 次阴影 - 增加深度
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(1, 2),
                      ),
                      // 选中时的高光效果
                      if (selected)
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: VintageCardPainter(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题（压在红线上）
                          Text(
                            recipe.title,
                            style: GoogleFonts.caveat(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Emoji 和信息
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.emoji,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 时间和卡路里在同一行
                                    Text(
                                      '⏱ ${recipe.cookingTimeMin}min  🔥 ${recipe.totalCaloriesEstimate.toStringAsFixed(0)}kcal',
                                      style: GoogleFonts.caveat(
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // 难度标签
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDifficultyColor(recipe.difficulty).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        recipe.difficulty.toUpperCase(),
                                        style: GoogleFonts.caveat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getDifficultyColor(recipe.difficulty),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 和纸胶带（顶部）- 更短更自然的海浪色胶带
              Positioned(
                top: -5,
                left: tapeLeft,
                child: ClipPath(
                  clipper: JaggedEdgeClipper(seed: index + 100),
                  child: Container(
                    width: 55, // 缩短胶带宽度 (从80改为55)
                    height: 20, // 稍微降低高度 (从25改为20)
                    decoration: BoxDecoration(
                      color: tapeColor,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8CB4D4).withOpacity(0.25),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 选中标记（右上角）
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 显示菜谱选项菜单
  void _showRecipeOptions(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1E8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Text(
              recipe.title,
              style: GoogleFonts.caveat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Start Cooking 按钮 - 烹饪模式
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
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
                        isViewMode: false, // 烹饪模式
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  'Start Cooking',
                  style: GoogleFonts.kalam(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // View Steps 按钮 - 只读模式
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
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
                        isViewMode: true, // 只读模式
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.orange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.menu_book),
                label: Text(
                  'View Steps',
                  style: GoogleFonts.kalam(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
