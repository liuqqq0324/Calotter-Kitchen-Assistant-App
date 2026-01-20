// 波点胶带绘制器
// 用于绘制带波点图案的日式胶带（Washi Tape）效果

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';

class WashiTapePainter extends CustomPainter {
  final Color tapeColor;
  final double tearDepth;

  WashiTapePainter({
    this.tapeColor = AppStyle.tapeColorLight,
    this.tearDepth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = tapeColor;

    final path = Path();

    // 上边缘：撕裂效果 (ZigZag)
    path.moveTo(0, 0);
    for (double i = 0; i < size.width; i += 5) {
      path.lineTo(i + 2.5, i % 10 == 0 ? -tearDepth : 0);
    }
    path.lineTo(size.width, 0);

    // 右边
    path.lineTo(size.width, size.height);

    // 下边缘：撕裂效果
    for (double i = size.width; i > 0; i -= 5) {
      path.lineTo(i - 2.5, size.height + (i % 10 == 0 ? -tearDepth : 0));
    }
    path.lineTo(0, size.height);
    path.close();

    // 绘制胶带底色
    canvas.drawPath(path, paint);

    // 绘制胶带半透明感
    canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.2));

    // --- 绘制波点 (Polka Dots) ---
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);
    double dotSize = 3.0;
    double spacing = 10.0;

    for (double y = 10; y < size.height; y += spacing) {
      for (double x = 6; x < size.width; x += spacing) {
        // 交错排列
        double offsetX = (y ~/ spacing) % 2 == 0 ? 0 : spacing / 2;
        if (x + offsetX < size.width - 2) {
          canvas.drawCircle(Offset(x + offsetX, y), dotSize, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

