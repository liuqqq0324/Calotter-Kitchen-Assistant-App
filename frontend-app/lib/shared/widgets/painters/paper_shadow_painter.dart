// 纸张阴影绘制器
// 用于绘制手绘风格的阴影效果

import 'package:flutter/material.dart';

class PaperShadowPainter extends CustomPainter {
  final double blurRadius;
  final double opacity;

  PaperShadowPainter({
    this.blurRadius = 10.0,
    this.opacity = 0.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius); // 高斯模糊

    final path = Path();
    // 简单模拟纸张形状，稍微小一点
    path.addRect(Rect.fromLTWH(5, 5, size.width - 10, size.height - 10));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

