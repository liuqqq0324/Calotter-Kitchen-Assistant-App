// lib/pages/recipes/recipes_home_page.dart
import 'dart:math' as math;
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

// ========== CustomPainter: 绘制格子纸效果 ==========
class _GridPaperPainter extends CustomPainter {
  final int seed;

  _GridPaperPainter({this.seed = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // 检查 size 是否有效
    if (size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      return;
    }

    final random = math.Random(seed); // 使用传入的种子，确保每个卡片一致

    // 创建不规则边缘路径
    final path = _createIrregularPath(size, random);

    // 1. 先绘制阴影效果（让网格纸看起来悬浮）
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(6, 6));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. 绘制背景
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF8F8F5) // 网格纸背景色
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, backgroundPaint);

    // 3. 绘制网格线（只在背景区域内）
    final gridPaint = Paint()
      ..color = const Color(0xFFE3E6E8) // 网格线颜色（浅蓝灰色）
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSpacing = 20.0;

    // 使用 clipPath 限制网格线只在纸张区域内
    canvas.save();
    canvas.clipPath(path);

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.restore();

    // 4. 绘制不规则边缘线（手绘风格，略有毛边）
    final edgePaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, edgePaint);
  }

  Path _createIrregularPath(Size size, math.Random random) {
    final path = Path();
    const double edgeNoise = 2.5; // 边缘不规则程度
    const double step = 8.0; // 路径点的间距

    // 确保路径在有效范围内
    final double effectiveWidth = size.width > 0 ? size.width : 100.0;
    final double effectiveHeight = size.height > 0 ? size.height : 100.0;

    // 顶部边缘：从左到右，带不规则偏移（限制在有效范围内）
    path.moveTo(0, 0);
    for (double x = step; x < effectiveWidth; x += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = noise.clamp(-edgeNoise, edgeNoise).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, 0);

    // 右侧边缘：从上到下
    for (double y = step; y < effectiveHeight; y += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = (effectiveWidth + noise.clamp(-edgeNoise, edgeNoise)).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, effectiveHeight);

    // 底部边缘：从右到左
    for (double x = effectiveWidth - step; x > 0; x -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = (effectiveHeight + noise.clamp(-edgeNoise, edgeNoise)).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(0, effectiveHeight);

    // 左侧边缘：从下到上
    for (double y = effectiveHeight - step; y > 0; y -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = noise.clamp(-edgeNoise, edgeNoise).toDouble();
      path.lineTo(x, y);
    }

    path.close();
    return path;
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
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: const RecipeFilterPage(isBottomSheet: true),
          ),
        );
      },
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
                  _AnimatedFilterButton(onTap: _openFilterPage),
                ],
              ),

              const SizedBox(height: 8),

              // 如果有 filter，总结一下当前条件 - 手绘风格（与 generated recipes 一致）
              if (summaryText != null) ...[
                SketchyCard(
                  backgroundColor: const Color(0xFFD68C5E).withOpacity(0.12), // 与 generated recipes 一致
                  borderColor: const Color(0xFF8C5E4A), // 与 generated recipes 一致
                  borderWidth: 2.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        size: 18,
                        color: Color(0xFF8C5E4A), // 与 generated recipes 一致
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summaryText,
                          style: GoogleFonts.kalam(
                            fontSize: 14,
                            color: const Color(0xFF8C5E4A), // 与 generated recipes 一致
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
                          style: GoogleFonts.kalam(
                            fontSize: 12,
                            color: const Color(0xFF8C5E4A), // 与 generated recipes 一致
                          ),
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
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 40, top: 12),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final recipe = favorites[index];
                              final selected = _selectedFavoriteIds.contains(
                                recipe.id,
                              );
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
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const accent = Color(0xFFD68C5E); // Terracotta
                              const shadow = Color(0x1F8C5E4A); // Rust Brown @ 12%
                              return Center(
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.90,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final selectedRecipes = favorites
                                          .where(
                                            (r) => _selectedFavoriteIds
                                                .contains(r.id),
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
                                            isViewMode: false, // 批量烹饪模式
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: shadow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text(
                                      'Start cooking (${_selectedFavoriteIds.length} selected)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // 生成食谱按钮 - 向上移动覆盖部分区域，增加融合感
              Transform.translate(
                offset: const Offset(0, 0),
                child: SizedBox(
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
    ThemeData theme, {
    required int index,
    required bool selected,
    required VoidCallback onToggleSelect,
  }) {
    const selectionAccent = Color(0xFFD68C5E); // Terracotta (#D68C5E)
    const selectedCardShadow = Color(0xCCFFFFFF); // White shadow/glow for floating effect
    const selectedAccentShadow =
        Color(0x1F8C5E4A); // Rust Brown (#8C5E4A) @ 12% opacity

    // 错落布局逻辑
    final isEven = index % 2 == 0;
    final double rotation = isEven ? -0.025 : 0.03;
    final EdgeInsets margin = EdgeInsets.only(
      top: 16,
      bottom: 16,
      left: isEven ? 12 : 40,
      right: isEven ? 40 : 12,
    );

    // 淡米色胶带和位置
    final tapeColor = const Color(0xFFEBE3CA).withOpacity(0.7); // 淡米色，70%透明度
    final tapeLeft = isEven ? 140.0 : 160.0; // 更靠近中间位置

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
              // 格子纸卡片主体
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                transformAlignment: Alignment.center,
                transform: Matrix4.translationValues(0, selected ? -3 : 0, 0),
                child: Container(
                  height: 135,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? selectedCardShadow
                            : Colors.black.withOpacity(0.30),
                        blurRadius: selected ? 18 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _GridPaperPainter(seed: index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.caveat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ).copyWith(height: 1.1),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 难度、时间和卡路里在同一行
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  // 难度标签（手绘风格）
                                  _buildSketchyDifficultyBadge(
                                    label: recipe.difficulty.toUpperCase(),
                                    color: _getDifficultyColor(recipe.difficulty),
                                  ),
                                const SizedBox(width: 12),
                                // 时间和卡路里
                                Expanded(
                                  child: Text(
                                    '⏱ ${recipe.cookingTimeMin}min  🔥 ${recipe.totalCaloriesEstimate.toStringAsFixed(0)}kcal',
                                    style: GoogleFonts.caveat(
                                      fontSize: 17,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 和纸胶带（顶部）- 更短更自然的海浪色胶带
              Positioned(
                top: -7,
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
                          color: const Color(0xFFEBE3CA).withOpacity(0.3),
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selectionAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFDFCF5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedAccentShadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
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
                  backgroundColor: const Color(0xFFD68C5E), // Terracotta
                  foregroundColor: Colors.white,
                  shadowColor: const Color(0x1F8C5E4A), // Rust Brown @ 12%
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
                        isViewMode: true, // 只读模式
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD68C5E), // Terracotta
                  foregroundColor: Colors.white,
                  shadowColor: const Color(0x1F8C5E4A), // Rust Brown @ 12%
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

  // 构建手绘风格难度标签
  Widget _buildSketchyDifficultyBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: CustomPaint(
        painter: _SketchyBadgePainter(
          borderColor: color,
          backgroundColor: color.withOpacity(0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            label,
            style: GoogleFonts.caveat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// 手绘风格标签绘制器
class _SketchyBadgePainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  _SketchyBadgePainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final path = _createSketchyPath(size, random);

    // 绘制背景
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // 绘制边框
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, borderPaint);
  }

  Path _createSketchyPath(Size size, math.Random random) {
    final path = Path();
    const double wobble = 1.5;
    const double step = 6.0;

    // Top edge
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, noise.clamp(-wobble, wobble));
    }
    path.lineTo(size.width, 0);

    // Right edge
    for (double y = step; y < size.height; y += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(size.width + noise.clamp(-wobble, wobble), y);
    }
    path.lineTo(size.width, size.height);

    // Bottom edge
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, size.height + noise.clamp(-wobble, wobble));
    }
    path.lineTo(0, size.height);

    // Left edge
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(noise.clamp(-wobble, wobble), y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 带动画效果的Filter按钮
class _AnimatedFilterButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedFilterButton({required this.onTap});

  @override
  State<_AnimatedFilterButton> createState() => _AnimatedFilterButtonState();
}

class _AnimatedFilterButtonState extends State<_AnimatedFilterButton> {
  bool _isPressed = false;
  static const double _pressedTiltAngle = -0.09;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(_isPressed ? _pressedTiltAngle : 0.0),
        child: SizedBox(
          height: 34,
          child: Image.asset(
            'assets/images/filter_button.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
