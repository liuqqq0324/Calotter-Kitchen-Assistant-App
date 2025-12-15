import 'package:flutter/material.dart';
// Modified by Chase: Import user static data / 由 Chase 修改：导入用户静态数据
import '../../../data/user_static_data.dart';
import '../../../services/user_service.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // Modified by Chase: Initialize controllers from API data / 由 Chase 修改：从 API 数据初始化控制器
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController genderController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  // Modified by Chase: Use references to global lists instead of local copies / 由 Chase 修改：使用全局列表的引用，而不是本地副本
  // These will directly modify kCurrentUser's lists / 这些将直接修改 kCurrentUser 的列表
  late List<String> preferences;
  late List<String> taboos;
  late List<String> allergies;

  // 输入框控制器
  final TextEditingController preferenceInputController =
      TextEditingController();
  final TextEditingController taboosInputController = TextEditingController();
  final TextEditingController allergiesInputController =
      TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

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
        _userData = result['data'];
        // Initialize controllers from API data
        final data = result['data'];
        usernameController = TextEditingController(
          text: data['userName'] ?? '',
        );
        emailController = TextEditingController(text: data['email'] ?? '');
        genderController = TextEditingController(
          text: data['profile']?['gender'] ?? '',
        );
        ageController = TextEditingController(
          text: data['profile']?['age']?.toString() ?? '',
        );
        heightController = TextEditingController(
          text: data['profile']?['height']?.toString() ?? '',
        );
        weightController = TextEditingController(
          text: data['profile']?['weight']?.toString() ?? '',
        );
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        final user = kCurrentUser;
        usernameController = TextEditingController(text: user.username);
        emailController = TextEditingController(text: user.email);
        genderController = TextEditingController(text: user.gender);
        ageController = TextEditingController(text: user.age);
        heightController = TextEditingController(text: user.height);
        weightController = TextEditingController(text: user.weight);
      }
    }

    // Load preferences, taboos, and allergies from backend
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
      kCurrentUser.preferences = List<String>.from(prefs['cuisineTypes'] ?? []);
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

    // Get references to global lists
    preferences = kCurrentUser.preferences;
    taboos = kCurrentUser.taboos;
    allergies = kCurrentUser.allergies;
  }

  void _addPreference() {
    final text = preferenceInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Modified by Chase: Directly modify global kCurrentUser.preferences / 由 Chase 修改：直接修改全局 kCurrentUser.preferences
        kCurrentUser.preferences.add(text);
        preferenceInputController.clear();
      });
    }
  }

  void _removePreference(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.preferences / 由 Chase 修改：直接修改全局 kCurrentUser.preferences
      kCurrentUser.preferences.removeAt(index);
    });
  }

  void _addTaboo() {
    final text = taboosInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Modified by Chase: Directly modify global kCurrentUser.taboos / 由 Chase 修改：直接修改全局 kCurrentUser.taboos
        kCurrentUser.taboos.add(text);
        taboosInputController.clear();
      });
    }
  }

  void _removeTaboo(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.taboos / 由 Chase 修改：直接修改全局 kCurrentUser.taboos
      kCurrentUser.taboos.removeAt(index);
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
    usernameController.dispose();
    emailController.dispose();
    genderController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    preferenceInputController.dispose();
    taboosInputController.dispose();
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
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // 列表项
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Dismissible(
            key: Key('$title-$index-$item'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              onRemove(index);
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(title: Text(item)),
            ),
          );
        }),
        // 底部输入框
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: 'Add $title',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle),
              iconSize: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              // Save to backend API
              final age = int.tryParse(ageController.text);
              final gender = genderController.text.trim();
              final height = int.tryParse(
                heightController.text.replaceAll(' cm', '').trim(),
              );
              final weight = int.tryParse(
                weightController.text.replaceAll(' kg', '').trim(),
              );

              // Save user basic info
              final result = await UserService.updateUserInfo(
                age: age,
                gender: gender.isNotEmpty ? gender : null,
                height: height,
                weight: weight,
              );

              if (result['success'] == true) {
                // Also update local static data for compatibility
                kCurrentUser.age = ageController.text;
                kCurrentUser.gender = genderController.text;
                kCurrentUser.height = heightController.text;
                kCurrentUser.weight = weightController.text;

                // Save preferences (cuisineTypes only, other fields are managed separately)
                final prefsResult = await UserService.updateUserPreferences(
                  cuisineTypes: kCurrentUser.preferences,
                );

                // Save taboos
                final taboosResult = await UserService.updateUserTaboos(
                  taboos: kCurrentUser.taboos,
                );

                // Save allergies
                final allergiesResult = await UserService.updateUserAllergies(
                  allergies: kCurrentUser.allergies,
                );

                // Check if all saves were successful
                bool allSuccess =
                    prefsResult['success'] == true &&
                    taboosResult['success'] == true &&
                    allergiesResult['success'] == true;

                if (allSuccess) {
                  // Modified by Chase: Return true to notify parent page to refresh / 由 Chase 修改：返回 true 通知父页面刷新
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile saved',
                        style: GoogleFonts.kalam(),
                      ),
                      backgroundColor: Colors.green.shade300,
                    ),
                  );
                } else {
                  // Some saves failed, but user info was saved
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Profile saved, but some lists failed to save',
                        style: GoogleFonts.kalam(),
                      ),
                      backgroundColor: Colors.orange.shade300,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] ?? 'Failed to save profile',
                      style: GoogleFonts.kalam(),
                    ),
                    backgroundColor: Colors.red.shade300,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 头像修改区域
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: 实现头像上传
              },
              child: const Text('Modify Picture'),
            ),
            const SizedBox(height: 40),
            // 输入框
            Row(
              children: [
                const SizedBox(width: 100, child: Text('User name')),
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Email')),
                Expanded(
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Gender')),
                Expanded(
                  child: TextField(
                    controller: genderController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('AGE')),
                Expanded(
                  child: TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Height')),
                Expanded(
                  child: TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Weight')),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Modified by Chase: Use global lists from kCurrentUser / 由 Chase 修改：使用 kCurrentUser 的全局列表
            // 列表编辑区域
            _buildListSection(
              'Preferences',
              kCurrentUser.preferences,
              preferenceInputController,
              _addPreference,
              _removePreference,
            ),
            _buildListSection(
              'Taboos',
              kCurrentUser.taboos,
              taboosInputController,
              _addTaboo,
              _removeTaboo,
            ),
            _buildListSection(
              'Allergies',
              kCurrentUser.allergies,
              allergiesInputController,
              _addAllergy,
              _removeAllergy,
            ),
            const SizedBox(height: 20),
            // Settings 按钮
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: 导航到设置页
                },
                child: const Text('settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
