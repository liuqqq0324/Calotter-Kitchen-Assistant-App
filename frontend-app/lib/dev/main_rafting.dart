// lib/main_rafting.dart
import 'package:flutter/material.dart';
import 'design_b_rafting.dart';

/// 漂流风格页面快速启动入口
/// 运行方式：flutter run -t lib/main_rafting.dart
void main() {
  runApp(const RaftingApp());
}

class RaftingApp extends StatelessWidget {
  const RaftingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Rafting Design',
      debugShowCheckedModeBanner: false,
      home: DesignBRaftingPage(),
    );
  }
}
