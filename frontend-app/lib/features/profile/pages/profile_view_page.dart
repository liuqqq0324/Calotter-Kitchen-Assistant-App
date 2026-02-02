import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/core/config/avatar_config.dart';
import 'package:personal_sous_chef/services/business/avatar_service.dart';
import 'settings_page.dart';
// Modified by Chase: Removed separate list pages after implementing accordion UI / 由 Chase 修改：实现折叠 UI 后移除单独的列表页面导入
import '../../../services/business/standard_library_service.dart';
import '../../../data/models/user_profile.dart';

import '../../../shared/widgets/common/sketchy_card.dart';
import '../../../shared/widgets/common/sketchy_button.dart';
import '../../../shared/widgets/common/programmatic_sketchy_card.dart';
import '../../../shared/widgets/common/passport_page_view.dart';
import '../../../shared/widgets/common/washed_brush_background.dart';
import '../../../services/business/user_service.dart';
import '../../household/pages/household_manage_page.dart';

/// 胶带样式枚举
enum TapeStyle {
  standard, // 标准样式（水平线条）
  dots, // 波点样式
  stripes, // 条纹样式
}

// Modified by Chase: Changed to StatefulWidget to support refresh after edit / 由 Chase 修改：改为 StatefulWidget 以支持编辑后刷新
class ProfileViewPage extends StatefulWidget {
  final bool shouldAnimateCover; // 是否显示封面打开动画

  const ProfileViewPage({super.key, this.shouldAnimateCover = false});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _healthInfo;
  bool _isLoading = true;
  String? _selectedGoalType; // "MAINTENANCE", "LOSE_FAT", "MUSCLE_GAIN"
  bool _isSavingGoal = false;

  // 新增：用于偏好设置页面的折叠交互和数据
  String? _expandedSection; // "preferences", "diet", "allergies"
  List<Map<String, dynamic>> _standardAllergens = [];
  bool _isSavingPrefs = false;

  // 头像：默认 otter，点击可更换
  String _selectedAvatarId = AvatarConfig.defaultAvatar;

  // 兜底过敏原列表，防止 API 返回为空
  static const List<String> _fallbackAllergens = [
    'Peanut',
    'Milk',
    'Egg',
    'Soybean',
    'Wheat',
    'Seafood',
    'Tree Nut',
    'Fish',
    'Sesame',
    'Shellfish',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final id = await AvatarService.getSelectedAvatar();
    if (mounted) setState(() => _selectedAvatarId = id);
  }

  Future<void> _showAvatarPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Avatar', style: GoogleFonts.caveat(fontSize: 24)),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AvatarConfig.options.map((opt) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, opt.id),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(opt.path, fit: BoxFit.contain),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null) {
      await AvatarService.setSelectedAvatar(selected);
      if (mounted) setState(() => _selectedAvatarId = selected);
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserBriefInfo();
    if (result['success'] == true && mounted) {
      setState(() {
        _userData = result['data'];
      });
    } else {
      // Fallback to static data if API fails
    }

    // Also load lists data
    await _loadListsData();

    // Load health info
    await _loadHealthInfo();

    // 所有数据加载完成后，最后关闭 loading
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHealthInfo() async {
    final result = await UserService.getUserHealthInfo();
    if (result['success'] == true && mounted) {
      final data = result['data'];

      // 处理 goalType：确保是字符串格式
      String? goalTypeStr;
      if (data['goalType'] is String) {
        goalTypeStr = data['goalType'];
      } else if (data['goalType'] != null) {
        goalTypeStr = data['goalType'].toString();
      }

      setState(() {
        // 合并数据而不是完全替换，保留已有的营养数据（如果新数据中没有）
        if (_healthInfo != null) {
          // 保留已有的营养数据，除非新数据中有值
          _healthInfo = {
            ..._healthInfo!,
            ...data,
            // 如果新数据中的营养字段为 null，保留旧值
            if (data['dailyEnergy'] == null &&
                _healthInfo!['dailyEnergy'] != null)
              'dailyEnergy': _healthInfo!['dailyEnergy'],
            if (data['dailyProtein'] == null &&
                _healthInfo!['dailyProtein'] != null)
              'dailyProtein': _healthInfo!['dailyProtein'],
            if (data['dailyFat'] == null && _healthInfo!['dailyFat'] != null)
              'dailyFat': _healthInfo!['dailyFat'],
            if (data['dailyCarbohydrates'] == null &&
                _healthInfo!['dailyCarbohydrates'] != null)
              'dailyCarbohydrates': _healthInfo!['dailyCarbohydrates'],
            if (data['dailyFiber'] == null &&
                _healthInfo!['dailyFiber'] != null)
              'dailyFiber': _healthInfo!['dailyFiber'],
          };
        } else {
          _healthInfo = data;
        }

        // Debug: print health info to check BMI
        print('=== Health Info Debug ===');
        print('Full health info: $_healthInfo');
        print('BMI value: ${_healthInfo?['bmi']}');
        print('BMI type: ${_healthInfo?['bmi']?.runtimeType}');
        print('Goal type (raw): ${data['goalType']}');
        print('Goal type (processed): $goalTypeStr');
        print('Daily Energy: ${_healthInfo?['dailyEnergy']}');
        print('Daily Protein: ${_healthInfo?['dailyProtein']}');
        print('========================');
        // 设置当前选中的目标类型（只有在有值且与当前不同时才更新）
        if (goalTypeStr != null) {
          _selectedGoalType = goalTypeStr;
          // 确保 _healthInfo 中的 goalType 也是字符串格式
          _healthInfo!['goalType'] = goalTypeStr;
        }
      });
    } else {
      print('❌ Failed to load health info: ${result['error']}');
      // Even if API fails, ensure _healthInfo is initialized to avoid null errors
      if (mounted) {
        setState(() {
          // 如果加载失败，保留已有的数据，不要清空
          if (_healthInfo == null) {
            _healthInfo = {};
          }
        });
      }
    }
  }

  Future<void> _saveHealthGoal() async {
    if (_selectedGoalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a health goal'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    setState(() {
      _isSavingGoal = true;
    });

    final result = await UserService.createOrUpdateHealthGoal(
      goalType: _selectedGoalType!,
    );

    if (result['success'] == true) {
      final responseData = result['data'];

      // 处理 goalType：可能是字符串或枚举对象
      String? goalTypeStr;
      if (responseData['goalType'] is String) {
        goalTypeStr = responseData['goalType'];
      } else if (responseData['goalType'] != null) {
        // 如果是枚举对象，尝试获取 name 属性或转换为字符串
        goalTypeStr = responseData['goalType'].toString();
      }
      // 如果还是 null，使用当前选中的值
      goalTypeStr = goalTypeStr ?? _selectedGoalType;

      print('📥 ========== Save Goal Response ==========');
      print('   Full response data: $responseData');
      print('   Goal type (raw): ${responseData['goalType']}');
      print('   Goal type (processed): $goalTypeStr');
      print('   Nutrition targets from backend:');
      print('     Daily Calories: ${responseData['dailyCalories']}');
      print('     Protein: ${responseData['protein']}g');
      print('     Fat: ${responseData['fat']}g');
      print('     Carb: ${responseData['carb']}g');
      print('     Fiber: ${responseData['fiber']}g');
      print('===========================================');

      // 直接使用保存返回的数据更新 UI（包含最新的营养数据）
      // 使用全新的 Map 对象确保 Flutter 框架强制重绘
      final updatedHealthInfo = Map<String, dynamic>.from(_healthInfo ?? {});

      // 更新目标类型
      updatedHealthInfo['goalType'] = goalTypeStr;

      // 只有当保存返回的营养数据不为 null 时才设置，确保使用后端最新计算出的值
      if (responseData['dailyCalories'] != null) {
        updatedHealthInfo['dailyEnergy'] = responseData['dailyCalories'];
      }
      if (responseData['protein'] != null) {
        updatedHealthInfo['dailyProtein'] = responseData['protein'];
      }
      if (responseData['fat'] != null) {
        updatedHealthInfo['dailyFat'] = responseData['fat'];
      }
      if (responseData['carb'] != null) {
        updatedHealthInfo['dailyCarbohydrates'] = responseData['carb'];
      }
      if (responseData['fiber'] != null) {
        updatedHealthInfo['dailyFiber'] = responseData['fiber'];
      }

      setState(() {
        _healthInfo = updatedHealthInfo;
        _selectedGoalType = goalTypeStr;
      });

      // 重新加载完整数据（主要是为了更新 BMI，但保留营养数据）
      // 注意：由于事务延迟，可能读取到旧数据，所以我们在重新加载后再次使用保存返回的数据
      await _loadHealthInfo();

      print('📥 ========== After Reload Health Info ==========');
      print('   Goal type: ${_healthInfo?['goalType']}');
      print('   Nutrition targets from database:');
      print('     Daily Energy: ${_healthInfo?['dailyEnergy']}');
      print('     Daily Protein: ${_healthInfo?['dailyProtein']}g');
      print('     Daily Fat: ${_healthInfo?['dailyFat']}g');
      print('     Daily Carbs: ${_healthInfo?['dailyCarbohydrates']}g');
      print('     Daily Fiber: ${_healthInfo?['dailyFiber']}g');
      print('================================================');

      // 重新加载后，再次强制使用保存返回的最新营养数据（防止被后端可能的事务延迟产生的旧数据覆盖）
      if (mounted) {
        setState(() {
          _selectedGoalType = goalTypeStr;

          final finalHealthInfo = Map<String, dynamic>.from(_healthInfo ?? {});
          finalHealthInfo['goalType'] = goalTypeStr;

          if (responseData['dailyCalories'] != null) {
            finalHealthInfo['dailyEnergy'] = responseData['dailyCalories'];
          }
          if (responseData['protein'] != null) {
            finalHealthInfo['dailyProtein'] = responseData['protein'];
          }
          if (responseData['fat'] != null) {
            finalHealthInfo['dailyFat'] = responseData['fat'];
          }
          if (responseData['carb'] != null) {
            finalHealthInfo['dailyCarbohydrates'] = responseData['carb'];
          }
          if (responseData['fiber'] != null) {
            finalHealthInfo['dailyFiber'] = responseData['fiber'];
          }

          _healthInfo = finalHealthInfo;
        });
      }

      print('📥 ========== After Force Update ==========');
      print('   Final nutrition targets in UI:');
      print('     Daily Energy: ${_healthInfo?['dailyEnergy']}');
      print('     Daily Protein: ${_healthInfo?['dailyProtein']}g');
      print('     Daily Fat: ${_healthInfo?['dailyFat']}g');
      print('     Daily Carbs: ${_healthInfo?['dailyCarbohydrates']}g');
      print('     Daily Fiber: ${_healthInfo?['dailyFiber']}g');
      print('===========================================');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health goal saved successfully'),
          duration: Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save health goal'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }

    setState(() {
      _isSavingGoal = false;
    });
  }

  // 偏好数据（用于显示）
  List<String> _tastes = [];
  List<String> _cuisines = [];

  // ✅ 格式化文本：将下划线命名转换为标题格式
  // 例如：south_east_asian → South East Asian, low_sugar → Low Sugar
  String _formatToTitleCase(String text) {
    return text
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // 保存偏好设置 (Tastes & Cuisines)
  Future<void> _savePreferencesMap() async {
    setState(() => _isSavingPrefs = true);
    final result = await UserService.updateUserPreferencesMap(
      tastes: _tastes,
      cuisines: _cuisines,
    );
    setState(() => _isSavingPrefs = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved'),
          duration: Duration(milliseconds: 800),
        ),
      );
      setState(() => _expandedSection = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  // 保存饮食习惯
  Future<void> _saveDietHabits() async {
    setState(() => _isSavingPrefs = true);
    final result = await UserService.updateUserDietHabits(
      dietHabits: kCurrentUser.dietHabits,
    );
    setState(() => _isSavingPrefs = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diet habits saved'),
          duration: Duration(milliseconds: 800),
        ),
      );
      setState(() => _expandedSection = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  // 保存过敏原
  Future<void> _saveAllergies() async {
    setState(() => _isSavingPrefs = true);
    final result = await UserService.updateUserAllergies(
      allergies: kCurrentUser.allergies,
    );
    setState(() => _isSavingPrefs = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Allergies saved'),
          duration: Duration(milliseconds: 800),
        ),
      );
      setState(() => _expandedSection = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> _loadListsData() async {
    // Load preferences map (TASTE, CUISINE, DISLIKE)
    final prefsResult = await UserService.getUserPreferencesMap();
    if (prefsResult['success'] == true) {
      final data = prefsResult['data'] ?? {};
      setState(() {
        _tastes = List<String>.from(data['tastes'] ?? []);
        _cuisines = List<String>.from(data['cuisines'] ?? []);
      });
    }

    // Load diet habits
    final dietHabitsResult = await UserService.getUserDietHabits();
    if (dietHabitsResult['success'] == true && mounted) {
      final dietHabitsList = List<String>.from(
        dietHabitsResult['data']['dietHabits'] ?? [],
      );
      setState(() {
        kCurrentUser.dietHabits = dietHabitsList;
      });
    }

    // Load allergies
    final allergiesResult = await UserService.getUserAllergies();
    if (allergiesResult['success'] == true && mounted) {
      final allergiesList = List<String>.from(
        allergiesResult['data']['allergies'] ?? [],
      );
      setState(() {
        kCurrentUser.allergies = allergiesList;
      });
    }

    // Load standard allergens for editing
    try {
      final allergens = await StandardLibraryService.getStandardAllergens();
      if (mounted) {
        setState(() {
          _standardAllergens = allergens;
        });
      }
    } catch (e) {
      print('Failed to load standard allergens: $e');
    }
  }

  Widget _buildGoalTypeSelector() {
    // 三张不同长短、略微倾斜的小纸条 - 竖向排版
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Maintain - 中等长度
        _buildGoalTypeNote(
          'MAINTENANCE',
          'Maintain Health',
          rotation: 0.02, // 轻微向右倾斜
          widthFactor: 1.0, // 基准宽度
        ),
        const SizedBox(height: 12),
        // Lose - 最短
        _buildGoalTypeNote(
          'LOSE_FAT',
          'Lose Weight',
          rotation: -0.015, // 轻微向左倾斜
          widthFactor: 0.7, // 更短
        ),
        const SizedBox(height: 12),
        // Build - 最长
        _buildGoalTypeNote(
          'MUSCLE_GAIN',
          'Build Muscle',
          rotation: 0.01, // 轻微向右倾斜
          widthFactor: 1.2, // 更长
        ),
      ],
    );
  }

  Widget _buildGoalTypeNote(
    String value,
    String label, {
    double rotation = 0.0,
    double widthFactor = 1.0,
  }) {
    final isSelected = _selectedGoalType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = value;
        });
      },
      child: Transform.rotate(
        angle: rotation, // 轻微旋转，更自然
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 竖向排版时，宽度基于父容器，高度根据 widthFactor 调整
            final width = constraints.maxWidth;
            final height =
                50.0 + (widthFactor - 1.0) * 20.0; // 基础高度 50，根据 widthFactor 调整

            return Container(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // 背景：撕裂纸条效果
                  CustomPaint(
                    size: Size(width, height),
                    painter: _TornPaperNotePainter(
                      isSelected: isSelected,
                      label: label,
                      seed: value.hashCode, // 使用 value 作为种子，确保每个纸条的毛边不同
                    ),
                  ),
                  // 文字内容
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        label,
                        style: GoogleFonts.kalam(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF6B4F4F) // 选中时：深棕色文字
                              : const Color(
                                  0xFF6B4F4F,
                                ).withOpacity(0.8), // 未选中时：稍浅
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatBmi(dynamic bmi) {
    if (bmi == null) {
      return '--';
    }
    print('BMI type: ${bmi.runtimeType}, value: $bmi');

    // Handle numeric types (int, double, num)
    if (bmi is num) {
      return bmi.toStringAsFixed(1);
    }

    // Handle string types (BigDecimal may be serialized as string)
    if (bmi is String) {
      try {
        // Remove any quotes or whitespace
        final cleaned = bmi.trim().replaceAll('"', '').replaceAll("'", '');
        final bmiValue = double.parse(cleaned);
        return bmiValue.toStringAsFixed(1);
      } catch (e) {
        print('Failed to parse BMI string: $e');
        return bmi;
      }
    }

    // Try to convert any other type to double
    try {
      final bmiValue = double.parse(bmi.toString().trim());
      return bmiValue.toStringAsFixed(1);
    } catch (e) {
      print('Failed to convert BMI: $e');
      return bmi.toString();
    }
  }

  // 获取 BMI 状态文本和颜色
  Map<String, dynamic> _getBmiStatus(dynamic bmi) {
    if (bmi == null) {
      return {'status': '--', 'color': Colors.grey};
    }

    double bmiValue;
    try {
      if (bmi is num) {
        bmiValue = bmi.toDouble();
      } else if (bmi is String) {
        final cleaned = bmi.trim().replaceAll('"', '').replaceAll("'", '');
        bmiValue = double.parse(cleaned);
      } else {
        bmiValue = double.parse(bmi.toString().trim());
      }
    } catch (e) {
      return {'status': '--', 'color': Colors.grey};
    }

    if (bmiValue < 18.5) {
      return {'status': 'Underweight', 'color': Colors.blue};
    } else if (bmiValue < 25) {
      return {'status': 'Normal', 'color': Colors.green};
    } else if (bmiValue < 30) {
      return {'status': 'Overweight', 'color': Colors.orange};
    } else {
      return {'status': 'Obese', 'color': Colors.red};
    }
  }

  Widget _buildNutritionTargets() {
    final dailyEnergy = _healthInfo?['dailyEnergy'] as num?;
    final dailyProtein = _healthInfo?['dailyProtein'] as num?;
    final dailyFat = _healthInfo?['dailyFat'] as num?;
    final dailyCarbohydrates = _healthInfo?['dailyCarbohydrates'] as num?;

    // 如果没有任何营养数据，不显示（仅显示 Energy / Protein / Fat / Carbs 四个）
    if (dailyEnergy == null &&
        dailyProtein == null &&
        dailyFat == null &&
        dailyCarbohydrates == null) {
      return const SizedBox.shrink();
    }

    // 四行：Energy 靠左、Protein 靠右、Fat 靠左、Carbs 靠右；便签稍大，可部分重叠但不挡信息，一屏内可见
    final Map<String, String>? energy = dailyEnergy != null
        ? {'label': 'Energy', 'value': '${dailyEnergy.toInt()} kcal'}
        : null;
    final Map<String, String>? protein = dailyProtein != null
        ? {'label': 'Protein', 'value': '${dailyProtein.toInt()} g'}
        : null;
    final Map<String, String>? fat = dailyFat != null
        ? {'label': 'Fat', 'value': '${dailyFat.toInt()} g'}
        : null;
    final Map<String, String>? carbs = dailyCarbohydrates != null
        ? {'label': 'Carbs', 'value': '${dailyCarbohydrates.toInt()} g'}
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Daily Nutrition Targets',
          style: GoogleFonts.kalam(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B4F4F),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            // 左右间距拉大，便签宽度限制在各自半区，不重叠、不挡信息
            const double horizontalPadding = 28.0;
            final contentWidth = maxWidth - horizontalPadding * 2;
            final noteWidth = (contentWidth * 0.48).clamp(
              140.0,
              220.0,
            ); // 左/右各占半区约一半，中间留空
            const double noteHeight = 168.0;
            const double rowOverlap = 92.0; // 每行下移量，稍松散

            Widget sticky(Map<String, String>? metric, int index) {
              if (metric == null) return const SizedBox.shrink();
              final useSticky1 = index.isEven;
              final asset = useSticky1
                  ? 'assets/profile_passport/Sticky1.png'
                  : 'assets/profile_passport/Sticky2.png';
              final rotation = useSticky1 ? _stickyLeftRot : _stickyRightRot;
              final tapeTop = useSticky1 ? 5.0 : -5.0;
              final tapeWidth = useSticky1 ? 42.0 : 40.0;
              return _buildStickyNote(
                label: metric['label']!,
                value: metric['value']!,
                stickyAsset: asset,
                width: noteWidth,
                height: noteHeight,
                rotation: rotation,
                tapeTop: tapeTop,
                tapeWidth: tapeWidth,
              );
            }

            final stackHeight = 3 * rowOverlap + noteHeight; // 松散布局，总高约 444

            return SizedBox(
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 第一行：Energy 靠左，留出左边距
                  Positioned(
                    left: horizontalPadding,
                    top: 0,
                    child: sticky(energy, 0),
                  ),
                  // 第二行：Protein 靠右，留出右边距
                  Positioned(
                    right: horizontalPadding,
                    top: rowOverlap,
                    child: sticky(protein, 1),
                  ),
                  // 第三行：Fat 靠左
                  Positioned(
                    left: horizontalPadding,
                    top: rowOverlap * 2,
                    child: sticky(fat, 2),
                  ),
                  // 第四行：Carbs 靠右
                  Positioned(
                    right: horizontalPadding,
                    top: rowOverlap * 3,
                    child: sticky(carbs, 3),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSummary() {
    if (_tastes.isEmpty && _cuisines.isEmpty) {
      return Text(
        'No preferences set. Tap "Edit" to add preferences.',
        style: GoogleFonts.kalam(
          fontSize: 14,
          color: const Color(
            0xFF6B4F4F,
          ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
        ).copyWith(fontStyle: FontStyle.italic),
      );
    }

    Widget chips(String label, List<String> values) {
      if (values.isEmpty) return const SizedBox.shrink();
      final show = values.take(2).toList(); // ✅ 最多显示2项
      final remaining = values.length - show.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.kalam(
              fontSize: 14, // 调大 13 -> 14
              fontWeight: FontWeight.bold,
              color: const Color(
                0xFF6B4F4F,
              ), // River Deep Brown - 与 Profile 页面一致
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...show.map(
                (v) => Chip(
                  backgroundColor: Colors.grey.shade200,
                  label: Text(
                    _formatToTitleCase(v),
                    style: GoogleFonts.kalam(
                      fontSize: 13, // 调大 12 -> 13
                      color: const Color(
                        0xFF6B4F4F,
                      ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
                    ),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              if (remaining > 0)
                Chip(
                  backgroundColor: Colors.grey.shade200,
                  label: Text(
                    '+$remaining',
                    style: GoogleFonts.kalam(
                      fontSize: 13, // 调大 12 -> 13
                      color: const Color(
                        0xFF6B4F4F,
                      ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
                    ),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chips('Tastes', _tastes),
        if (_tastes.isNotEmpty && _cuisines.isNotEmpty)
          const SizedBox(height: 12),
        chips('Cuisines', _cuisines),
      ],
    );
  }

  // ✅ 构建项目摘要（最多显示2项，超过显示+n，使用 Chip 风格）
  Widget _buildItemsSummary(List<String> items) {
    if (items.isEmpty) {
      return Text(
        'No items',
        style: GoogleFonts.kalam(
          fontSize: 12,
          color: const Color(
            0xFF6B4F4F,
          ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
        ),
      );
    }

    final show = items.take(2).toList();
    final remaining = items.length - show.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...show.map(
          (item) => Chip(
            backgroundColor: Colors.grey.shade200,
            label: Text(
              _formatToTitleCase(item),
              style: GoogleFonts.kalam(
                fontSize: 13, // 调大 12 -> 13
                color: const Color(
                  0xFF6B4F4F,
                ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
              ),
            ),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        if (remaining > 0)
          Chip(
            backgroundColor: Colors.grey.shade200,
            label: Text(
              '+$remaining',
              style: GoogleFonts.kalam(
                fontSize: 13, // 调大 12 -> 13
                color: const Color(
                  0xFF6B4F4F,
                ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
              ),
            ),
            side: BorderSide(color: Colors.grey.shade400),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.kalam(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6B4F4F), // River Deep Brown - 与 Profile 页面一致
        ),
      ),
    );
  }

  /// 便签旋转角度（弧度）：左列逆时针 -5°，右列顺时针 +5°（参考图布局）
  static const double _stickyLeftRot = -0.087; // -5°
  static const double _stickyRightRot = 0.087; // +5°

  /// 便签样式信息卡片，使用 Sticky1 或 Sticky2 作为背景，带透明胶带效果
  /// Sticky1 和 Sticky2 尺寸不同，胶带位置/大小需分开配置
  Widget _buildStickyNote({
    required String label,
    required String value,
    required String stickyAsset,
    double? width,
    double height = 128,
    double rotation = 0,
    double tapeTop = 0,
    double tapeWidth = 62,
    double tapeHeight = 16,
    double verticalOffset = 0,
    double horizontalOffset = 0,
    BoxFit imageFit = BoxFit.cover,
  }) {
    final displayValue = value.isNotEmpty ? value : 'Not set';
    final stickyContent = Container(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 便签主体（铺满整个容器）
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(stickyAsset),
                  fit: imageFit,
                  alignment: imageFit == BoxFit.contain
                      ? Alignment.topCenter
                      : Alignment.center,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.kalam(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B4F4F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayValue,
                    style: GoogleFonts.kalam(
                      fontSize: 22,
                      color: const Color(0xFF6B4F4F).withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // 2. 透明胶带：Sticky1/Sticky2 分别配置位置和尺寸
          Positioned(
            top: tapeTop,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: tapeWidth,
                height: tapeHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE0).withOpacity(0.85), // 米白色
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: const Color(0xFFE5D9C8).withOpacity(0.6), // 米白偏深描边
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _ProfileTapeTexturePainter(
                    style: TapeStyle.standard,
                    seed: 42,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Widget result = stickyContent;
    if (rotation != 0) {
      result = Transform.rotate(angle: rotation, child: result);
    }
    if (verticalOffset != 0 || horizontalOffset != 0) {
      result = Transform.translate(
        offset: Offset(horizontalOffset, verticalOffset),
        child: result,
      );
    }
    return result;
  }

  static const double _edgeIconSize = 30.0;

  List<Widget> _buildProfileEdgeIcons(double w, double h) {
    const base = 'assets/profile_passport';
    return [
      // 左侧边缘 3 个
      Positioned(
        left: -4,
        top: h * -0.02,
        child: Image.asset(
          '$base/profile_icon1.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: -4,
        top: h * 0.22,
        child: Image.asset(
          '$base/profile_icon2.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: -4,
        top: h * 0.44,
        child: Image.asset(
          '$base/profile_icon3.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      // 右侧边缘 2 个
      Positioned(
        right: -4,
        top: h * 0.02,
        child: Image.asset(
          '$base/profile_icon4.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        right: -4,
        top: h * 0.36,
        child: Image.asset(
          '$base/profile_icon5.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      // 上侧边缘 2 个
      Positioned(
        left: w * 0.18,
        top: -8,
        child: Image.asset(
          '$base/profile_icon6.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: w * 0.62,
        top: -8,
        child: Image.asset(
          '$base/profile_icon1.png',
          width: _edgeIconSize,
          height: _edgeIconSize,
          fit: BoxFit.contain,
        ),
      ),
    ];
  }

  /// 创建带胶带效果的手绘风格卡片
  Widget _buildTapedCard({
    required Widget child,
    double? width,
    double rotation = 0.0, // 卡片旋转角度（弧度）
    TapeStyle tapeStyle = TapeStyle.standard, // 胶带样式
  }) {
    return Transform.rotate(
      angle: rotation, // 微小随机旋转
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // 允许胶带超出卡片边界
        children: [
          // 1. 背景层：手绘纸张容器
          Container(
            width: width ?? double.infinity,
            margin: const EdgeInsets.only(top: 14), // 为胶带留出空间
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFFFF0), // 米白色/奶油色
              shape: const SketchyRectBorder(
                borderWidth: 1.0,
                wobbleAmount: 2.5,
                seed: 42, // 固定种子确保一致性
              ),
              shadows: [
                // 向右下偏移、带有模糊感的淡褐色阴影
                BoxShadow(
                  color: const Color(0xFF8B7355).withOpacity(0.25), // 淡褐色
                  blurRadius: 8,
                  offset: const Offset(3, 4), // 向右下偏移
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: child,
          ),

          // 2. 胶带层：程序化胶带效果（多样化）
          _buildTape(tapeStyle: tapeStyle),
        ],
      ),
    );
  }

  /// 构建胶带（支持不同样式）
  Widget _buildTape({required TapeStyle tapeStyle}) {
    // 根据样式设置不同的参数
    double tapeAngle;
    double tapeWidth;
    int seed;

    switch (tapeStyle) {
      case TapeStyle.standard:
        tapeAngle = -0.05;
        tapeWidth = 85;
        seed = 42;
        break;
      case TapeStyle.dots:
        tapeAngle = 0.03; // 稍微向右倾斜
        tapeWidth = 75; // 稍短
        seed = 123;
        break;
      case TapeStyle.stripes:
        tapeAngle = -0.08; // 稍微向左倾斜
        tapeWidth = 95; // 稍长
        seed = 456;
        break;
    }

    return Positioned(
      top: 4, // 胶带位置稍微在卡片上方
      child: Transform.rotate(
        angle: tapeAngle,
        child: Container(
          width: tapeWidth,
          height: 18,
          decoration: BoxDecoration(
            // 半透明黄白色胶带颜色
            color: const Color(0xFFFFF8DC).withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
            // 添加细微边框使其更像胶带
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 0.5,
            ),
            // 添加细微阴影使胶带突出
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          // 根据样式添加不同的纹理
          child: CustomPaint(
            painter: _ProfileTapeTexturePainter(style: tapeStyle, seed: seed),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionStatCard({
    required IconData icon,
    required String label,
    required String valueText,
    required Color accent,
    Color? labelColor,
    Color? valueColor,
    double rotation = 0.0,
    TapeStyle tapeStyle = TapeStyle.standard,
    double? width, // 新增：指定卡片宽度
    int zIndex = 1, // 新增：z-index，用于调整阴影深度
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.kalam(
                    fontSize: 16, // 增大字体（从12改为16）
                    fontWeight: FontWeight.bold, // 加粗（从w500改为bold）
                    color:
                        labelColor ?? const Color(0xFF6B4F4F).withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: GoogleFonts.caveat(
                    fontSize: 22, // 增大字体（从18改为22）
                    fontWeight: FontWeight.bold, // 保持加粗
                    color: valueColor ?? const Color(0xFF6B4F4F),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // 使用 Sticky2.png 作为背景图片，替代原来的胶带卡片
    // 根据 zIndex 调整阴影深度：下层浅，上层深
    final shadowOpacity =
        0.15 + (zIndex - 1) * 0.05; // zIndex 1: 0.15, 2: 0.20, 3: 0.25, 4: 0.30
    final shadowBlur =
        4.0 + (zIndex - 1) * 2.0; // zIndex 1: 4, 2: 6, 3: 8, 4: 10
    final shadowOffset = Offset(
      2.0 + (zIndex - 1) * 1.0,
      3.0 + (zIndex - 1) * 1.5,
    ); // 上层阴影更明显

    return Transform.rotate(
      angle: rotation, // 应用旋转角度
      child: Container(
        width: width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4F4F).withOpacity(shadowOpacity),
              blurRadius: shadowBlur,
              offset: shadowOffset,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景图片：Sticky2.png
            Image.asset(
              'assets/profile_passport/Sticky2.png',
              width: width,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 如果图片加载失败，使用原来的卡片样式作为后备
                return _buildTapedCard(
                  child: cardContent,
                  rotation: 0.0,
                  tapeStyle: tapeStyle,
                  width: width,
                );
              },
            ),
            // 内容层：显示图标和文字
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: cardContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get gender display text
  String _getGenderDisplay(String gender) {
    if (gender == '1') return 'Male';
    if (gender == '2') return 'Female';
    return gender.isNotEmpty ? gender : 'Unknown';
  }

  // Helper method to get user profile data
  UserProfile _getUserProfile() {
    return _userData != null
        ? UserProfile.fromApiData(_userData!)
        : kCurrentUser;
  }

  // Helper method to format birthdate
  String _formatBirthdate(String ageStr) {
    if (ageStr.isEmpty) return '';
    try {
      final birthdate = DateTime.parse(ageStr);
      return '${birthdate.year}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return ageStr;
    }
  }

  // Build Profile Page (Page 0)
  Widget _buildProfilePage(BuildContext context) {
    final user = _getUserProfile();
    final birthdate = _formatBirthdate(user.age);

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SizedBox.expand(
        child: Stack(
          children: [
            // 内容区域
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: 头像（左） + 用户名与邮箱（右），头像可点击更换
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 14,
                      top: 6,
                      bottom: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Transform.translate(
                            offset: const Offset(-12, 0),
                            child: Transform.rotate(
                              angle: -0.25, // ✅ 增大倾斜角度从 -0.15 到 -0.25
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Image.asset(
                                  AvatarConfig.getPath(_selectedAvatarId),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: WashedBrushBackground(
                            seed: 42,
                            color: const Color(0xE8F5EDE0), // 米白色
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              4,
                              12,
                              20,
                            ), // 上少下多，文字上移，总高度不变笔刷不缩短
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user.username,
                                  style: GoogleFonts.caveat(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(
                                      0xFF6B4F4F,
                                    ).withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    user.email,
                                    style: GoogleFonts.kalam(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  // 四个便签 + Settings/Invite：散乱但有秩序的贴纸布局
                  SizedBox(
                    height: 440,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = 440.0;
                        final stickyW = w * 0.46;
                        final stickyH = 140.0;
                        final settingsBtnW = (w * 0.76).clamp(0.0, 300.0);
                        final inviteBtnW = (w * 0.55).clamp(0.0, 180.0);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 木板边缘装饰图标：左侧3个、右侧2个、上侧2个
                            ..._buildProfileEdgeIcons(w, h),
                            // Birthdate
                            Positioned(
                              left: w * 0.06,
                              top: h * 0.01,
                              child: _buildStickyNote(
                                label: 'Birthdate',
                                value: birthdate,
                                stickyAsset:
                                    'assets/profile_passport/Sticky1.png',
                                width: stickyW,
                                height: stickyH,
                                rotation: 0.10,
                                tapeTop: 5,
                                tapeWidth: 42,
                              ),
                            ),
                            // Gender
                            Positioned(
                              left: w * 0.46,
                              top: h * -0.08,
                              child: _buildStickyNote(
                                label: 'Gender',
                                value: _getGenderDisplay(user.gender),
                                stickyAsset:
                                    'assets/profile_passport/Sticky2.png',
                                width: stickyW,
                                height: stickyH,
                                rotation: 0.35,
                                tapeTop: -5,
                                tapeWidth: 40,
                                imageFit: BoxFit.contain,
                              ),
                            ),
                            // Weight
                            Positioned(
                              left: w * 0.04,
                              top: h * 0.38,
                              child: _buildStickyNote(
                                label: 'Weight',
                                value: user.weight.isNotEmpty
                                    ? (user.weight.endsWith(' kg')
                                          ? user.weight
                                          : '${user.weight} kg')
                                    : '',
                                stickyAsset:
                                    'assets/profile_passport/Sticky2.png',
                                width: stickyW,
                                height: stickyH,
                                rotation: -0.12,
                                tapeTop: -5,
                                tapeWidth: 40,
                                imageFit: BoxFit.contain,
                              ),
                            ),
                            // Height
                            Positioned(
                              left: w * 0.50,
                              top: h * 0.29,
                              child: _buildStickyNote(
                                label: 'Height',
                                value: user.height.isNotEmpty
                                    ? (user.height.endsWith(' cm')
                                          ? user.height
                                          : '${user.height} cm')
                                    : '',
                                stickyAsset:
                                    'assets/profile_passport/Sticky1.png',
                                width: stickyW,
                                height: stickyH,
                                rotation: -0.32,
                                tapeTop: 5,
                                tapeWidth: 42,
                              ),
                            ),
                            // Settings
                            Positioned(
                              left: w * -0.09,
                              top: h * 0.62,
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage(),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    _loadUserData();
                                  }
                                },
                                child: Image.asset(
                                  'assets/profile_passport/Settings.png',
                                  width: settingsBtnW,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // Invite
                            Positioned(
                              left: w * 0.5,
                              top: h * 0.58,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HouseholdManagePage(),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/profile_passport/Invite.png',
                                  width: inviteBtnW,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Health Dashboard Page (Page 1) - 融合了 Health 和 Nutrition 页面
  Widget _buildHealthPage(BuildContext context) {
    final user = _getUserProfile();

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI 显示（右上角贴纸）
            Builder(
              builder: (context) {
                dynamic bmiValue = _healthInfo?['bmi'];
                if (bmiValue == null &&
                    user.height.isNotEmpty &&
                    user.weight.isNotEmpty) {
                  try {
                    final height = double.tryParse(
                      user.height.replaceAll(' cm', '').trim(),
                    );
                    final weight = double.tryParse(
                      user.weight.replaceAll(' kg', '').trim(),
                    );
                    if (height != null && weight != null && height > 0) {
                      final heightM = height / 100.0;
                      bmiValue = weight / (heightM * heightM);
                    }
                  } catch (e) {
                    // Ignore
                  }
                }

                // 使用与 Profile 页相同的便签样式展示 BMI，统一手账感
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    // 缩小 BMI 贴纸尺寸：宽度占 55%，高度略减
                    final noteWidth = (maxWidth * 0.55).clamp(
                      0.0,
                      320.0,
                    ); // 贴纸宽度占 55%
                    return Align(
                      alignment: Alignment.topRight,
                      child: _buildStickyNote(
                        label: 'BMI',
                        value: _formatBmi(bmiValue),
                        stickyAsset: 'assets/profile_passport/Sticky1.png',
                        width: noteWidth,
                        height: 120,
                        rotation: 0.10,
                        tapeTop: 5,
                        tapeWidth: 42,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // 使用毛笔笔刷背景包裹 Health Goal 区域，使其与 Profile 页用户名区域风格统一
            WashedBrushBackground(
              color: const Color(0xE8F5EDE0), // 米白色水洗笔触
              seed: 18,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Health Goal',
                    style: GoogleFonts.kalam(
                      fontSize: 20, // 与 Nutrition Targets 保持一致
                      fontWeight: FontWeight.bold,
                      color: const Color(
                        0xFF6B4F4F,
                      ), // River Deep Brown - 与 Profile 页面一致
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGoalTypeSelector(),
                  const SizedBox(height: 16),
                  Center(
                    child: _isSavingGoal
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: _saveHealthGoal,
                            child: Image.asset(
                              'assets/profile_passport/Save Goal Button.png',
                              width: 110, // 缩小到原来的 1/2
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Nutrition Page (Page 2)
  Widget _buildNutritionPage(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Nutrition'),
            if (_healthInfo != null &&
                (_healthInfo!['dailyEnergy'] != null ||
                    _healthInfo!['dailyProtein'] != null ||
                    _healthInfo!['dailyFat'] != null ||
                    _healthInfo!['dailyCarbohydrates'] != null))
              _buildNutritionTargets()
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Set a health goal to see nutrition targets',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      color: const Color(
                        0xFF6B4F4F,
                      ).withOpacity(0.8), // River Deep Brown - 与 Profile 页面一致
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build Preferences Page (Page 2)
  Widget _buildPreferencesPage(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 已删除：_sectionTitle('Preferences')，用户要求去掉左上角多出的 Preferences

            // 1. Preferences Section (Tastes & Cuisines)
            _buildExpandableSection(
              id: 'preferences',
              title: 'Preferences',
              subtitle: _buildPreferencesSummary(),
              expandedChild: _buildPreferencesEditUI(),
              onSave: _savePreferencesMap,
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),

            // 2. Diet Habits Section
            _buildExpandableSection(
              id: 'diet',
              title: 'Diet Habits',
              subtitle: _buildItemsSummary(kCurrentUser.dietHabits),
              expandedChild: _buildDietHabitsEditUI(),
              onSave: _saveDietHabits,
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, height: 1),

            // 3. Allergies Section
            _buildExpandableSection(
              id: 'allergies',
              title: 'Allergies',
              subtitle: _buildItemsSummary(kCurrentUser.allergies),
              expandedChild: _buildAllergiesEditUI(),
              onSave: _saveAllergies,
            ),
          ],
        ),
      ),
    );
  }

  // 核心辅助方法：构建可折叠的编辑区域
  Widget _buildExpandableSection({
    required String id,
    required String title,
    required Widget subtitle,
    required Widget expandedChild,
    required VoidCallback onSave,
  }) {
    final bool isExpanded = _expandedSection == id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: GoogleFonts.kalam(
              fontSize: 18, // 调大折叠栏标题从 16 到 18
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B4F4F),
            ),
          ),
          subtitle: isExpanded ? null : subtitle,
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xFF6B4F4F),
          ),
          onTap: () {
            setState(() {
              _expandedSection = isExpanded ? null : id;
            });
          },
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          SketchyCard(
            backgroundColor: Colors.white.withOpacity(0.5),
            borderColor: const Color(0xFF6B4F4F),
            borderWidth: 1.5,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                expandedChild,
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _expandedSection = null),
                      child: Text('Cancel', style: GoogleFonts.kalam()),
                    ),
                    const SizedBox(width: 8),
                    _isSavingPrefs
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: onSave,
                            child: Text(
                              'Save',
                              style: GoogleFonts.kalam(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  // 偏好设置编辑 UI
  Widget _buildPreferencesEditUI() {
    final standard = StandardLibraryService.getStandardPreferences();
    final tasteOptions = standard['tastes'] ?? [];
    final cuisineOptions = standard['cuisines'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tastes',
          style: GoogleFonts.kalam(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ), // 调大 14 -> 16
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tasteOptions.map((taste) {
            final isSelected = _tastes.contains(taste);
            return FilterChip(
              label: Text(
                _formatToTitleCase(taste),
                style: GoogleFonts.kalam(fontSize: 14), // 调大 12 -> 14
              ),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val)
                    _tastes.add(taste);
                  else
                    _tastes.remove(taste);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Cuisines',
          style: GoogleFonts.kalam(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ), // 调大 14 -> 16
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cuisineOptions.map((cuisine) {
            final isSelected = _cuisines.contains(cuisine);
            return FilterChip(
              label: Text(
                _formatToTitleCase(cuisine),
                style: GoogleFonts.kalam(fontSize: 14), // 调大 12 -> 14
              ),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val)
                    _cuisines.add(cuisine);
                  else
                    _cuisines.remove(cuisine);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 饮食习惯编辑 UI
  Widget _buildDietHabitsEditUI() {
    final options = StandardLibraryService.getStandardDietHabits();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final value = option['value']!;
        final label = option['label']!;
        final isSelected = kCurrentUser.dietHabits.contains(value);
        return FilterChip(
          label: Text(
            label,
            style: GoogleFonts.kalam(fontSize: 14),
          ), // 调大 12 -> 14
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val)
                kCurrentUser.dietHabits.add(value);
              else
                kCurrentUser.dietHabits.remove(value);
            });
          },
        );
      }).toList(),
    );
  }

  // 过敏原编辑 UI
  Widget _buildAllergiesEditUI() {
    // 优先使用 API 返回的标准库，如果为空则使用兜底列表
    final List<String> options = _standardAllergens.isNotEmpty
        ? _standardAllergens
              .map((e) => (e['name'] ?? e['label'] ?? '').toString())
              .where((name) => name.isNotEmpty)
              .toList()
        : _fallbackAllergens;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((name) {
        final isSelected = kCurrentUser.allergies.contains(name);
        return FilterChip(
          label: Text(
            _formatToTitleCase(name),
            style: GoogleFonts.kalam(fontSize: 14), // 调大 12 -> 14
          ),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                kCurrentUser.allergies.add(name);
              } else {
                kCurrentUser.allergies.remove(name);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wood_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PassportPageView(
          pages: [
            _buildProfilePage(context),
            _buildHealthPage(context),
            _buildPreferencesPage(context),
          ],
          pageLabels: const ['Profile', 'Health', 'Preferences'],
          initialPage: 0,
          shouldAnimateCover: widget.shouldAnimateCover, // 启用封面动画
        ),
      ),
    );
  }
}

/// 撕裂纸条绘制器（用于 Health Goal 选择器）
class _TornPaperNotePainter extends CustomPainter {
  final bool isSelected;
  final String label;
  final int seed;

  _TornPaperNotePainter({
    required this.isSelected,
    required this.label,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);

    // 创建撕裂边缘路径（毛边效果）
    final path = _createTornEdgePath(size, random);

    // 1. 绘制阴影
    final shadowPaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(2, 3));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. 绘制背景颜色
    final bgColor = isSelected
        ? const Color(0xFFE8F5E9) // 选中时：淡绿色便签纸
        : Colors.white.withOpacity(0.6); // 未选中时：半透明白纸

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // 3. 绘制毛边边缘线
    final edgePaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(isSelected ? 0.4 : 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, edgePaint);
  }

  Path _createTornEdgePath(Size size, math.Random random) {
    final path = Path();
    const double tearSize = 2.5; // 毛边效果大小
    const double step = 4.0; // 步长，越小越精细

    // 顶部边缘 - 毛边效果
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(x, noise.clamp(-tearSize, tearSize));
    }
    path.lineTo(size.width, 0);

    // 右侧边缘 - 毛边效果
    for (double y = step; y < size.height; y += step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(size.width + noise.clamp(-tearSize, tearSize), y);
    }
    path.lineTo(size.width, size.height);

    // 底部边缘 - 毛边效果（更明显，像从笔记本撕下来的）
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize * 1.2; // 底部毛边更明显
      path.lineTo(
        x,
        size.height + noise.clamp(-tearSize * 1.2, tearSize * 1.2),
      );
    }
    path.lineTo(0, size.height);

    // 左侧边缘 - 毛边效果
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (random.nextDouble() * 2 - 1) * tearSize;
      path.lineTo(noise.clamp(-tearSize, tearSize), y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 胶带纹理绘制器（用于 Profile Health Page）- 支持多种样式
class _ProfileTapeTexturePainter extends CustomPainter {
  final TapeStyle style;
  final int seed;

  _ProfileTapeTexturePainter({this.style = TapeStyle.standard, this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    switch (style) {
      case TapeStyle.standard:
        // 标准样式：水平线条
        for (double y = 2; y < size.height; y += 3) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case TapeStyle.dots:
        // 波点样式：小圆点
        paint.style = PaintingStyle.fill;
        for (double y = 3; y < size.height - 3; y += 4) {
          for (double x = 3; x < size.width - 3; x += 4) {
            if (random.nextDouble() > 0.3) {
              // 70% 的概率绘制点
              canvas.drawCircle(Offset(x, y), 1.0, paint);
            }
          }
        }
        break;
      case TapeStyle.stripes:
        // 条纹样式：斜向条纹
        paint.strokeWidth = 0.8;
        for (
          double offset = -size.height;
          offset < size.width + size.height;
          offset += 4
        ) {
          canvas.drawLine(
            Offset(offset, 0),
            Offset(offset + size.height, size.height),
            paint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// BMI 圆形复古印章组件
class _BmiStamp extends StatelessWidget {
  final String bmiValue;
  final String status;
  final Color statusColor;

  const _BmiStamp({
    required this.bmiValue,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // 使用棕色系
    final stampColor = const Color(0xFF6B4F4F); // 深棕色
    final lightBrown = const Color(0xFF8B6F47); // 浅棕色

    return Opacity(
      opacity: 0.75, // 半透明效果，像印在纸上
      child: Transform.rotate(
        angle: -0.08, // 轻微倾斜，更自然
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 双线边框，模拟印章效果
            border: Border.all(color: stampColor, width: 3.0),
          ),
          child: Stack(
            children: [
              // 内部圆形边框线
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: stampColor, width: 2.0),
                  ),
                ),
              ),
              // 内容
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BMI 标签 - 顶部
                    Text(
                      'BMI',
                      style: GoogleFonts.kalam(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: stampColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // BMI 数值 - 中间
                    Text(
                      bmiValue,
                      style: GoogleFonts.caveat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: stampColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 状态标签 - 底部（简化显示）
                    Text(
                      status.length > 8 ? status.substring(0, 8) : status,
                      style: GoogleFonts.kalam(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: lightBrown,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
