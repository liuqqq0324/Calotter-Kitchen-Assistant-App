import 'package:flutter/material.dart';
import 'pages/inventory/inventory_page.dart';
import 'pages/add_item/add_item_page.dart';
import 'pages/home/home_page.dart';
import 'package:personal_sous_chef/data/static_data.dart'; // 🔥 记得引入这个文件
import 'package:personal_sous_chef/models/ingredient.dart'; // 引入 Ingredient 模型

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), // 主题色
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

  // 修改 _MainScaffoldState 类里面的 _pages 变量
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const Center(child: Text('Page 2: Recipes')),
    const AddItemPage(), // 中间的加号页面
    const InventoryPage(), // 原来的库存页移到这里了
    const Center(child: Text('Page 5: User Profile')),
  ];

  // 修改 main.dart 中的 _onItemTapped 方法

  // lib/main.dart

  void _onItemTapped(int index) async {
    // 点击了中间的 "Add" 按钮
    if (index == 2) {
      // 等待 AddItemPage -> ReviewIngredientsPage 返回结果
      // 现在的 result 可能是 'kitchen' 或 'recipe'
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddItemPage()),
      );

      if (result != null) {
        setState(() {
          if (result == 'kitchen') {
            // 用户选择了 "View Kitchen"
            _selectedIndex = 3;
          } else if (result == 'recipe') {
            // 用户选择了 "Generate Recipe"
            _selectedIndex = 1; // 假设 Recipes 页在 index 1
          }
          // 注意：不需要再执行 kInitialIngredients.addAll 了
          // 因为 ReviewIngredientsPage 已经替我们做过了
        });
      }
      return;
    }

    // 点击其他按钮正常切换
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
      // 修改 build 方法里的 bottomNavigationBar 部分
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        // 这里可以控制标签是否一直显示，或者只在选中时显示
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <Widget>[
          // 1. Homepage
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home), // 选中时变实心，交互感更好
            label: 'Home',
          ),

          // 2. Recipes
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),

          // 3. Add Items (突出显示的中间按钮)
          NavigationDestination(
            // 这里特意把 size 设大到 40 (默认是24)，并使用了圆形加号图标
            icon: Icon(Icons.add_circle, size: 40, color: Colors.orange),
            label: 'Add',
          ),

          // 4. Inventory (原来的冰箱)
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Kitchen', // 改个短点的名字适合导航栏
          ),

          // 5. UserInfo
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
