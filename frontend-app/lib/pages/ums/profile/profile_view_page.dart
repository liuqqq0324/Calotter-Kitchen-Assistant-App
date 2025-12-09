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
  }

  @override
  Widget build(BuildContext context) {
    // Use API data if available, otherwise fallback to static data
    final user = _userData != null
        ? UserProfile(
            username: _userData!['userName'] ?? 'Unknown',
            email: _userData!['email'] ?? '',
            age: _userData!['profile']?['age']?.toString() ?? '',
            gender: '', // Not in API response
            height: _userData!['profile']?['height']?.toString() ?? '',
            weight: _userData!['profile']?['weight']?.toString() ?? '',
          )
        : kCurrentUser;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
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
        title: Text(
          'Profile',
          style: GoogleFonts.caveat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息区域 - 手绘风格
            SketchyCard(
              backgroundColor: Colors.grey.shade100,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SketchyBorder(
                    borderColor: Colors.black87,
                    borderWidth: 2.0,
                    borderRadius: 40,
                    roughness: 2.0,
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
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
                            fontSize: 24,
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
            ),
            const SizedBox(height: 40),
            // 个人信息 - 手绘风格卡片
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGE',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.age,
                    style: GoogleFonts.kalam(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gender',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.gender,
                    style: GoogleFonts.kalam(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Height',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.height,
                    style: GoogleFonts.kalam(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Weight',
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.weight,
                    style: GoogleFonts.kalam(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 设置项 - 手绘风格卡片
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreferencesListPage(),
                  ),
                );
                setState(() {});
              },
              child: ListTile(
                title: Text(
                  'Preferences',
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            const SizedBox(height: 12),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaboosListPage(),
                  ),
                );
                setState(() {});
              },
              child: ListTile(
                title: Text(
                  'Taboos',
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            const SizedBox(height: 12),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllergiesListPage(),
                  ),
                );
                setState(() {});
              },
              child: ListTile(
                title: Text(
                  'Allergies',
                  style: GoogleFonts.kalam(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      ),
    );
  }
}
