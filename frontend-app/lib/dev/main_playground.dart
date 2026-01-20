import 'package:flutter/material.dart';
import 'package:personal_sous_chef/dev/ui_playground.dart';

/// UI Playground 快速启动入口
/// 运行方式：flutter run -t lib/main_playground.dart
void main() {
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'UI Playground',
      debugShowCheckedModeBanner: false,
      home: PersonalCenterPage(),
    );
  }
}
