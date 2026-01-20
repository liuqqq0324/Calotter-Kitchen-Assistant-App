// 手绘方框绘制器
// 用于绘制图标框的手绘风格边框

import 'package:flutter/material.dart';

class SketchyBoxPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SketchyBoxPainter({
    this.color = const Color(0xFF8D6E63),
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 画两圈，模拟随意画的感觉
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 第一圈
    canvas.drawRect(rect, paint);

    // 第二圈 (稍微错位)
    final path = Path();
    path.moveTo(-1, -1);
    path.lineTo(size.width + 1, 2);
    path.lineTo(size.width - 1, size.height + 1);
    path.lineTo(2, size.height - 1);
    path.close();

    paint.color = paint.color.withOpacity(0.4); // 第二圈淡一点
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

