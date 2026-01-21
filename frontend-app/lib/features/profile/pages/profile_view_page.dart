import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';
// Modified by Chase: Fixed import paths after moving preferences pages to ums/preferences/ folder / 由 Chase 修改：偏好页面移动到 ums/preferences/ 文件夹后修复导入路径
// Need to go up to ums/ then into preferences/ folder / 需要向上到 ums/ 然后进入 preferences/ 文件夹
import '../preferences/preferences_list_page.dart';
import '../preferences/diet_habits_list_page.dart';
import '../preferences/allergies_list_page.dart';
// Modified by Chase: Import user static data / 由 Chase 修改：导入用户静态数据
import '../../../data/models/user_profile.dart';

import '../../../shared/widgets/common/sketchy_card.dart';
import '../../../shared/widgets/common/sketchy_button.dart';
import '../../../shared/widgets/common/sketchy_border.dart';
import '../../../shared/widgets/common/passport_page_view.dart';
import '../../../shared/widgets/common/otter_approved_stamp.dart';
import '../../../services/business/user_service.dart';
import '../../household/pages/household_manage_page.dart';

// Modified by Chase: Changed to StatefulWidget to support refresh after edit / 由 Chase 修改：改为 StatefulWidget 以支持编辑后刷新
class ProfileViewPage extends StatefulWidget {
  final bool shouldAnimateCover; // 是否显示封面打开动画
  
  const ProfileViewPage({
    super.key,
    this.shouldAnimateCover = false,
  });

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _healthInfo;
  bool _isLoading = true;
  String? _selectedGoalType; // "MAINTENANCE", "LOSE_FAT", "MUSCLE_GAIN"
  bool _isSavingGoal = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserBriefInfo();
    if (result['success'] == true && mounted) {
      setState(() {
        _userData = result['data'];
        _isLoading = false;
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Also load lists data
    await _loadListsData();

    // Load health info
    await _loadHealthInfo();
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
        const SnackBar(content: Text('Please select a health goal')),
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

      // 先保存当前的 BMI（如果有）
      final currentBmi = _healthInfo?['bmi'];

      // 直接使用保存返回的数据更新 UI（包含最新的营养数据）
      setState(() {
        // 更新健康信息，使用保存返回的最新数据
        // 只有当数据不为 null 时才设置，避免覆盖为 null
        final updatedHealthInfo = <String, dynamic>{
          'goalType': goalTypeStr,
          // 保留原有的 BMI（如果有）
          if (currentBmi != null) 'bmi': currentBmi,
        };

        // 只有当保存返回的营养数据不为 null 时才设置
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

        // 合并到现有的 _healthInfo（保留已有的数据）
        _healthInfo = {...?_healthInfo, ...updatedHealthInfo};

        // 确保选中状态与保存的数据一致
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

      // 重新加载后，强制使用保存返回的最新营养数据（防止被旧数据覆盖）
      if (mounted) {
        setState(() {
          _selectedGoalType = goalTypeStr;
          if (_healthInfo != null) {
            // 确保 goalType 正确
            _healthInfo!['goalType'] = goalTypeStr;
            // 强制使用保存返回的最新营养数据（覆盖可能从数据库读取的旧数据）
            // 只有当保存返回的数据不为 null 时才更新
            if (responseData['dailyCalories'] != null) {
              _healthInfo!['dailyEnergy'] = responseData['dailyCalories'];
            }
            if (responseData['protein'] != null) {
              _healthInfo!['dailyProtein'] = responseData['protein'];
            }
            if (responseData['fat'] != null) {
              _healthInfo!['dailyFat'] = responseData['fat'];
            }
            if (responseData['carb'] != null) {
              _healthInfo!['dailyCarbohydrates'] = responseData['carb'];
            }
            if (responseData['fiber'] != null) {
              _healthInfo!['dailyFiber'] = responseData['fiber'];
            }
          }
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
        const SnackBar(content: Text('Health goal saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save health goal'),
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
  }

  Widget _buildGoalTypeSelector() {
    return Column(
      children: [
        _buildGoalTypeOption('MAINTENANCE', 'Maintain Health', Colors.green),
        const SizedBox(height: 10),
        _buildGoalTypeOption('LOSE_FAT', 'Lose Weight', Colors.orange),
        const SizedBox(height: 10),
        _buildGoalTypeOption('MUSCLE_GAIN', 'Build Muscle', Colors.blue),
      ],
    );
  }

  Widget _buildGoalTypeOption(String value, String label, Color color) {
    final isSelected = _selectedGoalType == value;
    return SketchyCard(
      // ✅ 统一风格：与 Nutrition Targets 使用同样的手绘黑色边框
      backgroundColor: isSelected ? color.withOpacity(0.10) : Colors.white,
      borderColor: Colors.black87,
      borderWidth: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () {
        setState(() {
          _selectedGoalType = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade500,
                width: 2.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.kalam(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ),
        ],
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

  Widget _buildNutritionTargets() {
    final dailyEnergy = _healthInfo?['dailyEnergy'] as num?;
    final dailyProtein = _healthInfo?['dailyProtein'] as num?;
    final dailyFat = _healthInfo?['dailyFat'] as num?;
    final dailyCarbohydrates = _healthInfo?['dailyCarbohydrates'] as num?;
    final dailyFiber = _healthInfo?['dailyFiber'] as num?;

    // 如果没有任何营养数据，不显示
    if (dailyEnergy == null &&
        dailyProtein == null &&
        dailyFat == null &&
        dailyCarbohydrates == null &&
        dailyFiber == null) {
      return const SizedBox.shrink();
    }

    final items = <Widget>[
      if (dailyEnergy != null)
        _buildNutritionStatCard(
          icon: Icons.local_fire_department,
          label: 'Energy',
          valueText: '${dailyEnergy.toInt()} kcal',
          accent: Colors.orange,
        ),
      if (dailyProtein != null)
        _buildNutritionStatCard(
          icon: Icons.fitness_center,
          label: 'Protein',
          valueText: '${dailyProtein.toInt()} g',
          accent: Colors.blue,
        ),
      if (dailyFat != null)
        _buildNutritionStatCard(
          icon: Icons.water_drop,
          label: 'Fat',
          valueText: '${dailyFat.toInt()} g',
          accent: Colors.amber,
        ),
      if (dailyCarbohydrates != null)
        _buildNutritionStatCard(
          icon: Icons.eco,
          label: 'Carbs',
          valueText: '${dailyCarbohydrates.toInt()} g',
          accent: Colors.green,
        ),
      if (dailyFiber != null)
        _buildNutritionStatCard(
          icon: Icons.agriculture,
          label: 'Fiber',
          valueText: '${dailyFiber.toInt()} g',
          accent: Colors.brown,
        ),
    ];

    return SketchyCard(
      backgroundColor: Colors.orange.shade50,
      borderColor: Colors.black87,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nutrition Targets',
            style: GoogleFonts.kalam(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // ✅ 修复：减小 childAspectRatio 以增加每个 item 的高度，避免溢出
            // childAspectRatio = width / height，值越小，高度越大
            childAspectRatio: 1.8, // 从 2.2 改为 1.8，增加高度
            children: items,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSummary() {
    if (_tastes.isEmpty && _cuisines.isEmpty) {
      return Text(
        'No preferences set. Tap "Edit" to add preferences.',
        style: GoogleFonts.kalam(
          fontSize: 14,
          color: Colors.grey[600],
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
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
                    style: GoogleFonts.kalam(fontSize: 12),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              if (remaining > 0)
                Chip(
                  backgroundColor: Colors.grey.shade200,
                  label: Text(
                    '+$remaining',
                    style: GoogleFonts.kalam(fontSize: 12),
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
        style: GoogleFonts.kalam(fontSize: 12, color: Colors.grey[600]),
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
              style: GoogleFonts.kalam(fontSize: 12),
            ),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        if (remaining > 0)
          Chip(
            backgroundColor: Colors.grey.shade200,
            label: Text('+$remaining', style: GoogleFonts.kalam(fontSize: 12)),
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
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.kalam(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'Not set',
          style: GoogleFonts.kalam(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildNutritionStatCard({
    required IconData icon,
    required String label,
    required String valueText,
    required Color accent,
  }) {
    return SketchyCard(
      backgroundColor: Colors.white,
      borderColor: Colors.black87,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(10), // ✅ 修复：减小 padding 从 12 到 10
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ✅ 修复：限制 Column 大小
              children: [
                Text(
                  label,
                  style: GoogleFonts.kalam(
                    fontSize: 11, // ✅ 修复：减小字体从 12 到 11
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 1), // ✅ 修复：减小间距从 2 到 1
                Text(
                  valueText,
                  style: GoogleFonts.kalam(
                    fontSize: 12, // ✅ 修复：减小字体从 13 到 12
                    fontWeight: FontWeight.bold,
                    color: accent,
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
  }

  // Helper method to get user profile data
  UserProfile _getUserProfile() {
    return _userData != null
        ? UserProfile.fromApiData(_userData!)
        : kCurrentUser;
  }

  // Helper method to calculate age and birthdate
  Map<String, String> _calculateAgeAndBirthdate(String ageStr) {
    String displayAge = '';
    String displayBirthdate = '';
    if (ageStr.isNotEmpty) {
      try {
        final birthdate = DateTime.parse(ageStr);
        final now = DateTime.now();
        final age = now.year - birthdate.year;
        final monthDiff = now.month - birthdate.month;
        final dayDiff = now.day - birthdate.day;
        final actualAge = (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0))
            ? age - 1
            : age;
        displayAge = actualAge.toString();
        displayBirthdate =
            '${birthdate.year}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}';
      } catch (e) {
        displayAge = ageStr;
        displayBirthdate = '';
      }
    }
    return {'age': displayAge, 'birthdate': displayBirthdate};
  }

  // Build Profile Page (Page 0)
  Widget _buildProfilePage(BuildContext context) {
    final user = _getUserProfile();
    final ageData = _calculateAgeAndBirthdate(user.age);

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: 用户信息 + 简要资料
                SketchyCard(
                  backgroundColor: Colors.grey.shade100,
                  borderColor: Colors.black87,
                  borderWidth: 2.0,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SketchyBorder(
                            borderColor: Colors.black87,
                            borderWidth: 2.0,
                            borderRadius: 40,
                            roughness: 2.0,
                            child: const CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: GoogleFonts.caveat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: GoogleFonts.kalam(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SketchyButton(
                            text: 'Invite',
                            backgroundColor: Colors.orange.shade100,
                            borderColor: Colors.orange.shade700,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HouseholdManagePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 160,
                            child: _buildMiniInfo('Birthdate', ageData['birthdate']!),
                          ),
                          if (ageData['age']!.isNotEmpty)
                            SizedBox(
                              width: 120,
                              child: _buildMiniInfo('Age', '${ageData['age']} years'),
                            ),
                          SizedBox(
                            width: 140,
                            child: _buildMiniInfo('Gender', user.gender),
                          ),
                          SizedBox(
                            width: 140,
                            child: _buildMiniInfo('Height', user.height),
                          ),
                          SizedBox(
                            width: 140,
                            child: _buildMiniInfo('Weight', user.weight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Settings 按钮 - 手绘风格
                Center(
                  child: SketchyButton(
                    text: 'settings',
                    backgroundColor: Colors.grey.shade400,
                    borderColor: Colors.grey.shade700,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // 参考图元素：精准裁剪的红色爪印 + 代码生成的艺术字印章（半透明，不挡信息）
            Positioned(
              top: 120,
              right: -4,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.38,
                  child: Image.asset(
                    'assets/profile_passport/paw.png',
                    width: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 258,
              right: -18,
              child: IgnorePointer(
                child: OtterApprovedStamp(
                  width: 240,
                  opacity: 0.52,
                  rotation: -0.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Health Page (Page 1)
  Widget _buildHealthPage(BuildContext context) {
    final user = _getUserProfile();

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Health'),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BMI显示
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

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI',
                              style: GoogleFonts.kalam(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatBmi(bmiValue),
                              style: GoogleFonts.caveat(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Health Goal',
                    style: GoogleFonts.kalam(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGoalTypeSelector(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _isSavingGoal
                        ? const Center(child: CircularProgressIndicator())
                        : SketchyButton(
                            text: 'Save Goal',
                            backgroundColor: Colors.green.shade100,
                            borderColor: Colors.green.shade700,
                            onPressed: () {
                              _saveHealthGoal();
                            },
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Nutrition'),
            if (_healthInfo != null &&
                (_healthInfo!['dailyEnergy'] != null ||
                    _healthInfo!['dailyProtein'] != null ||
                    _healthInfo!['dailyFat'] != null ||
                    _healthInfo!['dailyCarbohydrates'] != null ||
                    _healthInfo!['dailyFiber'] != null))
              _buildNutritionTargets()
            else
              SketchyCard(
                backgroundColor: Colors.white,
                borderColor: Colors.black87,
                borderWidth: 2.0,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Set a health goal to see nutrition targets',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build Preferences Page (Page 3)
  Widget _buildPreferencesPage(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Preferences'),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Preferences',
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildPreferencesSummary(),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesListPage(),
                        ),
                      );
                      await _loadListsData();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Diet Habits',
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: _buildItemsSummary(kCurrentUser.dietHabits),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DietHabitsListPage(),
                        ),
                      );
                      await _loadListsData();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Allergies',
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: _buildItemsSummary(kCurrentUser.allergies),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllergiesListPage(),
                        ),
                      );
                      await _loadListsData();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.caveat(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
              if (result == true) {
                _loadUserData();
              }
            },
            child: Text(
              'Edit',
              style: GoogleFonts.kalam(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Text(
              'Settings',
              style: GoogleFonts.kalam(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: PassportPageView(
        pages: [
          _buildProfilePage(context),
          _buildHealthPage(context),
          _buildNutritionPage(context),
          _buildPreferencesPage(context),
        ],
        pageLabels: const ['Profile', 'Health', 'Nutrition', 'Preferences'],
        initialPage: 0,
        shouldAnimateCover: widget.shouldAnimateCover, // 启用封面动画
      ),
    );
  }
}
