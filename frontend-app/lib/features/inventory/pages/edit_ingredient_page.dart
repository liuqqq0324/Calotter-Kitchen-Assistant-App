import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/config/ingredient_icon_config.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/forms/quantity_selector.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_button.dart';
import 'package:personal_sous_chef/services/api/inventory_api_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/services/business/standard_library_service.dart';

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
  String? _matchedStandardName; // 匹配到的标准食材名称（用于显示对应图标）

  // ✅ 允许的单位列表（根据选中的标准食材动态加载）
  List<String> _allowedUnits = ['g', 'pcs', 'ml']; // 默认单位列表
  bool _isLoadingUnits = false;

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

    // ✅ 如果是编辑模式，尝试加载当前食材的允许单位
    if (!widget.isNew && widget.ingredient.standardIngredientId != null) {
      _loadAllowedUnits(widget.ingredient.standardIngredientId!);
    }

    // ✅ 监听食材名称变化，自动从本地标准食材库查找并更新可用单位
    _nameController.addListener(_onNameChanged);
  }

  /// ✅ 加载允许的单位列表并规范化单位
  Future<void> _loadAllowedUnits(int standardIngredientId) async {
    if (_isLoadingUnits) return; // 防止重复加载

    setState(() {
      _isLoadingUnits = true;
    });

    try {
      // 1. 获取标准食材详情（包含 primaryUnit）
      // ✅ 修复：将名称中的空格替换回连字符，以匹配数据库中的格式
      final normalizedName = widget.ingredient.name.replaceAll(' ', '-');
      final standardIngredient =
          await InventoryApiService.searchStandardIngredients(
            name: normalizedName,
            fuzzy: false,
          );

      // 2. 获取允许的单位列表（primaryUnit 和 secondaryUnit）
      final allowedUnits = await InventoryApiService.getAllowedUnits(
        standardIngredientId,
      );

      // 3. 提取 primaryUnit（主单位，优先使用）
      String? primaryUnit;
      if (standardIngredient is Map<String, dynamic>) {
        primaryUnit = standardIngredient['primaryUnit'] as String?;
      }

      if (mounted) {
        setState(() {
          _allowedUnits = allowedUnits.isNotEmpty
              ? allowedUnits
              : ['g', 'pcs', 'ml'];
          _isLoadingUnits = false;

          // ✅ 规范化单位：优先使用 primaryUnit，如果不存在则使用第一个允许的单位
          if (primaryUnit != null && _allowedUnits.contains(primaryUnit)) {
            // 如果是新食材或当前单位不在允许列表中，使用 primaryUnit
            if (widget.isNew || !_allowedUnits.contains(_unit)) {
              _unit = primaryUnit;
            }
          } else if (!_allowedUnits.contains(_unit)) {
            // 如果 primaryUnit 不可用，使用第一个允许的单位
            _unit = _allowedUnits.isNotEmpty ? _allowedUnits[0] : 'g';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
        });
        // 加载失败时使用默认单位列表
        _allowedUnits = ['g', 'pcs', 'ml'];
      }
    }
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
        });

        // ✅ 如果当前食材名已存在，触发单位更新（从本地数据查找）
        if (widget.ingredient.name.isNotEmpty) {
          _onNameChanged();
        }
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

  /// ✅ 监听食材名称变化，从本地标准食材库查找并更新可用单位
  void _onNameChanged() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      // 如果名称为空，恢复默认单位列表和图标
      setState(() {
        _allowedUnits = ['g', 'pcs', 'ml'];
        _selectedStandardIngredientId = null;
        _matchedStandardName = null;
      });
      return;
    }

    // 在本地标准食材库中查找完全匹配的食材
    // ✅ 修复：将名称中的空格替换为连字符，以匹配数据库中的格式
    // 支持用户输入 "Bok Choy" 或 "Bok-Choy" 都能匹配到数据库中的 "Bok-Choy"
    final normalizedName = name.replaceAll(' ', '-');
    final matched = _standardIngredients.firstWhere((ing) {
      final ingName = ing['name'] as String?;
      if (ingName == null) return false;
      // 同时支持空格和连字符的匹配
      final normalizedIngName = ingName.replaceAll(' ', '-');
      return normalizedIngName.toLowerCase().trim() == normalizedName.toLowerCase().trim();
    }, orElse: () => {});

    if (matched.isNotEmpty && matched['id'] != null) {
      final standardIngredientId = matched['id'] as int;
      final standardName = matched['name'] as String?;
      final primaryUnit = matched['primaryUnit'] as String?;
      final secondaryUnit = matched['secondaryUnit'] as String?;

      // 构建允许的单位列表（从本地数据提取）
      List<String> allowedUnits = [];
      if (primaryUnit != null && primaryUnit.isNotEmpty) {
        allowedUnits.add(primaryUnit);
      }
      if (secondaryUnit != null &&
          secondaryUnit.isNotEmpty &&
          secondaryUnit != primaryUnit) {
        allowedUnits.add(secondaryUnit);
      }

      // 如果没有找到单位信息，保持默认列表
      if (allowedUnits.isEmpty) {
        allowedUnits = ['g', 'pcs', 'ml'];
      }

      setState(() {
        _selectedStandardIngredientId = standardIngredientId;
        _matchedStandardName = standardName;
        _allowedUnits = allowedUnits;

        // 如果是新食材或当前单位不在允许列表中，自动切换为主单位
        // 编辑模式下，如果单位仍然有效，保持不变
        if (widget.isNew || !_allowedUnits.contains(_unit)) {
          _unit = allowedUnits.first;
        }
      });
    } else {
      // 没有找到匹配的食材，恢复默认单位列表和图标
      setState(() {
        _allowedUnits = ['g', 'pcs', 'ml'];
        _selectedStandardIngredientId = null;
        _matchedStandardName = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _quantityController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  /// 根据匹配到的标准食材名称显示图标，无匹配时用 imagePlaceholder（资源路径或 emoji）
  Widget _buildIngredientIcon() {
    final path = getIngredientIconPath(_matchedStandardName) ??
        getIngredientIconPath(_matchedStandardName?.replaceAll(' ', '-'));
    if (path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _iconFallback(),
        ),
      );
    }
    return _iconFallback();
  }

  Widget _iconFallback() {
    final ph = widget.ingredient.imagePlaceholder;
    if (ph.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          ph,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(ph, style: const TextStyle(fontSize: 24)),
        ),
      );
    }
    return Text(ph, style: const TextStyle(fontSize: 60));
  }

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
      backgroundColor: Colors.transparent,
      // 顶部导航栏
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            // 1. 大图片容器：使用手绘纸张背景（sketch_paper_transparent.png），匹配标准食材时显示对应图标，否则 emoji 占位
            Container(
              width: 152,
              height: 152,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                    'assets/images/sketch_paper_transparent.png',
                  ),
                  fit: BoxFit.fill,
                  centerSlice: const Rect.fromLTWH(25, 15, 360, 380),
                ),
              ),
              child: Center(
                child: _buildIngredientIcon(),
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

                      // ✅ 选中回调：记录选中的标准食材ID，并加载允许的单位列表
                      onSelected: (String selection) {
                        // 1. 更新控制器的文本（虽然 Autocomplete 会做，但我们要确保同步）
                        _nameController.text = selection;

                        // 2. 🔥 立即手动触发名称变更逻辑，强制更新单位
                        _onNameChanged();

                        // 3. 收起键盘 (可选优化)
                        FocusScope.of(context).unfocus();
                      },

                      // 自定义输入框样式 (伪装成之前的大橙色字体)
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                            // ✅ 修复点：正确处理控制器的"偷梁换柱"
                            // Autocomplete 生成了新控制器，我们必须把监听器转移过去
                            if (_nameController != controller) {
                              _nameController.removeListener(
                                _onNameChanged,
                              ); // 移除旧的
                              _nameController = controller; // 替换引用
                              _nameController.addListener(
                                _onNameChanged,
                              ); // 绑定新的
                            }

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

                  // ✅ 传入数据源：使用动态加载的允许单位列表
                  unitOptions: _allowedUnits,

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
            SketchyButton(
              text: "Done",
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
              backgroundColor: Colors.orange,
              isFullWidth: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
