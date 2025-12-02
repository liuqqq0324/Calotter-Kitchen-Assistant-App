import 'package:flutter/material.dart';
import 'login_page.dart';
import 'registration_page.dart';
// Modified by Chase: Fixed import paths after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/widgets/ / 需要向上3级才能到达 lib/widgets/
import '../../../widgets/video_background.dart';
import '../../../widgets/handwriting_animation.dart';
import '../../../widgets/sketchy_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBackground(
        // 视频路径（本地）或 URL（网络）
        // videoPath: 'assets/videos/background.mp4',
        // 或者使用网络视频（示例URL，需要替换为实际视频）
        videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App 名称 - 手写动画
                const HandwritingAnimation(
                  text: 'A Chef',
                  fontSize: 64,
                  color: Colors.white,
                  animationDuration: Duration(seconds: 2),
                ),
                const SizedBox(height: 60),
                // Log in 按钮 - 手绘风格
                SketchyButton(
                  text: 'Log in',
                  icon: Icons.arrow_forward,
                  backgroundColor: Colors.orange.shade400,
                  borderColor: Colors.deepOrange.shade700,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Sign up 按钮 - 手绘风格
                SketchyButton(
                  text: 'Sign up',
                  icon: Icons.arrow_forward,
                  backgroundColor: Colors.green.shade400,
                  borderColor: Colors.green.shade700,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationPage()),
                    );
                  },
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
