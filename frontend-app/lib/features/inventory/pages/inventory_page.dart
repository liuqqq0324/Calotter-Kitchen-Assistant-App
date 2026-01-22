import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/features/inventory/pages/edit_ingredient_page.dart';
import 'package:personal_sous_chef/shared/widgets/cards/ingredient_card.dart';
import 'package:personal_sous_chef/features/add_item/pages/add_item_page.dart';
import 'package:personal_sous_chef/navigation/main_scaffold.dart'; // ⚠️ 已更新：MainScaffoldState 从 main.dart 移至 navigation/main_scaffold.dart
import 'package:personal_sous_chef/data/models/cookware.dart';
import 'package:personal_sous_chef/shared/widgets/forms/item_toggle_grid.dart';
import 'package:personal_sous_chef/services/api/inventory_api_service.dart';
import 'package:personal_sous_chef/services/business/standard_library_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/data/models/leftover.dart';
import 'package:personal_sous_chef/shared/widgets/cards/leftover_card.dart';
import 'package:personal_sous_chef/shared/widgets/cards/stop_motion_dismissible.dart'; // 引入定格动画滑动删除组件

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
      if (_tabController.indexIsChanging) {
        setState(() {}); // 触发重绘以更新书签状态
      }
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

    // 【新设计】参考 home_page.dart 的背景和 container 层级布局
    // 使用 SizedBox.expand 包裹整个页面，使用 Stack 实现分层效果
    return SizedBox.expand(
      child: Stack(
        children: [
          // =========================================
          // 背景图层 1: 木纹背景图片
          // =========================================
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.png',
              fit: BoxFit.cover,
              // 如果背景图路径不对/资源未打包，使用错误处理
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/sketch_paper_transparent.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // =========================================
          // 背景图层 2: 纸张泛黄蒙版（让内容更易读）
          // =========================================
          Positioned.fill(
            child: Container(color: const Color(0xFFF3E5AB).withOpacity(0.35)),
          ),

          // =========================================
          // 内容层: 书签、羊皮纸、浮动按钮等
          // =========================================
          Scaffold(
            backgroundColor: Colors.transparent,
            // Stack 是实现分层效果的关键
            body: Stack(
              children: [
                // =========================================
                // 【新设计】层级 A (底层): 羊皮纸主体 (Parchment Sheet)
                // 说明：把羊皮纸放在书签之前，这样它就会被书签盖住 (Z轴在后)
                // container 设为全透明，底部不留 margin
                // =========================================
                Positioned(
                  top: 0,
                  bottom: 0, // 【修改】底部不留 margin
                  left: 16,
                  right: 16,
                  child: _buildParchmentSheet(),
                ),

                // =========================================
                // 【新设计】层级 B (上层): 悬挂的书签 (Bookmarks)
                // 说明：把书签放在羊皮纸之后，这样它就会浮在纸张上面 (Z轴在前)
                // 这样当列表滚动时，内容会滑入书签背后的区域，营造真正的"夹在书签下的纸张"效果
                // 🔥 关键修改 1: 向上提 15px，让书签顶部"钻"进木纹标题栏下方
                // 这样无论木纹边缘怎么不规则，书签看起来都是从木板后面伸出来的
                // =========================================
                Positioned(
                  top: -15, // 🔥 关键修改 1: 向上提 15px
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 110, // 🔥 关键修改 2: 增加容器高度，容纳变长的书签
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHangingBookmark(
                            0,
                            'Ingredients',
                            'assets/icons/Ingredients.png',
                            Colors.orange.shade300,
                          ),
                          _buildHangingBookmark(
                            1,
                            'Seasonings',
                            'assets/icons/Seasonings.png',
                            Colors.green.shade300,
                          ),
                          _buildHangingBookmark(
                            2,
                            'Cookware',
                            'assets/icons/Cookwares.png',
                            Colors.blue.shade300,
                          ),
                          _buildHangingBookmark(
                            3,
                            'Dish',
                            'assets/icons/Dishes.png',
                            Colors.yellow.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================================
                // 层级 3 (浮动层): 按钮与遮罩
                // =========================================
                if (_isExpanded)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleExpand,
                      child: Container(color: Colors.black54),
                    ),
                  ),

                // 浮动菜单
                if (_tabController.index == 0) // 只在第一个Tab显示
                  Positioned(
                    left: 0,
                    right: 0,
                    // 适配底部安全区（iPhone Home 条 / Android 手势条）
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildExpandableFab(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 【新设计】羊皮纸方案：构建统一的羊皮纸容器
  // =========================================================
  /// 构建羊皮纸容器，将标题和列表装进同一个容器里
  /// 核心思路：不再把标题和列表看作两个悬浮元素，而是统一在一个容器中
  /// 这样滚动时内容是在纸张内部滑动，视觉上更加连贯统一
  Widget _buildParchmentSheet() {
    return Container(
      // 1. 设置容器为全透明（移除背景色和阴影）
      decoration: BoxDecoration(
        color: Colors.transparent, // 【修改】设为全透明
      ),
      // 2. 移除 clipBehavior，因为透明容器不需要裁切
      // clipBehavior: Clip.hardEdge,

      // 3. 垂直布局：直接显示列表内容（已移除标题）
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 滚动区域 (Body) ---
          Expanded(
            // 使用 Expanded 占满剩余空间
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildIngredientPage(), // 你的各个页面
                _buildSeasoningsPage(),
                _buildCookwarePage(),
                _buildLeftoversPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 核心逻辑：构建悬挂式书签
  Widget _buildHangingBookmark(
    int index,
    String label,
    String imagePath,
    Color baseColor,
  ) {
    final bool isSelected = _tabController.index == index;

    // 动画参数调整
    // 🔥 关键修改 3: 整体增加高度 (原 76/56 -> 现 95/75)
    // 因为顶部约 15px 被木纹遮住了，我们需要补回来
    final double height = isSelected ? 95.0 : 75.0;
    final double width = 65.0;

    // 🔥 关键修改 4: 调整未选中时的收起幅度
    // 未选中时向上收起更多，营造层次感
    final double topMargin = isSelected ? 0.0 : -15.0;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack, // 使用弹簧曲线，更有物理感
        transform: Matrix4.translationValues(0, topMargin, 0),
        width: width,
        height: height,
        decoration: BoxDecoration(
          // 使用图片作为背景
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            opacity: isSelected ? 1.0 : 0.7,
            colorFilter: isSelected
                ? null
                : const ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
          // 保留颜色叠加效果
          color: isSelected
              ? baseColor.withOpacity(0.3)
              : baseColor.withOpacity(0.2), // 未选中变暗
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // 内容靠下
          children: [
            // 文字
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0), // 文字稍微稍微往上提一点点
              child: Text(
                label,
                style: GoogleFonts.caveat(
                  fontSize: 14, // 稍微加大字体
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助构建方法：封装调料页面
  Widget _buildSeasoningsPage() {
    if (_isLoadingSeasonings) {
      return const Center(child: CircularProgressIndicator());
    }
    // 【新设计】修改 padding：增加顶部 padding 以避让书签（书签覆盖在羊皮纸上方）
    return Padding(
      // 【旧设计】padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // 旧设计中需要左右和上下 padding
      padding: const EdgeInsets.fromLTRB(
        0,
        130, // 🔥 关键修改 5: 从 110 改为 130 (适配变长的书签)
        0,
        0,
      ), // 新设计：顶部留出书签空间，左右为0（羊皮纸容器已有边距）
      child: ItemToggleGrid(items: _seasonings, onToggle: _handleItemToggle),
    );
  }

  // 辅助构建方法：封装厨具页面
  Widget _buildCookwarePage() {
    if (_isLoadingCookware) {
      return const Center(child: CircularProgressIndicator());
    }
    // 【新设计】修改 padding：增加顶部 padding 以避让书签（书签覆盖在羊皮纸上方）
    return Padding(
      // 【旧设计】padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // 旧设计中需要左右和上下 padding
      padding: const EdgeInsets.fromLTRB(
        0,
        130, // 🔥 关键修改 5: 从 110 改为 130 (适配变长的书签)
        0,
        0,
      ), // 新设计：顶部留出书签空间，左右为0（羊皮纸容器已有边距）
      child: ItemToggleGrid(items: _cookwares, onToggle: _handleItemToggle),
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
    // 【新设计】修改 padding：增加顶部 padding 以避让书签（书签覆盖在羊皮纸上方）
    return ListView.builder(
      // 给内容加 padding，否则卡片会贴着屏幕边缘
      // 【旧设计】padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 旧设计中顶部需要留出空间给标题
      padding: const EdgeInsets.fromLTRB(
        0,
        130, // 🔥 关键修改 5: 从 110 改为 130 (适配变长的书签)
        // 确保第一个项目从书签下方可见，上滑时会平滑地滑入书签背后的区域
        0,
        100,
      ), // 新设计：顶部留出书签空间，左右为0（羊皮纸容器已有边距），底部留 100 给 FAB
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
    // 【新设计】修改 padding：增加顶部 padding 以避让书签（书签覆盖在羊皮纸上方）
    return ListView.builder(
      // 【旧设计】padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 旧设计中顶部需要留出空间给标题
      padding: const EdgeInsets.fromLTRB(
        0,
        130, // 🔥 关键修改 5: 从 110 改为 130 (适配变长的书签)
        // 确保第一个项目从书签下方可见，上滑时会平滑地滑入书签背后的区域
        0,
        100,
      ), // 新设计：顶部留出书签空间，左右为0（羊皮纸容器已有边距），底部留 100 给 FAB
      physics: const BouncingScrollPhysics(),
      itemCount: _leftovers.length,
      itemBuilder: (context, index) {
        final leftover = _leftovers[index];

        // 🔥 使用定格动画滑动删除组件
        return StopMotionDismissible(
          dismissKey: leftover.id,
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
      // 底部居中：让主按钮与展开的小按钮中线对齐
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. 手动输入按钮
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                mainAxisAlignment: MainAxisAlignment.center,
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

        // 🔥🔥🔥 3. 主开关按钮 (修改部分) 🔥🔥🔥
        GestureDetector(
          onTap: _toggleExpand, // 绑定点击事件
          child: RotationTransition(
            // 保留原来的旋转动画
            turns: Tween(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: Image.asset(
              'assets/icons/Add_Item.png', // 你的加号图片资源
              // 🔥 调整大小：因为去掉了 FAB 的外壳，图片本身需要大一点
              // 之前 FAB 默认大小约 56，这里设为 70-80 会比较容易点击
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
