import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/pages/inventory/edit_ingredient_page.dart';
import 'package:personal_sous_chef/widgets/ingredient_card.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 引入全局数据
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';
import 'package:personal_sous_chef/widgets/generate_recipe_button.dart'; // 引入复用按钮
import 'package:personal_sous_chef/main.dart'; // 🔥 引入 main.dart 以访问 MainScaffoldState

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  // 不要在定义时初始化，在 build 里同步
  late List<Ingredient> _ingredients;

  final List<Cookware> _cookwares = [
    Cookware(
      name: 'Frying Pan',
      icon: Icons.circle_outlined,
      isAvailable: true,
    ),
    Cookware(name: 'Stock Pot', icon: Icons.coffee, isAvailable: true),
    Cookware(name: 'Oven', icon: Icons.microwave, isAvailable: false),
    Cookware(name: 'Blender', icon: Icons.electric_bolt, isAvailable: false),
    Cookware(name: 'Knife Set', icon: Icons.cut, isAvailable: true),
    Cookware(name: 'Rice Cooker', icon: Icons.rice_bowl, isAvailable: false),
  ];

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // 🔥 1. 移除这里的数据初始化，只保留动画逻辑

    _animationController = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animationController,
    );
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
      setState(() {
        _ingredients.remove(item);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${item.name} removed.")));
    } else if (result == true) {
      setState(() {
        if (isNew) {
          // 因为 _ingredients 引用的是 kInitialIngredients，直接 add 即可
          _ingredients.add(item);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${item.name} added!")));
        }
        // 不需要手动调 _sortItems，因为 setState 会触发 build，build 里会自动排序
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 3. 核心修复：每次构建时同步全局数据并排序
    // 这样当 Add 流程结束后回到这里，数据会自动刷新
    _ingredients = kInitialIngredients;
    _sortItems();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Kitchen'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.egg_alt), text: 'Ingredients'),
              Tab(icon: Icon(Icons.soup_kitchen), text: 'Cookware'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildIngredientPage(), _buildCookwareGrid()],
        ),
      ),
    );
  }

  // =========================================================
  // UI 构建方法
  // =========================================================

  Widget _buildIngredientPage() {
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
                onDismissed: (direction) {
                  final deletedItem = item;
                  final deletedIndex = index;

                  setState(() {
                    _ingredients.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${deletedItem.name} deleted"),
                      action: SnackBarAction(
                        label: "UNDO",
                        onPressed: () {
                          setState(() {
                            _ingredients.insert(deletedIndex, deletedItem);
                          });
                        },
                      ),
                    ),
                  );
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

  Widget _buildCookwareGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _cookwares.length,
      itemBuilder: (context, index) {
        return _buildCookwareCard(_cookwares[index]);
      },
    );
  }

  Widget _buildCookwareCard(Cookware item) {
    final color = item.isAvailable ? Colors.orange : Colors.grey;
    final bgColor = item.isAvailable
        ? Colors.orange.shade50
        : Colors.grey.shade100;

    return GestureDetector(
      onTap: () {
        setState(() {
          item.isAvailable = !item.isAvailable;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.isAvailable
                  ? '${item.name} added!'
                  : '${item.name} removed.',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isAvailable ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: item.isAvailable
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.isAvailable ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.isAvailable ? 'Available' : 'Not Owned',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
