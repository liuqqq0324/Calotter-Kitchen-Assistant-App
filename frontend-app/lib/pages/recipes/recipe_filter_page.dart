// lib/pages/recipes/recipe_filter_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/services/recipe_api_service.dart';
import 'package:personal_sous_chef/services/household_service.dart';
import 'package:personal_sous_chef/services/standard_library_service.dart';

class RecipeFilterPage extends StatefulWidget {
  const RecipeFilterPage({super.key});

  @override
  State<RecipeFilterPage> createState() => _RecipeFilterPageState();
}

class _RecipeFilterPageState extends State<RecipeFilterPage> {
  // ------------ 文本输入控制器 ------------
  TextEditingController _allergyController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  final _dishCountController = TextEditingController(text: '1');
  final _calorieController = TextEditingController();
  final _maxTimeController = TextEditingController();

  // ------------ 选项类状态 ------------
  Set<String> _selectedCuisines = {};
  Set<String> _selectedTastes = {};
  Set<String> _selectedCookers = {};
  Set<String> _selectedDifficulties = {}; // 支持多选
  Set<String> _selectedAllergies = {}; // ✅ 已选择的过敏原列表
  Set<String> _selectedTaboos = {}; // ✅ 已选择的禁忌标签（标准库）
  Set<String> _selectedAvoidIngredients = {}; // ✅ 已选择的避免食材（标准库）

  // ✅ 标准过敏源库数据（包含 id 和 name）
  List<Map<String, dynamic>> _standardAllergens = [];
  bool _isLoadingAllergens = true;

  // ✅ 标准食材库（用于 avoid ingredients）
  List<Map<String, dynamic>> _standardIngredients = [];
  bool _isLoadingIngredients = true;

  // 可选值列表（和你 prompt 里面保持一致）
  static const List<String> _cuisineOptions = [
    "chinese",
    "japanese",
    "korean",
    "south_east_asian",
    "indian",
    "western",
    "italian",
    "mediterranean",
    "mexican",
    "middle_eastern",
    "fusion",
  ];

  static const List<String> _tasteOptions = [
    "light",
    "rich",
    "spicy",
    "sweet",
    "sour",
    "salty",
    "umami",
  ];

  static const List<String> _difficultyOptions = ["easy", "medium", "hard"];

  static const List<String> _cookerOptions = [
    "stove",
    "oven",
    "microwave",
    "air_fryer",
    "rice_cooker",
    "pressure_cooker",
    "steamer",
    "slow_cooker",
    "blender",
  ];

  bool _isLoadingDefaults = false;

  @override
  void initState() {
    super.initState();
    _allergyController = TextEditingController();
    _loadDefaultFilter();
    _loadStandardAllergens(); // ✅ 加载标准过敏源库
    _loadStandardIngredients(); // ✅ 加载标准食材库（avoid ingredients）
  }

  /// ✅ 加载标准过敏源库（使用缓存服务）
  Future<void> _loadStandardAllergens() async {
    try {
      final allergens = await StandardLibraryService.getStandardAllergens();
      if (mounted) {
        setState(() {
          _standardAllergens = allergens;
          _isLoadingAllergens = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAllergens = false;
        });
        print('[FilterPage] Failed to load standard allergens: $e');
        // 不阻止用户使用，只是记录错误
      }
    }
  }

  /// ✅ 加载标准食材库（使用缓存服务）
  Future<void> _loadStandardIngredients() async {
    try {
      final ingredients = await StandardLibraryService.getStandardIngredients();
      if (mounted) {
        setState(() {
          _standardIngredients = ingredients;
          _isLoadingIngredients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingIngredients = false;
        });
        print('[FilterPage] Failed to load standard ingredients: $e');
      }
    }
  }

  /// 加载默认 Filter 并填充表单
  Future<void> _loadDefaultFilter() async {
    setState(() => _isLoadingDefaults = true);
    try {
      final householdId = await HouseholdService.getHouseholdId();
      if (householdId == null) {
        print(
          '[FilterPage] Failed to get householdId, skipping default filter',
        );
        return;
      }

      final defaultFilter = await RecipeApiService.getDefaultFilter(
        householdId: householdId,
      );

      if (mounted) {
        setState(() {
          // 填充 servings
          final servings = defaultFilter['servings'];
          if (servings != null) {
            _servingsController.text = servings.toString();
          }

          // 填充 dish_count
          final dishCount = defaultFilter['dish_count'];
          if (dishCount != null) {
            _dishCountController.text = dishCount.toString();
          }

          // 填充 calorie_target
          final calorieTarget = defaultFilter['calorie_target'];
          if (calorieTarget != null) {
            _calorieController.text = calorieTarget.toString();
          }

          // 填充 max_cooking_time_min
          final maxTime = defaultFilter['max_cooking_time_min'];
          if (maxTime != null) {
            _maxTimeController.text = maxTime.toString();
          }

          // 填充 diet_preferences
          final dietPrefs =
              defaultFilter['diet_preferences'] as Map<String, dynamic>? ?? {};
          final allergies = (dietPrefs['allergies'] as List?) ?? [];
          if (allergies.isNotEmpty) {
            // ✅ 将过敏原列表存储到Set中，而不是直接显示在TextField中
            _selectedAllergies = Set<String>.from(allergies);
            // 如果只有一个且是"none"，显示在TextField中
            if (allergies.length == 1 && allergies[0] == 'none') {
              _allergyController.text = 'none';
            } else {
              _allergyController.text = ''; // 清空，使用Chip显示
            }
          }

          final avoidIngredients =
              (dietPrefs['avoid_ingredients'] as List?) ?? [];
          if (avoidIngredients.isNotEmpty) {
            _selectedAvoidIngredients = Set<String>.from(avoidIngredients);
          }

          final taboos = (dietPrefs['taboos'] as List?) ?? [];
          if (taboos.isNotEmpty) {
            _selectedTaboos = Set<String>.from(taboos);
          }

          final cuisines = (dietPrefs['cuisine_preferences'] as List?) ?? [];
          _selectedCuisines = Set<String>.from(cuisines);

          final tastes = (dietPrefs['taste_preferences'] as List?) ?? [];
          _selectedTastes = Set<String>.from(tastes);

          // 填充 difficulty_target
          final difficulty = defaultFilter['difficulty_target'];
          if (difficulty != null) {
            if (difficulty is List) {
              _selectedDifficulties = Set<String>.from(difficulty);
            } else {
              _selectedDifficulties = {difficulty.toString()};
            }
          }

          // 填充 cookers
          final cookers = (defaultFilter['cookers'] as List?) ?? [];
          _selectedCookers = Set<String>.from(cookers);
        });
      }
    } catch (e) {
      print('[FilterPage] Failed to load default filter: $e');
      // 不阻止用户使用，只是记录错误
    } finally {
      if (mounted) {
        setState(() => _isLoadingDefaults = false);
      }
    }
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _servingsController.dispose();
    _dishCountController.dispose();
    _calorieController.dispose();
    _maxTimeController.dispose();
    super.dispose();
  }

  // ------------ 简单的数字解析 + 校验 ------------
  int? _parsePositiveInt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = int.tryParse(trimmed);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onConfirmPressed() async {
    // 1. 解析必填字段：servings, dish_count
    final servings = _parsePositiveInt(_servingsController.text);
    final dishCount = _parsePositiveInt(_dishCountController.text);

    if (servings == null || servings > 10) {
      _showSnack("Please enter a valid number of servings (1–10).");
      return;
    }

    if (dishCount == null || dishCount > 6) {
      _showSnack("Please enter a valid dish count (1–6).");
      return;
    }

    // 2. 过敏必填逻辑
    // ✅ 优先使用已选择的过敏原列表，如果没有则检查TextField输入
    List<String> allergyList;
    if (_selectedAllergies.isNotEmpty) {
      allergyList = _selectedAllergies.toList();
    } else {
      String allergyText = _allergyController.text.trim();
      if (allergyText.isEmpty) {
        final bool noAllergy =
            await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("No allergies?"),
                content: const Text(
                  "You left the allergy field empty.\n\n"
                  "If you truly have no allergies, we will set it to 'none'.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Go back"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("I have no allergies"),
                  ),
                ],
              ),
            ) ??
            false;

        if (!noAllergy) {
          // 用户选择返回，重新填写
          return;
        } else {
          allergyList = ["none"];
        }
      } else {
        // ✅ 验证输入的过敏原是否在标准库中
        if (allergyText.toLowerCase() != 'none') {
          final isStandardAllergen = _standardAllergens.any(
            (allergen) => allergen['name'].toLowerCase() == allergyText.toLowerCase(),
          );
          if (!isStandardAllergen) {
            _showSnack(
              'Allergy "$allergyText" not found in standard library. Please select from suggestions.',
            );
            return;
          }
        }
        allergyList = [allergyText];
      }
    }

    // 3. 解析其它可选数字字段
    final calorieTarget = _parsePositiveInt(_calorieController.text);
    final maxTime = _parsePositiveInt(_maxTimeController.text);

    // 4. 构造一个简单的 filter 对象（暂时用 Map）
    final filter = {
      "servings": servings,
      "dish_count": dishCount,
      "calorie_target": calorieTarget, // 这里先用一个值，后端再转成区间
      "max_cooking_time_min": maxTime,
      "diet_preferences": {
        "allergies": allergyList, // ✅ 使用验证后的过敏原列表
        "avoid_ingredients": _selectedAvoidIngredients.toList(),
        "taboos": _selectedTaboos.toList(),
        "cuisine_preferences": _selectedCuisines.toList(),
        "taste_preferences": _selectedTastes.toList(),
      },
      "difficulty_target": _selectedDifficulties.toList(),
      "cookers": _selectedCookers.toList(),
    };

    // 现在我们先简单地 pop 出去，把 filter 回传给上一个页面
    Navigator.pop(context, filter);
  }

  // ------------ UI ------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Filter")),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoadingDefaults
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  Text(
                    "Filter your generated menus",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Set allergies, servings, dish count and other preferences.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Allergies & Taboo ----
                  _buildSectionTitle("Allergies, taboos & avoid ingredients"),
                  const SizedBox(height: 8),
                  // ✅ 显示已选择的过敏原Chip
                  if (_selectedAllergies.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedAllergies.map((allergy) {
                        return Chip(
                          label: Text(allergy),
                          onDeleted: () {
                            setState(() {
                              _selectedAllergies.remove(allergy);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                  if (_selectedAllergies.isNotEmpty) const SizedBox(height: 8),
                  // ✅ 使用Autocomplete限制用户只能选择标准过敏原
                  _isLoadingAllergens
                      ? const Center(child: CircularProgressIndicator())
                      : Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _standardAllergens
                                .where((allergen) {
                                  final name = allergen['name'] as String? ?? '';
                                  return name.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      );
                                })
                                .map((allergen) => allergen['name'] as String);
                          },
                          onSelected: (String selection) {
                            // ✅ 用户选择后，添加到已选择列表
                            if (selection.toLowerCase() == 'none') {
                              setState(() {
                                _selectedAllergies.clear();
                                _selectedAllergies.add('none');
                                _allergyController.text = 'none';
                              });
                            } else {
                              setState(() {
                                _selectedAllergies.remove('none'); // 移除"none"如果存在
                                if (!_selectedAllergies.contains(selection)) {
                                  _selectedAllergies.add(selection);
                                }
                                _allergyController.text = ''; // 清空输入框
                              });
                            }
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onEditingComplete) {
                            // ✅ 使用Autocomplete提供的controller，同步到_allergyController
                            // 注意：这里需要同步controller的状态
                            if (_allergyController.text != controller.text) {
                              controller.text = _allergyController.text;
                            }
                            _allergyController = controller;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                labelText: "Allergies (required)",
                                hintText:
                                    "Search and select allergies or type 'none'",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                suffixIcon: const Icon(Icons.search),
                              ),
                              onSubmitted: (value) {
                                // ✅ 手动提交时验证
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) return;
                                
                                if (trimmed.toLowerCase() == 'none') {
                                  setState(() {
                                    _selectedAllergies.clear();
                                    _selectedAllergies.add('none');
                                    controller.text = 'none';
                                  });
                                } else {
                                  // ✅ 验证是否在标准库中
                                  final matchedAllergen = _standardAllergens.firstWhere(
                                    (allergen) =>
                                        allergen['name'].toLowerCase() ==
                                        trimmed.toLowerCase(),
                                    orElse: () => {},
                                  );
                                  if (matchedAllergen.isNotEmpty) {
                                    final allergenName = matchedAllergen['name'] as String;
                                    setState(() {
                                      _selectedAllergies.remove('none');
                                      if (!_selectedAllergies.contains(allergenName)) {
                                        _selectedAllergies.add(allergenName);
                                      }
                                      controller.text = '';
                                    });
                                  } else {
                                    _showSnack(
                                      'Allergy "$trimmed" not found in standard library. Please select from suggestions.',
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 12),
                  // ✅ Taboos (standard library)
                  _buildSubTitle("Taboos (standard tags, optional)"),
                  const SizedBox(height: 6),
                  if (_selectedTaboos.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedTaboos.map((t) {
                        return Chip(
                          label: Text(t),
                          onDeleted: () {
                            setState(() {
                              _selectedTaboos.remove(t);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                  if (_selectedTaboos.isNotEmpty) const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim().toLowerCase();
                      if (q.isEmpty) return const Iterable<String>.empty();
                      // Use standard taboos list (value field)
                      return StandardLibraryService.getStandardTaboos()
                          .map((e) => e['value'] ?? '')
                          .where((v) => v.isNotEmpty)
                          .where((v) => v.toLowerCase().contains(q))
                          .take(20);
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _selectedTaboos.add(selection);
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: InputDecoration(
                          labelText: "Add taboo tag",
                          hintText: "Type e.g. veg → vegetarian",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          suffixIcon: const Icon(Icons.search),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  // ✅ Avoid ingredients (standard ingredient library)
                  _buildSubTitle("Avoid ingredients (standard library, optional)"),
                  const SizedBox(height: 6),
                  if (_selectedAvoidIngredients.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedAvoidIngredients.map((ing) {
                        return Chip(
                          label: Text(ing),
                          onDeleted: () {
                            setState(() {
                              _selectedAvoidIngredients.remove(ing);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                  if (_selectedAvoidIngredients.isNotEmpty) const SizedBox(height: 8),
                  _isLoadingIngredients
                      ? const Center(child: CircularProgressIndicator())
                      : Autocomplete<String>(
                          optionsBuilder: (TextEditingValue tev) {
                            final q = tev.text.trim().toLowerCase();
                            if (q.isEmpty) return const Iterable<String>.empty();
                            return _standardIngredients
                                .map((e) => e['name']?.toString() ?? '')
                                .where((name) => name.isNotEmpty)
                                .where((name) => name.toLowerCase().contains(q))
                                .take(30);
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedAvoidIngredients.add(selection);
                            });
                          },
                          fieldViewBuilder:
                              (context, controller, focusNode, onEditingComplete) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                labelText: "Add avoid ingredient",
                                hintText: "Type e.g. beef / broccoli",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                suffixIcon: const Icon(Icons.search),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 24),

                  // ---- Servings & Dish count ----
                  _buildSectionTitle("People & dishes"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _servingsController,
                          label: "Servings (required)",
                          hint: "1–10",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _dishCountController,
                          label: "Dish count (required)",
                          hint: "1–6",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---- Calories & time & difficulty ----
                  _buildSectionTitle("Calories & cooking time"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _calorieController,
                    label: "Target calories per person (optional)",
                    hint: "e.g. 600 (approx.)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _maxTimeController,
                    label: "Max cooking time per dish (min, optional)",
                    hint: "e.g. 40",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildSubTitle("Difficulty (optional)"),
                  Wrap(
                    spacing: 8,
                    children: _difficultyOptions.map((d) {
                      final selected = _selectedDifficulties.contains(d);
                      return FilterChip(
                        label: Text(d),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedDifficulties.add(d);
                            } else {
                              _selectedDifficulties.remove(d);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---- Cuisine preferences ----
                  _buildSectionTitle("Cuisine preferences (optional)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _cuisineOptions.map((c) {
                      final selected = _selectedCuisines.contains(c);
                      return FilterChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedCuisines.add(c);
                            } else {
                              _selectedCuisines.remove(c);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---- Taste preferences ----
                  _buildSectionTitle("Taste preferences (optional)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tasteOptions.map((t) {
                      final selected = _selectedTastes.contains(t);
                      return FilterChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedTastes.add(t);
                            } else {
                              _selectedTastes.remove(t);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---- Cookers ----
                  _buildSectionTitle("Cookers / equipment (optional)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _cookerOptions.map((c) {
                      final selected = _selectedCookers.contains(c);
                      return FilterChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedCookers.add(c);
                            } else {
                              _selectedCookers.remove(c);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 底部 Confirm 按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onConfirmPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Confirm filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------ 小组件：标题 & 输入框 ------------
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
