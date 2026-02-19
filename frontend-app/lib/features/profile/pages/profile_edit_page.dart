import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/shared/widgets/common/section_title.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/wood_background_scaffold.dart';
import '../../../data/models/user_profile.dart';
import '../../../services/business/user_service.dart';

/// Profile 风格主色（与 profile_view_page 一致）
const Color _kPassportBrown = Color(0xFF6B4F4F);

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // Modified by Chase: Initialize controllers from API data / 由 Chase 修改：从 API 数据初始化控制器
  late TextEditingController usernameController;
  late TextEditingController emailController;
  String? _selectedGender;
  DateTime? _selectedBirthdate; // Changed from ageController to birthdate
  late TextEditingController heightController;
  late TextEditingController weightController;

  // Modified by Chase: Use references to global lists instead of local copies / 由 Chase 修改：使用全局列表的引用，而不是本地副本
  // These will directly modify kCurrentUser's lists / 这些将直接修改 kCurrentUser 的列表
  late List<String> preferences;
  late List<String> dietHabits;
  late List<String> allergies;

  // 标准库菜系选项（与后端 PreferenceStandardLibrary 保持一致）
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

  // 输入框控制器
  final TextEditingController preferenceInputController =
      TextEditingController();
  final TextEditingController dietHabitsInputController =
      TextEditingController();
  final TextEditingController allergiesInputController =
      TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Load user basic info
    final result = await UserService.getUserBriefInfo();
    if (result['success'] == true && mounted) {
      setState(() {
        // Initialize controllers from API data
        final data = result['data'];
        usernameController = TextEditingController(
          text: data['userName'] ?? '',
        );
        emailController = TextEditingController(text: data['email'] ?? '');
        _selectedGender = data['profile']?['gender']?.toString();
        // Parse birthdate from API response
        final birthdateStr = data['profile']?['birthdate'];
        if (birthdateStr != null && birthdateStr.toString().isNotEmpty) {
          try {
            _selectedBirthdate = DateTime.parse(birthdateStr.toString());
          } catch (e) {
            _selectedBirthdate = null;
          }
        } else {
          _selectedBirthdate = null;
        }
        heightController = TextEditingController(
          text:
              data['profile']?['height']
                  ?.toString()
                  .replaceAll(' cm', '')
                  .trim() ??
              '',
        );
        weightController = TextEditingController(
          text:
              data['profile']?['weight']
                  ?.toString()
                  .replaceAll(' kg', '')
                  .trim() ??
              '',
        );
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        // Use kCurrentUser as fallback
        final user = kCurrentUser;
        usernameController = TextEditingController(
          text: user.username.isNotEmpty ? user.username : '',
        );
        emailController = TextEditingController(
          text: user.email.isNotEmpty ? user.email : '',
        );
        _selectedGender = user.gender.isNotEmpty ? user.gender : null;
        // Parse birthdate from user.age (if it's a date string) or set to null
        if (user.age.isNotEmpty) {
          try {
            _selectedBirthdate = DateTime.parse(user.age);
          } catch (e) {
            _selectedBirthdate = null;
          }
        } else {
          _selectedBirthdate = null;
        }
        heightController = TextEditingController(
          text: user.height.replaceAll(' cm', '').trim(),
        );
        weightController = TextEditingController(
          text: user.weight.replaceAll(' kg', '').trim(),
        );
      }
    }

    // Load preferences, diet habits, and allergies from backend
    await _loadListsData();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadListsData() async {
    // Load preferences
    final prefsResult = await UserService.getUserPreferences();
    if (prefsResult['success'] == true) {
      final prefs = prefsResult['data']['preferences'] ?? {};
      final cuisineList = List<String>.from(prefs['cuisineTypes'] ?? []);
      // 只保留标准库中的值
      final validPreferences = cuisineList
          .where((c) => _cuisineOptions.contains(c.toLowerCase()))
          .toList();
      // 更新本地列表和全局列表
      if (mounted) {
        setState(() {
          preferences = validPreferences;
          kCurrentUser.preferences = validPreferences;
        });
      }
    } else {
      preferences = kCurrentUser.preferences;
    }

    // Load diet habits
    final dietHabitsResult = await UserService.getUserDietHabits();
    if (dietHabitsResult['success'] == true) {
      final dietHabitsList = List<String>.from(
        dietHabitsResult['data']['dietHabits'] ?? [],
      );
      if (mounted) {
        setState(() {
          dietHabits = dietHabitsList;
          kCurrentUser.dietHabits = dietHabitsList;
        });
      }
    } else {
      dietHabits = kCurrentUser.dietHabits;
    }

    // Load allergies
    final allergiesResult = await UserService.getUserAllergies();
    if (allergiesResult['success'] == true) {
      final allergiesList = List<String>.from(
        allergiesResult['data']['allergies'] ?? [],
      );
      if (mounted) {
        setState(() {
          allergies = allergiesList;
          kCurrentUser.allergies = allergiesList;
        });
      }
    } else {
      allergies = kCurrentUser.allergies;
    }
  }

  void _addPreference() {
    final text = preferenceInputController.text.trim();
    if (text.isNotEmpty) {
      // 验证是否在标准库中
      if (!_cuisineOptions.contains(text.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid cuisine type. Please use standard options: ${_cuisineOptions.join(", ")}',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.orange.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
        return;
      }

      final normalizedText = text.toLowerCase();
      if (!kCurrentUser.preferences.contains(normalizedText)) {
        setState(() {
          // Modified by Chase: Directly modify global kCurrentUser.preferences / 由 Chase 修改：直接修改全局 kCurrentUser.preferences
          kCurrentUser.preferences.add(normalizedText);
          preferenceInputController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This cuisine is already in your preferences',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.orange.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  void _removePreference(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.preferences / 由 Chase 修改：直接修改全局 kCurrentUser.preferences
      kCurrentUser.preferences.removeAt(index);
    });
  }

  void _addDietHabit() {
    final text = dietHabitsInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Modified by Chase: Directly modify global kCurrentUser.dietHabits / 由 Chase 修改：直接修改全局 kCurrentUser.dietHabits
        kCurrentUser.dietHabits.add(text);
        dietHabitsInputController.clear();
      });
    }
  }

  void _removeDietHabit(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.dietHabits / 由 Chase 修改：直接修改全局 kCurrentUser.dietHabits
      kCurrentUser.dietHabits.removeAt(index);
    });
  }

  void _addAllergy() {
    final text = allergiesInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Modified by Chase: Directly modify global kCurrentUser.allergies / 由 Chase 修改：直接修改全局 kCurrentUser.allergies
        kCurrentUser.allergies.add(text);
        allergiesInputController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.allergies / 由 Chase 修改：直接修改全局 kCurrentUser.allergies
      kCurrentUser.allergies.removeAt(index);
    });
  }

  @override
  void dispose() {
    // Dispose controllers safely (they are always initialized in _loadUserData)
    try {
      usernameController.dispose();
      emailController.dispose();
      // _selectedGender doesn't need disposal
      // ageController removed - using _selectedBirthdate instead
      heightController.dispose();
      weightController.dispose();
    } catch (e) {
      // Controllers might not be initialized if widget was disposed before _loadUserData completed
      // This is safe to ignore
    }
    preferenceInputController.dispose();
    dietHabitsInputController.dispose();
    allergiesInputController.dispose();
    super.dispose();
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    TextEditingController inputController,
    VoidCallback onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Dismissible(
            key: Key('$title-$index-$item'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red.shade400,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              onRemove(index);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: SketchyCard(
                backgroundColor: Colors.white,
                borderColor: _kPassportBrown,
                borderWidth: 2.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.kalam(
                          fontSize: 16,
                          color: _kPassportBrown,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: Icon(Icons.close, size: 20, color: _kPassportBrown),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: 'Add $title',
                  hintStyle: GoogleFonts.kalam(
                    color: _kPassportBrown.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _kPassportBrown),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.kalam(color: _kPassportBrown),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle, color: _kPassportBrown),
              iconSize: 40,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(VoidCallback? onSave) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kPassportBrown),
      title: Text(
        'Edit Profile',
        style: GoogleFonts.kalam(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _kPassportBrown,
        ),
      ),
      actions: [
        if (onSave != null)
          TextButton(
            onPressed: onSave,
            child: Text(
              'Save',
              style: GoogleFonts.kalam(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _kPassportBrown,
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: GoogleFonts.kalam(color: _kPassportBrown.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _kPassportBrown),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _kPassportBrown.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPassportBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _saveProfile() async {
    final birthdate = _selectedBirthdate != null
        ? _selectedBirthdate!.toIso8601String().split('T')[0]
        : null;
    final gender = _selectedGender;
    final height = double.tryParse(
      heightController.text.replaceAll(' cm', '').trim(),
    )?.toInt();
    final weight = double.tryParse(
      weightController.text.replaceAll(' kg', '').trim(),
    )?.toInt();

    final result = await UserService.updateUserInfo(
      birthdate: birthdate,
      gender: gender,
      height: height,
      weight: weight,
    );

    if (result['success'] == true) {
      kCurrentUser.age = birthdate ?? '';
      kCurrentUser.gender = _selectedGender ?? '';
      kCurrentUser.height = heightController.text;
      kCurrentUser.weight = weightController.text;

      final prefsResult = await UserService.updateUserPreferences(
        cuisineTypes: kCurrentUser.preferences,
      );
      final dietHabitsResult = await UserService.updateUserDietHabits(
        dietHabits: kCurrentUser.dietHabits,
      );
      final allergiesResult = await UserService.updateUserAllergies(
        allergies: kCurrentUser.allergies,
      );

      bool allSuccess =
          prefsResult['success'] == true &&
          dietHabitsResult['success'] == true &&
          allergiesResult['success'] == true;

      if (!mounted) return;
      if (allSuccess) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile saved, but some lists failed to save',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.orange.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] ?? 'Failed to save profile',
            style: GoogleFonts.kalam(),
          ),
          backgroundColor: Colors.red.shade300,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WoodBackgroundScaffold(
        appBar: _buildAppBar(null),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WoodBackgroundScaffold(
      appBar: _buildAppBar(_saveProfile),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SketchyCard(
              backgroundColor: Colors.blue.shade50,
              borderColor: _kPassportBrown,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Basic Info'),
                  const SizedBox(height: 8),
                  _buildLabel('User name'),
                  TextField(
                    controller: usernameController,
                    decoration: _inputDecoration(),
                    style: GoogleFonts.kalam(color: _kPassportBrown),
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Email'),
                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration(),
                    style: GoogleFonts.kalam(color: _kPassportBrown),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Gender'),
                  DropdownButtonFormField<String>(
                    value: (_selectedGender == '1' || _selectedGender == '2')
                        ? _selectedGender
                        : null,
                    decoration: _inputDecoration().copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    dropdownColor: Colors.blue.shade50,
                    items: [
                      DropdownMenuItem(
                        value: '1',
                        child: Text(
                          'Male',
                          style: GoogleFonts.kalam(color: _kPassportBrown),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text(
                          'Female',
                          style: GoogleFonts.kalam(color: _kPassportBrown),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    hint: Text(
                      'Select Gender',
                      style: GoogleFonts.kalam(
                        color: _kPassportBrown.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Birthdate'),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _selectedBirthdate ??
                            DateTime.now().subtract(
                              const Duration(days: 365 * 25),
                            ),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        helpText: 'Select birthdate',
                      );
                      if (picked != null &&
                          picked != _selectedBirthdate &&
                          mounted) {
                        setState(() {
                          _selectedBirthdate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _kPassportBrown.withOpacity(0.7),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedBirthdate != null
                                ? '${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}'
                                : 'Select birthdate',
                            style: GoogleFonts.kalam(
                              color: _selectedBirthdate != null
                                  ? _kPassportBrown
                                  : _kPassportBrown.withOpacity(0.5),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: _kPassportBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Height'),
                  TextField(
                    controller: heightController,
                    decoration: _inputDecoration(suffixText: 'cm'),
                    style: GoogleFonts.kalam(color: _kPassportBrown),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Weight'),
                  TextField(
                    controller: weightController,
                    decoration: _inputDecoration(suffixText: 'kg'),
                    style: GoogleFonts.kalam(color: _kPassportBrown),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SketchyCard(
              backgroundColor: Colors.blue.shade50,
              borderColor: _kPassportBrown,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: _buildListSection(
                'Preferences',
                kCurrentUser.preferences,
                preferenceInputController,
                _addPreference,
                _removePreference,
              ),
            ),
            const SizedBox(height: 20),
            SketchyCard(
              backgroundColor: Colors.blue.shade50,
              borderColor: _kPassportBrown,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: _buildListSection(
                'Diet Habits',
                kCurrentUser.dietHabits,
                dietHabitsInputController,
                _addDietHabit,
                _removeDietHabit,
              ),
            ),
            const SizedBox(height: 20),
            SketchyCard(
              backgroundColor: Colors.blue.shade50,
              borderColor: _kPassportBrown,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: _buildListSection(
                'Allergies',
                kCurrentUser.allergies,
                allergiesInputController,
                _addAllergy,
                _removeAllergy,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.kalam(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _kPassportBrown,
        ),
      ),
    );
  }
}
