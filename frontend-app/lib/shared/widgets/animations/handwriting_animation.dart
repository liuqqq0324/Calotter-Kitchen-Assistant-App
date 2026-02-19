import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HandwritingAnimation extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Duration animationDuration;

  const HandwritingAnimation({
    super.key,
    required this.text,
    this.fontSize = 48,
    this.color = Colors.white,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<HandwritingAnimation> createState() => _HandwritingAnimationState();
}

class _HandwritingAnimationState extends State<HandwritingAnimation> {
  bool _animationComplete = false;
  int _animationKey = 0; // 用于强制重置 AnimatedTextKit

  @override
  void initState() {
    super.initState();
    // 每次创建新实例时，重置动画状态
    _animationComplete = false;
  }

  @override
  void didUpdateWidget(HandwritingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 key 改变时（父组件传入新的 key），重置动画
    if (oldWidget.key != widget.key) {
      setState(() {
        _animationComplete = false;
        _animationKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animationComplete) {
      // 动画完成后显示固定文字
      return Text(
        widget.text,
        style: GoogleFonts.dancingScript(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          color: widget.color,
          letterSpacing: 2,
        ),
      );
    }

    // 手写动画效果 - 使用 key 确保每次重置时完全重建
    return AnimatedTextKit(
      key: ValueKey(_animationKey), // 使用内部 key 强制重建
      animatedTexts: [
        TypewriterAnimatedText(
          widget.text,
          textStyle: GoogleFonts.dancingScript(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: widget.color,
            letterSpacing: 2,
          ),
          speed: widget.animationDuration ~/ widget.text.length,
        ),
      ],
      totalRepeatCount: 1,
      onFinished: () {
        setState(() {
          _animationComplete = true;
        });
      },
    );
  }
}
