import 'package:flutter/material.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';
import 'preferences_list_page.dart';
import 'taboos_list_page.dart';
import 'allergies_list_page.dart';

class ProfileViewPage extends StatelessWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 假数据
    const username = 'Chase_70_70';
    const email = 'chase666@gmail.com';
    const age = '25';
    const gender = 'Male';
    const height = '175 cm';
    const weight = '70 kg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileEditPage()),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息区域
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // 个人信息
            const Text(
              'AGE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(age, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(gender, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              'Height',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(height, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              'Weight',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(weight, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            // 设置项
            ListTile(
              title: const Text('Preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PreferencesListPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Taboos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaboosListPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Allergies'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllergiesListPage()),
                );
              },
            ),
            const SizedBox(height: 40),
            // Settings 按钮
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
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

