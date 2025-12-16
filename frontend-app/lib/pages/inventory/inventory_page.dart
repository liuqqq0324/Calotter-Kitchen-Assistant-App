import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/pages/inventory/edit_ingredient_page.dart';
import 'package:personal_sous_chef/widgets/ingredient_card.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 引入全局数据
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';
import 'package:personal_sous_chef/widgets/generate_recipe_button.dart'; // 引入复用按钮
import 'package:personal_sous_chef/main.dart'; // 🔥 引入 main.dart 以访问 MainScaffoldState
import 'package:personal_sous_chef/models/cookware.dart';
import 'package:personal_sous_chef/widgets/item_toggle_grid.dart';
import 'package:personal_sous_chef/services/inventory_api_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  List<Ingredient> _ingredients = [];
  late List<Cookware> _seasonings;
  late List<Cookware> _cookwares;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _seasonings = kBasicSeasonings;
    _cookwares = kBasicCookware;

    _animationController = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animationController,
    );

    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await InventoryApiService.getInventory();
      setState(() {
        _ingredients = data.map((item) {
          // ✅ 适配后端返回的 IngredientResponse 格式
          DateTime expiryDate = DateTime.now().add(const Duration(days: 7));
          if (item['expirationDate'] != null) {
            try {
              expiryDate = DateTime.parse(item['expirationDate']);
            } catch (e) {
              // Keep default if parsing fails
            }
          }
          return Ingredient(
            // ✅ 使用 standardIngredientName（后端返回的字段）
            name: item['standardIngredientName'] ?? item['name'] ?? 'Unknown',
            expiryDate: expiryDate,
            quantity: (item['quantity'] ?? 0).toInt(),
            unit: item['unit'] ?? 'pcs',
            imagePlaceholder: item['image_url'] != null ? '🖼️' : '📦',
            // ✅ 使用 id（后端返回的字段）
            inventoryId:
                item['id']?.toString() ?? item['inventory_id']?.toString(),
          );
        }).toList();
        _sortItems();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fallback to static data on error
        _ingredients = kInitialIngredients;
        _sortItems();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // --- 逻辑方法：排序 ---
  // 🔥 2. 去掉 setState，使其变为纯数据操作，方便在 build 中调用
  void _sortItems() {
    _ingredients.sort((a, b) {
      if (a.isExpired && !b.isExpired) return -1;
      if (!a.isExpired && b.isExpired) return 1;
      return a.expiryDate.compareTo(b.expiryDate);
    });
  }

  // --- 逻辑：跳转编辑/添加 ---
  void _navigateToEdit(Ingredient item, {bool isNew = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditIngredientPage(ingredient: item, isNew: isNew),
      ),
    );

    if (!mounted) return;

    if (result == 'delete') {
      // Delete from API
      if (item.inventoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot delete: missing inventory ID")),
        );
        return;
      }
      try {
        await InventoryApiService.deleteInventory(
          inventoryId: item.inventoryId!,
        );
        await _loadInventory();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${item.name} removed.")));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    } else if (result == true) {
      // Reload from API after add/edit
      await _loadInventory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.name} ${isNew ? 'added' : 'updated'}!")),
      );
    }
  }

  // 🔥 2. 抽离通用的 Toggle 逻辑
  // 这样 调料 和 炊具 都可以用这一个方法来处理点击
  void _handleItemToggle(Cookware item) {
    setState(() {
      item.isAvailable = !item.isAvailable;
    });
    // 震动反馈或提示
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isAvailable ? '${item.name} added!' : '${item.name} removed.',
        ),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating, // 悬浮样式更好看
        width: 200, // 窄一点
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data is loaded from API in initState and _loadInventory

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 去掉返回箭头
          title: const Text('My Kitchen'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.egg_alt), text: 'Ingredients'),
              Tab(icon: Icon(Icons.local_dining), text: 'Seasonings'), // 新增调料
              Tab(icon: Icon(Icons.soup_kitchen), text: 'Cookware'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIngredientPage(),
            // 🔥 4. 使用复用组件渲染 调料 (Seasonings)
            ItemToggleGrid(
              items: _seasonings,
              onToggle: _handleItemToggle, // 传入逻辑
            ),

            // 🔥 5. 使用复用组件渲染 炊具 (Cookware)
            ItemToggleGrid(
              items: _cookwares,
              onToggle: _handleItemToggle, // 传入相同的逻辑
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UI 构建方法
  // =========================================================

  Widget _buildIngredientPage() {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _ingredients.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInventory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildExpandableFab(),
      body: Stack(
        children: [
          // 列表区域
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 100, top: 5), // 🔥 底部留白给按钮
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final item = _ingredients[index];
              return Dismissible(
                key: ValueKey(
                  item.name + item.expiryDate.toString(),
                ), // 确保 Key 唯一
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.red, size: 30),
                ),
                onDismissed: (direction) async {
                  final deletedItem = item;
                  if (deletedItem.inventoryId == null) {
                    // If no inventory_id, just remove from local list
                    setState(() {
                      _ingredients.removeAt(index);
                    });
                    return;
                  }

                  // Delete from API
                  try {
                    await InventoryApiService.deleteInventory(
                      inventoryId: deletedItem.inventoryId!,
                    );
                    await _loadInventory();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${deletedItem.name} deleted")),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to delete: $e"),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            // Reload to restore
                            _loadInventory();
                          },
                        ),
                      ),
                    );
                  }
                },
                child: _buildIngredientCard(item),
              );
            },
          ),

          // 展开菜单时的半透明遮罩
          if (_isExpanded)
            GestureDetector(
              onTap: _toggleExpand,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // 🔥 4. 底部“生成食谱”按钮 (使用你的 GenerateRecipeButton)
          if (!_isExpanded)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: GenerateRecipeButton(
                  onPressed: () {
                    // 跳转逻辑：查找 MainScaffoldState 并切换 Tab
                    context
                        .findAncestorStateOfType<MainScaffoldState>()
                        ?.switchTab(1);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Ingredient item) {
    return IngredientCard(
      item: item,
      useStatusColors: true,
      onTap: () => _navigateToEdit(item),
      onQuantityChanged: (val) {
        // 更新数量
        item.quantity = val;
        // 注意：这里没调用 setState，如果需要即时排序变化，可以加 setState(() {})
      },
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. 手动输入按钮
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: "btn_manual",
                    onPressed: () {
                      _toggleExpand();
                      _navigateToEdit(
                        Ingredient(
                          name: "",
                          expiryDate: DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          quantity: 1,
                          unit: 'pcs',
                          imagePlaceholder: '📝',
                        ),
                        isNew: true,
                      );
                    },
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.edit, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. 拍照按钮
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: "btn_camera",
                    onPressed: () async {
                      _toggleExpand();

                      // 🔥 5. 修正跳转逻辑：适配 Review 页的新流程
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddItemPage(),
                        ),
                      );

                      if (!mounted) return;

                      // 处理 AddItemPage (ReviewPage) 返回的指令
                      if (result == 'recipe') {
                        // 如果用户想生成食谱，跳转 Tab
                        context
                            .findAncestorStateOfType<MainScaffoldState>()
                            ?.switchTab(1);
                      } else {
                        // 否则 (比如返回 'kitchen' 或 null)，只需刷新当前页
                        setState(() {
                          // 触发 build，重新拉取全局数据并显示
                        });
                      }
                    },
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.camera_alt, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. 主开关按钮
        FloatingActionButton(
          heroTag: "btn_main",
          onPressed: _toggleExpand,
          backgroundColor: Colors.orange,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
