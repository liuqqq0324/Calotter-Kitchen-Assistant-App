import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// 淡淡的网格覆盖层，叠在木纹背景之上
class _GridOverlayPainter extends CustomPainter {
  static const double _spacing = 24.0;
  static const double _opacity = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(_opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double x = 0; x <= size.width; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
            // 背景：沙色纹理（作为半透明层）
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8DCC6).withOpacity(0.3),
                    const Color(0xFFD4C4A8).withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // 淡淡网格/纹理覆盖层
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _GridOverlayPainter()),
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
                  Expanded(child: _buildPaperStack()),
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

  /// 纸堆叠：填满内容区，由下而上 Piled1 → Piled2 → Main Paper，Main Paper 为内容容器
  Widget _buildPaperStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              // 最底层：基准
              Positioned.fill(
                child: Image.asset(
                  'assets/profile_passport/Piled Paper1.png',
                  fit: BoxFit.contain,
                ),
              ),
              // 中层：稍向右下偏移并旋转（约 2.3°）
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(8, 10),
                  child: Transform.rotate(
                    angle: 0.04,
                    child: Image.asset(
                      'assets/profile_passport/Piled Paper2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // 最顶层：主内容容器，偏左上，露出底层边缘形成厚度感
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(-4, -5),
                  child: Transform.rotate(
                    angle: -0.01,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/profile_passport/Main Paper.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final cw = c.maxWidth;
                              final ch = c.maxHeight;
                              final pad = math.max(
                                24.0,
                                math.min(48.0, math.min(cw, ch) * 0.08),
                              );
                              return Padding(
                                padding: EdgeInsets.all(pad),
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: _onPageChanged,
                                  itemCount: widget.pages.length,
                                  itemBuilder: (context, index) {
                                    return _buildPageWithStyle(
                                      widget.pages[index],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                fontSize: isActive ? 16 : 14, // 调大导航标签字体，从 13/11 调大到 16/14
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
