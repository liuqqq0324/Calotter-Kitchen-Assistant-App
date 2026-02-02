import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 手绘风格笔刷背景组件
/// 用于包裹文字，呈现水彩/毛笔划过的不规则形状，边缘带晕染效果
class WashedBrushBackground extends StatelessWidget {
  final Widget child;
  final Color color;
  final int seed;
  final EdgeInsets padding;

  const WashedBrushBackground({
    super.key,
    required this.child,
    this.color = const Color(0xE8F5EDE0), // 米白色，半透明透出木纹
    this.seed = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _WashedBrushPainter(
              color: color,
              seed: seed,
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }
}

class _WashedBrushPainter extends CustomPainter {
  final Color color;
  final int seed;

  _WashedBrushPainter({required this.color, required this.seed});

  /// 生成单笔横向笔刷路径（带随机弧度）
  Path _createStrokePath(
    math.Random rnd,
    double w,
    double h,
  ) {
    final centerY = h / 2;
    // 起点略偏左随机；终点缩短，避免右边空白过多
    final startX = (rnd.nextDouble() * 2 - 1) * (5 + rnd.nextDouble() * 8);
    final endX = w - (10 + rnd.nextDouble() * 15); // 右边缩短 10-25px
    // startY、endY 在中心线上下随机偏移，拉宽笔刷上下范围
    final startY = centerY + (rnd.nextDouble() * 2 - 1) * (h * 0.25);
    final endY = centerY + (rnd.nextDouble() * 2 - 1) * (h * 0.25);
    // 随机控制点，让线条有轻微弧度
    final ctrlX = (startX + endX) / 2 + (rnd.nextDouble() * 2 - 1) * 25;
    final ctrlY = (startY + endY) / 2 + (rnd.nextDouble() * 2 - 1) * (h * 0.2);

    final path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(ctrlX, ctrlY, endX, endY);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;
    final rnd = math.Random(seed);

    // 3 到 5 笔叠加
    final strokeCount = 3 + rnd.nextInt(3);

    for (int i = 0; i < strokeCount; i++) {
      final path = _createStrokePath(rnd, w, h);

      // 笔触粗细：文字高度的 55%-80%，上下拉宽
      final strokeWidth = h * (0.55 + rnd.nextDouble() * 0.25);
      // 透明度 0.3 到 0.5，多笔重叠处颜色深、边缘浅（调高以更明显）
      final alpha = 0.3 + rnd.nextDouble() * 0.2;
      final strokeColor = color.withOpacity(alpha);

      final paint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WashedBrushPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.seed != seed;
  }
}
