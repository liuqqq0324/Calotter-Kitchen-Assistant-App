// lib/pages/recipes/recipe_generate_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_filter_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipe_instruction_page.dart';
import 'package:personal_sous_chef/services/recipe_api_service.dart';
import 'package:personal_sous_chef/services/household_service.dart';

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
  List<RecipeMenuModel> _menus = [];
  bool _loading = false;
  String? _error;
  int? _selectedMenuId;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedMenuId = null;
    });

    try {
      // 获取householdId
      final householdId = await HouseholdService.getHouseholdId();
      final menus = await RecipeApiService.generateMenus(
        widget.filter,
        householdId: householdId,
      );
      setState(() {
        _menus = menus;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
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

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState(theme)
                    : _menus.isEmpty
                        ? _buildEmptyState(theme)
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: _menus.length,
                            itemBuilder: (context, index) {
                              final menu = _menus[index];
                              return _buildMenuCard(context, menu, theme);
                            },
                          ),
          ),
        ],
      ),

      // 底部操作：Start cooking（选中的 menu）+ Generate again
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _selectedMenuId == null
                      ? null
                      : () {
                          final menu = _menus
                              .firstWhere((m) => m.menuId == _selectedMenuId);
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _selectedMenuId == null
                        ? 'Select a menu to start cooking'
                        : 'Start cooking (Menu $_selectedMenuId)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _fetchMenus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 单个菜单卡片 UI，增加 Start cooking 按钮
  Widget _buildMenuCard(
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

    final isSelected = _selectedMenuId == menu.menuId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Row(
                        children: [
                          Text(
                            'Menu ${menu.menuId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMenuId = menu.menuId;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 18,
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSelected ? 'Selected' : 'Select',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
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
                      Text(
                        primaryRecipe.shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedMenuId = menu.menuId;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isSelected
                            ? Colors.orange
                            : Colors.orange.shade200,
                      ),
                      foregroundColor:
                          isSelected ? Colors.orange : Colors.orange.shade800,
                    ),
                    child: Text(isSelected ? 'Selected' : 'Choose this menu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('View steps'),
                  ),
                ),
              ],
            ),
          ],
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
    bool isQuotaError = errorMessage.contains('429') || 
                        errorMessage.contains('quota') || 
                        errorMessage.contains('配额') ||
                        errorMessage.contains('Quota exceeded');
    
    if (isQuotaError) {
      displayMessage = 'API 配额已用完\n\n请稍后再试，或检查您的 API 配额限制。';
    } else if (errorMessage.length > 200) {
      // 如果错误信息太长，截取前200个字符
      displayMessage = errorMessage.substring(0, 200) + '...';
    }
    
    return Center(
      child: SingleChildScrollView(  // 添加滚动支持
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
                isQuotaError ? 'API 配额已用完' : 'Failed to load recipes.',
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
                maxLines: 10,  // 限制最大行数
                overflow: TextOverflow.ellipsis,  // 超出部分显示省略号
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchMenus,
                child: const Text('Retry'),
              ),
              if (isQuotaError) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // 可以添加跳转到设置页面或显示更多信息的逻辑
                  },
                  child: const Text('查看配额信息'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
