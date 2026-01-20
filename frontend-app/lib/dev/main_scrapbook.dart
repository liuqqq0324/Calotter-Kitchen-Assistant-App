// lib/main_scrapbook.dart
import 'package:flutter/material.dart';
import 'design_a_scrapbook.dart';

/// 剪贴簿页面快速启动入口
/// 运行方式：flutter run -t lib/main_scrapbook.dart
void main() {
  runApp(const ScrapbookApp());
}

class ScrapbookApp extends StatelessWidget {
  const ScrapbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scrapbook Design',
      debugShowCheckedModeBanner: false,
      home: DesignAScrapbookPage(),
    );
  }
}
