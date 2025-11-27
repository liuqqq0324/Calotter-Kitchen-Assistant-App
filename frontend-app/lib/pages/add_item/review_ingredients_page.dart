import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/widgets/ingredient_card.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 用于获取单位列表

class ReviewIngredientsPage extends StatefulWidget {
  const ReviewIngredientsPage({super.key});

  @override
  State<ReviewIngredientsPage> createState() => _ReviewIngredientsPageState();
}

class _ReviewIngredientsPageState extends State<ReviewIngredientsPage> {
  // 模拟 AI 识别出的“临时数据”
  // 在真实 App 中，这应该是从上一页传过来的 List<Ingredient>
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
    Ingredient(
      name: "Carrots",
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      quantity: 4,
      unit: 'pcs',
      imagePlaceholder: '🥕',
    ),
  ];

  // 日期选择器 (复用 EditPage 的逻辑)
  Future<void> _selectDate(Ingredient item) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: item.expiryDate,
      firstDate: DateTime.now(), // Review 阶段通常是新买的，所以从今天开始
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        item.expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕底部的安全距离（避开手机的小黑条）
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Review Ingredients",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // 🔥 核心修改：不再用 Column 分层，而是用一个 ListView 把所有东西包起来
      body: ListView(
        // 列表内容
        children: [
          // 1. 顶部提示语
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Text(
              "We detected ${_detectedItems.length} ingredients. Adjust quantities or add more if needed.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ),

          const SizedBox(height: 10),

          // 2. 循环渲染食材卡片
          // 使用 ... (Spread Operator) 把列表展开塞进 children 里
          ..._detectedItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // 左右留白
              child: _buildReviewCard(item),
            );
          }),

          // 3. "Add manually" 按钮 (紧跟在卡片后面)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  print("跳转到手动添加页面");
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),

          // 4. 底部双按钮区域 (现在它是列表的一部分了！)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Add to inventory 按钮
                SizedBox(
                  width: double.infinity,
                  height: 55, // 稍微加高一点，更大气
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ingredients added to inventory!"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
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

                const SizedBox(height: 16), // 按钮间距
                // Scan again 按钮
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ), // 边框加粗一点
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

          // 🔥 5. 底部安全区垫片 (关键！)
          // 加上这个高度，保证最后一个按钮不会被手机的小黑条遮挡
          SizedBox(height: bottomPadding + 30),
        ],
      ),
    );
  }

  // --- 卡片构建方法 (复用 InventoryPage 风格，但针对 Review 优化) ---
  Widget _buildReviewCard(Ingredient item) {
    return IngredientCard(
      item: item,
      useStatusColors: false, // 关闭变色，保持页面干净
      // 传入单位列表 -> 开启下拉菜单
      unitOptions: kUnitOptions,
      onUnitChanged: (val) => setState(() => item.unit = val),

      onQuantityChanged: (val) => setState(() => item.quantity = val),

      // 传入日期点击回调 -> 开启日期修改
      onExpiryTap: () => _selectDate(item),

      // onTap 不传 -> 点击卡片本身没反应 (符合 Review 页逻辑)
    );
  }
}
