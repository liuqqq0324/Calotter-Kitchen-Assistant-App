import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';
// Modified by Chase: Fixed import paths after moving preferences pages to ums/preferences/ folder / 由 Chase 修改：偏好页面移动到 ums/preferences/ 文件夹后修复导入路径
// Need to go up to ums/ then into preferences/ folder / 需要向上到 ums/ 然后进入 preferences/ 文件夹
import '../preferences/preferences_list_page.dart';
import '../preferences/taboos_list_page.dart';
import '../preferences/allergies_list_page.dart';
// Modified by Chase: Import user static data / 由 Chase 修改：导入用户静态数据
import '../../../data/user_static_data.dart';
import '../../../widgets/sketchy_card.dart';
import '../../../widgets/sketchy_button.dart';
import '../../../widgets/sketchy_border.dart';
import '../../../services/user_service.dart';

// Modified by Chase: Changed to StatefulWidget to support refresh after edit / 由 Chase 修改：改为 StatefulWidget 以支持编辑后刷新
class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

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

    // Load taboos
    final taboosResult = await UserService.getUserTaboos();
    if (taboosResult['success'] == true) {
      kCurrentUser.taboos = List<String>.from(
        taboosResult['data']['taboos'] ?? [],
      );
    }

    // Load allergies
    final allergiesResult = await UserService.getUserAllergies();
    if (allergiesResult['success'] == true) {
      kCurrentUser.allergies = List<String>.from(
        allergiesResult['data']['allergies'] ?? [],
      );
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
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoalType = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
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
      ),
    );
  }

  String _formatBmi(dynamic bmi) {
    if (bmi == null) {
      print('BMI is null');
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
            // 通过调小 childAspectRatio 来提高每个 item 的高度，避免小屏/大字体时 RenderFlex overflow
            // childAspectRatio = width / height
            childAspectRatio: 2.2,
            children: items,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem({
    required IconData icon,
    required String label,
    required int value,
    required String unit,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.kalam(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(
          '$value $unit',
          style: GoogleFonts.kalam(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
          color: Colors.grey[600],
        ).copyWith(fontStyle: FontStyle.italic),
      );
    }

    Widget chips(String label, List<String> values) {
      if (values.isEmpty) return const SizedBox.shrink();
      final show = values.take(6).toList();
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
                  label: Text(v, style: GoogleFonts.kalam(fontSize: 12)),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  valueText,
                  style: GoogleFonts.kalam(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use API data if available, otherwise fallback to static data
    final user = _userData != null
        ? UserProfile(
            username: _userData!['userName'] ?? 'Unknown',
            email: _userData!['email'] ?? '',
            age:
                _userData!['profile']?['birthdate']?.toString() ??
                _userData!['profile']?['age']?.toString() ??
                '', // Fallback to age if birthdate not available
            gender: _userData!['profile']?['gender'] ?? '',
            height: _userData!['profile']?['height']?.toString() ?? '',
            weight: _userData!['profile']?['weight']?.toString() ?? '',
          )
        : kCurrentUser;

    // Calculate age from birthdate if available
    String displayAge = '';
    String displayBirthdate = '';
    if (user.age.isNotEmpty) {
      try {
        final birthdate = DateTime.parse(user.age);
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
        // If parsing fails, treat as age number
        displayAge = user.age;
        displayBirthdate = '';
      }
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 去掉返回箭头
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
        automaticallyImplyLeading: false, // 去掉返回箭头
        title: Text(
          'Profile',
          style: GoogleFonts.caveat(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Modified by Chase: Wait for result and refresh if data was saved / 由 Chase 修改：等待结果，如果数据已保存则刷新
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
              // Modified by Chase: Refresh page if edit was saved / 由 Chase 修改：如果编辑已保存则刷新页面
              if (result == true) {
                _loadUserData(); // Reload from API
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
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: 用户信息 + 简要资料（不改变风格，只调整布局层级）
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 160,
                          child: _buildMiniInfo('Birthdate', displayBirthdate),
                        ),
                        if (displayAge.isNotEmpty)
                          SizedBox(
                            width: 120,
                            child: _buildMiniInfo('Age', '$displayAge years'),
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
              const SizedBox(height: 24),

              _sectionTitle('Health'),
              SketchyCard(
                backgroundColor: Colors.white,
                borderColor: Colors.black87,
                borderWidth: 2.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BMI显示 - 更突出的设计
                    // 只要有身高和体重数据，就应该显示BMI（即使没有健康目标）
                    Builder(
                      builder: (context) {
                        // 尝试从多个来源获取BMI
                        dynamic bmiValue = _healthInfo?['bmi'];

                        // 如果BMI为null，但用户有身高和体重，尝试计算BMI
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
                            if (height != null &&
                                weight != null &&
                                height > 0) {
                              final heightM = height / 100.0;
                              bmiValue = weight / (heightM * heightM);
                              print('Calculated BMI from user data: $bmiValue');
                            }
                          } catch (e) {
                            print('Failed to calculate BMI from user data: $e');
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
                    // 健康目标选择
                    Text(
                      'Health Goal',
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 目标类型选择器
                    _buildGoalTypeSelector(),
                    const SizedBox(height: 16),
                    // 保存按钮
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

              if (_healthInfo != null &&
                  (_healthInfo!['dailyEnergy'] != null ||
                      _healthInfo!['dailyProtein'] != null ||
                      _healthInfo!['dailyFat'] != null ||
                      _healthInfo!['dailyCarbohydrates'] != null ||
                      _healthInfo!['dailyFiber'] != null)) ...[
                const SizedBox(height: 24),
                _sectionTitle('Nutrition'),
                _buildNutritionTargets(),
              ],

              const SizedBox(height: 24),
              _sectionTitle('Preferences'),
              // 偏好 / taboos / allergies 合并为一个卡片，减少“卡片堆叠感”
              SketchyCard(
                backgroundColor: Colors.white,
                borderColor: Colors.black87,
                borderWidth: 2.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Preferences',
                          style: GoogleFonts.kalam(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            // 跳转到编辑页面
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PreferencesListPage(),
                              ),
                            );
                            // Reload lists data after returning from list page
                            await _loadListsData();
                            setState(() {});
                          },
                          child: Text(
                            'Edit',
                            style: GoogleFonts.kalam(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 显示偏好摘要（只读）
                    _buildPreferencesSummary(),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Taboos',
                        style: GoogleFonts.kalam(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${kCurrentUser.taboos.length} items',
                        style: GoogleFonts.kalam(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaboosListPage(),
                          ),
                        );
                        await _loadListsData();
                        setState(() {});
                      },
                    ),
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
                      subtitle: Text(
                        '${kCurrentUser.allergies.length} items',
                        style: GoogleFonts.kalam(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
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
      ),
    );
  }
}
