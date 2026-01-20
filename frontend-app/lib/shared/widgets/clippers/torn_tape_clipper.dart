// 撕裂胶带裁剪器
// 用于创建胶带的锯齿状边缘效果

import 'package:flutter/material.dart';
import 'dart:math' as math;

class NaturalTornClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);

    // --- 顶部边缘 (稍微不平整) ---
    path.lineTo(size.width, 0);

    // --- 右侧边缘 (稍微不平整) ---
    path.lineTo(size.width, size.height);

    // --- 底部边缘 (稍微不平整) ---
    path.lineTo(0, size.height);

    // --- 左侧边缘：重点改造！模拟撕裂 ---
    // 不用死板的锯齿，而是用多个正弦波叠加模拟随机性
    double y = size.height;
    while (y > 0) {
      y -= 2; // 步长越小越细腻
      // 核心算法：叠加两个频率不同的波，制造"乱"的感觉
      final double x = math.sin(y / 10) * 3 + // 大波浪
          math.cos(y / 3) * 1.5 + // 小抖动
          2; // 基础偏移量，保证不切到内容

      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// 保持向后兼容，原来的类名也保留
class TornTapeClipper extends NaturalTornClipper {}

