// lib/ui_comparison_runner.dart
import 'package:flutter/material.dart';
import 'design_a_scrapbook.dart';
import 'design_b_rafting.dart';
import 'design_c_glass.dart';

/// UI 设计对比运行器
/// 可以快速切换查看三种不同的设计风格
/// 运行方式：flutter run -t lib/ui_comparison_runner.dart
void main() {
  runApp(const UiComparisonApp());
}

class UiComparisonApp extends StatelessWidget {
  const UiComparisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'UI Design Comparison',
      debugShowCheckedModeBanner: false,
      home: UiComparisonRunner(),
    );
  }
}

/// UI 对比主页面（带底部导航栏）
class UiComparisonRunner extends StatefulWidget {
  const UiComparisonRunner({super.key});

  @override
  State<UiComparisonRunner> createState() => _UiComparisonRunnerState();
}

class _UiComparisonRunnerState extends State<UiComparisonRunner> {
  int _currentIndex = 0;

  // 三个设计页面
  final List<Widget> _pages = const [
    DesignAScrapbookPage(), // Tab 0: Scrapbook
    DesignBRaftingPage(),   // Tab 1: Rafting
    DesignCGlassPage(),     // Tab 2: Glass
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6B4F4F), // AppPalette.riverDeepBrown
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Caveat',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Caveat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: '📖 Scrapbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waves),
            label: '🪵 Rafting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            label: '💧 Glass',
          ),
        ],
      ),
    );
  }
}
