import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/pages/inventory/edit_ingredient_page.dart';
import 'package:personal_sous_chef/widgets/ingredient_card.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 引入数据文件
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';

// =========================================================
// 2. 页面主体区域 (Main Widget)
// =========================================================

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  // --- 数据源：食材列表 ---
  // 在真实App中，这些数据通常来自后端 API 或本地数据库
  final List<Ingredient> _ingredients = List.from(kInitialIngredients);

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

  // 初始化状态：页面第一次加载时执行
  @override
  void initState() {
    super.initState();
    _sortItems(); // 进来先排个序
    // 🔥 初始化动画 (200毫秒快进快出)
    _animationController = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // 使用 CurvedAnimation 让弹跳更自然
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animationController,
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // 记得销毁
    super.dispose();
  }

  // 🔥 切换展开/收起状态
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
  // 规则：过期的排最前 -> 临期的排中间 -> 正常的排最后
  void _sortItems() {
    setState(() {
      _ingredients.sort((a, b) {
        if (a.isExpired && !b.isExpired) return -1; // a过期，a排前
        if (!a.isExpired && b.isExpired) return 1; // b过期，b排前
        return a.expiryDate.compareTo(b.expiryDate); // 否则按时间先后排
      });
    });
  }

  // --- 逻辑：跳转编辑/添加 ---
  // 增加 isNew 参数，默认为 false (编辑模式)
  void _navigateToEdit(Ingredient item, {bool isNew = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditIngredientPage(
          ingredient: item,
          isNew: isNew, // 🔥 传进去
        ),
      ),
    );

    // 处理返回结果
    if (result == 'delete') {
      setState(() {
        _ingredients.remove(item);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${item.name} removed.")));
    } else if (result == true) {
      // 🔥 核心修改在这里：
      setState(() {
        if (isNew) {
          // 如果是新增模式，并且用户点了 Done，我们需要把这个临时对象正式加入列表
          _ingredients.add(item);

          // (可选) 可以在这里加个 SnackBar 提示添加成功
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${item.name} added!")));
        }

        // 无论是新增还是编辑，回来都要重新排序
        _sortItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // DefaultTabController 用于管理 Tab 的切换逻辑
    return DefaultTabController(
      length: 2, // 这里的 2 对应下面 TabBar 的两个 Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Kitchen'),
          // TabBar 是顶部的导航条
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.egg_alt), text: 'Ingredients'), // Tab 1 标题
              Tab(icon: Icon(Icons.soup_kitchen), text: 'Cookware'), // Tab 2 标题
            ],
          ),
        ),
        // TabBarView 是下方对应的内容区域，必须和 tabs 数量一致
        body: TabBarView(
          children: [
            _buildIngredientPage(), // 对应 Tab 1 的页面内容
            _buildCookwareGrid(), // 对应 Tab 2 的页面内容
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 3. UI 构建方法 (Private Helper Methods)
  // =========================================================

  // --- 模块 1: 食材页面列表 ---
  // --- 模块 1: 食材页面列表 (带侧滑删除) ---
  Widget _buildIngredientPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // 🔥 替换为我们写的复杂按钮组
      floatingActionButton: _buildExpandableFab(),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 10),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final item = _ingredients[index];

              // 🔥 核心修改：用 Dismissible 包裹卡片
              return Dismissible(
                // 1. Key: 必须是唯一的！用来识别删除的是哪一个
                key: ValueKey(item.name + item.expiryDate.toString()),

                // 2. 方向：只允许从右往左滑 (End to Start)
                direction: DismissDirection.endToStart,

                // 3. 背景：滑动时露出的红色垃圾桶区域
                background: Container(
                  // 保证背景和卡片的大小、圆角、间距完全一致，看起来才像“背后”
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100, // 浅橙色背景 (参考你的截图)
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight, // 图标靠右
                  padding: const EdgeInsets.only(right: 20), // 图标距离右边缘的距离
                  child: const Icon(
                    Icons.delete, // 垃圾桶图标
                    color: Colors.black87, // 深色图标
                    size: 30,
                  ),
                ),

                // 4. 逻辑：当滑动完成，真正删除数据
                onDismissed: (direction) {
                  // 先暂存被删除的数据（为了做撤销功能）
                  final deletedItem = item;
                  final deletedIndex = index;

                  setState(() {
                    _ingredients.removeAt(index); // 从列表移除
                  });

                  // 底部提示：已删除 + 撤销按钮
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${deletedItem.name} deleted"),
                      action: SnackBarAction(
                        label: "UNDO",
                        onPressed: () {
                          // 撤销操作：把数据插回去
                          setState(() {
                            _ingredients.insert(deletedIndex, deletedItem);
                          });
                        },
                      ),
                    ),
                  );
                },

                // 5. 子组件：原本的卡片
                child: _buildIngredientCard(item),
              );
            },
          ),
          if (_isExpanded)
            GestureDetector(
              onTap: _toggleExpand, // 点击空白处收起
              child: Container(
                color: Colors.black54, // 半透明黑底
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  // --- 模块 2: 食材卡片 (布局优化版：控制器右上角) ---
  Widget _buildIngredientCard(Ingredient item) {
    // 现在的调用非常清爽
    return IngredientCard(
      item: item,
      useStatusColors: true, // 开启变色警告
      onTap: () => _navigateToEdit(item), // 点击卡片跳转
      onQuantityChanged: (val) {
        // 更新数量 (setState 可加可不加，因为 QuantitySelector 内部有状态)
        // 这里加 setState 是为了确保排序逻辑等可能依赖数量的地方能刷新
        item.quantity = val;
      },
      // unitOptions 不传 -> 默认只读单位
      // onExpiryTap 不传 -> 日期不可点
    );
  }

  // --- 模块 3: 炊具网格 (和之前保持一致) ---
  Widget _buildCookwareGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      // gridDelegate 控制网格怎么排 (这里是一行 2 个)
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2, // 宽比高稍微大一点
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
      // 点击切换拥有的状态
      onTap: () {
        setState(() {
          item.isAvailable = !item.isAvailable;
        });
        // 显示底部的提示条 SnackBar
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
        duration: const Duration(milliseconds: 300), // 动画过渡时间
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isAvailable ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          // 如果拥有，加一个绿色的阴影
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
        // 1. 上面的小按钮：手动输入
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),

              // 🔥🔥🔥 核心修复：这里必须加一个 Row！
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 强制靠右
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

              // 🔥🔥🔥 Row 结束
            ),
          ),
        ),

        // 2. 上面的小按钮：拍照
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),

              // 🔥🔥🔥 核心修复：这里也要加 Row！
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 强制靠右
                children: [
                  FloatingActionButton.small(
                    heroTag: "btn_camera",
                    onPressed: () {
                      _toggleExpand(); // 收起菜单

                      // 🔥 跳转到 AddItemPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddItemPage(),
                        ),
                      );
                    },
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.camera_alt, color: Colors.orange),
                  ),
                ],
              ),

              // 🔥🔥🔥 Row 结束
            ),
          ),
        ),

        // 3. 大按钮 (保持不变)
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
