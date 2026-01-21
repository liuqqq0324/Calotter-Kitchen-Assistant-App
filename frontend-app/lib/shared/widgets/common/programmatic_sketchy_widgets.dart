import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// A wobbly, hand-drawn-looking rectangle border.
class SketchyRectBorder extends ShapeBorder {
  final double borderWidth;
  final double wobbleAmount;
  final int seed;
  final Color color;

  const SketchyRectBorder({
    this.borderWidth = 1.0,
    this.wobbleAmount = 2.5,
    this.seed = 42,
    this.color = const Color(0xFF6B4F4F),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(borderWidth), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final rnd = math.Random(seed);
    final path = Path();

    // Points count scales with size; keep it stable but not too dense.
    final topSteps = (rect.width / 24).round().clamp(6, 16);
    final sideSteps = (rect.height / 24).round().clamp(6, 16);

    double wob() => (rnd.nextDouble() - 0.5) * wobbleAmount * 2;

    // Start near top-left.
    path.moveTo(rect.left + wob(), rect.top + wob());

    // Top edge (left -> right)
    for (int i = 1; i <= topSteps; i++) {
      final t = i / topSteps;
      path.lineTo(rect.left + rect.width * t + wob(), rect.top + wob());
    }

    // Right edge (top -> bottom)
    for (int i = 1; i <= sideSteps; i++) {
      final t = i / sideSteps;
      path.lineTo(rect.right + wob(), rect.top + rect.height * t + wob());
    }

    // Bottom edge (right -> left)
    for (int i = 1; i <= topSteps; i++) {
      final t = i / topSteps;
      path.lineTo(rect.right - rect.width * t + wob(), rect.bottom + wob());
    }

    // Left edge (bottom -> top)
    for (int i = 1; i <= sideSteps; i++) {
      final t = i / sideSteps;
      path.lineTo(rect.left + wob(), rect.bottom - rect.height * t + wob());
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return SketchyRectBorder(
      borderWidth: borderWidth * t,
      wobbleAmount: wobbleAmount * t,
      seed: seed,
      color: color,
    );
  }
}

class _TapeTexturePainter extends CustomPainter {
  final int seed;

  _TapeTexturePainter({this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.10)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Light diagonal strokes + a bit of speckle.
    for (int i = 0; i < 10; i++) {
      final x1 = rnd.nextDouble() * size.width;
      final y1 = rnd.nextDouble() * size.height;
      final dx = 8 + rnd.nextDouble() * 10;
      final dy = 3 + rnd.nextDouble() * 6;
      canvas.drawLine(Offset(x1, y1), Offset(x1 + dx, y1 + dy), paint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.06)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.8 + rnd.nextDouble() * 0.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TapeTexturePainter oldDelegate) =>
      oldDelegate.seed != seed;
}

/// A paper-like sketchy container with a small tape on top.
class ProgrammaticSketchyPaper extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double tapeWidth;
  final double tapeHeight;
  final double tapeRotation;
  final Color paperColor;
  final Color inkColor;
  final VoidCallback? onTap;

  const ProgrammaticSketchyPaper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.tapeWidth = 85,
    this.tapeHeight = 18,
    this.tapeRotation = -0.05,
    this.paperColor = const Color(0xFFFFFFF0),
    this.inkColor = const Color(0xFF6B4F4F),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14), // Space for tape
          padding: padding,
          decoration: ShapeDecoration(
            color: paperColor,
            shape: SketchyRectBorder(
              borderWidth: 1.0,
              wobbleAmount: 2.5,
              seed: 42,
              color: inkColor,
            ),
            shadows: [
              BoxShadow(
                color: inkColor.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(2, 6),
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: 4,
          child: Transform.rotate(
            angle: tapeRotation,
            child: Container(
              width: tapeWidth,
              height: tapeHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8DC).withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: CustomPaint(painter: _TapeTexturePainter()),
            ),
          ),
        ),
      ],
    );

    final wrapped = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: content,
            ),
          );

    return Padding(padding: margin, child: wrapped);
  }
}

/// A sketchy button that darkens slightly on press.
class ProgrammaticSketchyButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color inkColor;
  final EdgeInsets padding;
  final bool expanded;

  const ProgrammaticSketchyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = const Color(0xFFFFFFF0),
    this.textColor = const Color(0xFF6B4F4F),
    this.inkColor = const Color(0xFF6B4F4F),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.expanded = true,
  });

  @override
  State<ProgrammaticSketchyButton> createState() =>
      _ProgrammaticSketchyButtonState();
}

class _ProgrammaticSketchyButtonState extends State<ProgrammaticSketchyButton> {
  bool _pressed = false;

  Color _darken(Color c, [double amount = 0.10]) {
    return Color.lerp(c, Colors.black, amount) ?? c;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.backgroundColor;
    final pressed = _darken(base);

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: widget.textColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.kalam(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
            ),
          ),
        ),
      ],
    );

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      tween: ColorTween(end: _pressed ? pressed : base),
      builder: (context, bg, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Container(
              padding: widget.padding,
              decoration: ShapeDecoration(
                color: bg ?? base,
                shape: SketchyRectBorder(
                  borderWidth: 1.0,
                  wobbleAmount: 2.0,
                  seed: 24,
                  color: widget.inkColor,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

