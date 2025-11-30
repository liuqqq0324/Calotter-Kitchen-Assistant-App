import 'package:flutter/material.dart';
import 'login_page.dart';
import 'registration_page.dart';
import '../widgets/video_background.dart';
import '../widgets/handwriting_animation.dart';
import '../widgets/gradient_button.dart';

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
                // Log in 按钮
                GradientButton(
                  text: 'Log in',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Sign up 按钮
                GradientButton(
                  text: 'Sign up',
                  icon: Icons.arrow_forward,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.blue.shade400,
                  ],
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
