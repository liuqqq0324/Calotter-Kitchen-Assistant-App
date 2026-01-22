import 'package:flutter/material.dart';
import 'package:personal_sous_chef/navigation/bottom_nav_config.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/navigation/otter_tooltip.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';
import 'dart:math' as math;

/// 海獭浮动导航组件
/// 从屏幕右下角向上滑动可以展开导航菜单
/// 支持拖动海獭按钮到任意位置
class OtterFloatingNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const OtterFloatingNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<OtterFloatingNav> createState() => _OtterFloatingNavState();
}

class _OtterFloatingNavState extends State<OtterFloatingNav>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

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

    // 初始化时检查并显示提示
    _checkAndShowTooltip();
  }

  /// 检查并显示提示
  Future<void> _checkAndShowTooltip() async {
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
    super.dispose();
  }

  void _toggleMenu() {
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

          // 🦦 提示气泡（在海獭按钮上方）
          if (_currentTooltipMessage != null)
            Positioned(
              right: 16 + _position.dx - 120, // 调整位置，使气泡在海獭按钮上方居中（气泡宽度约240）
              bottom: 16 + _position.dy + 80, // 在海獭按钮上方
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.7, // 最大宽度为屏幕的70%
                ),
                child: OtterTooltipWithArrow(
                  message: _currentTooltipMessage!,
                  type: _currentTooltipType,
                  arrowPosition: ArrowPosition.bottom,
                  onDismiss: _hideTooltip,
                  autoHideDuration: const Duration(seconds: 5),
                ),
              ),
            ),

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
                child: _buildOtterImage(),
              ),
            ),
          ),
        ],
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

  // 🔥 修复后的菜单构建逻辑
  Widget _buildExpandedMenu(Size screenSize, EdgeInsets safeArea) {
    final destinations = BottomNavConfig.destinations;

    final buttonSize = 120.0;

    // 按钮的实际位置
    final buttonRight = 16.0 + _position.dx;
    final buttonBottom = 16.0 + _position.dy;

    // 按钮中心坐标（相对于屏幕左上角）
    final buttonCenterX = screenSize.width - buttonRight - buttonSize / 2;
    final buttonCenterY =
        screenSize.height - safeArea.bottom - buttonBottom - buttonSize / 2;
    final buttonCenter = Offset(buttonCenterX, buttonCenterY);

    final itemSize = 110.0;
    final itemHalf = itemSize / 2;

    // 🔥 关键 1: 定义一个严格的安全区域，确保 Item 完全显示在屏幕内
    // 不仅仅是中心点在屏幕内，而是边缘也要在屏幕内 (inset by itemHalf)
    final safeRect = Rect.fromLTRB(
      safeArea.left + itemHalf,
      safeArea.top + itemHalf,
      screenSize.width - safeArea.right - itemHalf,
      screenSize.height - safeArea.bottom - itemHalf,
    );

    // 最小间距定义
    final minDistanceFromButton =
        (buttonSize / 2) + (itemSize / 2) - 10; // 允许轻微重叠看起来更紧凑
    final minItemSpacing = itemSize * 0.85; // Item 之间的最小距离

    // 计算朝向屏幕中心的角度
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final towardCenterAngle = math.atan2(
      screenCenter.dy - buttonCenter.dy,
      screenCenter.dx - buttonCenter.dx,
    );

    // 生成候选点的方法
    List<Offset> candidateCenters({
      required double radius,
      required double spreadRadians,
    }) {
      final count = destinations.length;
      if (count == 1) {
        final c =
            buttonCenter +
            Offset(math.cos(towardCenterAngle), math.sin(towardCenterAngle)) *
                radius;
        return [c];
      }
      return List.generate(count, (i) {
        // 在扇形区域内均匀分布
        final t = (i / (count - 1)) - 0.5; // range [-0.5, 0.5]
        final angle = towardCenterAngle + t * spreadRadians;
        return buttonCenter + Offset(math.cos(angle), math.sin(angle)) * radius;
      });
    }

    // 检查一组点是否有效
    bool centersFit(List<Offset> centers) {
      for (int i = 0; i < centers.length; i++) {
        final c = centers[i];
        // 1. 检查是否在安全区域内
        if (!safeRect.contains(c)) return false;

        // 2. 检查是否遮挡了海獭按钮
        if ((c - buttonCenter).distance < minDistanceFromButton) return false;

        // 3. 检查互相重叠
        for (int j = i + 1; j < centers.length; j++) {
          if ((c - centers[j]).distance < minItemSpacing) return false;
        }
      }
      return true;
    }

    // 🔥 关键 2: 扩展搜索策略
    // 增加更小的半径 (100, 110) 和 更大的角度范围，以便在角落挤得下
    final radii = <double>[130, 120, 110, 100];
    final spreads = <double>[3.8, 3.2, 2.5, 2.0, 1.5]; // 弧度

    List<Offset> finalCenters = const [];
    bool found = false;

    // 尝试寻找完美布局
    for (final r in radii) {
      for (final s in spreads) {
        final c = candidateCenters(radius: r, spreadRadians: s);
        if (centersFit(c)) {
          finalCenters = c;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    // 🔥 关键 3: 物理防重叠兜底 (Relaxation Algorithm)
    // 如果上面找不到完美布局（比如在死角），我们手动计算位置
    if (!found) {
      // 1. 初始位置：朝向屏幕中心，用较小的半径紧凑排列
      List<Offset> currentPositions = candidateCenters(
        radius: 110,
        spreadRadians: 2.0,
      );

      // 迭代多次以解开重叠 (类似物理引擎的迭代求解)
      for (int iter = 0; iter < 10; iter++) {
        for (int i = 0; i < currentPositions.length; i++) {
          Offset pos = currentPositions[i];

          // A. 强制拉回屏幕内 (Clamp to Screen)
          double dx = pos.dx.clamp(safeRect.left, safeRect.right);
          double dy = pos.dy.clamp(safeRect.top, safeRect.bottom);
          pos = Offset(dx, dy);

          // B. 解决与海獭按钮的重叠 (Repel from Button)
          Offset vecToButton = pos - buttonCenter;
          double distToButton = vecToButton.distance;
          if (distToButton < minDistanceFromButton) {
            if (distToButton == 0) vecToButton = const Offset(1, 0); // 防止除零
            // 向外推
            pos =
                buttonCenter +
                (vecToButton / distToButton) * minDistanceFromButton;
          }

          // C. 解决与其他 Item 的重叠 (Repel from others)
          for (int j = 0; j < currentPositions.length; j++) {
            if (i == j) continue;
            Offset vecToOther = pos - currentPositions[j];
            double distToOther = vecToOther.distance;

            if (distToOther < minItemSpacing) {
              if (distToOther == 0)
                vecToOther = Offset(
                  math.Random().nextDouble() - 0.5,
                  math.Random().nextDouble() - 0.5,
                );
              // 稍微推开一点，每次迭代推一点，直到解开
              double pushDist = (minItemSpacing - distToOther) * 0.5;
              pos += (vecToOther / distToOther) * pushDist;
            }
          }

          currentPositions[i] = pos;
        }
      }
      finalCenters = currentPositions;
    }

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(destinations.length, (index) {
          final c = finalCenters[index];

          return Positioned(
            left: c.dx - itemHalf,
            top: c.dy - itemHalf,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleItemTap(index),
                customBorder: const CircleBorder(),
                child: AnimatedScale(
                  scale: _expandAnimation.value,
                  duration: Duration(milliseconds: 100 + index * 50),
                  curve: Curves.easeOutBack,
                  child: Stack(
                    alignment: Alignment.center, // 确保所有子元素居中
                    clipBehavior: Clip.none, // 允许内容超出边界
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B4F4F),
                            shadows: [
                              Shadow(
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1.5,
                                color: const Color(
                                  0xFF4A3A3A,
                                ).withOpacity(0.2), // 微弱的深色投影
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
