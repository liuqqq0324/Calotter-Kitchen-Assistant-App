import 'package:flutter/material.dart';
// Modified by Chase: Fixed import paths after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/main.dart and lib/widgets/ / 需要向上3级才能到达 lib/main.dart 和 lib/widgets/
import '../../../main.dart';
import '../../../widgets/video_background.dart';
import '../../../widgets/gradient_button.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log in',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: VideoBackground(
        // 使用与启动页相同的视频或不同的视频
        videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Log in with email or username
                InkWell(
                  onTap: () {
                    // 直接进入主应用（demo模式）
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScaffold()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log in with email → or username',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Back 按钮
                GradientButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  gradientColors: [
                    Colors.grey.shade600,
                    Colors.grey.shade800,
                  ],
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
