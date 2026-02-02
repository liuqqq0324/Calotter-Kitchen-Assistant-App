import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/config/yolo_labels_config.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/cards/ingredient_card.dart';
import 'package:personal_sous_chef/features/inventory/pages/edit_ingredient_page.dart';
import 'package:personal_sous_chef/services/api/inventory_api_service.dart';
import 'package:personal_sous_chef/shared/widgets/cards/stop_motion_dismissible.dart'; // 引入定格动画滑动删除组件
import 'package:personal_sous_chef/shared/widgets/common/sketchy_confirm_dialog.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart'; // 引入 SketchyRectBorder
import 'package:personal_sous_chef/shared/widgets/common/sketchy_button.dart';

class ReviewIngredientsPage extends StatefulWidget {
  // 🔥 新增：定义一个变量来接收外部传入的数据
  final List<Ingredient>? analyzedIngredients;

  const ReviewIngredientsPage({
    super.key,
    this.analyzedIngredients, // 🔥 新增：在构造函数中允许传入这个参数
  });

  @override
  State<ReviewIngredientsPage> createState() => _ReviewIngredientsPageState();
}

class _ReviewIngredientsPageState extends State<ReviewIngredientsPage> {
  // 字体：使用本地字体 PatrickHand（在 pubspec.yaml 中注册）
  static const String _fontFamily = 'PatrickHand';

  TextStyle _pangolin({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // 模拟识别结果
  // 🔥 修改 1: 去掉 final，加上 late (因为我们要稍后初始化它)
  late List<Ingredient> _detectedItems;

  // ✅ 为每个食材存储允许的单位列表（key: 食材名称，value: 允许的单位列表）
  Map<String, List<String>> _ingredientAllowedUnits = {};

  // ✅ 为每个食材存储标准食材ID（key: 食材名称，value: 标准食材ID）
  Map<String, int?> _ingredientStandardIds = {};

  /// 第二层防护：LLM 常错的别名 → 标准库名称（小写 key）
  /// 不区分黄/紫/红/白洋葱 → Onion；bell pepper → Capsicum
  static const Map<String, String> _manualAliases = {
    'grapes': 'Grape',
    'chili': 'Capsicum',
    'chili-pepper': 'Capsicum',
    'chilli': 'Capsicum',
    'bell pepper': 'Capsicum',
    'bell peppers': 'Capsicum',
    'shrimps': 'Shrimp',
    'potatoes': 'Potato',
    'tomatoes': 'Tomato',
    'eggs': 'Egg',
    'onions': 'Onion',
    'yellow onion': 'Onion',
    'purple onion': 'Onion',
    'red onion': 'Onion',
    'white onion': 'Onion',
    'peppers': 'Capsicum',
    'carrots': 'Carrot',
    'apples': 'Apple',
    'bananas': 'Banana',
  };

  /// 归一化食材名用于 API 查询：别名表 + 简单单复数（仅当去 s 后在标准库中存在时替换）
  String _normalizeIngredientNameForLookup(String ingredientName) {
    final lowerName = ingredientName.toLowerCase().trim();
    if (_manualAliases.containsKey(lowerName)) {
      return _manualAliases[lowerName]!;
    }
    // 简单单复数：Grapes -> Grape，仅当 Grape 在标准库中存在时替换
    if (lowerName.endsWith('es') && lowerName.length > 2) {
      final singular = ingredientName.substring(0, ingredientName.length - 2);
      for (final l in yoloLabels) {
        if (l.toLowerCase() == singular.toLowerCase()) return l;
      }
    }
    if (lowerName.endsWith('s') && lowerName.length > 1) {
      final singular = ingredientName.substring(0, ingredientName.length - 1);
      for (final l in yoloLabels) {
        if (l.toLowerCase() == singular.toLowerCase()) return l;
      }
    }
    return ingredientName;
  }

  // 🔥 修改 2: 在 initState 中判断是用真实数据还是测试数据
  @override
  void initState() {
    super.initState();

    // 如果 widget.analyzedIngredients 有值（也就是从拍照页面传过来的），就用它
    if (widget.analyzedIngredients != null &&
        widget.analyzedIngredients!.isNotEmpty) {
      _detectedItems = widget.analyzedIngredients!;
    } else {
      // 否则使用原来的 Mock 数据（作为测试兜底）
      _detectedItems = [
        Ingredient(
          name: "Tomatoes",
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          quantity: 3.0,
          unit: 'pcs',
          imagePlaceholder: '🍅',
        ),
        Ingredient(
          name: "Eggs",
          expiryDate: DateTime.now().add(const Duration(days: 14)),
          quantity: 6.0,
          unit: 'pcs',
          imagePlaceholder: '🥚',
        ),
        Ingredient(
          name: "Potatoes",
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          quantity: 2.0,
          unit: 'kg',
          imagePlaceholder: '🥔',
        ),
        // ... 你原来的其他测试数据 ...
      ];
    }

    // ✅ 初始化时，为所有食材加载允许的单位列表
    _loadAllowedUnitsForAll();
  }

  /// ✅ 为所有食材加载允许的单位列表
  Future<void> _loadAllowedUnitsForAll() async {
    for (final ingredient in _detectedItems) {
      await _loadAllowedUnitsForIngredient(ingredient.name);
    }
  }

  /// ✅ 为单个食材加载允许的单位列表并规范化单位
  /// 第二层防护：先用 _normalizeIngredientNameForLookup 做别名/单复数归一化再查 API
  Future<void> _loadAllowedUnitsForIngredient(String ingredientName) async {
    try {
      // 1. 语义归一化：别名表 + 单复数，得到用于 API 查询的名称
      final searchName = _normalizeIngredientNameForLookup(ingredientName);
      final normalizedName = searchName.replaceAll(' ', '-');
      final standardIngredientId =
          await InventoryApiService.findStandardIngredientIdByName(
            normalizedName,
          );

      if (standardIngredientId != null) {
        // 2. 保存标准食材ID
        _ingredientStandardIds[ingredientName] = standardIngredientId;

        // 3. 获取标准食材详情（包含 primaryUnit）
        final standardIngredient =
            await InventoryApiService.searchStandardIngredients(
              name: normalizedName,
              fuzzy: false,
            );

        // 4. 获取允许的单位列表（primaryUnit 和 secondaryUnit）
        final allowedUnits = await InventoryApiService.getAllowedUnits(
          standardIngredientId,
        );

        // 5. 提取 primaryUnit（主单位，优先使用）
        String? primaryUnit;
        if (standardIngredient is Map<String, dynamic>) {
          primaryUnit = standardIngredient['primaryUnit'] as String?;
        }

        if (mounted) {
          setState(() {
            _ingredientAllowedUnits[ingredientName] = allowedUnits.isNotEmpty
                ? allowedUnits
                : ['g', 'pcs', 'ml'];

            // ✅ 规范化单位：优先使用 primaryUnit，如果不存在则使用第一个允许的单位
            final ingredient = _detectedItems.firstWhere(
              (ing) => ing.name == ingredientName,
              orElse: () => _detectedItems.first,
            );

            // 如果当前单位不在允许列表中，或者没有设置，使用 primaryUnit
            if (primaryUnit != null &&
                _ingredientAllowedUnits[ingredientName]!.contains(
                  primaryUnit,
                )) {
              ingredient.unit = primaryUnit; // ✅ 优先使用主单位
            } else if (!_ingredientAllowedUnits[ingredientName]!.contains(
              ingredient.unit,
            )) {
              ingredient.unit = _ingredientAllowedUnits[ingredientName]!.first;
            }
          });
        }
      } else {
        // 如果找不到标准食材，使用默认单位列表
        if (mounted) {
          setState(() {
            _ingredientAllowedUnits[ingredientName] = ['g', 'pcs', 'ml'];
            _ingredientStandardIds[ingredientName] = null;
          });
        }
      }
    } catch (e) {
      // 加载失败时使用默认单位列表
      if (mounted) {
        setState(() {
          _ingredientAllowedUnits[ingredientName] = ['g', 'pcs', 'ml'];
          _ingredientStandardIds[ingredientName] = null;
        });
      }
    }
  }

  // 🔥 状态控制：是否已完成添加
  bool _isAdded = false;
  // 🔥 保存状态：是否正在保存到数据库
  bool _isSaving = false;

  // 🔥 保存食材到数据库
  Future<void> _saveIngredientsToDatabase() async {
    if (_detectedItems.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    int successCount = 0;
    int failCount = 0;
    List<String> failedItems = [];
    List<Ingredient> successfullySavedItems = []; // 成功保存的食材列表

    try {
      // 遍历所有识别的食材，逐个保存
      for (final ingredient in _detectedItems) {
        try {
          // ✅ 优先使用已加载的标准食材ID（如果之前加载过）
          int? standardIngredientId = _ingredientStandardIds[ingredient.name];

          // 如果没有加载过，尝试通过名称查找
          if (standardIngredientId == null) {
            // ✅ 修复：将名称中的空格替换回连字符，以匹配数据库中的格式
            final normalizedName = ingredient.name.replaceAll(' ', '-');
            standardIngredientId =
                await InventoryApiService.findStandardIngredientIdByName(
                  normalizedName,
                );
          }

          if (standardIngredientId == null) {
            // 找不到标准食材，跳过并记录
            failCount++;
            failedItems.add(ingredient.name);
            continue;
          }

          // 2. 格式化过期日期为 ISO 8601 格式
          final expiryDateStr = ingredient.expiryDate.toIso8601String().split(
            'T',
          )[0];

          // 3. 调用 API 保存到数据库
          await InventoryApiService.addInventory(
            name: ingredient.name,
            quantity: ingredient.quantity, // 🔥 quantity 已经是 double，无需转换
            unit: ingredient.unit,
            expiryDate: expiryDateStr,
            standardIngredientId: standardIngredientId,
          );

          successCount++;
          successfullySavedItems.add(ingredient); // 记录成功保存的食材
        } catch (e) {
          // 单个食材保存失败，记录但继续处理其他食材
          failCount++;
          failedItems.add(ingredient.name);
          // 可选：记录详细错误日志
          debugPrint('Failed to save ${ingredient.name}: $e');
        }
      }

      // 4. 成功保存的食材已保存到数据库，无需更新全局数据

      // 5. 显示结果提示
      if (!mounted) return;

      String message;
      if (successCount == _detectedItems.length) {
        // 全部成功
        message =
            "Successfully added $successCount ingredient(s) to inventory!";
      } else if (successCount > 0) {
        // 部分成功
        message =
            "Added $successCount ingredient(s) successfully. ${failCount > 0 ? '$failCount item(s) failed: ${failedItems.join(", ")}' : ''}";
      } else {
        // 全部失败
        message =
            "Failed to add ingredients. Please check if ingredient names match the standard library.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: failCount > 0 ? 5 : 3),
          backgroundColor: successCount == _detectedItems.length
              ? Colors.green
              : (successCount > 0 ? Colors.orange : Colors.red),
        ),
      );

      // 6. 如果有成功的，切换到成功视图
      if (successCount > 0) {
        setState(() {
          _isAdded = true;
          _isSaving = false;
        });
      } else {
        // 全部失败，保持当前视图，允许用户重试
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      // 整体错误处理
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving ingredients: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // 日期选择逻辑 (保持不变)
  Future<void> _selectDate(Ingredient item) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: item.expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );

    // 🔥 安全检查：等待日历关闭后，先看一眼页面还在不在
    if (!mounted) return;

    if (picked != null) {
      setState(() => item.expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      // 使用木纹海浪图片作为背景，确保填满整个页面
      child: Stack(
        children: [
          // 背景图层：填满整个屏幕
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.png',
              fit: BoxFit.cover,
              // 如果背景图路径不对/资源未打包，先用现有的 sketch_paper_transparent.png 兜底，避免崩溃
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/sketch_paper_transparent.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 可选：加一层轻薄的"纸张泛黄"蒙版，让内容更易读
          Positioned.fill(
            child: Container(color: const Color(0xFFF3E5AB).withOpacity(0.35)),
          ),
          // 内容层
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // 如果已添加，隐藏返回按钮，强制用户选下面两个路径（或者保留看你自己）
              leading: _isAdded
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: const Color(0xFF6B4F4F), // River Deep Brown
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
              title: Text(
                _isAdded ? "Success" : "Review Ingredients", // 标题也跟着变
                style: _pangolin(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B4F4F), // River Deep Brown
                  letterSpacing: 1.0,
                ),
              ),
              centerTitle: true,
            ),

            // 🔥 核心逻辑：根据状态切换整个页面内容
            body: _isAdded
                ? _buildSuccessPage() // 状态 B: 全屏成功页
                : _buildReviewList(), // 状态 A: 之前的列表页
          ),
        ],
      ),
    );
  }

  // =======================================================
  // 状态 A: 审核列表视图 (Add 之前)
  // =======================================================
  Widget _buildReviewList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 50),
      children: [
        // 1. 顶部提示
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: ShapeDecoration(
            color: const Color(
              0xFFFFFFF0,
            ).withOpacity(0.9), // Off-white/cream color
            shape: const SketchyRectBorder(
              borderWidth: 1.5,
              wobbleAmount: 2.0,
              seed: 100,
            ),
          ),
          child: Text(
            "We detected ${_detectedItems.length} ingredients. Slide left to delete unwanted items.",
            style: _pangolin(
              fontSize: 16,
              color: const Color(0xFF6B4F4F).withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 2. 列表内容 (使用定格动画滑动删除功能)
        ..._detectedItems.map((item) {
          return StopMotionDismissible(
            dismissKey: ObjectKey(item).toString(),
            confirmDismiss: (direction) async {
              return await showSketchyConfirmDeleteDialog(
                context,
                title: '确认移除？',
                message: '确定要从列表中移除 ${item.name} 吗？',
                cancelLabel: '取消',
                confirmLabel: '移除',
              );
            },
            onDismissed: (direction) {
              final removedItem = item;
              final index = _detectedItems.indexOf(item);
              setState(() => _detectedItems.remove(item));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${item.name} removed"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _detectedItems.insert(index, removedItem);
                      });
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IngredientCard(
                item: item,
                useStatusColors: false,
                showUnmatchedWarning: _ingredientStandardIds[item.name] == null,
                unitOptions:
                    _ingredientAllowedUnits[item.name] ?? ['g', 'pcs', 'ml'],
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditIngredientPage(ingredient: item, isNew: false),
                    ),
                  );
                  if (!mounted) return;
                  if (result == true) {
                    await _loadAllowedUnitsForIngredient(item.name);
                    setState(() {});
                  }
                },
                onUnitChanged: (val) => setState(() => item.unit = val),
                onQuantityChanged: (val) => setState(() => item.quantity = val),
                onExpiryTap: () => _selectDate(item),
              ),
            ),
          );

          // =========================================================
          // 🔥 原有滑动删除代码（已注释，保留作为参考）
          // =========================================================
          /*
          return Dismissible(
            key: ObjectKey(item),
            direction: DismissDirection.endToStart, // 允许删除
            background: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.red, size: 30),
            ),
            onDismissed: (direction) {
              final removedItem = item;
              final index = _detectedItems.indexOf(item);
              setState(() => _detectedItems.remove(item));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${item.name} removed"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      // 🔥 安全检查：如果页面已经关了，就别刷新了
                      if (!mounted) return;

                      setState(() {
                        // 这里用 insert 插回原位是安全的，
                        // 因为 Review 页面不像 Inventory 页面那样会实时排序，
                        // 它是维持用户扫描顺序的，所以插回 index 没问题。
                        _detectedItems.insert(index, removedItem);
                      });
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IngredientCard(
                item: item,
                useStatusColors: false,
                // ✅ 使用动态加载的允许单位列表
                unitOptions:
                    _ingredientAllowedUnits[item.name] ??
                    ['g', 'pcs', 'ml'], // 默认单位列表
                onUnitChanged: (val) => setState(() => item.unit = val),
                onQuantityChanged: (val) => setState(() => item.quantity = val),
                onExpiryTap: () => _selectDate(item),
              ),
            ),
          );
          */
        }),

        const SizedBox(height: 0),

        // 3. 底部操作按钮（统一使用 SketchyButton 手绘风格）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Add Manually
              SketchyButton(
                text: "Add ingredients manually",
                icon: Icons.add_circle_outline,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                onPressed: () async {
                  final newIngredient = Ingredient(
                    name: "",
                    expiryDate: DateTime.now().add(const Duration(days: 7)),
                    quantity: 1,
                    unit: 'pcs',
                    imagePlaceholder: '📝',
                  );
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditIngredientPage(
                        ingredient: newIngredient,
                        isNew: true,
                      ),
                    ),
                  );
                  if (!mounted) return;
                  if (result == true) {
                    setState(() => _detectedItems.add(newIngredient));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${newIngredient.name} manually"),
                      ),
                    );
                  }
                },
                isFullWidth: true,
                backgroundColor: const Color(0xFFFFFFF0),
                textColor: const Color(0xFF6B4F4F),
                borderColor: const Color(0xFF6B4F4F).withOpacity(0.7),
                fontSize: 16,
              ),

              // Add to inventory
              SketchyButton(
                text: _isSaving ? "Saving..." : "Add ingredients to inventory",
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                onPressed: _isSaving ? () {} : _saveIngredientsToDatabase,
                isFullWidth: true,
                backgroundColor: _isSaving
                    ? Colors.grey
                    : const Color(0xFF6B4F4F),
                textColor: Colors.white,
                borderColor: const Color(0xFF6B4F4F).withOpacity(0.8),
                fontSize: 18,
              ),

              // Scan again
              SketchyButton(
                text: "Scan again",
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                onPressed: () => Navigator.pop(context),
                isFullWidth: true,
                backgroundColor: const Color(0xFFFFFFF0),
                textColor: const Color(0xFF6B4F4F),
                borderColor: const Color(0xFF6B4F4F).withOpacity(0.7),
                fontSize: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =======================================================
  // 状态 B: 成功页面视图 (Add 之后)
  // =======================================================
  Widget _buildSuccessPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 大勾勾图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4F4F).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: const Color(0xFF6B4F4F), // River Deep Brown
                size: 80,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              "All Set!",
              style: _pangolin(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B4F4F), // River Deep Brown
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${_detectedItems.length} ingredients have been added to your kitchen.",
              textAlign: TextAlign.center,
              style: _pangolin(
                fontSize: 16,
                color: const Color(0xFF6B4F4F).withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 60), // 留白
            // 选项 1: 查看库存 (次要按钮)
            SketchyButton(
              text: "View Kitchen Inventory",
              icon: Icons.kitchen,
              onPressed: () => Navigator.pop(context, 'kitchen'),
              isFullWidth: true,
              backgroundColor: const Color(0xFFFFFFF0),
              textColor: const Color(0xFF6B4F4F),
              borderColor: const Color(0xFF6B4F4F).withOpacity(0.7),
              fontSize: 16,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            ),

            const SizedBox(height: 20),

            // 选项 2: 生成食谱 (主要按钮)
            SketchyButton(
              text: "Generate Recipes",
              icon: Icons.restaurant_menu,
              onPressed: () => Navigator.pop(context, 'recipe'),
              isFullWidth: true,
              backgroundColor: const Color(0xFF6B4F4F),
              textColor: Colors.white,
              borderColor: const Color(0xFF6B4F4F).withOpacity(0.8),
              fontSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            ),
          ],
        ),
      ),
    );
  }
}
