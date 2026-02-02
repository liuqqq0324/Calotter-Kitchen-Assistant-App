import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'profile_edit_page.dart';
// Modified by Chase: Import auth service / 由 Chase 修改：导入认证服务
import '../../../services/business/auth_service.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/pages/landing_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          // 用户信息区域（可点击进入编辑页）
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
              // Modified by Chase: If profile was edited, notify the parent page when popping / 由 Chase 修改：如果资料已修改，则在返回时通知父页面
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const Divider(),
          // 设置选项
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: 导航到修改密码页
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change Password (To be implemented)'),
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Log out'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // Call logout API
                final result = await AuthService.logout();

                if (mounted) {
                  // Navigate to landing page first, then push login page
                  // This ensures LoginPage can navigate back to LandingPage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingPage(),
                    ),
                    (route) => false, // Remove all previous routes
                  );
                  // Then push LoginPage on top so Back button can return to LandingPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ?? 'Logged out successfully',
                        style: GoogleFonts.kalam(),
                      ),
                      backgroundColor: Colors.green.shade300,
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: 实现删除账户逻辑
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Delete Account (To be implemented)'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
