// lib/pages/recipes/recipe_filter_page.dart
import 'package:flutter/material.dart';

class RecipeFilterPage extends StatefulWidget {
  const RecipeFilterPage({super.key});

  @override
  State<RecipeFilterPage> createState() => _RecipeFilterPageState();
}

class _RecipeFilterPageState extends State<RecipeFilterPage> {
  // ------------ 文本输入控制器 ------------
  final _allergyController = TextEditingController();
  final _tabooController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  final _dishCountController = TextEditingController(text: '1');
  final _calorieController = TextEditingController();
  final _maxTimeController = TextEditingController();

  // ------------ 选项类状态 ------------
  final Set<String> _selectedCuisines = {};
  final Set<String> _selectedTastes = {};
  final Set<String> _selectedCookers = {};
  final Set<String> _selectedDifficulties = {}; // 支持多选

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

  static const List<String> _difficultyOptions = [
    "easy",
    "medium",
    "hard",
  ];

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

  @override
  void dispose() {
    _allergyController.dispose();
    _tabooController.dispose();
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
      ..showSnackBar(
        SnackBar(content: Text(msg)),
      );
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
    String allergyText = _allergyController.text.trim();
    if (allergyText.isEmpty) {
      final bool noAllergy = await showDialog<bool>(
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
        allergyText = "none";
        _allergyController.text = "none";
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
        "allergies": allergyText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        "avoid_ingredients": _tabooController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
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
      appBar: AppBar(
        title: const Text("Filter"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  Text(
                    "Filter your generated menus",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Set allergies, servings, dish count and other preferences.",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // ---- Allergies & Taboo ----
                  _buildSectionTitle("Allergies & Taboo ingredients"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _allergyController,
                    label: "Allergies (required)",
                    hint:
                        "e.g. peanut, shrimp (comma separated) or 'none' if no allergies",
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _tabooController,
                    label: "Taboo / avoid ingredients (optional)",
                    hint: "e.g. coriander, lamb",
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
