import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/widgets/ingredient_card.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 🔥 必须引入，用于更新全局数据
import 'package:personal_sous_chef/pages/inventory/edit_ingredient_page.dart'; // 🔥 引入编辑页

class ReviewIngredientsPage extends StatefulWidget {
  const ReviewIngredientsPage({super.key});

  @override
  State<ReviewIngredientsPage> createState() => _ReviewIngredientsPageState();
}

class _ReviewIngredientsPageState extends State<ReviewIngredientsPage> {
  // 模拟识别结果
  final List<Ingredient> _detectedItems = [
    Ingredient(
      name: "Tomatoes",
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      quantity: 3,
      unit: 'pcs',
      imagePlaceholder: '🍅',
    ),
    Ingredient(
      name: "Eggs",
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      quantity: 6,
      unit: 'pcs',
      imagePlaceholder: '🥚',
    ),
    Ingredient(
      name: "Potatoes",
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      quantity: 2,
      unit: 'kg',
      imagePlaceholder: '🥔',
    ),
  ];

  // 🔥 状态控制：是否已完成添加
  bool _isAdded = false;

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
                unitOptions: kUnitOptions,
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
                  onPressed: () {
                    if (_detectedItems.isEmpty) return;

                    // 1. 更新全局数据
                    setState(() {
                      kInitialIngredients.addAll(_detectedItems);
                      // 2. 切换到成功视图
                      _isAdded = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
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
