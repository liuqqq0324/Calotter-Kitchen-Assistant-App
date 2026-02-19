import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'dart:ui' as ui;

/// 海獭爪子印章组件
class OtterStamp extends StatelessWidget {
  final double size;
  final bool showText;
  final double opacity;

  const OtterStamp({
    super.key,
    this.size = 120,
    this.showText = true,
    this.opacity = 0.6, // 默认半透明
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 爪子印
          CustomPaint(
            size: Size(size, size),
            painter: _PawPrintPainter(),
          ),
          if (showText) ...[
            const SizedBox(height: 8),
            // "OTTER APPROVED" 印章文字
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.red.shade900,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade900.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                'OTTER APPROVED',
                style: GoogleFonts.kalam(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 改进的爪子印绘制器 - 更美观的设计
class _PawPrintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = size.width * 0.12;

    // 使用渐变和阴影效果
    final shadowPaint = Paint()
      ..color = Colors.red.shade900.withOpacity(0.3)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);

    final mainPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.fill;

    // 掌垫（底部大圆）- 带阴影
    final padRadius = baseRadius * 1.3;
    final padY = centerY + baseRadius * 1.2;
    
    // 阴影
    canvas.drawCircle(
      Offset(centerX + 2, padY + 2),
      padRadius,
      shadowPaint,
    );
    
    // 主圆
    canvas.drawCircle(
      Offset(centerX, padY),
      padRadius,
      mainPaint,
    );
    
    // 高光
    canvas.drawCircle(
      Offset(centerX - padRadius * 0.3, padY - padRadius * 0.3),
      padRadius * 0.4,
      highlightPaint,
    );

    // 4个小脚趾（上方）- 更自然的排列
    final toeRadius = baseRadius * 0.55;
    final toeSpacing = baseRadius * 1.1;
    
    // 计算脚趾位置（更自然的弧形排列）
    final toes = [
      Offset(centerX - toeSpacing * 0.7, centerY - toeSpacing * 0.4), // 左上
      Offset(centerX - toeSpacing * 0.2, centerY - toeSpacing * 0.6), // 左中上
      Offset(centerX + toeSpacing * 0.2, centerY - toeSpacing * 0.6), // 右中上
      Offset(centerX + toeSpacing * 0.7, centerY - toeSpacing * 0.4), // 右上
    ];

    for (final toePos in toes) {
      // 阴影
      canvas.drawCircle(
        Offset(toePos.dx + 1, toePos.dy + 1),
        toeRadius,
        shadowPaint,
      );
      // 主圆
      canvas.drawCircle(toePos, toeRadius, mainPaint);
      // 小高光
      canvas.drawCircle(
        Offset(toePos.dx - toeRadius * 0.3, toePos.dy - toeRadius * 0.3),
        toeRadius * 0.4,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
