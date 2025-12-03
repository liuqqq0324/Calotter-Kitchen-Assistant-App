import 'package:flutter/material.dart';
// Modified by Chase: Fixed import paths after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/main.dart and lib/widgets/ / 需要向上3级才能到达 lib/main.dart 和 lib/widgets/
import '../../../main.dart';
import '../../../widgets/video_background.dart';
import '../../../widgets/sketchy_button.dart';
import '../../../widgets/sketchy_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_sous_chef/config/api_config.dart'; // 引入你的配置

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log in',
          style: GoogleFonts.caveat(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: VideoBackground(
        // 使用与启动页相同的本地视频
        videoPath: 'assets/videos/meow.mp4',
        // 或者使用网络视频（备用，已注释）
        // videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Log in with email or username - 手绘风格卡片
                SketchyCard(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  borderColor: Colors.black87,
                  borderWidth: 2.0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  onTap: () async {
                    // 🔥 [新增] 显示 Loading (简单用个 SnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logging in as Test Admin..."),
                      ),
                    );

                    try {
                      // 1. 准备假数据 (对应数据库里的 Seed Data)
                      final loginBody = {
                        "username": "chef_admin",
                        "password": "password123",
                      };

                      // 2. 发送请求
                      final url = Uri.parse(
                        '${ApiConfig.baseUrl}/api/Auth/login',
                      );
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode(loginBody),
                      );

                      // 3. 处理结果
                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);

                        // 4. 保存 Token 和 UserID
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('token', data['token']);
                        await prefs.setInt('userId', data['id']);
                        await prefs.setInt('kitchenId', data['kitchenId']);

                        if (!context.mounted) return;

                        // 5. 跳转主页
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScaffold(),
                          ),
                        );
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Login Failed: ${response.body}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Connection Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log in with email → or username',
                        style: GoogleFonts.kalam(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.green.shade600),
                    ],
                  ),
                ),
                const Spacer(),
                // Back 按钮 - 手绘风格
                SketchyButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  backgroundColor: Colors.grey.shade600,
                  borderColor: Colors.grey.shade800,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
