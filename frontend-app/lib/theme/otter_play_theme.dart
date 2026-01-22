import 'package:flutter/material.dart';

/// 方案三：治愈卡通向 · Otter Play
///
/// 用户指定配色：
/// - 主色：浅海蓝 #8ECAE6
/// - 辅色：开心绿 #90DBA4
/// - 点缀：蜜桃粉 #FFB4A2
/// - 背景：暖白 #FFFDF9
/// - 主文字：#2E2E2E（避免纯黑）
/// - 副文字：#7A7A7A
/// - 按钮文字：#FFFFFF
///
/// 说明：#8ECAE6 是较浅的品牌蓝，为了保证“蓝底白字”对比度，
/// 主按钮使用更深一档的蓝（同色系衍生）。
class OtterPlayColors {
  static const Color brandBlue = Color(0xFF8ECAE6);
  static const Color happyGreen = Color(0xFF90DBA4);
  static const Color peachPink = Color(0xFFFFB4A2);

  static const Color warmWhite = Color(0xFFFFFDF9);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color buttonText = Color(0xFFFFFFFF);

  // 深蓝：用于主按钮/高对比强调（衍生色）
  static const Color actionBlue = Color(0xFF219EBC);
}

ThemeData buildOtterPlayTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: OtterPlayColors.actionBlue,
    onPrimary: OtterPlayColors.buttonText,
    primaryContainer: OtterPlayColors.brandBlue,
    onPrimaryContainer: OtterPlayColors.textPrimary,
    secondary: OtterPlayColors.happyGreen,
    onSecondary: OtterPlayColors.textPrimary,
    secondaryContainer: OtterPlayColors.happyGreen.withOpacity(0.35),
    onSecondaryContainer: OtterPlayColors.textPrimary,
    tertiary: OtterPlayColors.peachPink,
    onTertiary: OtterPlayColors.textPrimary,
    tertiaryContainer: OtterPlayColors.peachPink.withOpacity(0.35),
    onTertiaryContainer: OtterPlayColors.textPrimary,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    surface: OtterPlayColors.warmWhite,
    onSurface: OtterPlayColors.textPrimary,
    surfaceContainerHighest: Colors.white,
    onSurfaceVariant: OtterPlayColors.textSecondary,
    outline: OtterPlayColors.actionBlue.withOpacity(0.55),
    shadow: Colors.black.withOpacity(0.12),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: OtterPlayColors.warmWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: OtterPlayColors.warmWhite,
      foregroundColor: OtterPlayColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OtterPlayColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: OtterPlayColors.peachPink,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: OtterPlayColors.warmWhite,
      indicatorColor: OtterPlayColors.brandBlue.withOpacity(0.35),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: OtterPlayColors.textSecondary),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? OtterPlayColors.actionBlue : OtterPlayColors.textSecondary,
        );
      }),
    ),
    dividerTheme: DividerThemeData(
      color: OtterPlayColors.actionBlue.withOpacity(0.18),
      thickness: 1,
    ),
  );
}


