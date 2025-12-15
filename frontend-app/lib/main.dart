import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/pages/home/home_page.dart';
import 'package:personal_sous_chef/pages/inventory/inventory_page.dart';
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipes_home_page.dart';
// Modified by Chase: Import authentication and profile pages / 由 Chase 修改：导入认证和用户资料页面
import 'package:personal_sous_chef/pages/ums/auth/landing_page.dart';
import 'package:personal_sous_chef/pages/ums/profile/profile_view_page.dart';
// import 'package:personal_sous_chef/data/static_data.dart'; // 如果 main.dart 没直接用到这个，可以注释掉
// import 'package:personal_sous_chef/models/ingredient.dart'; // 同上

// 1. 定义全局 Key
final GlobalKey<MainScaffoldState> mainScaffoldKey =
    GlobalKey<MainScaffoldState>();

// 2. 定义全局 RouteObserver 用于监听路由变化
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const SousChefApp());
}

class SousChefApp extends StatelessWidget {
  const SousChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sous Chef',
      navigatorObservers: [routeObserver], // 添加路由观察者
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        // 使用本地字体族 Caveat 作为全局字体
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Caveat'),
      ),
      // Start with landing page for authentication
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
  // Start on Recipes tab (index 1) for quick testing; change back to 0 if needed.
  int _selectedIndex = 0;

  // ✅ 改为 Getter (每次调用都生成新的 Widget 列表)
  // 这样能确保当你 setState 时，InventoryPage 会被重新构建
  List<Widget> get _pages => [
    HomePage(),
    RecipesHomePage(),
    AddItemPage(),

    // 🔥 关键：去掉 const！
    // 这样每次 _pages 被读取时，都会创建一个新的 InventoryPage 引用
    // Flutter 比较时发现引用变了，就会去触发它的 build()
    InventoryPage(), // 👈 其实如果不去掉 const，只要 _pages 是 getter 也能生效，但建议去掉 const 保持动态性
    // Modified by Chase: Replaced BackendTestPage with ProfileViewPage / 由 Chase 修改：将测试页面替换为用户资料页面
    // This matches the "Me" navigation label / 这符合导航栏的 "Me" 标签
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
        automaticallyImplyLeading: false, // 去掉返回箭头
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 海獭emoji作为图标
            const Text('🦦', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            const Text(
              'CalOtter',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
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
