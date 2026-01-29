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
    final now = DateTime.now();
    final isExpired = now.isAfter(expiryDate);
    final diffDays = expiryDate.difference(now).inDays;
    final isExpiringSoon = diffDays >= 0 && diffDays <= 3;

    // 颜色与图标（与 leftover_card 一致：红/橙/灰）
    Color iconColor;
    IconData icon = Icons.access_time;

    if (useStatusColors) {
      if (isExpired) {
        iconColor = Colors.red.shade800;
        icon = Icons.warning_amber_rounded;
      } else if (isExpiringSoon) {
        iconColor = AppStyle.accentColor;
      } else {
        iconColor = Colors.grey[600]!;
      }
    } else {
      iconColor = AppStyle.accentColor;
    }

    // 易读文案（参考 leftover_card：过期 X 天 / 即将过期 X 天 / 还有 X 天）
    String label;
    if (isExpired) {
      final daysAgo = now.difference(expiryDate).inDays;
      label = daysAgo <= 0
          ? 'Expired today'
          : 'Expired $daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else if (isExpiringSoon) {
      label = diffDays == 0
          ? 'Expires today'
          : 'Expiring in $diffDays day${diffDays == 1 ? '' : 's'}';
    } else {
      label = 'Expires in $diffDays days';
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: iconColor,
              fontWeight: isExpired || isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(Icons.edit, size: 10, color: iconColor.withOpacity(0.6)),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}
