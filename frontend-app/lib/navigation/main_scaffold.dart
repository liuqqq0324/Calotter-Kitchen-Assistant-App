import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_sous_chef/app/app_keys.dart';
import 'package:personal_sous_chef/features/home/pages/home_page.dart';
import 'package:personal_sous_chef/features/inventory/pages/inventory_page.dart';
import 'package:personal_sous_chef/features/add_item/pages/add_item_page.dart';
import 'package:personal_sous_chef/features/recipes/pages/recipes_home_page.dart';
import 'package:personal_sous_chef/features/profile/pages/profile_view_page.dart';
// import 'package:personal_sous_chef/navigation/bottom_nav_config.dart'; // 🔥 保留但注释，因为原有导航栏代码被注释了
import 'package:personal_sous_chef/navigation/otter_floating_nav.dart';

// 主框架 Scaffold
// 已从 main.dart 拆分出来

class MainScaffold extends StatefulWidget {
  // 🔥 修复点 3: 构造函数接收 key 并传给 super
  // 因为我们要在运行时传入 key，所以这里最好也去掉 const (虽然留着也不一定会错，但去掉更稳妥)
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

// 🔥 修复点 4: 确保类名是 MainScaffoldState (公有，没下划线)，方便外部引用
class MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

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
    const ProfileViewPage(),
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

    setState(() {
      _selectedIndex = index;
    });
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
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
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
                  fontFamily: 'PatrickHand',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/title.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // 安全检查：防止索引越界
        body: _selectedIndex < _pages.length
            ? _pages[_selectedIndex]
            : _pages[0],
        
        // 🦦 新的海獭浮动导航 - 放在 Scaffold 顶层，不会被页面内容遮挡
        floatingActionButton: OtterFloatingNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        // 🔥 原有导航栏代码保留但不启用（注释掉）
        // bottomNavigationBar: NavigationBar(
        //   onDestinationSelected: _onItemTapped,
        //   selectedIndex: _selectedIndex,
        //   labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        //   destinations: BottomNavConfig.destinations,
        // ),
      ),
    );
  }
}
