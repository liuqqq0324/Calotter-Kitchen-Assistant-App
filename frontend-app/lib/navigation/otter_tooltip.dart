import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// 提示类型
enum OtterTooltipType {
  welcome, // 欢迎提示
  guide, // 功能引导
  pageHint, // 页面特定提示
  actionHint, // 操作提示
}

/// 海獭提示气泡组件
class OtterTooltip extends StatefulWidget {
  final String message;
  final OtterTooltipType type;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;
  final bool showArrow;

  const OtterTooltip({
    super.key,
    required this.message,
    this.type = OtterTooltipType.guide,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 5),
    this.showArrow = true,
  });

  @override
  State<OtterTooltip> createState() => _OtterTooltipState();
}

class _OtterTooltipState extends State<OtterTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // 自动隐藏
    if (widget.autoHideDuration.inMilliseconds > 0) {
      Future.delayed(widget.autoHideDuration, () {
        if (mounted && _isVisible) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!_isVisible) return;
    setState(() {
      _isVisible = false;
    });
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case OtterTooltipType.welcome:
        return Colors.orange.shade100;
      case OtterTooltipType.guide:
        return Colors.blue.shade50;
      case OtterTooltipType.pageHint:
        return Colors.green.shade50;
      case OtterTooltipType.actionHint:
        return Colors.purple.shade50;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case OtterTooltipType.welcome:
        return Colors.orange.shade400;
      case OtterTooltipType.guide:
        return Colors.blue.shade300;
      case OtterTooltipType.pageHint:
        return Colors.green.shade300;
      case OtterTooltipType.actionHint:
        return Colors.purple.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _dismiss,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getBorderColor(), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 海獭emoji
                const Text('🦦', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                // 提示文字
                Flexible(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.kalam(
                      fontSize: 14,
                      color: Colors.brown.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 关闭按钮
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 带箭头指向的提示气泡（用于海獭按钮上方）
class OtterTooltipWithArrow extends StatelessWidget {
  final String message;
  final OtterTooltipType type;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;
  final ArrowPosition arrowPosition;

  const OtterTooltipWithArrow({
    super.key,
    required this.message,
    this.type = OtterTooltipType.guide,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 5),
    this.arrowPosition = ArrowPosition.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        OtterTooltip(
          message: message,
          type: type,
          onDismiss: onDismiss,
          autoHideDuration: autoHideDuration,
          showArrow: false,
        ),
        // 箭头（指向海獭按钮）
        if (arrowPosition == ArrowPosition.bottom)
          Positioned(
            bottom: -8,
            right: 32, // 箭头位置，指向海獭按钮中心
            child: CustomPaint(
              size: const Size(16, 8),
              painter: _ArrowPainter(
                color: _getBorderColor(),
                direction: ArrowDirection.down,
              ),
            ),
          )
        else if (arrowPosition == ArrowPosition.top)
          Positioned(
            top: -8,
            right: 32,
            child: CustomPaint(
              size: const Size(16, 8),
              painter: _ArrowPainter(
                color: _getBorderColor(),
                direction: ArrowDirection.up,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBorderColor() {
    switch (type) {
      case OtterTooltipType.welcome:
        return Colors.orange.shade400;
      case OtterTooltipType.guide:
        return Colors.blue.shade300;
      case OtterTooltipType.pageHint:
        return Colors.green.shade300;
      case OtterTooltipType.actionHint:
        return Colors.purple.shade300;
    }
  }
}

enum ArrowPosition { top, bottom, left, right }

enum ArrowDirection { up, down, left, right }

class _ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;

  _ArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (direction == ArrowDirection.down) {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    } else if (direction == ArrowDirection.up) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
