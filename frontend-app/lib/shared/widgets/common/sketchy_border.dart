import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 手绘风格的不规则边框装饰
/// 通过随机偏移创建手绘效果
class SketchyBorder extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double borderRadius;
  final double roughness; // 粗糙度，控制随机偏移的程度

  const SketchyBorder({
    super.key,
    required this.child,
    this.borderColor = Colors.black87,
    this.borderWidth = 2.0,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.roughness = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SketchyBorderPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        roughness: roughness,
      ),
      child: Container(
        padding: EdgeInsets.all(borderWidth + roughness),
        child: child,
      ),
    );
  }
}

class _SketchyBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double borderRadius;
  final double roughness;
  final math.Random _random = math.Random(42); // 固定种子，确保每次绘制一致

  _SketchyBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    this.backgroundColor,
    required this.borderRadius,
    required this.roughness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 绘制背景（如果有）
    if (backgroundColor != null) {
      final bgPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      _drawRoughRect(canvas, size, bgPaint, true);
    }

    // 绘制边框
    _drawRoughRect(canvas, size, paint, false);
  }

  void _drawRoughRect(Canvas canvas, Size size, Paint paint, bool fill) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = borderRadius;

    // 左上角
    path.moveTo(
      _randomOffset(r, roughness),
      _randomOffset(r, roughness),
    );

    // 上边
    final topPoints = 8;
    for (int i = 1; i < topPoints; i++) {
      final t = i / topPoints;
      path.lineTo(
        _randomOffset(r + (w - 2 * r) * t, roughness),
        _randomOffset(r, roughness),
      );
    }

    // 右上角
    path.lineTo(
      _randomOffset(w - r, roughness),
      _randomOffset(r, roughness),
    );

    // 右边
    final rightPoints = 8;
    for (int i = 1; i < rightPoints; i++) {
      final t = i / rightPoints;
      path.lineTo(
        _randomOffset(w - r, roughness),
        _randomOffset(r + (h - 2 * r) * t, roughness),
      );
    }

    // 右下角
    path.lineTo(
      _randomOffset(w - r, roughness),
      _randomOffset(h - r, roughness),
    );

    // 下边
    final bottomPoints = 8;
    for (int i = bottomPoints - 1; i > 0; i--) {
      final t = i / bottomPoints;
      path.lineTo(
        _randomOffset(r + (w - 2 * r) * t, roughness),
        _randomOffset(h - r, roughness),
      );
    }

    // 左下角
    path.lineTo(
      _randomOffset(r, roughness),
      _randomOffset(h - r, roughness),
    );

    // 左边
    final leftPoints = 8;
    for (int i = leftPoints - 1; i > 0; i--) {
      final t = i / leftPoints;
      path.lineTo(
        _randomOffset(r, roughness),
        _randomOffset(r + (h - 2 * r) * t, roughness),
      );
    }

    path.close();

    if (fill) {
      canvas.drawPath(path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  double _randomOffset(double base, double roughness) {
    return base + (_random.nextDouble() - 0.5) * roughness;
  }

  @override
  bool shouldRepaint(covariant _SketchyBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.roughness != roughness;
  }
}

