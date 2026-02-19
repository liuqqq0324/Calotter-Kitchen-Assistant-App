// 手绘感边框绘制器
// 模拟铅笔手绘的不规则边框效果，线条微微颤抖

import 'package:flutter/material.dart';

class SketchyBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SketchyBorderPainter({
    this.color = const Color(0xFF8D6E63),
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();

    // 模拟手画的矩形，起点和终点不完全重合，线条稍微弯曲
    path.moveTo(2, 2);
    path.quadraticBezierTo(size.width / 2, 0, size.width - 2, 3); // 上线
    path.quadraticBezierTo(size.width, size.height / 2, size.width - 3, size.height - 2); // 右线
    path.quadraticBezierTo(size.width / 2, size.height, 2, size.height - 3); // 下线
    path.quadraticBezierTo(0, size.height / 2, 2, 2); // 左线

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

