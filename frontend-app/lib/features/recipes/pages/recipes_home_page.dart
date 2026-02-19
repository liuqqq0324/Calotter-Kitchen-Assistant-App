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
  bool _isEditMode = false; // 编辑/删除模式
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // 搜索关键词
  final Set<String> _selectedCategories = {}; // 选中的分类（支持多选）

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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

    return Stack(
      children: [
        // Bottom layer: static wood + waves background that fills the screen
        const Positioned.fill(
          child: Image(
            image: AssetImage('assets/wood_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Top layer: page content on transparent background
        SafeArea(
          // This page is already positioned under the custom header in MainScaffold.
          top: false,
          child: Padding(
            // Top spacing between header and content; bottom padding交给列表本身.
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标题 + Select/取消按钮 + Filter按钮 - 手绘风格
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：标题 + 小勾圈圈/取消按钮
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 标题
                        Text(
                          (_isEditMode || _selectedFavoriteIds.isNotEmpty)
                              ? '${_selectedFavoriteIds.length} Selected'
                              : 'My Recipes',
                          style: GoogleFonts.caveat(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 取消按钮（选择模式下）或 Select 图标
                        if (_isEditMode || _selectedFavoriteIds.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditMode = false;
                                _selectedFavoriteIds.clear();
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.kalam(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B4F4F),
                              ).copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditMode = true;
                              });
                            },
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 26,
                              color: const Color(0xFF6B4F4F).withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Filter按钮（厨师帽）
                  _AnimatedFilterButton(onTap: _openFilterPage),
                ],
              ),

              const SizedBox(height: 12),

                // 搜索栏 - 纸胶带样式
                _WashiTapeSearchBar(
                controller: _searchController,
              ),

              const SizedBox(height: 16),

                // 分类筛选栏
                _CategoryFilterBar(
                selectedCategories: _selectedCategories,
                onCategorySelected: (category) {
                  setState(() {
                    // 如果已选中，则取消选择；否则添加到选中列表
                    if (_selectedCategories.contains(category)) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
              ),

              const SizedBox(height: 6),

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

                    // 根据搜索关键词和分类过滤食谱
                    var filteredFavorites = favorites;
                    
                    // 先按分类过滤（支持多选）
                    if (_selectedCategories.isNotEmpty) {
                      filteredFavorites = filteredFavorites.where((recipe) {
                        return _selectedCategories.contains(recipe.category);
                      }).toList();
                    }
                    
                    // 再按搜索词过滤
                    if (_searchQuery.isNotEmpty) {
                      filteredFavorites = filteredFavorites.where((recipe) {
                        final title = recipe.title.toLowerCase();
                        final ingredients = recipe.ingredients
                            .map((i) => i.name.toLowerCase())
                            .join(' ');
                        return title.contains(_searchQuery) ||
                            ingredients.contains(_searchQuery);
                      }).toList();
                    }

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

                    // 如果搜索后没有结果
                    if (filteredFavorites.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No recipes found for "$_searchQuery"',
                              style: GoogleFonts.kalam(
                                fontSize: 16,
                                color: Colors.grey.shade600,
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
                            // Extra bottom padding so the last card can scroll above the action bar.
                            padding: const EdgeInsets.only(bottom: 100, top: 6),
                            itemCount: filteredFavorites.length,
                            itemBuilder: (context, index) {
                              final recipe = filteredFavorites[index];
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
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      // Contextual Action Bar: selection bar or Generate Recipes (AnimatedSwitcher)
      Positioned(
        left: 20,
        right: 20,
        bottom: 16,
        child: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedFavoriteIds.isNotEmpty
                ? KeyedSubtree(
                    key: const ValueKey<String>('selection_bar'),
                    child: _buildSelectionActionBar(context),
                  )
                : GenerateRecipeButton(
                    key: const ValueKey<String>('generate'),
                    isFullWidth: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeGeneratePage(filter: _currentFilter),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSelectionActionBar(BuildContext context) {
    const cream = Color(0xFFFFFFF0);
    const ink = Color(0xFF6B4F4F);
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          // Delete - 与 Generated Menus 同款：米白底、手绘棕边，图标红色区分
          SizedBox(
            width: 70,
            height: 70,
            child: _SketchyButtonWithAnimation(
              backgroundColor: cream,
              withShadow: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              onPressed: () async {
                final confirmed = await _showDeleteConfirmation(
                  context,
                  _selectedFavoriteIds.length,
                );
                if (!confirmed) return;
                final favorites = CollectedRecipesStore.favorites.value;
                final selectedRecipes = favorites
                    .where((r) => _selectedFavoriteIds.contains(r.id))
                    .toList();
                if (selectedRecipes.isEmpty) return;
                final householdId = await HouseholdService.getHouseholdId();
                if (householdId == null) return;
                for (final recipe in selectedRecipes) {
                  try {
                    await CollectedRecipesStore.remove(
                      recipe,
                      householdId: householdId,
                    );
                  } catch (e) {
                    debugPrint('Failed to remove recipe: $e');
                  }
                }
                setState(() {
                  _selectedFavoriteIds.clear();
                  _isEditMode = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${selectedRecipes.length} recipe(s) deleted',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFB91C1C),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Start Cooking - 与 Generated Menus 同款：米白底、棕边、Kalam 棕字
          Expanded(
            child: SizedBox(
              height: 70,
              child: _SketchyButtonWithAnimation(
                backgroundColor: cream,
                withShadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onPressed: () {
                  final favorites = CollectedRecipesStore.favorites.value;
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
                        isViewMode: false,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 22,
                      color: ink.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Cook Mode (${_selectedFavoriteIds.length})',
                        style: GoogleFonts.kalam(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

    return Dismissible(
      key: Key(recipe.id),
      direction: DismissDirection.endToStart, // 只允许从右向左滑动
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        // 显示确认对话框
        return await _showDeleteConfirmation(context, 1);
      },
      onDismissed: (direction) async {
        // 删除单个菜谱
        final householdId = await HouseholdService.getHouseholdId();
        if (householdId != null) {
          try {
            await CollectedRecipesStore.remove(
              recipe,
              householdId: householdId,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${recipe.title} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('Failed to remove recipe: $e');
          }
        }
      },
      child: Transform.rotate(
      angle: rotation,
      child: Container(
        margin: margin,
        child: GestureDetector(
          onTap: () {
            // 如果在编辑模式或已经选中了某些卡片，点击切换选择状态
            if (_isEditMode || _selectedFavoriteIds.isNotEmpty) {
              onToggleSelect();
            } else {
              // 否则弹出菜单
              _showRecipeOptions(context, recipe);
            }
          },
          onLongPress: () {
            // 长按进入编辑模式并选择
            if (!_isEditMode) {
              setState(() {
                _isEditMode = true;
              });
            }
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
                transform: Matrix4.translationValues(0, selected ? -5 : 0, 0),
                child: Container(
                  height: 135,
                  decoration: BoxDecoration(
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null, // 非选中状态没有阴影
                  ),
                  child: CustomPaint(
                    painter: _GridPaperPainter(seed: index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        children: [
                          // 左侧：分类图标
                          if (recipe.category != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  recipe.categoryImagePath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // 如果图片加载失败，显示默认图标
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 32,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          // 右侧：文字信息
                          Expanded(
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
              // 选中标记（右上角）- 在选择模式下始终显示
              if (_isEditMode || _selectedFavoriteIds.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? selectionAccent : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? const Color(0xFFFDFCF5) : const Color(0xFF6B4F4F).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selected 
                              ? selectedAccentShadow 
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : null, // 未选中时显示空心圆
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // 显示删除确认对话框
  Future<bool> _showDeleteConfirmation(BuildContext context, int count) async {
    const terracotta = Color(0xFFD68C5E); // Terracotta
    const rustBrown = Color(0xFF8C5E4A); // Rust Brown
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F1E8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Recipes?',
          style: GoogleFonts.caveat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to delete $count recipe${count > 1 ? 's' : ''}? This action cannot be undone.',
          style: GoogleFonts.kalam(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(
                fontSize: 16,
                color: rustBrown,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: terracotta,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: rustBrown.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.kalam(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
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
                  'Cook Mode',
                  style: GoogleFonts.kalam(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // View Mode 按钮 - 只读模式
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
                  'View Mode',
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

// 手绘风格删除按钮
class _SketchyDeleteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _SketchyDeleteButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_SketchyDeleteButton> createState() => _SketchyDeleteButtonState();
}

class _SketchyDeleteButtonState extends State<_SketchyDeleteButton> {
  bool _isPressed = false;

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
    const terracotta = Color(0xFFD68C5E);
    const rustBrown = Color(0xFF8C5E4A);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(_isPressed ? -0.02 : 0.0)
          ..scale(_isPressed ? 0.98 : 1.0),
        height: 60,
        decoration: BoxDecoration(
          boxShadow: !_isPressed ? [
            BoxShadow(
              color: rustBrown.withOpacity(0.15),
              offset: const Offset(2, 3),
              blurRadius: 4,
            )
          ] : null,
        ),
        child: CustomPaint(
          painter: _SketchyButtonBorderPainter(
            borderColor: terracotta,
            backgroundColor: const Color(0xFFFFFFF0), // Paper White
            borderWidth: _isPressed ? 2.0 : 1.5,
            wobbleAmount: 1.5,
            seed: 999,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 22,
                  color: terracotta,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.kalam(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: terracotta,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 手绘按钮边框绘制器
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color? backgroundColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.backgroundColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);
    
    // 1. 先画背景（如果有）
    if (backgroundColor != null) {
      final fillPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // 2. 再画边框
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, borderPaint);
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

// 带动画效果的Delete按钮
class _AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isEditMode;

  const _AnimatedDeleteButton({
    required this.onTap,
    required this.isEditMode,
  });

  @override
  State<_AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<_AnimatedDeleteButton> {
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
    const terracotta = Color(0xFFD68C5E); // Terracotta
    const rustBrown = Color(0xFF8C5E4A); // Rust Brown
    
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
          ..rotateZ(_isPressed ? _pressedTiltAngle : 0.0)
          ..scale(_isPressed ? 0.95 : 1.0),
        child: Icon(
          widget.isEditMode ? Icons.close : Icons.delete_outline,
          size: 26,
          color: widget.isEditMode ? terracotta : rustBrown.withOpacity(0.7),
        ),
      ),
    );
  }
}

// 分类数据
class _CategoryData {
  final String name;
  final String displayName;
  final String sketchIcon;
  final String colorIcon;

  const _CategoryData({
    required this.name,
    required this.displayName,
    required this.sketchIcon,
    required this.colorIcon,
  });
}

// 所有分类
const List<_CategoryData> _allCategories = [
  _CategoryData(
    name: 'STIR_FRY_PAN_FRY',
    displayName: 'Stir Fry',
    sketchIcon: 'assets/dish_category/SKETCH_STIR_FRY_PAN_FRY.png',
    colorIcon: 'assets/dish_category/STIR_FRY_PAN_FRY.png',
  ),
  _CategoryData(
    name: 'STEAM_BOIL',
    displayName: 'Steam',
    sketchIcon: 'assets/dish_category/SKETCH_STEAM_BOIL.png',
    colorIcon: 'assets/dish_category/STEAM_BOIL.png',
  ),
  _CategoryData(
    name: 'BRAISE_STEW',
    displayName: 'Braise',
    sketchIcon: 'assets/dish_category/SKETCH_BRAISE_STEW.png',
    colorIcon: 'assets/dish_category/BRAISE_STEW.png',
  ),
  _CategoryData(
    name: 'COLD_SALAD',
    displayName: 'Salad',
    sketchIcon: 'assets/dish_category/SKETCH_COLD_SALAD.png',
    colorIcon: 'assets/dish_category/COLD_SALAD.png',
  ),
  _CategoryData(
    name: 'SOUP',
    displayName: 'Soup',
    sketchIcon: 'assets/dish_category/SKETCH_SOUP.png',
    colorIcon: 'assets/dish_category/SOUP.png',
  ),
  _CategoryData(
    name: 'ROAST_BAKE',
    displayName: 'Roast',
    sketchIcon: 'assets/dish_category/SKETCH_ROAST_BAKE.png',
    colorIcon: 'assets/dish_category/ROAST_BAKE.png',
  ),
];

// 分类筛选栏
class _CategoryFilterBar extends StatelessWidget {
  final Set<String> selectedCategories;
  final ValueChanged<String> onCategorySelected;

  const _CategoryFilterBar({
    required this.selectedCategories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          final isSelected = selectedCategories.contains(category.name);
          
          return _CategoryIconButton(
            category: category,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category.name),
          );
        },
      ),
    );
  }
}

// 分类图标按钮
class _CategoryIconButton extends StatelessWidget {
  final _CategoryData category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryIconButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标容器
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 56,
              height: 56,
              child: Image.asset(
                isSelected ? category.colorIcon : category.sketchIcon,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 2),
            // 分类名称
            Text(
              category.displayName,
              style: GoogleFonts.kalam(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? const Color(0xFF8C5E4A) 
                    : Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 纸胶带样式的搜索栏
class _WashiTapeSearchBar extends StatefulWidget {
  final TextEditingController controller;

  const _WashiTapeSearchBar({required this.controller});

  @override
  State<_WashiTapeSearchBar> createState() => _WashiTapeSearchBarState();
}

class _WashiTapeSearchBarState extends State<_WashiTapeSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); // 更新清除按钮显示
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: CustomPaint(
        painter: _WashiTapePainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 放大镜图标
              const Icon(
                Icons.search,
                size: 24,
                color: Color(0xFF8C5E4A), // Rust Brown 主题色
              ),
              const SizedBox(width: 12),
              // 搜索输入框
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search chicken, beef...',
                    hintStyle: GoogleFonts.kalam(
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              // 清除按钮
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () => widget.controller.clear(),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 纸胶带背景绘制器（撕裂边缘效果）
class _WashiTapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    // 创建撕裂边缘路径
    final path = _createTornEdgePath(size, random);
    
    // 绘制阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(2, 3));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // 绘制纸胶带背景（米黄色）
    final bgPaint = Paint()
      ..color = const Color(0xFFFFF8E7) // 米黄色
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);
    
    // 添加纸张纹理
    canvas.save();
    canvas.clipPath(path);
    _drawPaperTexture(canvas, size, random);
    canvas.restore();
    
    // 绘制边缘线
    final edgePaint = Paint()
      ..color = const Color(0xFFE8D5B7).withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, edgePaint);
  }
  
  Path _createTornEdgePath(Size size, math.Random random) {
    final path = Path();
    const double tearSize = 2.0; // 撕裂效果大小
    const double step = 5.0;
    
    // 顶部边缘 - 撕裂效果
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(x, noise.clamp(-tearSize, tearSize));
    }
    path.lineTo(size.width, 0);
    
    // 右侧边缘 - 撕裂效果
    for (double y = step; y < size.height; y += step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(size.width + noise.clamp(-tearSize, tearSize), y);
    }
    path.lineTo(size.width, size.height);
    
    // 底部边缘 - 撕裂效果
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(x, size.height + noise.clamp(-tearSize, tearSize));
    }
    path.lineTo(0, size.height);
    
    // 左侧边缘 - 撕裂效果
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(noise.clamp(-tearSize, tearSize), y);
    }
    
    path.close();
    return path;
  }
  
  void _drawPaperTexture(Canvas canvas, Size size, math.Random random) {
    final texturePaint = Paint()
      ..color = const Color(0xFFF5E6D3).withOpacity(0.3)
      ..strokeWidth = 0.5;
    
    // 随机绘制一些细线来模拟纸张纹理
    for (int i = 0; i < 30; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = x1 + (random.nextDouble() * 20 - 10);
      final y2 = y1 + (random.nextDouble() * 20 - 10);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), texturePaint);
    }
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
    const ink = Color(0xFF6B4F4F);
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
          ..scale(_isPressed ? 1.1 : 1.0)
          ..rotateZ(_isPressed ? _pressedTiltAngle : 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 42,
              width: 42,
              child: Image.asset(
                'assets/dish_category/CHEF_HAT.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'Prefs',
              style: GoogleFonts.kalam(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ink.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带点击加深动画的手绘按钮
class _SketchyButtonWithAnimation extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor; // null = default brown (0xFF6B4F4F)
  final bool withShadow;

  const _SketchyButtonWithAnimation({
    required this.onPressed,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.withShadow = false,
  });

  @override
  State<_SketchyButtonWithAnimation> createState() =>
      _SketchyButtonWithAnimationState();
}

class _SketchyButtonWithAnimationState
    extends State<_SketchyButtonWithAnimation> {
  bool _isPressed = false;

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
    final baseColor = widget.borderColor ?? const Color(0xFF6B4F4F);
    final borderColor = baseColor.withOpacity(_isPressed ? 1.0 : 0.7);

    final effectivePadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_isPressed ? -0.05 : 0.0)
            ..scale(_isPressed ? 0.98 : 1.0),
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: (widget.withShadow && !_isPressed)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(1, 2),
                      blurRadius: 2,
                    )
                  ]
                : null,
          ),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              backgroundColor: widget.backgroundColor,
              borderWidth: _isPressed ? 2.0 : 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
