import 'package:flutter/material.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';
// Modified by Chase: Fixed import paths after moving preferences pages to ums/preferences/ folder / 由 Chase 修改：偏好页面移动到 ums/preferences/ 文件夹后修复导入路径
// Need to go up to ums/ then into preferences/ folder / 需要向上到 ums/ 然后进入 preferences/ 文件夹
import '../preferences/preferences_list_page.dart';
import '../preferences/taboos_list_page.dart';
import '../preferences/allergies_list_page.dart';
// Modified by Chase: Import user static data / 由 Chase 修改：导入用户静态数据
import '../../../data/user_static_data.dart';

// Modified by Chase: Changed to StatefulWidget to support refresh after edit / 由 Chase 修改：改为 StatefulWidget 以支持编辑后刷新
class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  @override
  Widget build(BuildContext context) {
    // Modified by Chase: Read data from global kCurrentUser instead of hardcoded values / 由 Chase 修改：从全局 kCurrentUser 读取数据，而不是硬编码值
    // This will read the latest data every time build is called / 每次 build 被调用时都会读取最新数据
    final user = kCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
                setState(() {});
              }
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
                        user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            Text(user.age, style: const TextStyle(fontSize: 16)),
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
            Text(user.gender, style: const TextStyle(fontSize: 16)),
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
            Text(user.height, style: const TextStyle(fontSize: 16)),
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
            Text(user.weight, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            // 设置项
            ListTile(
              title: const Text('Preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Modified by Chase: Refresh after returning from preferences page / 由 Chase 修改：从偏好页面返回后刷新
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreferencesListPage(),
                  ),
                );
                setState(
                  () {},
                ); // Refresh to show updated preferences / 刷新以显示更新的偏好
              },
            ),
            ListTile(
              title: const Text('Taboos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Modified by Chase: Refresh after returning from taboos page / 由 Chase 修改：从禁忌页面返回后刷新
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaboosListPage(),
                  ),
                );
                setState(() {}); // Refresh to show updated taboos / 刷新以显示更新的禁忌
              },
            ),
            ListTile(
              title: const Text('Allergies'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Modified by Chase: Refresh after returning from allergies page / 由 Chase 修改：从过敏页面返回后刷新
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllergiesListPage(),
                  ),
                );
                setState(
                  () {},
                ); // Refresh to show updated allergies / 刷新以显示更新的过敏
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
                      builder: (context) => const SettingsPage(),
                    ),
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
