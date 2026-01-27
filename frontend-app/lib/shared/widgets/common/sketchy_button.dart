import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'sketchy_border.dart';

/// 手绘风格的按钮组件
class SketchyButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final bool isFullWidth;
  final double fontSize;

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
    this.fontSize = 20,
  });

  @override
  State<SketchyButton> createState() => _SketchyButtonState();
}

class _SketchyButtonState extends State<SketchyButton> {
  bool _pressed = false;

  Color _darken(Color c, [double amount = 0.12]) {
    return Color.lerp(c, Colors.black, amount) ?? c;
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final pressedBg = _darken(baseBg);
    final txtColor = widget.textColor ?? Colors.white;

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      tween: ColorTween(end: _pressed ? pressedBg : baseBg),
      builder: (context, bg, _) {
        return SketchyBorder(
          borderColor: widget.borderColor,
          borderWidth: widget.borderWidth,
          backgroundColor: bg ?? baseBg,
          borderRadius: 30.0,
          roughness: 3.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                width: widget.isFullWidth ? double.infinity : null,
                child: Row(
                  mainAxisSize:
                      widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.text,
                        style: GoogleFonts.caveat(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                          letterSpacing: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 12),
                      Icon(widget.icon, color: txtColor, size: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 手绘风格的图标按钮
class SketchyIconButton extends StatefulWidget {
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
  State<SketchyIconButton> createState() => _SketchyIconButtonState();
}

class _SketchyIconButtonState extends State<SketchyIconButton> {
  bool _pressed = false;

  Color _darken(Color c, [double amount = 0.12]) {
    return Color.lerp(c, Colors.black, amount) ?? c;
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final pressedBg = _darken(baseBg);
    final icnColor = widget.iconColor ?? Colors.white;

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      tween: ColorTween(end: _pressed ? pressedBg : baseBg),
      builder: (context, bg, _) {
        return SketchyBorder(
          borderColor: widget.borderColor,
          borderWidth: 2.5,
          backgroundColor: bg ?? baseBg,
          borderRadius: widget.size / 2,
          roughness: 3.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                child: Icon(widget.icon, color: icnColor, size: widget.size * 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
