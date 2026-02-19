import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// OTTER APPROVED 艺术字印章组件
/// 参考参考图样式，使用代码生成印章效果
class OtterApprovedStamp extends StatelessWidget {
  final double width;
  final double opacity;
  final double rotation; // 旋转角度（弧度）

  const OtterApprovedStamp({
    super.key,
    this.width = 240,
    this.opacity = 0.52,
    this.rotation = -0.20, // 默认轻微倾斜
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // 双线边框，模拟印章效果
            border: Border.all(
              color: Colors.red.shade700,
              width: 3,
            ),
            // 内部边框
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // 内部边框线
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red.shade700,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // 文字
              Center(
                child: Text(
                  'OTTER APPROVED',
                  style: GoogleFonts.kalam(
                    fontSize: width * 0.12, // 根据宽度自适应字体大小
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    letterSpacing: 2.0,
                  ).copyWith(
                    // 添加一些纹理效果（通过阴影模拟）
                    shadows: [
                      Shadow(
                        color: Colors.red.shade900.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
