import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/widgets/quantity_selector.dart';
import 'package:personal_sous_chef/services/inventory_api_service.dart';
import 'package:personal_sous_chef/services/household_service.dart';
import 'package:personal_sous_chef/services/standard_library_service.dart';

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
  late double _quantity; // 🔥 改为 double 支持小数
  late String _unit;
  late DateTime _expiryDate;

  // ✅ 标准食材库数据（包含 id 和 name）
  List<Map<String, dynamic>> _standardIngredients = [];
  bool _isLoadingIngredients = true;
  int? _selectedStandardIngredientId; // 用户选择的标准食材ID

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

    // ✅ 页面加载时获取标准食材库
    _loadStandardIngredients();
  }

  /// 加载标准食材库（使用缓存服务）
  Future<void> _loadStandardIngredients() async {
    try {
      // ✅ 使用 StandardLibraryService，优先使用缓存
      final ingredients = await StandardLibraryService.getStandardIngredients();
      if (mounted) {
        setState(() {
          _standardIngredients = ingredients;
          _isLoadingIngredients = false;
          // 如果当前食材名已存在，尝试匹配对应的ID
          if (widget.ingredient.name.isNotEmpty) {
            final matched = ingredients.firstWhere(
              (ing) => ing['name'] == widget.ingredient.name,
              orElse: () => {},
            );
            if (matched.isNotEmpty && matched['id'] != null) {
              _selectedStandardIngredientId = matched['id'] as int;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingIngredients = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load standard ingredients: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();

    super.dispose();
  }

  // 日期选择器逻辑
  // 日期选择器逻辑
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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

    // 🔥 优化：先检查 mounted，如果不在线直接返回，干脆利落
    if (!mounted) return;

    // 🔥 业务逻辑：此时已经很安全了，不需要再写 && mounted
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
              child: _isLoadingIngredients
                  ? const Center(child: CircularProgressIndicator())
                  : Autocomplete<String>(
                      // 初始值
                      initialValue: TextEditingValue(
                        text: widget.ingredient.name,
                      ),

                      // ✅ 搜索逻辑：从标准食材库中筛选
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return _standardIngredients
                            .where((ingredient) {
                              final name = ingredient['name'] as String? ?? '';
                              return name.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            })
                            .map((ingredient) => ingredient['name'] as String);
                      },

                      // ✅ 选中回调：记录选中的标准食材ID
                      onSelected: (String selection) {
                        _nameController.text = selection; // 更新控制器
                        // 查找对应的标准食材ID
                        final matched = _standardIngredients.firstWhere(
                          (ing) => ing['name'] == selection,
                          orElse: () => {},
                        );
                        if (matched.isNotEmpty && matched['id'] != null) {
                          setState(() {
                            _selectedStandardIngredientId =
                                matched['id'] as int;
                          });
                        }
                        print(
                          '用户选择了: $selection (ID: $_selectedStandardIngredientId)',
                        );
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
                  unitOptions: const [
                    'pcs',
                    'g',
                    'kg',
                    'ml',
                    'L',
                    'blocks',
                    'box',
                    'bag',
                  ],

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
                onPressed: () async {
                  if (_quantity <= 0) _quantity = 1.0; // 🔥 改为 <= 0，并设置为 1.0

                  widget.ingredient.quantity = _quantity;
                  widget.ingredient.unit = _unit;
                  widget.ingredient.expiryDate = _expiryDate;
                  // 🔥 确保这里保存的是 _nameController.text
                  // 因为我们在 Autocomplete 里做了偷梁换柱 (_nameController = controller)
                  // 所以这里直接读 _nameController.text 就是用户最终输入的内容
                  widget.ingredient.name = _nameController.text;

                  // Save to API
                  try {
                    if (widget.isNew) {
                      // ✅ 添加新食材：使用已选择的标准食材ID
                      if (_selectedStandardIngredientId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a standard ingredient from the list.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }

                      // ✅ 获取 householdId
                      final householdId =
                          await HouseholdService.getHouseholdId();
                      if (householdId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Household not found. Please register or login first.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }

                      // ✅ 添加库存（使用标准食材ID和householdId）
                      final result = await InventoryApiService.addInventory(
                        name: widget.ingredient.name,
                        quantity: widget.ingredient.quantity.toDouble(),
                        unit: widget.ingredient.unit,
                        expiryDate: widget.ingredient.expiryDate
                            .toIso8601String()
                            .split('T')[0],
                        standardIngredientId: _selectedStandardIngredientId,
                        householdId: householdId.toString(),
                      );
                      widget.ingredient.inventoryId = result['id']?.toString();
                    } else if (widget.ingredient.inventoryId != null) {
                      // ✅ 更新现有食材（不需要 standardIngredientId，因为已经存在）
                      final householdId =
                          await HouseholdService.getHouseholdId();
                      if (householdId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Household not found. Please register or login first.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }
                      await InventoryApiService.updateInventory(
                        inventoryId: widget.ingredient.inventoryId!,
                        quantity: widget.ingredient.quantity.toDouble(),
                        unit: widget.ingredient.unit,
                        expiryDate: widget.ingredient.expiryDate
                            .toIso8601String()
                            .split('T')[0],
                        householdId: householdId.toString(),
                        standardIngredientId:
                            widget.ingredient.standardIngredientId,
                      );
                    }
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  }
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
}
