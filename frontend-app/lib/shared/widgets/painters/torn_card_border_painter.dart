// 撕裂卡片边框绘制器
// 模拟纸张边缘的可见边框痕迹（折页效果）

import 'package:flutter/material.dart';
import 'dart:math' as math;

class TornCardBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;

  TornCardBorderPainter({
    this.borderColor = const Color(0xFF8D6E63),
    this.borderWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withOpacity(0.4) // 半透明，模拟铅笔痕迹
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = math.Random(42); // 固定种子，保持一致性
    
    final path = Path();
    
    // --- 顶部边缘：不规则波浪 ---
    path.moveTo(0, 0);
    double x = 0;
    while (x < size.width) {
      x += 3;
      final y = math.sin(x / 15) * 2 +
          math.cos(x / 5) * 1 +
          random.nextDouble() * 0.5;
      path.lineTo(x, y.clamp(0.0, 4.0));
    }
    
    // --- 右侧边缘：轻微不规则 ---
    double y = 0;
    while (y < size.height) {
      y += 3;
      final offset = math.sin(y / 12) * 1.5 + 
          math.cos(y / 4) * 0.8 +
          random.nextDouble() * 0.3;
      path.lineTo(size.width - offset.clamp(0.0, 3.0), y);
    }
    
    // --- 底部边缘：不规则波浪 ---
    x = size.width;
    while (x > 0) {
      x -= 3;
      final offset = math.sin(x / 18) * 2.5 +
          math.cos(x / 6) * 1.2 +
          random.nextDouble() * 0.6;
      path.lineTo(x, size.height - offset.clamp(0.0, 4.0));
    }
    
    // --- 左侧边缘：撕裂效果 ---
    y = size.height;
    while (y > 0) {
      y -= 2;
      final double x = math.sin(y / 10) * 4 +
          math.cos(y / 3) * 2 +
          random.nextDouble() * 1.0 +
          3;
      
      path.lineTo(x.clamp(0.0, size.width * 0.1), y);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // --- 右下角折页效果：额外的边框强调 ---
    final cornerPaint = Paint()
      ..color = borderColor.withOpacity(0.6) // 稍微明显一点
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 1.2;
    
    // 绘制右下角的折页弧线
    final cornerPath = Path();
    final cornerRadius = 20.0;
    cornerPath.addArc(
      Rect.fromCircle(
        center: Offset(size.width - cornerRadius, size.height - cornerRadius),
        radius: cornerRadius,
      ),
      0, // 起始角度
      math.pi / 2, // 90度
    );
    canvas.drawPath(cornerPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

