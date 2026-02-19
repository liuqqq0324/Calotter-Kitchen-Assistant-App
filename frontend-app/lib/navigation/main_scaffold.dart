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
    // ✅ 修改：Add页面也作为tab切换，而不是push新页面，确保导航始终显示
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
    // 🔥 定义自定义标题栏的总高度（根据你的图片实际情况调整）
    // 这个高度需要包含状态栏高度 + 标题内容高度 + 底部不规则边缘延伸出的高度
    const double customHeaderHeight = 130.0; // 🔥 你可以根据实际显示效果微调这个数字

    // 获取状态栏高度，用于后续计算内边距
    final double statusBarHeight = MediaQuery.of(context).padding.top;

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
        // 🔥 关键修改 1: 彻底移除标准的 appBar 属性
        // appBar: AppBar( ... ),

        // 🔥 关键修改 2: 将 body 改为 Stack
        body: Stack(
          children: [
            // --- 2.1 底层：页面内容 ---
            Positioned.fill(
              // 🔥 修复关键点：
              // 原代码: top: statusBarHeight + kToolbarHeight, (~80px)
              // 修改为: 下面的代码
              // 解释: 我们用 header 高度 (130) 减去一点点 (20)，让页面内容从 110px 开始。
              // 这样内容不会被挡住太多，同时又能保证刚好衔接在木纹不规则边缘的下方。
              top: customHeaderHeight - 20,
              child: _selectedIndex < _pages.length
                  ? _pages[_selectedIndex]
                  : _pages[0],
            ),

            // --- 2.2 顶层：自定义不规则标题栏 ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: customHeaderHeight, // 设置自定义标题区域的高度
              child: Container(
                // ✅ 使用 BoxDecoration 设置背景图
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/title.png'),
                    // 🔥 关键：使用 BoxFit.cover 并顶部对齐
                    // 这样可以保证图片宽度铺满，且顶部固定，底部的透明不规则区域自然延伸
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // ✅ 这是一个安全区域和内容的容器
                child: Padding(
                  // Padding 用于把标题文字推到合适的位置，避开状态栏
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 10, // 状态栏高度 + 一点微调
                    left: 16,
                    bottom: 20, // 底部留出空间给不规则边缘
                  ),
                  // 这里放原本 AppBar title 里的 Row
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中对齐
                    children: [
                      const Text('🦦', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      const Text(
                        'CalOtter',
                        style: TextStyle(
                          fontFamily: 'PatrickHand',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          // ✅ 确保文字颜色在背景上清晰可见，如果背景偏浅可能需要深色文字
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 🦦 海獭浮动导航 (保持不变)
        floatingActionButton: OtterFloatingNav(
          key: otterFloatingNavKey,
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
