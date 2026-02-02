import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 格纹纸背景（与 home page 一致）：白底、网格线、不规则边缘
class GridPaperBackground extends StatelessWidget {
  final Widget child;
  final int seed;

  const GridPaperBackground({
    super.key,
    required this.child,
    this.seed = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPaperPainter(seed: seed),
          ),
        ),
        child,
      ],
    );
  }
}

class _GridPaperPainter extends CustomPainter {
  final int seed;

  _GridPaperPainter({this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      return;
    }

    final random = math.Random(seed);
    final path = _createIrregularPath(size, random);

    // 1. 阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(6, 6));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. 背景
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF8F8F5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, backgroundPaint);

    // 3. 网格线
    final gridPaint = Paint()
      ..color = const Color(0xFFE3E6E8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSpacing = 20.0;
    canvas.save();
    canvas.clipPath(path);

    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.restore();

    // 4. 边缘线
    final edgePaint = Paint()
      ..color = const Color(0xFF6B4F4F).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, edgePaint);
  }

  Path _createIrregularPath(Size size, math.Random random) {
    final path = Path();
    const double edgeNoise = 2.5;
    const double step = 8.0;

    final w = size.width > 0 ? size.width : 100.0;
    final h = size.height > 0 ? size.height : 100.0;

    path.moveTo(0, 0);
    for (double x = step; x < w; x += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      path.lineTo(x, noise.clamp(-edgeNoise, edgeNoise).toDouble());
    }
    path.lineTo(w, 0);

    for (double y = step; y < h; y += step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      path.lineTo(
          (w + noise.clamp(-edgeNoise, edgeNoise)).toDouble(), y);
    }
    path.lineTo(w, h);

    for (double x = w - step; x > 0; x -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      path.lineTo(
          x, (h + noise.clamp(-edgeNoise, edgeNoise)).toDouble());
    }
    path.lineTo(0, h);

    for (double y = h - step; y > 0; y -= step) {
      final noise = random.nextDouble() * edgeNoise * 2 - edgeNoise;
      path.lineTo(noise.clamp(-edgeNoise, edgeNoise).toDouble(), y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _GridPaperPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
