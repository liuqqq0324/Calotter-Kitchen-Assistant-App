import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_border.dart';

/// 手绘风格的确认删除对话框，视觉风格参考 [SketchyCard]
///
/// 使用 [SketchyBorder] 作为对话框容器，[SketchyTextStyle] 作为标题与正文样式。
/// 返回 true 表示用户确认删除，false 表示取消。
Future<bool> showSketchyConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Delete',
}) async {
  const terracotta = Color(0xFFD68C5E);
  const rustBrown = Color(0xFF8C5E4A);

  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: SketchyBorder(
        borderColor: Colors.black87,
        borderWidth: 2.0,
        backgroundColor: Colors.white,
        borderRadius: 16.0,
        roughness: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: SketchyTextStyle.heading(ctx),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: SketchyTextStyle.body(ctx),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      cancelLabel,
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        color: rustBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: terracotta,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: rustBrown.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: GoogleFonts.kalam(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
