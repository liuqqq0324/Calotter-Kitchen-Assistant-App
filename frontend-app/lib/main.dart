import 'package:flutter/material.dart';
import 'package:personal_sous_chef/pages/inventory/inventory_page.dart'; // 建议检查路径是否正确
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';
import 'package:personal_sous_chef/pages/home/home_page.dart';
// Modified by Chase: Import authentication and profile pages / 由 Chase 修改：导入认证和用户资料页面
import 'package:personal_sous_chef/pages/ums/auth/landing_page.dart';
import 'package:personal_sous_chef/pages/ums/profile/profile_view_page.dart';
// import 'package:personal_sous_chef/data/static_data.dart'; // 如果 main.dart 没直接用到这个，可以注释掉
// import 'package:personal_sous_chef/models/ingredient.dart'; // 同上

// 1. 定义全局 Key
final GlobalKey<MainScaffoldState> mainScaffoldKey =
    GlobalKey<MainScaffoldState>();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // Modified by Chase: Changed app entry point to LandingPage / 由 Chase 修改：将应用入口改为启动页
      // Users will see login/registration options first / 用户首先看到登录/注册选项
      home: const LandingPage(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  // 🔥 修复点 3: 构造函数接收 key 并传给 super
  // 因为我们要在运行时传入 key，所以这里最好也去掉 const (虽然留着也不一定会错，但去掉更稳妥)
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

// 🔥 修复点 4: 确保类名是 MainScaffoldState (公有，没下划线)，方便外部引用
class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // 🔥 修复点 5: 为了安全起见，去掉这里的 const
  // 因为 AddItemPage 或 InventoryPage 可能包含非 const 的逻辑
  late final List<Widget> _pages = <Widget>[
    const HomePage(),
    const Center(child: Text('Page 2: Recipes')),
    const AddItemPage(), // 去掉 const
    const InventoryPage(), // 去掉 const
    // Modified by Chase: Replaced placeholder with ProfileViewPage / 由 Chase 修改：将占位符替换为用户资料页面
    const ProfileViewPage(),
  ];

  // 公开的切换方法
  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddItemPage()),
      );

      if (result != null) {
        setState(() {
          if (result == 'kitchen') {
            _selectedIndex = 3;
          } else if (result == 'recipe') {
            _selectedIndex = 1;
          }
        });
      }
      return;
    }

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
      // 安全检查：防止索引越界
      body: _selectedIndex < _pages.length ? _pages[_selectedIndex] : _pages[0],

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.orange),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
