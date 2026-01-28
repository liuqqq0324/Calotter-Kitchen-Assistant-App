import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// 护照翻页效果的PageView组件
/// 支持翻页动画和底部标签导航
class PassportPageView extends StatefulWidget {
  final List<Widget> pages;
  final List<String> pageLabels;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final bool shouldAnimateCover; // 新增：是否需要封面动画

  const PassportPageView({
    super.key,
    required this.pages,
    required this.pageLabels,
    this.initialPage = 0,
    this.onPageChanged,
    this.shouldAnimateCover = false, // 默认不动画
  }) : assert(
         pages.length == pageLabels.length,
         'Pages and labels must have the same length',
       );

  @override
  State<PassportPageView> createState() => _PassportPageViewState();
}

class _PassportPageViewState extends State<PassportPageView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentPage;
  late AnimationController _coverAnimationController;
  late Animation<double> _coverAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);

    // 封面动画控制器
    _coverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _coverAnimation = CurvedAnimation(
      parent: _coverAnimationController,
      curve: Curves.easeInOutCubic,
    );

    // 如果需要动画且还没动画过，启动动画
    if (widget.shouldAnimateCover && !_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _coverAnimationController.forward();
          _hasAnimated = true;
        }
      });
    } else {
      // 不需要动画时直接显示
      _coverAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _coverAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    widget.onPageChanged?.call(index);
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _coverAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 底层背景：木纹背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/wood_background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // 中间层背景：容器背景（缩短到标签之上2.5cm的位置）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100, // 2.5cm ≈ 100 像素，在底部导航栏上方
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/inventory_container.png'),
                    fit: BoxFit.fill,
                    // 使用 centerSlice 保持边缘不变形
                    centerSlice: const Rect.fromLTWH(25, 15, 360, 380),
                  ),
                ),
              ),
            ),
            // 背景：沙色纹理（作为半透明层，可选）
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8DCC6).withOpacity(0.3), // 沙色，降低透明度以显示木纹
                    const Color(0xFFD4C4A8).withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // 封面（动画）
            if (_coverAnimation.value < 1.0)
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 透视
                    ..rotateY((1 - _coverAnimation.value) * 3.14), // 从右向左翻
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF8B6F47), // 封面颜色
                          const Color(0xFF6B4F2F),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.caveat(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 页面内容区域（淡入）
            Opacity(
              opacity: _coverAnimation.value,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // PageView with page styling
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: widget.pages.length,
                          itemBuilder: (context, index) {
                            return _buildPageWithStyle(widget.pages[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                  // 底部标签导航（粘贴效果）
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageWithStyle(Widget page) {
    return page;
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            widget.pageLabels.length,
            (index) => _buildNavItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = _currentPage == index;
    // 随机旋转角度，模拟粘贴效果
    final rotation = (index % 2 == 0) ? -0.05 : 0.05;

    return Expanded(
      child: GestureDetector(
        onTap: () => _goToPage(index),
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              // 便签纸效果
              color: isActive ? Colors.yellow.shade100 : Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive ? Colors.brown.shade600 : Colors.brown.shade400,
                width: 1.5,
              ),
              // 粘贴效果的阴影
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.shade300.withOpacity(0.4),
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
                // 内部阴影，模拟粘贴的胶带效果
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 1,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Text(
              widget.pageLabels[index],
              textAlign: TextAlign.center,
              style: GoogleFonts.kalam(
                fontSize: isActive ? 13 : 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.brown.shade900 : Colors.brown.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
