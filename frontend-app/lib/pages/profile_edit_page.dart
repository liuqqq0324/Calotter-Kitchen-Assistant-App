import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 假数据（预填充）
  final TextEditingController usernameController =
      TextEditingController(text: 'Chase_70_70');
  final TextEditingController emailController =
      TextEditingController(text: 'chase666@gmail.com');
  final TextEditingController genderController =
      TextEditingController(text: 'Male');
  final TextEditingController ageController = TextEditingController(text: '25');
  final TextEditingController heightController =
      TextEditingController(text: '175 cm');
  final TextEditingController weightController =
      TextEditingController(text: '70 kg');

  // 列表数据
  List<String> preferences = ['Vegetarian', 'Low Carb'];
  List<String> taboos = ['Pork', 'Beef'];
  List<String> allergies = ['Peanuts', 'Shellfish'];

  // 输入框控制器
  final TextEditingController preferenceInputController =
      TextEditingController();
  final TextEditingController taboosInputController = TextEditingController();
  final TextEditingController allergiesInputController =
      TextEditingController();

  void _addPreference() {
    final text = preferenceInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        preferences.add(text);
        preferenceInputController.clear();
      });
    }
  }

  void _removePreference(int index) {
    setState(() {
      preferences.removeAt(index);
    });
  }

  void _addTaboo() {
    final text = taboosInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        taboos.add(text);
        taboosInputController.clear();
      });
    }
  }

  void _removeTaboo(int index) {
    setState(() {
      taboos.removeAt(index);
    });
  }

  void _addAllergy() {
    final text = allergiesInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        allergies.add(text);
        allergiesInputController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      allergies.removeAt(index);
    });
  }

  @override
  void dispose() {
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
              child: ListTile(
                title: Text(item),
              ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // 保存并返回
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved')),
              );
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
                const SizedBox(
                  width: 100,
                  child: Text('User name'),
                ),
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
                const SizedBox(
                  width: 100,
                  child: Text('Email'),
                ),
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
                const SizedBox(
                  width: 100,
                  child: Text('Gender'),
                ),
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
                const SizedBox(
                  width: 100,
                  child: Text('AGE'),
                ),
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
                const SizedBox(
                  width: 100,
                  child: Text('Height'),
                ),
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
                const SizedBox(
                  width: 100,
                  child: Text('Weight'),
                ),
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
            // 列表编辑区域
            _buildListSection(
              'Preferences',
              preferences,
              preferenceInputController,
              _addPreference,
              _removePreference,
            ),
            _buildListSection(
              'Taboos',
              taboos,
              taboosInputController,
              _addTaboo,
              _removeTaboo,
            ),
            _buildListSection(
              'Allergies',
              allergies,
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
