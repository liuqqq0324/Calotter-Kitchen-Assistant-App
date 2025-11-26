import 'package:flutter/material.dart';

void main() {
  runApp(const SousChefApp());
}

class SousChefApp extends StatelessWidget {
  const SousChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sous Chef',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // 主题色设为绿色
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // 当前选中的是第几个页面

  // 这里定义三个页面（暂时用占位符）
  final List<Widget> _pages = <Widget>[
    const Center(child: Text('Page 1: Inventory List (To be implemented)')),
    const Center(child: Text('Page 2: Camera/Scanner (To be implemented)')),
    const Center(child: Text('Page 3: Recipes (To be implemented)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Sous Chef'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex], // 显示当前选中的页面
      bottomNavigationBar: NavigationBar(
        // Material 3 风格导航栏
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.kitchen), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
        ],
      ),
    );
  }
}
