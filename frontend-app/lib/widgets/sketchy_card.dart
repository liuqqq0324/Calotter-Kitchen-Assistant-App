import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sketchy_border.dart';

/// 手绘风格的卡片组件
class SketchyCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const SketchyCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor = Colors.black87,
    this.borderWidth = 2.0,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SketchyBorder(
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor ?? Colors.white,
      borderRadius: 16.0,
      roughness: 4.0,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}

/// 手绘风格的文本样式
class SketchyTextStyle {
  static TextStyle title(BuildContext context) {
    return GoogleFonts.caveat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      letterSpacing: 1.2,
    );
  }

  static TextStyle heading(BuildContext context) {
    return GoogleFonts.caveat(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 1.0,
    );
  }

  static TextStyle body(BuildContext context) {
    return GoogleFonts.kalam(
      fontSize: 16,
      color: Colors.black87,
      letterSpacing: 0.5,
    );
  }

  static TextStyle caption(BuildContext context) {
    return GoogleFonts.kalam(
      fontSize: 14,
      color: Colors.grey[700],
      letterSpacing: 0.3,
    );
  }
}

