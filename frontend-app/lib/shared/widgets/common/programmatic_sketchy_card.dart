import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom ShapeBorder that creates irregular, hand-drawn looking borders
/// instead of perfect straight lines.
class SketchyRectBorder extends ShapeBorder {
  final double borderWidth;
  final double wobbleAmount; // How much the border wobbles
  final int seed; // Seed for random number generation to ensure consistency

  const SketchyRectBorder({
    this.borderWidth = 1.0,
    this.wobbleAmount = 2.5,
    this.seed = 42,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _createSketchyPath(rect.deflate(borderWidth));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createSketchyPath(rect);
  }

  /// Creates a path with irregular, wobbly edges
  Path _createSketchyPath(Rect rect) {
    final path = Path();
    final random = math.Random(seed);
    final step = 8.0; // Distance between points on the path
    final wobble = wobbleAmount;

    // Top edge: left to right
    path.moveTo(rect.left, rect.top);
    for (double x = rect.left + step; x < rect.right; x += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, rect.top + noise);
    }
    path.lineTo(rect.right, rect.top);

    // Right edge: top to bottom
    for (double y = rect.top + step; y < rect.bottom; y += step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(rect.right + noise, y);
    }
    path.lineTo(rect.right, rect.bottom);

    // Bottom edge: right to left
    for (double x = rect.right - step; x > rect.left; x -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, rect.bottom + noise);
    }
    path.lineTo(rect.left, rect.bottom);

    // Left edge: bottom to top
    for (double y = rect.bottom - step; y > rect.top; y -= step) {
      final noise = (random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(rect.left + noise, y);
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.25)
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
    );
  }
}

/// A programmatic card widget that creates a hand-drawn, taped paper style
/// without using any image assets.
class ProgrammaticSketchyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String fontFamily;

  const ProgrammaticSketchyCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.fontFamily = 'PatrickHand',
  });

  /// Builds a hand-drawn style icon based on the icon type
  Widget _buildHandDrawnIcon(IconData icon, Color color) {
    if (icon == Icons.restaurant_menu) {
      // Use custom image icon for dish intake - larger size
      return Image.asset(
        'assets/images/dish_intake_icon.png',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to hand-drawn spoon if image fails to load
          return CustomPaint(
            size: const Size(140, 140),
            painter: _HandDrawnSpoonPainter(),
          );
        },
      );
    } else if (icon == Icons.add_circle) {
      // Use custom image icon for add food - larger size
      return Image.asset(
        'assets/images/add_food_icon.png',
        width: 170,
        height: 170,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to hand-drawn plus if image fails to load
          return CustomPaint(
            size: const Size(170, 170),
            painter: _HandDrawnPlusPainter(),
          );
        },
      );
    } else {
      // Fallback to regular icon for other types
      return Icon(
        icon,
        size: 140,
        color: const Color(0xFF6B4F4F).withOpacity(0.85),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // Allow tape to extend beyond card bounds
        children: [
          // 1. Background Layer: Sketchy paper container
          Container(
            width: double.infinity,
            height: 170,
            margin: const EdgeInsets.only(top: 14), // Space for tape
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFFFF0), // Off-white/cream color
              shape: const SketchyRectBorder(
                borderWidth: 1.0,
                wobbleAmount: 2.5,
                seed: 42, // Fixed seed for consistent appearance
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0xFF6B4F4F).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon area - no padding or border, just the icon itself
                Expanded(
                  child: Center(
                    child: _buildHandDrawnIcon(icon, color),
                  ),
                ),
                const SizedBox(height: 6),
                // Title - smaller font size
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B4F4F),
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Subtitle - smaller font size
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 10,
                    color: const Color(0xFF6B4F4F).withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 2. Tape Layer: Programmatic tape effect
          Positioned(
            top: 4, // Position tape slightly above the card
            child: Transform.rotate(
              angle: -0.05, // Slight rotation for natural look
              child: Container(
                width: 85, // 缩短胶带长度
                height: 18,
                decoration: BoxDecoration(
                  // Semi-transparent yellowish-white tape color - more transparent
                  color: const Color(0xFFFFF8DC).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                  // Add a subtle border to make it look more like tape
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 0.5,
                  ),
                  // Add a subtle shadow to make the tape pop
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // Add some texture lines to simulate tape texture
                child: CustomPaint(
                  painter: _TapeTexturePainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to add subtle texture lines to the tape
class _TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines to simulate tape texture
    for (double y = 2; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for hand-drawn spoon icon
class _HandDrawnSpoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final random = math.Random(123); // Fixed seed for consistency

    // Helper function to add wobble to a point
    Offset wobble(Offset point, double amount) {
      return Offset(
        point.dx + (random.nextDouble() * 2 - 1) * amount,
        point.dy + (random.nextDouble() * 2 - 1) * amount,
      );
    }

    final path = Path();

    // Draw spoon bowl (oval shape at bottom)
    final bowlCenter = Offset(centerX, centerY + 8);
    final bowlWidth = 12.0;
    final bowlHeight = 8.0;

    // Create wobbly oval for bowl
    for (int i = 0; i <= 16; i++) {
      final angle = (i / 16) * 2 * math.pi;
      final x = bowlCenter.dx + math.cos(angle) * bowlWidth / 2;
      final y = bowlCenter.dy + math.sin(angle) * bowlHeight / 2;
      final point = wobble(Offset(x, y), 0.8);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Draw spoon handle (vertical line going up)
    final handleStart = Offset(bowlCenter.dx, bowlCenter.dy - bowlHeight / 2);
    final handleEnd = Offset(centerX, centerY - 12);

    // Create wobbly handle line
    final steps = 8;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = handleStart.dx + (handleEnd.dx - handleStart.dx) * t;
      final y = handleStart.dy + (handleEnd.dy - handleStart.dy) * t;
      final point = wobble(Offset(x, y), 1.2);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for hand-drawn plus icon
class _HandDrawnPlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final random = math.Random(456); // Fixed seed for consistency
    final lineLength = 14.0;

    // Helper function to add wobble to a point
    Offset wobble(Offset point, double amount) {
      return Offset(
        point.dx + (random.nextDouble() * 2 - 1) * amount,
        point.dy + (random.nextDouble() * 2 - 1) * amount,
      );
    }

    // Draw horizontal line
    final horizontalStart = Offset(centerX - lineLength / 2, centerY);
    final horizontalEnd = Offset(centerX + lineLength / 2, centerY);

    final horizontalPath = Path();
    final hSteps = 6;
    for (int i = 0; i <= hSteps; i++) {
      final t = i / hSteps;
      final x = horizontalStart.dx + (horizontalEnd.dx - horizontalStart.dx) * t;
      final y = horizontalStart.dy + (horizontalEnd.dy - horizontalStart.dy) * t;
      final point = wobble(Offset(x, y), 1.0);
      if (i == 0) {
        horizontalPath.moveTo(point.dx, point.dy);
      } else {
        horizontalPath.lineTo(point.dx, point.dy);
      }
    }

    // Draw vertical line
    final verticalStart = Offset(centerX, centerY - lineLength / 2);
    final verticalEnd = Offset(centerX, centerY + lineLength / 2);

    final verticalPath = Path();
    final vSteps = 6;
    for (int i = 0; i <= vSteps; i++) {
      final t = i / vSteps;
      final x = verticalStart.dx + (verticalEnd.dx - verticalStart.dx) * t;
      final y = verticalStart.dy + (verticalEnd.dy - verticalStart.dy) * t;
      final point = wobble(Offset(x, y), 1.0);
      if (i == 0) {
        verticalPath.moveTo(point.dx, point.dy);
      } else {
        verticalPath.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(horizontalPath, paint);
    canvas.drawPath(verticalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

