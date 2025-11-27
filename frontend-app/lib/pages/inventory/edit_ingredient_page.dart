import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/widgets/quantity_selector.dart';
import 'package:personal_sous_chef/data/static_data.dart';

class EditIngredientPage extends StatefulWidget {
  final Ingredient ingredient;
  final bool isNew;

  const EditIngredientPage({
    super.key,
    required this.ingredient,
    this.isNew = false,
  });

  @override
  State<EditIngredientPage> createState() => _EditIngredientPageState();
}

class _EditIngredientPageState extends State<EditIngredientPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late int _quantity;
  late String _unit;
  late DateTime _expiryDate;

  // 单位选项列表
  final List<String> _unitOptions = ['pcs', 'g', 'kg', 'ml', 'L', 'blocks'];

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _nameController = TextEditingController(text: widget.ingredient.name);
    _quantity = widget.ingredient.quantity;

    // 🔥 新增：初始化控制器，填入当前数量
    _quantityController = TextEditingController(text: _quantity.toString());

    _unit = widget.ingredient.unit;
    _expiryDate = widget.ingredient.expiryDate;
  }

  @override
  void dispose() {
    _quantityController.dispose();

    super.dispose();
  }

  // 日期选择器逻辑
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5年内
      builder: (context, child) {
        // 自定义日历颜色为橙色
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
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 顶部导航栏
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 去掉阴影
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNew ? "Add Ingredient" : "Edit Ingredient", // 🔥 动态标题
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // 标题靠左
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 1. 大图片容器
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.ingredient.imagePlaceholder,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. 物品名称 (带模糊搜索的 Autocomplete)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Autocomplete<String>(
                // 初始值
                initialValue: TextEditingValue(text: widget.ingredient.name),

                // 搜索逻辑：当用户输入时，从 kAllIngredients 里筛选
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return kAllIngredients.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },

                // 选中回调
                onSelected: (String selection) {
                  _nameController.text = selection; // 更新控制器
                  print('用户选择了: $selection');
                },

                // 自定义输入框样式 (伪装成之前的大橙色字体)
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                      // 🔥 关键：把 Autocomplete 的控制器赋值给我们自己的变量，方便最后保存
                      _nameController = controller;

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search Food...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.grey,
                          ),
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 24,
                            maxHeight: 24,
                          ),
                        ),
                      );
                    },
              ),
            ),

            const SizedBox(height: 30),

            // 3. 数量控制器
            Center(
              child: Transform.scale(
                scale: 1.5,
                child: QuantitySelector(
                  initialValue: _quantity,
                  unit: _unit,

                  // 🔥 传入宽度：因为加了箭头和下划线，我们给它宽一点的空间
                  totalWidth: 95,

                  // 🔥 传入数据源：启用下拉功能
                  unitOptions: kUnitOptions,

                  // 🔥 传入回调：当用户选了新单位时做什么
                  onUnitChanged: (newUnit) {
                    setState(() {
                      _unit = newUnit;
                    });
                  },

                  onChanged: (val) {
                    setState(() {
                      _quantity = val;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(), // 分割线
            const SizedBox(height: 20),

            // 4. 过期时间选择器
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Expire Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                // 日期显示框 (点击弹出日历)
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // 5. Done 按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_quantity < 1) _quantity = 1;

                  widget.ingredient.quantity = _quantity;
                  widget.ingredient.unit = _unit;
                  widget.ingredient.expiryDate = _expiryDate;
                  // 🔥 确保这里保存的是 _nameController.text
                  // 因为我们在 Autocomplete 里做了偷梁换柱 (_nameController = controller)
                  // 所以这里直接读 _nameController.text 就是用户最终输入的内容
                  widget.ingredient.name = _nameController.text;

                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 封装大圆按钮
  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50, // 大尺寸
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.orange, // 橙色实心
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
