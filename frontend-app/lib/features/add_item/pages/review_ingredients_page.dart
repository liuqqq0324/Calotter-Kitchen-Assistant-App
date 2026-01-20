import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/cards/ingredient_card.dart';
import 'package:personal_sous_chef/features/inventory/pages/edit_ingredient_page.dart'; // 🔥 引入编辑页
import 'package:personal_sous_chef/services/api/inventory_api_service.dart'; // 🔥 引入 API 服务

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
  // 模拟识别结果
  // 🔥 修改 1: 去掉 final，加上 late (因为我们要稍后初始化它)
  late List<Ingredient> _detectedItems;

  // ✅ 为每个食材存储允许的单位列表（key: 食材名称，value: 允许的单位列表）
  Map<String, List<String>> _ingredientAllowedUnits = {};

  // ✅ 为每个食材存储标准食材ID（key: 食材名称，value: 标准食材ID）
  Map<String, int?> _ingredientStandardIds = {};

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
  Future<void> _loadAllowedUnitsForIngredient(String ingredientName) async {
    try {
      // 1. 通过名称查找标准食材ID（支持精确匹配）
      // ✅ 修复：使用原始名称（带连字符）进行查找
      final standardIngredientId =
          await InventoryApiService.findStandardIngredientIdByName(
            ingredientName,
          );

      if (standardIngredientId != null) {
        // 2. 保存标准食材ID
        _ingredientStandardIds[ingredientName] = standardIngredientId;

        // 3. 获取标准食材详情（包含 primaryUnit）
        final standardIngredient =
            await InventoryApiService.searchStandardIngredients(
              name: ingredientName,
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
            standardIngredientId =
                await InventoryApiService.findStandardIngredientIdByName(
                  ingredient.name,
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 如果已添加，隐藏返回按钮，强制用户选下面两个路径（或者保留看你自己）
        leading: _isAdded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          _isAdded ? "Success" : "Review Ingredients", // 标题也跟着变
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // 🔥 核心逻辑：根据状态切换整个页面内容
      body: _isAdded
          ? _buildSuccessPage() // 状态 B: 全屏成功页
          : _buildReviewList(), // 状态 A: 之前的列表页
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
          color: Colors.white,
          child: Text(
            "We detected ${_detectedItems.length} ingredients. Slide left to delete unwanted items.",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(height: 10),

        // 2. 列表内容 (保持你的侧滑删除功能)
        ..._detectedItems.map((item) {
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
        }),

        const SizedBox(height: 30),

        // 3. 底部操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Add Manually
              TextButton.icon(
                onPressed: () async {
                  // 1. 创建一个临时的“空白”食材对象
                  final newIngredient = Ingredient(
                    name: "", // 留空，让用户填
                    expiryDate: DateTime.now().add(
                      const Duration(days: 7),
                    ), // 默认过期时间
                    quantity: 1,
                    unit: 'pcs',
                    imagePlaceholder: '📝', // 给个默认图标
                  );

                  // 2. 跳转到编辑页 (复用 isNew 逻辑)
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditIngredientPage(
                        ingredient: newIngredient, // 把空白对象传过去
                        isNew: true, // 🔥 标记为新建模式
                      ),
                    ),
                  );

                  // 3. 安全检查
                  if (!mounted) return;

                  // 4. 如果返回 true (代表用户点了 Done)，则加入列表
                  if (result == true) {
                    setState(() {
                      // EditIngredientPage 是直接修改传入的对象的，
                      // 所以此时 newIngredient 已经被填入了名字和数量
                      _detectedItems.add(newIngredient);
                    });

                    // 可选：给个小提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${newIngredient.name} manually"),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.orange,
                ),
                label: const Text(
                  "Add ingredients manually",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 确认按钮
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveIngredientsToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Add ingredients to inventory",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 重扫按钮
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Scan again",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
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
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 80,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "All Set!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${_detectedItems.length} ingredients have been added to your kitchen.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 60), // 留白
            // 选项 1: 查看库存 (次要按钮)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                // 🔥 返回 'kitchen' 指令
                onPressed: () => Navigator.pop(context, 'kitchen'),
                icon: const Icon(Icons.kitchen),
                label: const Text("View Kitchen Inventory"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 选项 2: 生成食谱 (主要按钮 - 橙色高亮)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                // 🔥 返回 'recipe' 指令
                onPressed: () => Navigator.pop(context, 'recipe'),
                icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                label: const Text("Generate Recipes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5, // 阴影重一点，强调这是下一步推荐操作
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
