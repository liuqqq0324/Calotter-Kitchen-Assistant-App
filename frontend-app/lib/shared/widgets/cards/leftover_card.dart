// lib/widgets/leftover_card.dart
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/leftover.dart';

class LeftoverCard extends StatelessWidget {
  final Leftover item;

  // --- 交互回调 ---
  final VoidCallback? onTap; // 点击卡片本身
  final VoidCallback? onDelete; // 删除剩菜

  const LeftoverCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 计算颜色逻辑（复用 IngredientCard 的逻辑）
    Color cardColor = Colors.white;
    Color textColor = Colors.black87;
    double elevation = 2.0;

    if (item.isExpired) {
      cardColor = Colors.red.shade50;
      textColor = Colors.red;
      elevation = 5.0;
    } else if (item.isExpiringSoon) {
      cardColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      elevation = 3.0;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          FocusScope.of(context).unfocus();
          onTap!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: elevation,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 左侧：图片 ---
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: item.coverImage != null && item.coverImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.coverImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // 如果图片加载失败，显示占位符
                            return Center(
                              child: Text(
                                item.imagePlaceholder ?? '🍽️',
                                style: const TextStyle(fontSize: 30),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          item.imagePlaceholder ?? '🍽️',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // --- 中间：信息 ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. 菜品名称
                    Text(
                      item.dishName ?? 'Unknown Dish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 2. Remaining weight and calories
                    Row(
                      children: [
                        Text(
                          'Remaining: ${item.formattedWeight}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (item.currentCalories != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${item.currentCalories} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 3. 制作时间/剩余天数
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: item.isExpired
                              ? Colors.red
                              : (item.isExpiringSoon
                                    ? Colors.orange
                                    : Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.isExpired
                              ? 'Expired ${item.daysSinceProduced} days ago'
                              : (item.isExpiringSoon
                                    ? 'Expiring soon (${3 - item.daysSinceProduced} days left)'
                                    : 'Made ${item.daysSinceProduced} days ago'),
                          style: TextStyle(
                            fontSize: 12,
                            color: item.isExpired
                                ? Colors.red
                                : (item.isExpiringSoon
                                      ? Colors.orange
                                      : Colors.grey[600]),
                            fontWeight: item.isExpired || item.isExpiringSoon
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Right side: Delete button ---
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete leftover',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
