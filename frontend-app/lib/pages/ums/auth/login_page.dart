import 'package:flutter/material.dart';
// Modified by Chase: Fixed import paths after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/main.dart and lib/widgets/ / 需要向上3级才能到达 lib/main.dart 和 lib/widgets/
import '../../../main.dart';
import '../../../widgets/video_background.dart';
import '../../../widgets/sketchy_button.dart';
import '../../../widgets/sketchy_card.dart';
import '../../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter username/email and password',
            style: GoogleFonts.kalam(),
          ),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call backend API for login
    final result = await AuthService.login(
      identifier: identifier,
      password: password,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Login successful, navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Login failed',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // 登录表单 - 手绘风格卡片
                SketchyCard(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  borderColor: Colors.black87,
                  borderWidth: 2.0,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log in with email or username',
                        style: GoogleFonts.caveat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 用户名/邮箱输入框
                      SketchyCard(
                        backgroundColor: Colors.white,
                        borderColor: Colors.black87,
                        borderWidth: 2.0,
                        padding: EdgeInsets.zero,
                        child: TextField(
                          controller: _identifierController,
                          style: GoogleFonts.kalam(fontSize: 16),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Username or Email',
                            labelStyle: GoogleFonts.kalam(
                              color: Colors.grey[700],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 密码输入框
                      SketchyCard(
                        backgroundColor: Colors.white,
                        borderColor: Colors.black87,
                        borderWidth: 2.0,
                        padding: EdgeInsets.zero,
                        child: TextField(
                          controller: _passwordController,
                          style: GoogleFonts.kalam(fontSize: 16),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.kalam(
                              color: Colors.grey[700],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[700],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[700],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 登录按钮
                      SketchyButton(
                        text: _isLoading ? 'Logging in...' : 'Log in',
                        isFullWidth: true,
                        backgroundColor: Colors.orange.shade400,
                        borderColor: Colors.deepOrange.shade700,
                        onPressed: _isLoading ? () {} : () => _handleLogin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
