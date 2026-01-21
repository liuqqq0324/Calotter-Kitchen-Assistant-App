import 'package:flutter/material.dart';
import 'package:personal_sous_chef/navigation/bottom_nav_config.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/navigation/otter_tooltip.dart';
import 'package:personal_sous_chef/navigation/otter_tooltip_manager.dart';
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
  String? _currentTooltipId;
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
    if (tooltipId != null) {
      final hasShown = await OtterTooltipManager.hasShown(tooltipId);
      if (!hasShown && mounted) {
        setState(() {
          _currentTooltipId = tooltipId;
          _currentTooltipMessage = _getTooltipMessageForPage(widget.selectedIndex);
          _currentTooltipType = _getTooltipTypeForPage(widget.selectedIndex);
        });
      }
    }
  }
  
  /// 根据页面获取提示ID
  String? _getTooltipIdForPage(int index) {
    switch (index) {
      case 0:
        return OtterTooltipIds.homePageHint;
      case 1:
        return OtterTooltipIds.recipesPageHint;
      case 2:
        return OtterTooltipIds.addItemHint;
      case 3:
        return OtterTooltipIds.kitchenPageHint;
      case 4:
        return OtterTooltipIds.profilePageHint;
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
    if (_currentTooltipId != null) {
      OtterTooltipManager.markAsShown(_currentTooltipId!);
    }
    setState(() {
      _currentTooltipId = null;
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
                final newDy = _position.dy - details.delta.dy; // Y轴反向（Flutter坐标系）
                
                // 计算边界（按钮大小64 + 边距16）
                final buttonSize = 64.0;
                final maxDx = screenSize.width - buttonSize - 16;
                final maxDy = screenSize.height - safeArea.bottom - buttonSize - 16;
                
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
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.brown.shade300,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildOtterImage(),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtterImage() {
    // TODO: 替换为从参考图抠出的海獭形象
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '🦦',
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
    // 后续替换为：
    // return Image.asset(
    //   'assets/profile_passport/otter_floating.png',
    //   fit: BoxFit.cover,
    // );
  }

  // 🔥 修复：简化菜单位置计算，确保正确显示
  Widget _buildExpandedMenu(Size screenSize, EdgeInsets safeArea) {
    final destinations = BottomNavConfig.destinations;
    final buttonSize = 64.0;
    final buttonRight = 16.0 + _position.dx;
    final buttonBottom = 16.0 + _position.dy;
    
    // 按钮中心位置（相对于屏幕）
    final buttonCenterX = screenSize.width - buttonRight - buttonSize / 2;
    final buttonCenterY = screenSize.height - safeArea.bottom - buttonBottom - buttonSize / 2;
    
    // 菜单半径（固定值，简化计算）
    final radius = 100.0;
    final itemSize = 56.0;
    final itemRadius = radius * 0.75; // 菜单项距离中心的距离
    final centerAngle = -math.pi / 2; // 从上方开始（12点方向）
    
    // 菜单容器大小
    final menuContainerSize = radius * 2;
    
    // 🔥 计算菜单容器的位置（确保不超出屏幕）
    final menuLeft = (buttonCenterX - radius).clamp(
      safeArea.left,
      screenSize.width - menuContainerSize - safeArea.right,
    );
    final menuTop = (buttonCenterY - radius).clamp(
      safeArea.top,
      screenSize.height - safeArea.bottom - menuContainerSize,
    );

    return Positioned(
      left: menuLeft,
      top: menuTop,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          width: menuContainerSize,
          height: menuContainerSize,
          child: Stack(
            children: List.generate(destinations.length, (index) {
              // 🔥 修复：计算每个菜单项相对于容器左上角的位置（扇形分布）
              final angle = centerAngle + (index * 2 * math.pi / destinations.length);
              final x = radius + itemRadius * math.cos(angle);
              final y = radius + itemRadius * math.sin(angle);

              final isSelected = widget.selectedIndex == index;

              return Positioned(
                left: x - itemSize / 2,
                top: y - itemSize / 2,
                child: GestureDetector(
                  onTap: () => _handleItemTap(index),
                  child: AnimatedScale(
                    scale: _expandAnimation.value,
                    duration: Duration(milliseconds: 100 + index * 50),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.brown.shade200 
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? Colors.brown.shade600 
                              : Colors.brown.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 使用 NavigationDestination 的 icon 或 selectedIcon
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: isSelected && destinations[index].selectedIcon != null
                                ? destinations[index].selectedIcon!
                                : destinations[index].icon,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            destinations[index].label,
                            style: GoogleFonts.kalam(
                              fontSize: 9,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              color: isSelected 
                                  ? Colors.brown.shade900 
                                  : Colors.brown.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
