// 撕裂卡片裁剪器（带卷角效果）
// 用于创建卡片所有边缘的不规则撕裂效果，并在右下角留出卷角空间

import 'package:flutter/material.dart';
import 'dart:math' as math;

class TornCardClipper extends CustomClipper<Path> {
  final double foldSize; // 卷角大小

  TornCardClipper({this.foldSize = 30.0});

  @override
  Path getClip(Size size) {
    final path = Path();

    // 使用随机种子确保每次绘制略有不同
    final random = math.Random(42); // 固定种子，保持一致性

    double w = size.width;
    double h = size.height;

    // --- 顶部边缘：不规则波浪（使用贝塞尔曲线模拟纸张边缘的微小起伏）---
    path.moveTo(0, 0);
    path.quadraticBezierTo(w * 0.5, -2, w, 0);

    // --- 右侧边缘：一直画到卷角开始的地方 ---
    double y = 0;
    while (y < h - foldSize) {
      y += 3;
      final offset =
          math.sin(y / 12) * 1.5 +
          math.cos(y / 4) * 0.8 +
          random.nextDouble() * 0.3;
      path.lineTo(w - offset.clamp(0.0, 3.0), y);
    }

    // --- 卷角缺口：切掉右下角，为卷角留出空间 ---
    // 这里的曲线要模拟纸张自然弯曲
    path.quadraticBezierTo(w - 5, h - 5, w - foldSize, h);

    // --- 底部边缘：不规则波浪 ---
    double x = w - foldSize;
    while (x > 0) {
      x -= 3;
      final offset =
          math.sin(x / 18) * 2.5 +
          math.cos(x / 6) * 1.2 +
          random.nextDouble() * 0.6;
      path.lineTo(x, h - offset.clamp(0.0, 4.0));
    }

    // --- 左侧边缘：重点改造！模拟撕裂（更明显）---
    y = h;
    while (y > 0) {
      y -= 2; // 步长越小越细腻
      // 核心算法：叠加两个频率不同的波，制造"乱"的感觉
      final double x =
          math.sin(y / 10) * 4 + // 大波浪（幅度更大）
          math.cos(y / 3) * 2 + // 小抖动
          random.nextDouble() * 1.0 + // 随机微调
          3; // 基础偏移量，保证不切到内容

      path.lineTo(x.clamp(0.0, w * 0.1), y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
