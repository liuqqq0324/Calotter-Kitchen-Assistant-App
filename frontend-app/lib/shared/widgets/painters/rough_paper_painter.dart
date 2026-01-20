// 手工纸张绘制器（毛边纸 + 内描边）
// 模拟 Deckle Edge（毛边纸）的细碎抖动边缘，以及内部铅笔手绘的内框线

import 'package:flutter/material.dart';
import 'dart:math' as math;

class RoughPaperPainter extends CustomPainter {
  final Color paperColor;
  final Color borderColor;
  final double borderPadding;

  RoughPaperPainter({
    this.paperColor = const Color(0xFFFDFBF7), // 米白纸
    this.borderColor = const Color(0xFF4E342E),
    this.borderPadding = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final paperPaint = Paint()..color = paperColor;

    // 铅笔描边
    final strokePaint = Paint()
      ..color = borderColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // --- 步骤A: 生成不规则边缘路径 (Deckle Edge) ---
    final path = Path();
    // 这种 paper 不像撕裂那么夸张，而是细碎的抖动
    // 我们用多个微小的正弦波叠加

    // 上边
    path.moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 2) {
      path.lineTo(x, math.sin(x / 5) * 1.5 + math.cos(x / 3) * 0.5);
    }
    // 右边
    for (double y = 0; y <= size.height; y += 2) {
      path.lineTo(size.width + math.sin(y / 4) * 1.0, y);
    }
    // 下边
    for (double x = size.width; x >= 0; x -= 2) {
      path.lineTo(x, size.height + math.sin(x / 6) * 1.5);
    }
    // 左边
    for (double y = size.height; y >= 0; y -= 2) {
      path.lineTo(math.sin(y / 5) * 1.0, y);
    }
    path.close();

    // 绘制阴影
    canvas.drawPath(path.shift(const Offset(2, 4)), shadowPaint);
    // 绘制纸张
    canvas.drawPath(path, paperPaint);

    // --- 步骤B: 绘制内描边 (The Sketchy Inner Border) ---
    // 参考图中，纸张边缘内部有一圈手绘的线
    final borderPath = Path();
    double pad = borderPadding;

    borderPath.moveTo(pad, pad);
    // 模拟手画直线的颤抖，用贝塞尔曲线微调
    borderPath.quadraticBezierTo(
      size.width / 2,
      pad + 1,
      size.width - pad,
      pad,
    ); // 上
    borderPath.quadraticBezierTo(
      size.width - pad - 1,
      size.height / 2,
      size.width - pad,
      size.height - pad,
    ); // 右
    borderPath.quadraticBezierTo(
      size.width / 2,
      size.height - pad - 1,
      pad,
      size.height - pad,
    ); // 下
    borderPath.quadraticBezierTo(pad + 1, size.height / 2, pad, pad); // 左

    canvas.drawPath(borderPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
