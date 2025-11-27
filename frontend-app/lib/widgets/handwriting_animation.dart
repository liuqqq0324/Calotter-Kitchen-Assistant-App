import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // 手写动画效果
    return AnimatedTextKit(
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

