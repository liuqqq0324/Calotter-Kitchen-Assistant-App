import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'dart:math' as math;

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
            // 背景：沙色纹理
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8DCC6), // 沙色
                    const Color(0xFFD4C4A8),
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
                        // 浮木装饰（右上角）
                        Positioned(
                          top: 20,
                          right: -30,
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              width: 120,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B6F47),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.shade300.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8), // 米白色纸张
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade400.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(4, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 手绘边框
            CustomPaint(painter: _PageBorderPainter(), child: page),
          ],
        ),
      ),
    );
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

/// 手绘页面边框绘制器
class _PageBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final roughness = 3.0;
    final random = math.Random(42);

    // 绘制手绘风格的边框
    path.moveTo(
      _randomOffset(0, roughness, random),
      _randomOffset(0, roughness, random),
    );

    // 上边
    for (int i = 1; i <= 20; i++) {
      final t = i / 20.0;
      path.lineTo(
        _randomOffset(size.width * t, roughness, random),
        _randomOffset(0, roughness, random),
      );
    }

    // 右边
    for (int i = 1; i <= 20; i++) {
      final t = i / 20.0;
      path.lineTo(
        _randomOffset(size.width, roughness, random),
        _randomOffset(size.height * t, roughness, random),
      );
    }

    // 下边
    for (int i = 19; i >= 0; i--) {
      final t = i / 20.0;
      path.lineTo(
        _randomOffset(size.width * t, roughness, random),
        _randomOffset(size.height, roughness, random),
      );
    }

    // 左边
    for (int i = 19; i >= 0; i--) {
      final t = i / 20.0;
      path.lineTo(
        _randomOffset(0, roughness, random),
        _randomOffset(size.height * t, roughness, random),
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double _randomOffset(double base, double roughness, math.Random random) {
    return base + (random.nextDouble() - 0.5) * roughness;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
