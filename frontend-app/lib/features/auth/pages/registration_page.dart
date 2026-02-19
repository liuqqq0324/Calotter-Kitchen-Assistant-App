import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
// Modified by Chase: Fixed import path after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/main.dart / 需要向上3级才能到达 lib/main.dart
// ⚠️ 已更新：registration_page.dart 不再需要导入 main.dart（如果不需要 MainScaffold）
import '../../../shared/widgets/common/sketchy_button.dart';
import '../../../shared/widgets/common/sketchy_card.dart';
import '../../../services/business/auth_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.kalam(),
          ),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    // 2. 邮箱格式校验
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid email format (e.g., name@example.com)',
            style: GoogleFonts.kalam(),
          ),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    // 2.1 仅允许指定邮箱域名（学校 + 常见邮箱）
    const allowedDomains = [
      '@aucklanduni.ac.nz',
      '@gmail.com',
      '@yahoo.com',
      '@outlook.com',
      '@hotmail.com',
      '@icloud.com',
    ];
    final emailLower = email.toLowerCase();
    if (!allowedDomains.any((d) => emailLower.endsWith(d))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please use a valid university or common email address (e.g. @aucklanduni.ac.nz, @gmail.com)',
            style: GoogleFonts.kalam(),
          ),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match', style: GoogleFonts.kalam()),
          backgroundColor: Colors.red.shade300,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call backend API for registration
    final result = await AuthService.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Registration successful, show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Please login.',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.green.shade300,
          ),
        );
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Registration failed',
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
          'Registrate',
          style: GoogleFonts.caveat(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 输入框 - 手绘风格
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _usernameController,
                style: GoogleFonts.kalam(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: GoogleFonts.kalam(color: Colors.grey[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _emailController,
                style: GoogleFonts.kalam(fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.kalam(color: Colors.grey[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  labelStyle: GoogleFonts.kalam(color: Colors.grey[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _confirmPasswordController,
                style: GoogleFonts.kalam(fontSize: 16),
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: GoogleFonts.kalam(color: Colors.grey[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Confirm 按钮 - 手绘风格
            SketchyButton(
              text: _isLoading ? 'Registering...' : 'confirm',
              isFullWidth: true,
              backgroundColor: Colors.orange.shade400,
              borderColor: Colors.deepOrange.shade700,
              onPressed: _isLoading ? () {} : () => _handleRegister(),
            ),
            const SizedBox(height: 20),
            // Back 按钮 - 手绘风格
            SketchyButton(
              text: 'Back',
              icon: Icons.arrow_back,
              backgroundColor: Colors.grey.shade400,
              borderColor: Colors.grey.shade700,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
