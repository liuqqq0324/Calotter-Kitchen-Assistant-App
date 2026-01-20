import 'package:flutter/material.dart';

// 应用主题配置
// 已从 main.dart 拆分出来

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      useMaterial3: true,
      // 使用本地字体族 PatrickHand 作为全局字体
      fontFamily: 'PatrickHand',
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'PatrickHand'),
    );
  }
}

