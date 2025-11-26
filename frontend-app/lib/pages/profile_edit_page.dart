import 'package:flutter/material.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
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
    final TextEditingController preferenceController =
        TextEditingController(text: 'Vegetarian');
    final TextEditingController taboosController =
        TextEditingController(text: 'Peanuts, Shellfish');

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
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Preference'),
                ),
                Expanded(
                  child: TextField(
                    controller: preferenceController,
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
                  child: Text('Taboos'),
                ),
                Expanded(
                  child: TextField(
                    controller: taboosController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
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

