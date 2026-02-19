// lib/pages/recipes/recipe_filter_page.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/services/api/recipe_api_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/services/business/standard_library_service.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

class RecipeFilterPage extends StatefulWidget {
  final bool isBottomSheet;
  
  const RecipeFilterPage({super.key, this.isBottomSheet = false});

  @override
  State<RecipeFilterPage> createState() => _RecipeFilterPageState();
}

class _RecipeFilterPageState extends State<RecipeFilterPage> with SingleTickerProviderStateMixin {
  // Theme colors - matching main app theme
  static const Color _terracotta = Color(0xFFD68C5E); // Terracotta accent
  static const Color _deepBrown = Color(0xFF6B4F4F); // Deep brown borders
  static const Color _lightBeige = Color(0xFFFFFFF0); // 米色背景（与菜单卡片一致）
  
  // ------------ 文本输入控制器 ------------
  TextEditingController _allergyController = TextEditingController();
  // Autocomplete 的 controller 由 Autocomplete 管理生命周期；我们自己创建的才需要 dispose。
  bool _ownsAllergyController = true;
  final _servingsController = TextEditingController(text: '1');
  final _dishCountController = TextEditingController(text: '1');
  final _calorieController = TextEditingController();
  final _maxTimeController = TextEditingController();

  // ------------ 选项类状态 ------------
  Set<String> _selectedCuisines = {};
  Set<String> _selectedTastes = {};
  Set<String> _selectedDifficulties = {}; // 支持多选
  Set<String> _selectedAllergies = {}; // ✅ 已选择的过敏原列表
  Set<String> _selectedDietHabits =
      {}; // ✅ 已选择的饮食习惯标签（标准库，发送给后端时字段名为 dietHabits）
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

  bool _isLoadingDefaults = false;

  @override
  void initState() {
    super.initState();
    _allergyController = TextEditingController();
    _ownsAllergyController = true;
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

          // ✅ 兼容两种格式：dietHabits (camelCase) 和 diet_habits (snake_case)
          final dietHabits =
              (dietPrefs['dietHabits'] ?? dietPrefs['diet_habits'] as List?) ??
              [];
          if (dietHabits.isNotEmpty) {
            _selectedDietHabits = Set<String>.from(dietHabits);
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

          // ✅ cookers 和 seasonings 由后端从数据库自动获取，不再需要前端处理
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
    // ✅ 如果 controller 来自 Autocomplete，则它会自行 dispose；这里不要重复 dispose
    if (_ownsAllergyController) {
      _allergyController.dispose();
    }
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
            (allergen) =>
                allergen['name'].toLowerCase() == allergyText.toLowerCase(),
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
        "dietHabits": _selectedDietHabits.toList(),
        "cuisine_preferences": _selectedCuisines.toList(),
        "taste_preferences": _selectedTastes.toList(),
      },
      "difficulty_target": _selectedDifficulties.toList(),
      // ✅ cookers 和 seasonings 由后端从数据库自动获取，不再需要前端发送
    };

    // 现在我们先简单地 pop 出去，把 filter 回传给上一个页面
    Navigator.pop(context, filter);
  }

  // ------------ UI ------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final terracottaSelectedFill =
        Color.lerp(_lightBeige, _terracotta, 0.52)!; // deeper theme tint
    final terracottaSelectedBorder =
        Color.lerp(_terracotta, _deepBrown, 0.25)!; // deepen terracotta

    // Custom theme for consistent colors throughout the page
    final customTheme = theme.copyWith(
      chipTheme: ChipThemeData(
        backgroundColor: _lightBeige,
        selectedColor: terracottaSelectedFill,
        checkmarkColor: _deepBrown,
        deleteIconColor: _deepBrown,
        labelStyle: TextStyle(color: _deepBrown, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _deepBrown.withOpacity(0.3), width: 1.2),
        ),
      ),
      colorScheme: theme.colorScheme.copyWith(
        primary: _terracotta,
        onPrimary: Colors.white,
        secondary: _terracotta,
        secondaryContainer: terracottaSelectedFill,
        onSecondaryContainer: _deepBrown,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _deepBrown.withOpacity(0.4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _deepBrown.withOpacity(0.4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _terracotta, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );

    final contentBody = Column(
      children: [
        Expanded(
          child: _isLoadingDefaults
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: widget.isBottomSheet
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                        // ---- Allergies & Diet Habits ----
                        _buildSectionTitle(
                          "Allergies, diet habits & avoid ingredients",
                        ),
                        const SizedBox(height: 8),
                        // ✅ 显示已选择的过敏原Chip
                        if (_selectedAllergies.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedAllergies.map((allergy) {
                              return _buildSelectedValueChip(
                                context,
                                label: allergy,
                                onDeleted: () {
                                  setState(() {
                                    _selectedAllergies.remove(allergy);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (_selectedAllergies.isNotEmpty)
                          const SizedBox(height: 8),
                        // ✅ 使用Autocomplete限制用户只能选择标准过敏原
                        _isLoadingAllergens
                            ? const Center(child: CircularProgressIndicator())
                            : Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      return _standardAllergens
                                          .where((allergen) {
                                            final name =
                                                allergen['name'] as String? ??
                                                '';
                                            return name.toLowerCase().contains(
                                              textEditingValue.text
                                                  .toLowerCase(),
                                            );
                                          })
                                          .map(
                                            (allergen) =>
                                                allergen['name'] as String,
                                          );
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
                                      _selectedAllergies.remove(
                                        'none',
                                      ); // 移除"none"如果存在
                                      if (!_selectedAllergies.contains(
                                        selection,
                                      )) {
                                        _selectedAllergies.add(selection);
                                      }
                                      _allergyController.text = ''; // 清空输入框
                                    });
                                  }
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      controller,
                                      focusNode,
                                      onEditingComplete,
                                    ) {
                                      // ✅ 使用Autocomplete提供的controller，同步到_allergyController
                                      // 注意：这里需要同步controller的状态
                                      final previousText =
                                          _allergyController.text;
                                      // 如果之前是我们自己创建的 controller，这里切换到 Autocomplete 的 controller 时先释放旧的
                                      if (_ownsAllergyController &&
                                          !identical(
                                            _allergyController,
                                            controller,
                                          )) {
                                        _allergyController.dispose();
                                      }
                                      if (controller.text != previousText) {
                                        controller.text = previousText;
                                      }
                                      _allergyController = controller;
                                      _ownsAllergyController = false;
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onEditingComplete: onEditingComplete,
                                        decoration: InputDecoration(
                                          labelText: "Allergies (required)",
                                          hintText:
                                              "Search and select allergies or type 'none'",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                            final matchedAllergen =
                                                _standardAllergens.firstWhere(
                                                  (allergen) =>
                                                      allergen['name']
                                                          .toLowerCase() ==
                                                      trimmed.toLowerCase(),
                                                  orElse: () => {},
                                                );
                                            if (matchedAllergen.isNotEmpty) {
                                              final allergenName =
                                                  matchedAllergen['name']
                                                      as String;
                                              setState(() {
                                                _selectedAllergies.remove(
                                                  'none',
                                                );
                                                if (!_selectedAllergies
                                                    .contains(allergenName)) {
                                                  _selectedAllergies.add(
                                                    allergenName,
                                                  );
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
                        // ✅ Diet Habits (standard library)
                        _buildSubTitle("Diet habits (standard tags, optional)"),
                        const SizedBox(height: 6),
                        if (_selectedDietHabits.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedDietHabits.map((t) {
                              return _buildSelectedValueChip(
                                context,
                                // Format diet habit for display: remove underscores & capitalize words.
                                label: _formatDietHabitLabel(t),
                                onDeleted: () {
                                  setState(() {
                                    _selectedDietHabits.remove(t);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (_selectedDietHabits.isNotEmpty)
                          const SizedBox(height: 8),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue tev) {
                            final q = tev.text.trim().toLowerCase();
                            if (q.isEmpty)
                              return const Iterable<String>.empty();
                            // Use standard diet habits list (value field)
                            return StandardLibraryService.getStandardDietHabits()
                                .map((e) => e['value'] ?? '')
                                .where((v) => v.isNotEmpty)
                                .where((v) => v.toLowerCase().contains(q))
                                .take(20);
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedDietHabits.add(selection);
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                controller,
                                focusNode,
                                onEditingComplete,
                              ) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: InputDecoration(
                                    labelText: "Add diet habit",
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
                        _buildSubTitle(
                          "Avoid ingredients (standard library, optional)",
                        ),
                        const SizedBox(height: 6),
                        if (_selectedAvoidIngredients.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedAvoidIngredients.map((ing) {
                              return _buildSelectedValueChip(
                                context,
                                label: ing,
                                onDeleted: () {
                                  setState(() {
                                    _selectedAvoidIngredients.remove(ing);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (_selectedAvoidIngredients.isNotEmpty)
                          const SizedBox(height: 8),
                        _isLoadingIngredients
                            ? const Center(child: CircularProgressIndicator())
                            : Autocomplete<String>(
                                optionsBuilder: (TextEditingValue tev) {
                                  final q = tev.text.trim().toLowerCase();
                                  if (q.isEmpty)
                                    return const Iterable<String>.empty();
                                  return _standardIngredients
                                      .map((e) => e['name']?.toString() ?? '')
                                      .where((name) => name.isNotEmpty)
                                      .where(
                                        (name) =>
                                            name.toLowerCase().contains(q),
                                      )
                                      .take(30);
                                },
                                onSelected: (String selection) {
                                  setState(() {
                                    _selectedAvoidIngredients.add(selection);
                                  });
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      controller,
                                      focusNode,
                                      onEditingComplete,
                                    ) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onEditingComplete: onEditingComplete,
                                        decoration: InputDecoration(
                                          labelText: "Add avoid ingredient",
                                          hintText: "Type e.g. beef / broccoli",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                            return _buildThemedFilterChip(
                              // Capitalize difficulty label (e.g. "easy" -> "Easy")
                              label: _formatDietHabitLabel(d),
                              selected: selected,
                              selectedFill: terracottaSelectedFill,
                              selectedBorder: terracottaSelectedBorder,
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
                            return _buildThemedFilterChip(
                              // Capitalize cuisine label (e.g. "asian fusion" -> "Asian fusion")
                              label: _formatDietHabitLabel(c),
                              selected: selected,
                              selectedFill: terracottaSelectedFill,
                              selectedBorder: terracottaSelectedBorder,
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
                            return _buildThemedFilterChip(
                              // Capitalize taste label
                              label: _formatDietHabitLabel(t),
                              selected: selected,
                              selectedFill: terracottaSelectedFill,
                              selectedBorder: terracottaSelectedBorder,
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
                        // ✅ Cookers 和 Seasonings 由后端从数据库自动获取，已移除 UI 选择组件
                      ],
                    ),
            ),

            // 底部 Confirm 按钮
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.isBottomSheet ? 0 : 20,
                8,
                widget.isBottomSheet ? 0 : 20,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _TiltImageButton(
                assetPath: 'assets/images/confirm_filters.png',
                height: 62,
                widthFactor: 0.92,
                onTap: _onConfirmPressed,
              ),
            ),
          ],
        );

    // Apply custom theme to content
    final themedContent = Theme(
      data: customTheme,
      child: contentBody,
    );

    // Bottom sheet mode
    if (widget.isBottomSheet) {
      return Material(
        color: Colors.transparent,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Slightly enlarge all text inside the Menu Preferences sheet
            textScaler: const TextScaler.linear(1.18),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SketchyCard(
                    backgroundColor: _lightBeige,
                    borderColor: _deepBrown,
                    borderWidth: 2.5,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Menu Preferences',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _deepBrown,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: _deepBrown),
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                        Divider(height: 1, color: _deepBrown.withOpacity(0.2)),
                        const SizedBox(height: 8),
                        Expanded(child: themedContent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Regular page mode
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Menu Preferences"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(child: themedContent),
      ),
    );
  }

  // ------------ 小组件：标题 & 输入框 ------------
  Widget _buildThemedFilterChip({
    required String label,
    required bool selected,
    required Color selectedFill,
    required Color selectedBorder,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.kalam(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _deepBrown,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: _lightBeige,
      selectedColor: selectedFill,
      checkmarkColor: _deepBrown,
      side: BorderSide(
        color: selected ? selectedBorder : _deepBrown.withOpacity(0.3),
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      // We use color and border to indicate selection; no extra checkmark needed.
      showCheckmark: false,
    );
  }

  String _formatDietHabitLabel(String raw) {
    // Convert values like "low_sodium" -> "Low sodium"
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return raw;

    final words = cleaned.split(RegExp(r'\s+'));
    final formattedWords = words.map((w) {
      if (w.isEmpty) return w;
      final lower = w.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).toList();

    return formattedWords.join(' ');
  }

  Widget _buildSelectedValueChip(
    BuildContext context, {
    required String label,
    required VoidCallback onDeleted,
  }) {
    // Use the same selected fill/border tones as difficulty / cuisine / taste chips
    final fill = Color.lerp(_lightBeige, _terracotta, 0.52)!;
    final border = Color.lerp(_terracotta, _deepBrown, 0.25)!;

    return Chip(
      label: Text(
        label,
        style: GoogleFonts.kalam(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          // Match cuisine/difficulty/taste chip label color
          color: _deepBrown,
        ),
      ),
      backgroundColor: fill,
      deleteIcon: Icon(Icons.close, size: 18, color: _deepBrown),
      deleteIconColor: _deepBrown,
      onDeleted: onDeleted,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border.withOpacity(0.85), width: 1.1),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.kalam(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _deepBrown,
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.kalam(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _deepBrown.withOpacity(0.7),
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

// Tilting image button with press animation
class _TiltImageButton extends StatefulWidget {
  final String assetPath;
  final double height;
  final double widthFactor;
  final VoidCallback onTap;

  const _TiltImageButton({
    required this.assetPath,
    required this.height,
    required this.widthFactor,
    required this.onTap,
  });

  @override
  State<_TiltImageButton> createState() => _TiltImageButtonState();
}

class _TiltImageButtonState extends State<_TiltImageButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * widget.widthFactor,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(_isPressed ? -0.09 : 0.0),
            child: SizedBox(
              height: widget.height,
              child: Image.asset(
                widget.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
