import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/features/inventory/pages/edit_ingredient_page.dart';
import 'package:personal_sous_chef/shared/widgets/cards/ingredient_card.dart';
import 'package:personal_sous_chef/features/add_item/pages/add_item_page.dart';
import 'package:personal_sous_chef/shared/widgets/buttons/generate_recipe_button.dart'; // 引入复用按钮
import 'package:personal_sous_chef/navigation/main_scaffold.dart'; // ⚠️ 已更新：MainScaffoldState 从 main.dart 移至 navigation/main_scaffold.dart
import 'package:personal_sous_chef/data/models/cookware.dart';
import 'package:personal_sous_chef/shared/widgets/forms/item_toggle_grid.dart';
import 'package:personal_sous_chef/services/api/inventory_api_service.dart';
import 'package:personal_sous_chef/services/business/standard_library_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/data/models/leftover.dart';
import 'package:personal_sous_chef/shared/widgets/cards/leftover_card.dart';
import 'package:personal_sous_chef/shared/widgets/cards/stop_motion_dismissible.dart'; // 引入定格动画滑动删除组件
import 'package:personal_sous_chef/shared/widgets/layouts/layered_inventory_layout.dart'; // 引入分层布局组件

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with TickerProviderStateMixin {
  List<Ingredient> _ingredients = [];
  List<Cookware> _seasonings = [];
  List<Cookware> _cookwares = [];
  List<Leftover> _leftovers = [];

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late TabController _tabController; // 🔥 新增：Tab控制器用于书签式交互
  bool _isExpanded = false;
  bool _isLoading = true;
  bool _isLoadingCookware = true;
  bool _isLoadingSeasonings = true;
  bool _isLoadingLeftovers = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animationController,
    );

    // 🔥 新增：初始化Tab控制器
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // 更新UI以反映Tab切换
    });

    _loadInventory();
    _loadCookware();
    _loadSeasonings();
    _loadLeftovers();
  }

  // 🔥 公开的刷新方法，供外部调用
  Future<void> refreshData() async {
    await Future.wait([
      _loadInventory(),
      _loadCookware(),
      _loadSeasonings(),
      _loadLeftovers(),
    ]);
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
            quantity: (item['quantity'] ?? 0) is int
                ? (item['quantity'] ?? 0).toDouble()
                : (item['quantity'] ?? 0.0)
                      .toDouble(), // 🔥 安全的类型转换，支持 int 和 double
            unit: item['unit'] ?? 'pcs',
            imagePlaceholder: item['image_url'] != null ? '🖼️' : '📦',
            // ✅ 使用 id（后端返回的字段）
            inventoryId:
                item['id']?.toString() ?? item['inventory_id']?.toString(),
            // ✅ 获取并保存 standardIngredientId（用于API更新）
            standardIngredientId: item['standardIngredientId'] != null
                ? (item['standardIngredientId'] is int
                      ? item['standardIngredientId'] as int
                      : int.tryParse(item['standardIngredientId'].toString()))
                : null,
          );
        }).toList();
        _sortItems();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fallback to empty list on error
        _ingredients = [];
        _sortItems();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose(); // 🔥 新增：释放Tab控制器
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

  /// ✅ 加载厨具列表（基于标准库）
  Future<void> _loadCookware() async {
    try {
      // 1. 获取标准厨具库（优先使用缓存）
      final standardUtensils =
          await StandardLibraryService.getStandardUtensils();

      // 2. 获取household的实际厨具数据
      List<Map<String, dynamic>> householdUtensils = [];
      try {
        householdUtensils = await InventoryApiService.getUtensils();
      } catch (e) {
        print('[InventoryPage] Failed to load household utensils: $e');
        // 继续使用标准库数据，只是isAvailable都是false
      }

      // 3. 创建映射：standardUtensilName -> isAvailable
      final Map<String, bool> availabilityMap = {};
      for (final item in householdUtensils) {
        final name = item['standardUtensilName'] ?? item['name'] ?? '';
        if (name.isNotEmpty) {
          availabilityMap[name] = item['isAvailable'] ?? false;
        }
      }

      // 4. 基于标准库创建Cookware列表
      if (mounted) {
        setState(() {
          _cookwares = standardUtensils.map((standardUtensil) {
            final name = standardUtensil['name'] ?? '';
            final id = standardUtensil['id']?.toString();
            // 查找对应的household厨具ID（如果存在）
            String? householdUtensilId;
            for (final item in householdUtensils) {
              if ((item['standardUtensilName'] ?? item['name'] ?? '') == name) {
                householdUtensilId = item['id']?.toString();
                break;
              }
            }

            return Cookware(
              id: householdUtensilId, // 使用household厨具的ID（如果存在）
              standardId: id, // ✅ 保存标准库ID
              name: name,
              icon: _getUtensilIcon(name),
              isAvailable: availabilityMap[name] ?? false,
            );
          }).toList();
          _isLoadingCookware = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCookware = false;
          // 如果加载失败，使用空列表作为fallback
          _cookwares = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cookware: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ✅ 加载调料列表（基于标准库）
  Future<void> _loadSeasonings() async {
    try {
      // 1. 获取标准调料库（优先使用缓存）
      final standardSpices = await StandardLibraryService.getStandardSpices();

      // 2. 获取household的实际调料数据
      List<Map<String, dynamic>> householdSpices = [];
      try {
        householdSpices = await InventoryApiService.getSpices();
      } catch (e) {
        print('[InventoryPage] Failed to load household spices: $e');
        // 继续使用标准库数据，只是isAvailable都是false
      }

      // 3. 创建映射：standardSpiceName -> isAvailable
      final Map<String, bool> availabilityMap = {};
      for (final item in householdSpices) {
        final name = item['standardSpiceName'] ?? item['name'] ?? '';
        if (name.isNotEmpty) {
          availabilityMap[name] = item['isAvailable'] ?? false;
        }
      }

      // 4. 基于标准库创建Cookware列表
      if (mounted) {
        setState(() {
          _seasonings = standardSpices.map((standardSpice) {
            final name = standardSpice['name'] ?? '';
            final id = standardSpice['id']?.toString();
            // 查找对应的household调料ID（如果存在）
            String? householdSpiceId;
            for (final item in householdSpices) {
              if ((item['standardSpiceName'] ?? item['name'] ?? '') == name) {
                householdSpiceId = item['id']?.toString();
                break;
              }
            }

            return Cookware(
              id: householdSpiceId, // 使用household调料的ID（如果存在）
              standardId: id, // ✅ 保存标准库ID
              name: name,
              icon: _getSpiceIcon(name),
              isAvailable: availabilityMap[name] ?? false,
            );
          }).toList();
          _isLoadingSeasonings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSeasonings = false;
          // 如果加载失败，使用空列表作为fallback
          _seasonings = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load seasonings: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 加载剩菜列表
  Future<void> _loadLeftovers() async {
    setState(() {
      _isLoadingLeftovers = true;
      _error = null;
    });

    try {
      final data = await InventoryApiService.getLeftovers();
      if (mounted) {
        setState(() {
          _leftovers = data.map((item) {
            DateTime producedTime = DateTime.now();
            if (item['producedTime'] != null) {
              try {
                producedTime = DateTime.parse(item['producedTime']);
              } catch (e) {
                // Keep default if parsing fails
              }
            }

            return Leftover(
              id: item['id']?.toString() ?? '',
              dishId: item['originalDishId']?.toString() ?? '',
              dishName: item['dishName']?.toString(), // ✅ 从后端获取
              quantityGram: item['currentQuantityGram'] ?? 0,
              producedTime: producedTime,
              coverImage: item['coverImage']?.toString(), // ✅ 从后端获取
              caloriesPer100g: item['caloriesPer100g'] != null
                  ? (item['caloriesPer100g'] as num).toInt()
                  : null, // ✅ 从后端获取
              imagePlaceholder: '🍽️',
            );
          }).toList();
          _isLoadingLeftovers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingLeftovers = false;
          _leftovers = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load leftovers: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 删除剩菜
  Future<void> _deleteLeftover(Leftover leftover) async {
    try {
      await InventoryApiService.deleteLeftover(leftoverId: leftover.id);
      if (mounted) {
        // 重新加载剩菜列表
        _loadLeftovers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leftover deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 根据名称获取厨具图标
  IconData _getUtensilIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('pan') || lowerName.contains('frying')) {
      return Icons.circle_outlined;
    } else if (lowerName.contains('pot') || lowerName.contains('stock')) {
      return Icons.coffee;
    } else if (lowerName.contains('knife')) {
      return Icons.cut;
    } else if (lowerName.contains('board') || lowerName.contains('cutting')) {
      return Icons.dashboard;
    } else if (lowerName.contains('oven')) {
      return Icons.microwave;
    } else if (lowerName.contains('blender')) {
      return Icons.electric_bolt;
    } else if (lowerName.contains('rice') || lowerName.contains('cooker')) {
      return Icons.rice_bowl;
    } else if (lowerName.contains('whisk')) {
      return Icons.loop;
    }
    return Icons.kitchen; // 默认图标
  }

  /// 根据名称获取调料图标
  IconData _getSpiceIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('salt')) {
      return Icons.grain;
    } else if (lowerName.contains('sugar')) {
      return Icons.check_box_outline_blank;
    } else if (lowerName.contains('pepper')) {
      return Icons.scatter_plot;
    } else if (lowerName.contains('soy') || lowerName.contains('sauce')) {
      return Icons.invert_colors;
    } else if (lowerName.contains('oil')) {
      return Icons.opacity;
    } else if (lowerName.contains('vinegar')) {
      return Icons.science;
    } else if (lowerName.contains('garlic')) {
      return Icons.spa;
    } else if (lowerName.contains('chili') || lowerName.contains('pepper')) {
      return Icons.whatshot;
    } else if (lowerName.contains('ketchup')) {
      return Icons.fastfood;
    }
    return Icons.local_dining; // 默认图标
  }

  /// ✅ 修复：切换厨具/调料可用性（调用API）
  Future<void> _handleItemToggle(Cookware item) async {
    try {
      // 先更新UI（乐观更新）
      setState(() {
        item.isAvailable = !item.isAvailable;
      });

      Map<String, dynamic> result;

      // ✅ 如果item没有ID，说明household中还没有这个厨具/调料，需要先创建
      if (item.id == null) {
        if (item.standardId == null) {
          throw Exception('Standard ID is required to create ${item.name}');
        }

        final standardId = int.parse(item.standardId!);

        if (_cookwares.contains(item)) {
          // 创建新厨具
          result = await InventoryApiService.createUtensil(
            standardUtensilId: standardId,
            isAvailable: item.isAvailable,
          );
          // 更新item的ID
          item.id = result['id']?.toString();
        } else if (_seasonings.contains(item)) {
          // 创建新调料
          result = await InventoryApiService.createSpice(
            standardSpiceId: standardId,
            isAvailable: item.isAvailable,
          );
          // 更新item的ID
          item.id = result['id']?.toString();
        } else {
          throw Exception('Unknown item type');
        }
      } else {
        // ✅ 如果item有ID，直接切换可用性
        if (_cookwares.contains(item)) {
          result = await InventoryApiService.toggleCookware(
            cookwareId: item.id!,
          );
        } else if (_seasonings.contains(item)) {
          result = await InventoryApiService.toggleSeasoning(
            seasoningId: item.id!,
          );
        } else {
          throw Exception('Unknown item type');
        }
      }

      // 更新item状态（使用API返回的最新状态）
      if (mounted) {
        setState(() {
          item.isAvailable = result['isAvailable'] ?? item.isAvailable;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.isAvailable
                  ? '${item.name} enabled!'
                  : '${item.name} disabled.',
            ),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
            width: 200,
          ),
        );
      }
    } catch (e) {
      // 如果API调用失败，回滚UI状态
      if (mounted) {
        setState(() {
          item.isAvailable = !item.isAvailable; // 回滚
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data is loaded from API in initState and _loadInventory

    return Scaffold(
      backgroundColor: Colors.transparent, // 透明背景，让分层布局显示
      body: LayeredInventoryLayout(
        selectedTabIndex: _tabController.index,
        onTabChanged: (index) {
          _tabController.animateTo(index);
        },
        // 所有书签数据
        bookmarkTabs: [
          BookmarkTabData(
            imagePath: 'assets/icons/inventory.png',
            label: 'Ingredients',
          ),
          BookmarkTabData(
            imagePath: 'assets/icons/seasonings.png',
            label: 'Seasonings',
          ),
          BookmarkTabData(
            imagePath: 'assets/icons/cookware.png',
            label: 'Cookware',
          ),
          BookmarkTabData(
            imagePath: 'assets/icons/dish.png',
            label: 'Leftovers',
          ),
        ],
        // 主容器层的内容
        mainContent: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(), // 🔥 允许横向滑动切换
          children: [
            _buildIngredientPage(),
            // ✅ 调料页面（从API加载）
            _isLoadingSeasonings
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ItemToggleGrid(
                      items: _seasonings,
                      onToggle: _handleItemToggle,
                    ),
                  ),

            // ✅ 厨具页面（从API加载）
            _isLoadingCookware
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ItemToggleGrid(
                      items: _cookwares,
                      onToggle: _handleItemToggle,
                    ),
                  ),

            // ✅ 剩菜页面（从API加载）
            _buildLeftoversPage(),
          ],
        ),
        // 第5层：浮动层（浮动按钮等）
        floatingContent: _buildFloatingLayer(),
      ),
    );
  }

  // =========================================================
  // 🔥 新增：构建浮动层（浮动按钮等）
  // =========================================================
  Widget? _buildFloatingLayer() {
    // 只在 Ingredients Tab 显示浮动按钮
    if (_tabController.index != 0) {
      return null;
    }

    return Stack(
      children: [
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

        // 🔥 底部"生成食谱"按钮
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

        // 展开式浮动按钮组
        Positioned(
          right: 16,
          bottom: _isExpanded ? 100 : 100, // 根据展开状态调整位置
          child: _buildExpandableFab(),
        ),
      ],
    );
  }

  // =========================================================
  // UI 构建方法
  // =========================================================

  Widget _buildIngredientPage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _ingredients.isEmpty) {
      return Center(
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
      );
    }

    // 如果列表为空，显示空状态提示
    if (_ingredients.isEmpty) {
      return const Center(
        child: Text(
          "The pantry is empty...",
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      );
    }

    // 🔥 使用普通的 ListView，背景透明
    return ListView.builder(
      // 给内容加 padding，否则卡片会贴着屏幕边缘
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 底部留 100 给 FAB
      physics: const BouncingScrollPhysics(),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final item = _ingredients[index];

        // 🔥 使用定格动画滑动删除组件
        return StopMotionDismissible(
          dismissKey: item.name + item.expiryDate.toString(),
          onDismissed: (direction) async {
            final deletedItem = item;
            if (deletedItem.inventoryId == null) {
              // If no inventory_id, just remove from local list
              setState(() {
                _ingredients.removeAt(index);
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${deletedItem.name} tossed!'),
                  backgroundColor: const Color(0xFF8D6E63),
                ),
              );
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
                SnackBar(
                  content: Text('${deletedItem.name} tossed!'),
                  backgroundColor: const Color(0xFF8D6E63),
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete: $e'),
                  backgroundColor: Colors.red.shade700,
                  action: SnackBarAction(
                    label: "UNDO",
                    textColor: Colors.white,
                    onPressed: () {
                      // Reload to restore
                      _loadInventory();
                    },
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildIngredientCard(item),
          ),
        );
      },
    );
  }

  Widget _buildLeftoversPage() {
    if (_isLoadingLeftovers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _leftovers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeftovers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_leftovers.isEmpty) {
      return const Center(
        child: Text(
          "No Leftovers",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // 🔥 使用普通的 ListView，背景透明
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _leftovers.length,
      itemBuilder: (context, index) {
        final leftover = _leftovers[index];

        // 🔥 使用定格动画滑动删除组件
        return StopMotionDismissible(
          dismissKey: leftover.id!,
          onDismissed: (direction) async {
            final deletedLeftover = leftover;
            try {
              await _deleteLeftover(deletedLeftover);
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed to delete: $e"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      _loadLeftovers();
                    },
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: LeftoverCard(item: leftover),
          ),
        );
      },
    );
  }

  Widget _buildIngredientCard(Ingredient item) {
    return IngredientCard(
      item: item,
      useStatusColors: true,
      onTap: () => _navigateToEdit(item),
      onQuantityChanged: (val) async {
        // 更新本地数量
        item.quantity = val;

        // ✅ 如果有 inventoryId，调用API更新后端
        if (item.inventoryId != null) {
          try {
            final householdId = await HouseholdService.getHouseholdId();
            if (householdId != null && item.standardIngredientId != null) {
              await InventoryApiService.updateInventory(
                inventoryId: item.inventoryId!,
                quantity: val,
                unit: item.unit,
                expiryDate: item.expiryDate.toIso8601String().split('T')[0],
                householdId: householdId.toString(),
                standardIngredientId: item.standardIngredientId,
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update quantity: $e')),
              );
            }
          }
        }
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
                          quantity: 1.0,
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
