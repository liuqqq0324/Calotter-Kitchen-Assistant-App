// 手绘风格（便利贴风格）样式定义
// Hand-drawn / Cozy Style Theme

import 'package:flutter/material.dart';

class AppStyle {
  // 背景纸张颜色 (米黄/奶油色)
  static const Color paperColor = Color(0xFFFFF9E6);
  
  // 泛黄纸张颜色（更温暖的色调，模拟老旧纸张）
  static const Color agedPaperColor = Color(0xFFF5E6D3);
  static const Color agedPaperColorLight = Color(0xFFFFF4E6);
  static const Color agedPaperColorDark = Color(0xFFE8D4B8);

  // 字体颜色 (深棕色，比纯黑更柔和)
  static const Color inkColor = Color(0xFF8D6E63);
  static const Color inkColorDark = Color(0xFF5D4037); // 更深的棕色用于强调

  // 强调色 (暖橙色，用于按钮)
  static const Color accentColor = Color(0xFFD87836);

  // 胶带颜色 (半透明棕色或花纹色)
  static const Color tapeColor = Color(0xAA8D6E63);
  static const Color tapeColorLight = Color(0xCCBCAAA4); // 浅一点的胶带色

  // 输入框边框颜色
  static const Color inputBorderColor = Color(0xFFD7CCC8);

  // 手写风格字体样式
  // 如果没有引入字体包，用默认字体配合样式模拟
  // 建议后续引入 google_fonts 并使用 'Patrick Hand' 或 'Kalam'
  static const TextStyle handWrittenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600, // 稍微粗一点
    color: inkColorDark,
    letterSpacing: 0.5,
    // fontFamily: 'Patrick Hand', // 建议在 pubspec.yaml 中引入
  );

  static const TextStyle handWrittenBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: inkColorDark,
    // fontFamily: 'Patrick Hand',
  );

  static const TextStyle handWrittenCaption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: inkColor,
    // fontFamily: 'Patrick Hand',
  );
}

