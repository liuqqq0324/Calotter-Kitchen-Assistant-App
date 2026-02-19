import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 手绘风虚线轨迹：每段有轻微随机长度变化 + 法线方向抖动
class SketchyDashedPathPainter extends CustomPainter {
  final Path path;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double jitter;
  final int seed;

  SketchyDashedPathPainter({
    required this.path,
    required this.color,
    this.strokeWidth = 2.0,
    this.dashLength = 10.0,
    this.gapLength = 8.0,
    this.jitter = 1.0,
    this.seed = 42,
  });

  static List<_DashSegment> _buildSegments(
    Path path,
    double dashLength,
    double gapLength,
    double jitter,
    int seed,
  ) {
    final segments = <_DashSegment>[];
    final rnd = math.Random(seed);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      final totalLen = metric.length;
      double pos = 0.0;

      while (pos < totalLen) {
        final lenVar = 0.8 + rnd.nextDouble() * 0.4;
        final segLen = (dashLength * lenVar).clamp(2.0, totalLen - pos);
        final endPos = (pos + segLen).clamp(0.0, totalLen);

        final startTangent = metric.getTangentForOffset(pos);
        final endTangent = metric.getTangentForOffset(endPos);

        if (startTangent != null && endTangent != null) {
          final startJitter = (rnd.nextDouble() - 0.5) * 2 * jitter;
          final endJitter = (rnd.nextDouble() - 0.5) * 2 * jitter;

          final startNorm = Offset(
            startTangent.vector.dy,
            -startTangent.vector.dx,
          );
          final endNorm = Offset(
            endTangent.vector.dy,
            -endTangent.vector.dx,
          );

          final normLenS = math.sqrt(
              startNorm.dx * startNorm.dx + startNorm.dy * startNorm.dy);
          final normLenE =
              math.sqrt(endNorm.dx * endNorm.dx + endNorm.dy * endNorm.dy);

          final startOffset = normLenS > 1e-6
              ? Offset(
                  startNorm.dx / normLenS * startJitter,
                  startNorm.dy / normLenS * startJitter,
                )
              : Offset.zero;
          final endOffset = normLenE > 1e-6
              ? Offset(
                  endNorm.dx / normLenE * endJitter,
                  endNorm.dy / normLenE * endJitter,
                )
              : Offset.zero;

          segments.add(_DashSegment(
            start: startTangent.position + startOffset,
            end: endTangent.position + endOffset,
          ));
        }

        pos = endPos + gapLength;
      }
    }

    return segments;
  }

  List<_DashSegment>? _cachedSegments;
  Rect? _cachedPathBounds;
  double _cachedDash = -1;
  double _cachedGap = -1;
  double _cachedJitter = -1;
  int _cachedSeed = -1;

  List<_DashSegment> _getSegments() {
    final bounds = path.getBounds();
    if (_cachedSegments != null &&
        _cachedPathBounds == bounds &&
        _cachedDash == dashLength &&
        _cachedGap == gapLength &&
        _cachedJitter == jitter &&
        _cachedSeed == seed) {
      return _cachedSegments!;
    }
    _cachedPathBounds = bounds;
    _cachedDash = dashLength;
    _cachedGap = gapLength;
    _cachedJitter = jitter;
    _cachedSeed = seed;
    _cachedSegments =
        _buildSegments(path, dashLength, gapLength, jitter, seed);
    return _cachedSegments!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final segments = _getSegments();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;

    for (final seg in segments) {
      canvas.drawLine(seg.start, seg.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchyDashedPathPainter oldDelegate) {
    return path != oldDelegate.path ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength ||
        jitter != oldDelegate.jitter ||
        seed != oldDelegate.seed;
  }
}

class _DashSegment {
  final Offset start;
  final Offset end;
  _DashSegment({required this.start, required this.end});
}

typedef PathBuilder = Path Function(Size size);

/// 封装 Widget：根据 size 构建 Path，用 CustomPaint 绘制
class SketchyDashedPath extends StatelessWidget {
  final PathBuilder pathBuilder;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double jitter;
  final int seed;

  const SketchyDashedPath({
    super.key,
    required this.pathBuilder,
    this.color = const Color(0xFF5A3A2E),
    this.strokeWidth = 2.0,
    this.dashLength = 10.0,
    this.gapLength = 8.0,
    this.jitter = 1.0,
    this.seed = 42,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.width <= 0 || size.height <= 0) {
          return const SizedBox.shrink();
        }
        final path = pathBuilder(size);
        return CustomPaint(
          size: size,
          painter: SketchyDashedPathPainter(
            path: path,
            color: color,
            strokeWidth: strokeWidth,
            dashLength: dashLength,
            gapLength: gapLength,
            jitter: jitter,
            seed: seed,
          ),
        );
      },
    );
  }
}
