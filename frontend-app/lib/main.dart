import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加 SystemNavigator 导入
import 'package:personal_sous_chef/pages/home/home_page.dart';
import 'package:personal_sous_chef/pages/inventory/inventory_page.dart';
import 'package:personal_sous_chef/pages/add_item/add_item_page.dart';
import 'package:personal_sous_chef/pages/recipes/recipes_home_page.dart';
// Modified by Chase: Import authentication and profile pages / 由 Chase 修改：导入认证和用户资料页面
import 'package:personal_sous_chef/pages/ums/auth/landing_page.dart';
import 'package:personal_sous_chef/pages/ums/profile/profile_view_page.dart';

// 1. 定义全局 Key
final GlobalKey<MainScaffoldState> mainScaffoldKey =
    GlobalKey<MainScaffoldState>();

// 🔥 定义 InventoryPage 的 GlobalKey，用于在切换 tab 时刷新数据
// 注意：使用 State<InventoryPage> 类型，因为 _InventoryPageState 是私有类
final GlobalKey<State<InventoryPage>> inventoryPageKey =
    GlobalKey<State<InventoryPage>>();

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
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

// 🔥 修复点 4: 确保类名是 MainScaffoldState (公有，没下划线)，方便外部引用
class MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;
  int _profileAnimationKey = 0; // 用于触发封面动画的key
  bool _shouldAnimateProfile = false; // 是否应该显示封面动画

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // ✅ 改为 Getter (每次调用都生成新的 Widget 列表)
  // 这样能确保当你 setState 时，InventoryPage 会被重新构建
  List<Widget> get _pages => [
    HomePage(),
    RecipesHomePage(),
    AddItemPage(),

    // 🔥 使用 GlobalKey 来访问 InventoryPage 的 State，以便在切换 tab 时刷新数据
    InventoryPage(key: inventoryPageKey),
    // Modified by Chase: Replaced BackendTestPage with ProfileViewPage / 由 Chase 修改：将测试页面替换为用户资料页面
    // This matches the "Me" navigation label / 这符合导航栏的 "Me" 标签
    // 使用key来强制重建，以便触发封面动画
    ProfileViewPage(
      key: ValueKey(_profileAnimationKey),
      shouldAnimateCover: _shouldAnimateProfile, // 是否显示封面动画
    ),
  ];

  // 公开的切换方法
  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 🔥 如果切换到 InventoryPage（index 3），刷新数据
    if (index == 3) {
      _refreshInventoryPage();
    }
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
            // 🔥 切换到 InventoryPage 时刷新数据
            _refreshInventoryPage();
          } else if (result == 'recipe') {
            _selectedIndex = 1;
          }
        });
      }
      return;
    }

    // 如果切换到Profile页面（index 4），触发封面动画
    if (index == 4 && _selectedIndex != 4) {
      setState(() {
        _shouldAnimateProfile = true; // 标记需要显示动画
        _profileAnimationKey++; // 增加key值，强制重建ProfileViewPage以触发动画
        _selectedIndex = index;
      });
      // 动画播放后重置标志
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _shouldAnimateProfile = false;
          });
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
        _shouldAnimateProfile = false; // 切换到其他页面时重置
      });
    }
    
    // 🔥 如果切换到 InventoryPage（index 3），刷新数据
    if (index == 3) {
      _refreshInventoryPage();
    }
  }

  // 🔥 刷新 InventoryPage 数据的方法
  void _refreshInventoryPage() {
    final inventoryState = inventoryPageKey.currentState;
    if (inventoryState != null) {
      // 使用 dynamic 调用 refreshData 方法（因为 _InventoryPageState 是私有类）
      (inventoryState as dynamic).refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 拦截返回键，防止返回到 LandingPage
      canPop: false, // 不允许返回到上一页
      onPopInvoked: (didPop) async {
        if (didPop) {
          // 如果已经 pop 了，不做任何操作
          return;
        }
        // 显示确认退出对话框
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退出应用'),
            content: const Text('确定要退出应用吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('退出'),
              ),
            ],
          ),
        );

        if (shouldExit == true && mounted) {
          // 退出应用
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
        body: _selectedIndex < _pages.length
            ? _pages[_selectedIndex]
            : _pages[0],

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
      ),
    );
  }
}
