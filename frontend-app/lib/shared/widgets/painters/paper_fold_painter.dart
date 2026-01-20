// 纸张卷角绘制器
// 用于绘制右下角的翻折效果，模拟纸张自然卷起

import 'package:flutter/material.dart';

class PaperFoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0E6D2) // 比纸张稍微深一点，模拟背光面
      ..style = PaintingStyle.fill;

    final path = Path();
    // 画一个三角形，模拟翻折
    path.moveTo(size.width, 0); // 右上
    path.lineTo(0, size.height); // 左下
    path.quadraticBezierTo(size.width, size.height, size.width, 0); // 稍微弯曲的边

    canvas.drawPath(path, paint);

    // 加一点阴影让卷角更立体
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

