import 'package:flutter/material.dart';
import 'package:personal_sous_chef/navigation/bottom_nav_config.dart';
import 'package:personal_sous_chef/navigation/otter_tooltip.dart';
import 'dart:math' as math;

/// 海獭浮动导航组件
/// 从屏幕右下角向上滑动可以展开导航菜单
/// 支持拖动海獭按钮到任意位置
class OtterFloatingNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isListening; // 🔥 新增：监听状态

  const OtterFloatingNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isListening = false, // 默认不监听
  });

  @override
  State<OtterFloatingNav> createState() => OtterFloatingNavState();
}

class OtterFloatingNavState extends State<OtterFloatingNav>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // 点击时缓慢抖动
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // 🔥 添加位置状态，支持拖动
  Offset _position = Offset.zero; // 相对于初始位置的偏移

  // 🦦 提示相关状态
  String? _currentTooltipMessage;
  OtterTooltipType _currentTooltipType = OtterTooltipType.guide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // 点击缓慢抖动：约 ±4.5° 左右摆两次后回正，总时长 600ms
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    const double wobbleRad = 0.08;
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: -wobbleRad),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -wobbleRad, end: wobbleRad),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween(begin: wobbleRad, end: -wobbleRad * 0.5),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -wobbleRad * 0.5, end: 0.0),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    // 初始化时检查并显示提示
    _checkAndShowTooltip();
  }

  /// 检查并显示提示
  Future<void> _checkAndShowTooltip() async {
    // 🔥 如果正在监听，不显示默认页面提示，避免遮挡语音提示
    if (widget.isListening) return;

    // 根据当前页面显示不同的提示
    final tooltipId = _getTooltipIdForPage(widget.selectedIndex);
    if (tooltipId != null && mounted) {
      // ✅ 需求：只要跳转到新页面就显示提示（不做“只弹一次”拦截）
      setState(() {
        _currentTooltipMessage = _getTooltipMessageForPage(
          widget.selectedIndex,
        );
        _currentTooltipType = _getTooltipTypeForPage(widget.selectedIndex);
      });
    }
  }

  /// 根据页面获取提示ID
  String? _getTooltipIdForPage(int index) {
    switch (index) {
      case 0:
        return 'home_page_hint';
      case 1:
        return 'recipes_page_hint';
      case 2:
        return 'add_item_hint';
      case 3:
        return 'kitchen_page_hint';
      case 4:
        return 'profile_page_hint';
      default:
        return null;
    }
  }

  /// 根据页面获取提示消息
  String _getTooltipMessageForPage(int index) {
    switch (index) {
      case 0:
        return 'Welcome to Home! 🏠\nClick me to explore features';
      case 1:
        return 'Browse recipes here! 📖\nFind your favorite dishes';
      case 2:
        return 'Add items to your kitchen! ➕\nTrack your ingredients';
      case 3:
        return 'Manage your kitchen! 🍳\nSee what you have';
      case 4:
        return 'Your profile! 👤\nManage your settings';
      default:
        return 'Click me to explore! 🦦';
    }
  }

  /// 根据页面获取提示类型
  OtterTooltipType _getTooltipTypeForPage(int index) {
    switch (index) {
      case 0:
        return OtterTooltipType.welcome;
      default:
        return OtterTooltipType.pageHint;
    }
  }

  /// 隐藏当前提示
  void _hideTooltip() {
    setState(() {
      _currentTooltipMessage = null;
    });
  }

  /// ✅ 公开方法：从外部显示临时消息
  void showMessage(
    String message, {
    OtterTooltipType type = OtterTooltipType.actionHint,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;
    setState(() {
      _currentTooltipMessage = message;
      _currentTooltipType = type;
    });
  }

  @override
  void didUpdateWidget(OtterFloatingNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 页面切换时检查并显示新提示
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _checkAndShowTooltip();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    // 点击时触发缓慢抖动
    _shakeController.forward(from: 0);
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        // 展开菜单时隐藏提示
        _hideTooltip();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleItemTap(int index) {
    widget.onItemTapped(index);
    _toggleMenu(); // 选择后自动收起菜单
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 展开的导航菜单（条件渲染）
          if (_isExpanded)
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return _buildExpandedMenu(screenSize, safeArea);
              },
            ),

          // 🦦 提示气泡（在海獭按钮上方），约束在屏幕内
          if (_currentTooltipMessage != null) ...[
            _buildTooltipPositioned(screenSize, safeArea),
          ],

          // 🔥 海獭浮动按钮 - 支持拖动
          Positioned(
            right: 16 + _position.dx,
            bottom: 16 + _position.dy,
            child: GestureDetector(
              onTap: _toggleMenu,
              // 🔥 使用 onPanUpdate 替代 onVerticalDragUpdate，支持任意方向拖动
              onPanUpdate: (details) {
                setState(() {
                  // 限制拖动范围，不超出屏幕
                  // 🔥 修复：反转 delta.dx，因为 right 是距离右边的距离
                  final newDx = _position.dx - details.delta.dx; // 反转 X 轴
                  final newDy =
                      _position.dy - details.delta.dy; // Y轴反向（Flutter坐标系）

                  // 计算边界（按钮大小120 + 边距16）
                  final buttonSize = 120.0;
                  final maxDx = screenSize.width - buttonSize - 16;
                  final maxDy =
                      screenSize.height - safeArea.bottom - buttonSize - 16;

                  _position = Offset(
                    newDx.clamp(-16.0, maxDx),
                    newDy.clamp(-16.0, maxDy),
                  );
                });
              },
              // 🔥 检测向上滑动展开菜单
              onPanEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond;
                // 向上滑动且速度足够快时展开菜单
                if (velocity.dy < -500 && !_isExpanded) {
                  _toggleMenu();
                }
                // 向下滑动且速度足够快时收起菜单
                else if (velocity.dy > 500 && _isExpanded) {
                  _toggleMenu();
                }
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _shakeAnimation.value,
                      child: child,
                    );
                  },
                  child: widget.isListening
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 1.1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: _buildOtterImage(),
                            );
                          },
                          onEnd: () {
                            // 循环缩放动画
                            setState(() {});
                          },
                        )
                      : _buildOtterImage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建提示气泡，并约束在屏幕范围内不溢出
  Widget _buildTooltipPositioned(Size screenSize, EdgeInsets safeArea) {
    const double tooltipPadding = 16.0;
    const double estimatedTooltipHeight = 100.0; // 约 3 行文字 + 内边距
    final double maxTooltipWidth = screenSize.width * 0.7;

    // 期望位置：在海獭按钮上方居中（气泡视觉中心约在按钮中心）
    double right = 16 + _position.dx - 120;
    double bottom = 16 + _position.dy + 110; // 与悬浮按钮的垂直间距（原 80，加大以更清晰）

    // 水平约束：right 表示气泡右缘到屏幕右缘的距离
    // 右缘不超出：right >= tooltipPadding
    // 左缘不超出：气泡左缘 = 屏幕宽 - right - 气泡宽 >= tooltipPadding => right <= 屏幕宽 - 最大宽 - tooltipPadding
    final double minRight = tooltipPadding;
    final double maxRight =
        screenSize.width - maxTooltipWidth - tooltipPadding;
    right = right.clamp(minRight, maxRight);

    // 垂直约束：bottom 表示气泡下缘到屏幕下缘的距离
    // 上缘不超出：气泡顶 = 屏幕高 - bottom - 气泡高 >= safeArea.top + tooltipPadding
    final double maxBottom = screenSize.height -
        safeArea.top -
        tooltipPadding -
        estimatedTooltipHeight;
    bottom = bottom.clamp(0.0, maxBottom);

    return Positioned(
      right: right,
      bottom: bottom,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxTooltipWidth),
        child: OtterTooltipWithArrow(
          message: _currentTooltipMessage!,
          type: _currentTooltipType,
          arrowPosition: ArrowPosition.bottom,
          onDismiss: _hideTooltip,
          autoHideDuration: const Duration(seconds: 5),
        ),
      ),
    );
  }

  Widget _buildOtterImage() {
    return Image.asset(
      'assets/images/otter_floating_transparent.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to emoji if image fails to load
        return Container(
          decoration: BoxDecoration(
            color: Colors.brown.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('🦦', style: const TextStyle(fontSize: 40)),
          ),
        );
      },
    );
  }

  // 🔥 修复后的智能菜单构建逻辑
  Widget _buildExpandedMenu(Size screenSize, EdgeInsets safeArea) {
    final destinations = BottomNavConfig.destinations;
    final int count = destinations.length;

    final buttonSize = 120.0;

    // 1. 计算按钮中心位置
    final buttonRight = 16.0 + _position.dx;
    final buttonBottom = 16.0 + _position.dy;
    final buttonCenterX = screenSize.width - buttonRight - buttonSize / 2;
    final buttonCenterY =
        screenSize.height - safeArea.bottom - buttonBottom - buttonSize / 2;
    final buttonCenter = Offset(buttonCenterX, buttonCenterY);

    // 2. 配置子菜单项参数
    final itemSize = 55.0;
    final itemHalf = itemSize / 2;

    // 基础半径 (海獭半径60 + 间隙 + 贝壳半径27.5)
    final double radius = 100.0;

    // 3. 定义安全区域 (确保子项完全展示在屏幕内)
    final double safeLeft = safeArea.left + itemHalf + 8; // +8 留点边距
    final double safeRight = screenSize.width - safeArea.right - itemHalf - 8;
    final double safeTop = safeArea.top + itemHalf + 8;
    final double safeBottom =
        screenSize.height - safeArea.bottom - itemHalf - 8;

    // 4. 计算初始角度：朝向屏幕中心
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    double baseAngle = math.atan2(
      screenCenter.dy - buttonCenter.dy,
      screenCenter.dx - buttonCenter.dx,
    );

    // 5. 初始展开幅度 (Spread)
    // 默认约 100~120 度，根据项目数量微调
    double spread = 110 * (math.pi / 180);

    // --- 🚀 智能适配核心算法 ---

    // 步骤 A: 预计算最外侧两个点的坐标 (Start 和 End)
    // 检查它们是否超出边界，如果超出，就旋转 baseAngle
    for (int step = 0; step < 20; step++) {
      // 尝试修正最多20次
      double startAngle = baseAngle - spread / 2;
      double endAngle = baseAngle + spread / 2;

      Offset startPos =
          buttonCenter +
          Offset(math.cos(startAngle), math.sin(startAngle)) * radius;
      Offset endPos =
          buttonCenter +
          Offset(math.cos(endAngle), math.sin(endAngle)) * radius;

      bool startOut = !_isInside(
        startPos,
        safeLeft,
        safeRight,
        safeTop,
        safeBottom,
      );
      bool endOut = !_isInside(
        endPos,
        safeLeft,
        safeRight,
        safeTop,
        safeBottom,
      );

      if (!startOut && !endOut) {
        break; // 都在界内，完美！
      }

      if (startOut && endOut) {
        // 两个都出界了（通常是卡在角落），说明 Spread 太宽了，缩小展开角度
        spread *= 0.9;
      } else if (startOut) {
        // 起始点出界，向 End 方向旋转
        baseAngle += 0.1; // 约 5 度
      } else if (endOut) {
        // 结束点出界，向 Start 方向旋转
        baseAngle -= 0.1;
      }
    }

    // 6. 生成最终坐标
    List<Offset> finalPositions = List.generate(count, (i) {
      // 线性分布
      double t = (count > 1) ? i / (count - 1) : 0.5;
      double angle = baseAngle - (spread / 2) + (spread * t);

      Offset pos =
          buttonCenter + Offset(math.cos(angle), math.sin(angle)) * radius;

      // 兜底：最后的最后，如果还是有一点点出界（比如计算误差），强制 Clamp 回来
      // 这只会导致轻微的贴边，不会导致乱序
      double cx = pos.dx.clamp(safeLeft, safeRight);
      double cy = pos.dy.clamp(safeTop, safeBottom);
      return Offset(cx, cy);
    });

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (index) {
          final pos = finalPositions[index];

          return Positioned(
            left: pos.dx - itemHalf,
            top: pos.dy - itemHalf,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleItemTap(index),
                customBorder: const CircleBorder(),
                child: AnimatedScale(
                  scale: _expandAnimation.value,
                  duration: Duration(milliseconds: 150 + index * 50),
                  curve: Curves.easeOutBack,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Shell.png',
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.fill,
                      ),
                      Center(
                        child: Text(
                          destinations[index].label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PatrickHand',
                            fontSize: 13, // 稍微调小一点字体适配小贝壳
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B4F4F),
                            height: 1.0,
                            shadows: [
                              Shadow(
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1.5,
                                color: const Color(0xFF4A3A3A).withOpacity(0.2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 辅助函数：检查点是否在安全区内
  bool _isInside(
    Offset p,
    double left,
    double right,
    double top,
    double bottom,
  ) {
    return p.dx >= left && p.dx <= right && p.dy >= top && p.dy <= bottom;
  }
}

/// Custom painter for sketchy button border
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;
  final math.Random _random;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  }) : _random = math.Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  Path _createSketchyPath(Size size) {
    final path = Path();
    const double step = 8.0; // Distance between points on the path
    final double wobble = wobbleAmount;

    // Top edge: left to right
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, noise);
    }
    path.lineTo(size.width, 0);

    // Right edge: top to bottom
    for (double y = step; y < size.height; y += step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(size.width + noise, y);
    }
    path.lineTo(size.width, size.height);

    // Bottom edge: right to left
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, size.height + noise);
    }
    path.lineTo(0, size.height);

    // Left edge: bottom to top
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(noise, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
