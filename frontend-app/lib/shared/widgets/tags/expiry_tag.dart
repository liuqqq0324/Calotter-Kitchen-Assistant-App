import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';

class ExpiryTag extends StatelessWidget {
  final DateTime expiryDate;
  final VoidCallback? onTap; // 如果传入，表示可点击
  final bool useStatusColors; // true: 红/橙/灰自动变色; false: 固定橙色

  const ExpiryTag({
    super.key,
    required this.expiryDate,
    this.onTap,
    this.useStatusColors = true, // 默认开启状态变色
  });

  @override
  Widget build(BuildContext context) {
    // 颜色逻辑：保持之前的逻辑，但颜色调成偏深色的墨水色，而不是背景色
    Color iconColor;
    IconData icon;

    if (useStatusColors) {
      // --- 模式 A: 智能状态色 (Inventory Page) ---
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryDate);
      final diff = expiryDate.difference(now).inDays;
      final isExpiringSoon = diff >= 0 && diff <= 3;

      if (isExpired) {
        iconColor = Colors.red.shade800; // 深红警告
        icon = Icons.warning_amber_rounded;
      } else if (isExpiringSoon) {
        iconColor = AppStyle.accentColor; // 深橙
        icon = Icons.access_time_rounded;
      } else {
        iconColor = AppStyle.inkColor; // 正常棕色
        icon = Icons.access_time_rounded;
      }
    } else {
      // --- 模式 B: 固定样式 (Review Page) ---
      iconColor = AppStyle.accentColor;
      icon = Icons.access_time_rounded;
    }

    // 极简风格：去掉背景色块，保留图标和日期
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 极简图标 (时钟)
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        // 日期文字
        Text(
          "${expiryDate.day}/${expiryDate.month}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: iconColor,
            // fontFamily: 'Patrick Hand', // 强烈建议手写体
          ),
        ),
        // 如果是 Review 模式 (onTap 不为空)，加个小提示
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(Icons.edit, size: 10, color: iconColor.withOpacity(0.6)),
        ],
      ],
    );

    // 如果传入了点击事件，包裹 GestureDetector
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
