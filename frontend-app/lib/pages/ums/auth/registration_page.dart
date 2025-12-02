import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Modified by Chase: Fixed import path after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/main.dart / 需要向上3级才能到达 lib/main.dart
import '../../../main.dart';
import '../../../widgets/sketchy_button.dart';
import '../../../widgets/sketchy_card.dart';
import '../../../widgets/sketchy_border.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrate',
          style: GoogleFonts.caveat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 头像上传区域 - 手绘风格
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
                    child: Text(
                      'Upload your picture',
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 输入框 - 手绘风格
            SketchyCard(
              backgroundColor: Colors.white,
              borderColor: Colors.black87,
              borderWidth: 2.0,
              padding: EdgeInsets.zero,
              child: TextField(
                style: GoogleFonts.kalam(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: GoogleFonts.kalam(
                    color: Colors.grey[700],
                  ),
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
                style: GoogleFonts.kalam(fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.kalam(
                    color: Colors.grey[700],
                  ),
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
                style: GoogleFonts.kalam(fontSize: 16),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.kalam(
                    color: Colors.grey[700],
                  ),
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
                style: GoogleFonts.kalam(fontSize: 16),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: GoogleFonts.kalam(
                    color: Colors.grey[700],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Confirm 按钮 - 手绘风格
            SketchyButton(
              text: 'confirm',
              isFullWidth: true,
              backgroundColor: Colors.orange.shade400,
              borderColor: Colors.deepOrange.shade700,
              onPressed: () {
                // 直接进入主应用（demo模式）
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainScaffold()),
                );
              },
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

