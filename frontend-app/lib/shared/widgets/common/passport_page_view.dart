import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// 木板区域暗角（vignette）：四周暗、中间亮
class _VignettePainter extends CustomPainter {
  static const double _opacity = 0.12; // 8–15%

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(_opacity),
      ],
      stops: const [0.3, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.multiply,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 纸张颗粒/噪点（4–8% 透明度，Overlay 感）
class _GrainPainter extends CustomPainter {
  static const int _seed = 42;
  static const double _maxOpacity = 0.06; // 4–8%

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rnd = math.Random(_seed);
    const step = 2.5;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final v = rnd.nextDouble();
        final a = v * _maxOpacity;
        if (a < 0.015) continue;
        final grey = (128 + (rnd.nextDouble() - 0.5) * 80).round().clamp(80, 180);
        canvas.drawRect(
          Rect.fromLTWH(
            x + (rnd.nextDouble() - 0.5) * 1.5,
            y + (rnd.nextDouble() - 0.5) * 1.5,
            1.2,
            1.2,
          ),
          Paint()
            ..color = Color.fromRGBO(grey, grey, grey, a)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
class PassportPageView extends StatefulWidget {
  final List<Widget> pages;
  final List<String> pageLabels;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final bool shouldAnimateCover;

  const PassportPageView({
    super.key,
    required this.pages,
    required this.pageLabels,
    this.initialPage = 0,
    this.onPageChanged,
    this.shouldAnimateCover = false,
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

    _coverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _coverAnimation = CurvedAnimation(
      parent: _coverAnimationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.shouldAnimateCover && !_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _coverAnimationController.forward();
          _hasAnimated = true;
        }
      });
    } else {
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
            // 1. 背景层 (木纹 + 沙色纹理 + 网格)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/wood_background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
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
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _GridOverlayPainter()),
              ),
            ),

            // 2. 封面动画层 (仅在动画未完成时显示)
            if (_coverAnimation.value < 1.0)
              _buildCoverAnimation(),

            // 3. 内容层：使用 Stack 实现纸张撑大和标签置底
            Opacity(
              opacity: _coverAnimation.value,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // 纸张主体：通过设置负的 left/right 让纸张显得更大
                  Positioned(
                    top: 14,
                    left: -35,
                    right: -35,
                    bottom: 95,
                    child: _buildPaperStack(),
                  ),
                  
                  // 底部标签：绝对定位在纸张底部边缘
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40, 
                    child: _buildBottomNavigation(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCoverAnimation() {
    return Positioned.fill(
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY((1 - _coverAnimation.value) * 3.14),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF8B6F47), Color(0xFF6B4F2F)],
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
    );
  }

  /// 修改后的纸张堆叠：移除手动 scale，改用 BoxFit.fill 撑满 Positioned 区域
  Widget _buildPaperStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(0.92, 1.05, 1.0),
                  child: Image.asset(
                    'assets/profile_passport/WoodBoard.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  w * 0.12, // 适度缩小边距
                  52,      // 顶部 Padding
                  w * 0.12,
                  66,      // 底部 Padding
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.pages.length,
                  itemBuilder: (context, index) {
                    return widget.pages[index];
                  },
                ),
              ),
            ),
            // 轻微氛围叠加：暗角 + 纸张颗粒
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _VignettePainter()),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _GrainPainter()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.pageLabels.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = _currentPage == index;
    final rotation = (index % 2 == 0) ? -0.05 : 0.05;

    return Expanded(
      child: GestureDetector(
        onTap: () => _goToPage(index),
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.yellow.shade100 : Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive ? Colors.brown.shade600 : Colors.brown.shade400,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.shade300.withOpacity(0.4),
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              widget.pageLabels[index],
              textAlign: TextAlign.center,
              style: GoogleFonts.kalam(
                fontSize: isActive ? 16 : 14,
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