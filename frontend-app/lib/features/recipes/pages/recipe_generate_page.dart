// lib/pages/recipes/recipe_generate_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_filter_page.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipe_instruction_page.dart';
import 'package:personal_sous_chef/services/api/recipe_api_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_widgets.dart';

class RecipeGeneratePage extends StatefulWidget {
  /// 从 RecipesHomePage 传过来的筛选条件（可为空）
  final Map<String, dynamic>? filter;

  const RecipeGeneratePage({super.key, this.filter});

  @override
  State<RecipeGeneratePage> createState() => _RecipeGeneratePageState();
}

class _RecipeGeneratePageState extends State<RecipeGeneratePage> {
  List<RecipeMenuModel> _menus = [];
  bool _loading = false;
  String? _error;
  int? _selectedMenuId;
  Map<String, dynamic>? _currentFilter; // 保存当前的 filter 设置

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _startMenuStream();
  }

  Future<void> _startMenuStream() async {
    setState(() {
      _menus = [];
      _loading = true;
      _error = null;
      _selectedMenuId = null;
    });

    try {
      final stream = RecipeApiService.generateMenusStream(
        _currentFilter,
        householdId: await HouseholdService.getHouseholdId(),
      );
      await for (final menu in stream) {
        if (!mounted) return;
        setState(() => _menus.add(menu));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 右上角 Filter 图标，使用弹窗方式打开过滤页面
  Future<void> _openFilter() async {
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

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });

      _startMenuStream();

      // 小提示：让你知道已经保存了
      if (mounted) {
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
  }

  /// 把传入的 filter 转成一行 summary 文本，显示在页面顶部
  String? get filterSummary {
    final filter = _currentFilter; // 使用 state 中的 filter
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryText = filterSummary; // 顶部那条 summary 用
    const terracotta = Color(0xFFD68C5E);
    const terracottaDeep = Color(0xFF8C5E4A);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Generated Menus',
            style: GoogleFonts.caveat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: terracottaDeep,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            _AnimatedFilterButton(onTap: _openFilter),
          ],
        ),
        body: _GridPaper(
          child: Column(
            children: [
              // 如果有筛选条件，就在最上面显示一条橘色小条
              if (summaryText != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SketchyCard(
                backgroundColor: terracotta.withOpacity(0.12),
                borderColor: terracottaDeep,
                borderWidth: 2.0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 18, color: terracottaDeep),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summaryText,
                        style: GoogleFonts.kalam(
                          fontSize: 14,
                          color: terracottaDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

              Expanded(
                child: _menus.isEmpty && _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _menus.isEmpty && !_loading && _error != null
                    ? _buildErrorState(theme)
                    : _menus.isEmpty && !_loading
                    ? _buildEmptyState(theme)
                    : _buildMenuList(),
              ),
            ],
          ),
        ),

        // 底部操作：Start cooking（选中的 menu）+ Generate again
        bottomNavigationBar: SafeArea(
          child: Container(
            // 【修改点】删掉了 decoration (那个渐变背景)，只留 padding
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // 1. Start Cooking 按钮
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: _SketchyButtonWithAnimation(
                      // 关键：保留这个背景色，让按钮是实心的，否则透出海浪会看不清
                      backgroundColor: const Color(0xFFFFFFF0),
                      withShadow: true, // 保留阴影，增加立体感
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onPressed: _selectedMenuId == null
                          ? null
                          : () {
                              final menu = _menus.firstWhere(
                                (m) => m.menuId == _selectedMenuId,
                              );
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 22,
                            color: _selectedMenuId == null
                                ? const Color(0xFF6B4F4F).withOpacity(0.3)
                                : const Color(0xFF6B4F4F),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Start cooking',
                              style: GoogleFonts.kalam(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _selectedMenuId == null
                                    ? const Color(0xFF6B4F4F).withOpacity(0.3)
                                    : const Color(0xFF6B4F4F),
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
                const SizedBox(width: 16),
                
                // 2. Generate Again 按钮
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: _SketchyButtonWithAnimation(
                      // 关键：保留背景色
                      backgroundColor: const Color(0xFFFFFFF0),
                      withShadow: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onPressed: _loading ? null : _startMenuStream,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 22,
                            color: const Color(0xFF6B4F4F).withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Generate Again',
                              style: GoogleFonts.kalam(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B4F4F).withOpacity(0.8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: _menus.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _menus.length) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _buildMenuCard(context, _menus[index]);
      },
    );
  }

  /// 单个菜单卡片 UI，使用 Today's Intake 样式
  Widget _buildMenuCard(
    BuildContext context,
    RecipeMenuModel menu,
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

    final isSelected = _selectedMenuId == menu.menuId;
    const ink = Color(0xFF6B4F4F); // River Deep Brown

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenuId = _selectedMenuId == menu.menuId ? null : menu.menuId;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1. 卡片主体 - 使用锯齿状边框
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 16), // 为胶带留出空间
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFFFF0), // Paper White / 米黄色便签
              shape: SketchyRectBorder(
                borderWidth: isSelected ? 2.5 : 2.0,
                wobbleAmount: 2.5,
                seed: menu.menuId, // 使用 menuId 作为种子，确保每个卡片一致
                color: isSelected
                    ? const Color(0xFF6B4F4F)
                    : const Color(0xFF6B4F4F).withOpacity(0.7),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 内容行：左侧餐盘 + 右侧信息
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧：放大的餐盘图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4F4F).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6B4F4F).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          primaryRecipe.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 右侧：三行信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 第一行：Menu 1 + 选中标记
                          Row(
                            children: [
                              Text(
                                'Menu ${menu.menuId}',
                                style: GoogleFonts.kalam(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSelected) _buildSketchySelectedBadge(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 第二行：菜品名
                          Text(
                            recipeTitles.length == 1
                                ? recipeTitles.first
                                : recipeTitles.join(', '),
                            style: GoogleFonts.kalam(
                              fontSize: 18,
                              color: ink,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // 第三行：难度、时间和卡路里
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSketchyDifficultyBadge(
                                label: difficultyLabel.toUpperCase(),
                                color: difficultyColor,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: ink.withOpacity(0.65),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '~ ${menu.totalCookingTimeMin} min',
                                  style: GoogleFonts.kalam(
                                    fontSize: 15,
                                    color: ink.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: ink.withOpacity(0.65),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${menu.totalCalories.toStringAsFixed(0)} kcal',
                                  style: GoogleFonts.kalam(
                                    fontSize: 15,
                                    color: ink.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 按钮行
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: _buildSketchyButton(
                          onPressed: () {
                            setState(() {
                              _selectedMenuId = _selectedMenuId == menu.menuId
                                  ? null
                                  : menu.menuId;
                            });
                          },
                          child: Text(
                            isSelected ? 'Selected' : 'Choose',
                            style: GoogleFonts.kalam(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B4F4F).withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: _buildSketchyButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeInstructionPage(
                                  menu: menu,
                                  initialRecipeIndex: 0,
                                  filter: widget.filter,
                                  isViewMode: true,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 20,
                                color: const Color(0xFF6B4F4F).withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'View',
                                style: GoogleFonts.kalam(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6B4F4F).withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 2. 胶带效果
          Positioned(
            top: 4,
            child: Transform.rotate(
              angle: -0.05, // 轻微旋转，更自然
              child: Container(
                width: 85,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8DC).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: CustomPaint(painter: _TapeTexturePainter()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建手绘边框按钮（带点击加深动画）
  Widget _buildSketchyButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return _SketchyButtonWithAnimation(
      onPressed: onPressed,
      // 关键点：减少 padding 以适应 height: 60 的容器
      // 垂直 8px * 2 = 16px，剩下 44px 给内容，足够放图标和文字了
      // 水平 12px 避免过宽
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    );
  }

  // 构建手绘风格难度标签
  Widget _buildSketchyDifficultyBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: CustomPaint(
        painter: _SketchyBadgePainter(
          borderColor: color,
          backgroundColor: color.withOpacity(0.12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            label,
            style: GoogleFonts.kalam(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // 构建手绘风格选中标记
  Widget _buildSketchySelectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: CustomPaint(
        painter: _SketchyBadgePainter(
          borderColor: const Color(0xFF6B4F4F),
          backgroundColor: const Color(0xFF6B4F4F).withOpacity(0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: const Color(0xFF6B4F4F),
              ),
              const SizedBox(width: 4),
              Text(
                "Selected",
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B4F4F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'No menus yet. Try generating again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    // 解析错误信息，提取关键信息
    String errorMessage = _error ?? 'Unknown error';
    String displayMessage = errorMessage;
    bool isQuotaError =
        errorMessage.contains('429') ||
        errorMessage.contains('quota') ||
        errorMessage.contains('配额') ||
        errorMessage.contains('Quota exceeded');

    if (isQuotaError) {
      displayMessage =
          'API quota exceeded\n\nPlease try again later or check your API quota limits.';
    } else if (errorMessage.length > 200) {
      // 如果错误信息太长，截取前200个字符
      displayMessage = errorMessage.substring(0, 200) + '...';
    }

    return Center(
      child: SingleChildScrollView(
        // 添加滚动支持
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isQuotaError ? Icons.hourglass_empty : Icons.error_outline,
                size: 48,
                color: isQuotaError ? Colors.orange : Colors.redAccent,
              ),
              const SizedBox(height: 8),
              Text(
                isQuotaError ? 'API quota exceeded' : 'Failed to load recipes.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                displayMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 10, // 限制最大行数
                overflow: TextOverflow.ellipsis, // 超出部分显示省略号
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _startMenuStream,
                child: const Text('Retry'),
              ),
              if (isQuotaError) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // 可以添加跳转到设置页面或显示更多信息的逻辑
                  },
                  child: const Text('View quota info'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for sketchy button border
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color? backgroundColor; // 新增：背景色
  final double borderWidth;
  final double wobbleAmount;
  final int seed;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.backgroundColor, // 新增
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

/// 带点击加深动画的手绘按钮
class _SketchyButtonWithAnimation extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding; // 新增参数
  final Color? backgroundColor; // 新增：背景色
  final bool withShadow; // 新增：是否开启阴影

  const _SketchyButtonWithAnimation({
    required this.onPressed,
    required this.child,
    this.padding, // 接收参数
    this.backgroundColor, // 新增
    this.withShadow = false, // 新增
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
    final borderColor = const Color(0xFF6B4F4F).withOpacity(
      _isPressed ? 1.0 : 0.7,
    );
    
    // 计算 Padding：如果有传入则用传入的，否则用默认较小的值
    // 默认值：vertical 12, horizontal 20
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
            ..scale(_isPressed ? 0.98 : 1.0), // 点击稍微缩小一点点
          padding: effectivePadding, // 使用计算后的 Padding
          decoration: BoxDecoration(
            // 移除这里的 color，因为我们用 Painter 画背景
            borderRadius: BorderRadius.circular(4),
            // 只有当开启阴影且未按下时显示阴影（模拟按压感）
            boxShadow: (widget.withShadow && !_isPressed) ? [
              BoxShadow(
                color: const Color(0xFF6B4F4F).withOpacity(0.15),
                offset: const Offset(2, 3), // 阴影偏移
                blurRadius: 4,
              )
            ] : null,
          ),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              backgroundColor: widget.backgroundColor, // 传入背景色
              borderWidth: _isPressed ? 2.0 : 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0), // 边框和内容之间的间距
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 带动画效果的Filter按钮
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

/// 胶带纹理绘制器
class _TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 绘制水平线来模拟胶带纹理
    for (double y = 2; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 格子纸组件
class _GridPaper extends StatelessWidget {
  final Widget child;

  const _GridPaper({required this.child});

  @override
  Widget build(BuildContext context) {
    final margin5mm = 18.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: margin5mm, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: CustomPaint(painter: _GridPaperPainter(), child: child),
          );
        },
      ),
    );
  }
}

/// 格子纸绘制器
class _GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      return;
    }

    final random = math.Random(42);

    // 创建不规则边缘路径
    final path = _createIrregularPath(size, random);

    // 1. 先绘制阴影效果
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

    // 3. 绘制网格线
    final gridPaint = Paint()
      ..color = const Color(0xFFE3E6E8) // 网格线颜色
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSpacing = 20.0;

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

    // 4. 绘制不规则边缘线
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
    const double edgeNoise = 2.5;
    const double step = 8.0;

    final double effectiveWidth = size.width > 0 ? size.width : 100.0;
    final double effectiveHeight = size.height > 0 ? size.height : 100.0;

    // 顶部边缘
    path.moveTo(0, 0);
    for (double x = step; x < effectiveWidth; x += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = noise.clamp(-edgeNoise, edgeNoise).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, 0);

    // 右侧边缘
    for (double y = step; y < effectiveHeight; y += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final x = (effectiveWidth + noise.clamp(-edgeNoise, edgeNoise)).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(effectiveWidth, effectiveHeight);

    // 底部边缘
    for (double x = effectiveWidth - step; x > 0; x -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      final y = (effectiveHeight + noise.clamp(-edgeNoise, edgeNoise)).toDouble();
      path.lineTo(x, y);
    }
    path.lineTo(0, effectiveHeight);

    // 左侧边缘
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
