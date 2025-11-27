import 'package:flutter/material.dart';

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
    // 1. 计算颜色逻辑
    Color bgColor;
    Color textColor;
    IconData icon;

    if (useStatusColors) {
      // --- 模式 A: 智能状态色 (Inventory Page) ---
      final now = DateTime.now();
      // 简单判断：比较时间戳 (忽略时分秒差异的严谨写法略繁琐，这里简化对比)
      final isExpired = now.isAfter(expiryDate);
      final diff = expiryDate.difference(now).inDays;
      final isExpiringSoon = diff >= 0 && diff <= 3;

      if (isExpired) {
        bgColor = Colors.red.shade50;
        textColor = Colors.red;
        icon = Icons.warning_amber_rounded; // 过期显示警告
      } else if (isExpiringSoon) {
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.access_time; // 临期显示时钟
      } else {
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.calendar_today; // 正常显示日历
      }
    } else {
      // --- 模式 B: 固定样式 (Review Page) ---
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.edit_calendar; // 编辑模式显示日历笔
    }

    // 2. 构建 UI
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(
            // 格式化日期: 25/11
            "${expiryDate.day}/${expiryDate.month}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          // 如果是 Review 模式 (onTap 不为空)，加个小提示
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 10, color: textColor.withOpacity(0.6)),
          ],
        ],
      ),
    );

    // 如果传入了点击事件，包裹 GestureDetector
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
