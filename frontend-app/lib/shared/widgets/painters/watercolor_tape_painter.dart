// 蓝色水彩胶带绘制器
// 模拟半透明水彩质感，颜色不均匀（边缘深中间浅），边缘是纤维状撕裂

import 'package:flutter/material.dart';

class WatercolorTapePainter extends CustomPainter {
  final double tearHeight;

  WatercolorTapePainter({
    this.tearHeight = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // 定义胶带形状（两头撕裂）
    // 上边缘 (撕裂)
    path.moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 3) {
      path.lineTo(x, (x % 6 == 0) ? -tearHeight : 0);
    }

    // 右侧 (稍微不平)
    path.lineTo(size.width, size.height);

    // 下边缘 (撕裂)
    for (double x = size.width; x >= 0; x -= 3) {
      path.lineTo(x, size.height + ((x % 6 == 0) ? -tearHeight : 0));
    }
    path.close();

    // --- 关键：模拟水彩质感 ---
    // 水彩胶带的特点：半透明，且边缘颜色比中间深（水痕效应）

    // 1. 基础色 (Teal/Blue Mix) - 半透明
    final basePaint = Paint()
      ..color = const Color(0xFF80CBC4).withOpacity(0.6); // 基础青色

    // 2. 渐变叠加 (模拟水渍不均匀)
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4DB6AC), // 深一点的青色
          Color(0xFFB2DFDB), // 浅一点
          Color(0xFF80CBC4),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..blendMode = BlendMode.srcATop // 混合模式
      ..color = Colors.white.withOpacity(0.5); // 透明度控制

    // 绘制
    canvas.drawPath(path, basePaint);
    canvas.drawPath(path, gradientPaint);

    // 3. 边缘加深 (Watercolor Edge)
    // 只描边，颜色深一点，模拟颜料堆积在纸张纤维边缘
    final edgePaint = Paint()
      ..color = const Color(0xFF00695C).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, edgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

