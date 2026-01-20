import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'sketchy_border.dart';

/// 手绘风格的按钮组件
class SketchyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final bool isFullWidth;

  const SketchyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor = Colors.black87,
    this.borderWidth = 2.5,
    this.padding,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final txtColor = textColor ?? Colors.white;

    Widget button = SketchyBorder(
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: bgColor,
      borderRadius: 30.0,
      roughness: 3.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            width: isFullWidth ? double.infinity : null,
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, color: txtColor, size: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return button;
  }
}

/// 手绘风格的图标按钮
class SketchyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color borderColor;
  final double size;

  const SketchyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.borderColor = Colors.black87,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final icnColor = iconColor ?? Colors.white;

    return SketchyBorder(
      borderColor: borderColor,
      borderWidth: 2.5,
      backgroundColor: bgColor,
      borderRadius: size / 2,
      roughness: 3.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(icon, color: icnColor, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
