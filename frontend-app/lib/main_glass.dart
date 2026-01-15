// lib/main_glass.dart
import 'package:flutter/material.dart';
import 'design_c_glass.dart';

/// 玻璃态风格页面快速启动入口
/// 运行方式：flutter run -t lib/main_glass.dart
void main() {
  runApp(const GlassApp());
}

class GlassApp extends StatelessWidget {
  const GlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Glass Design',
      debugShowCheckedModeBanner: false,
      home: DesignCGlassPage(),
    );
  }
}
