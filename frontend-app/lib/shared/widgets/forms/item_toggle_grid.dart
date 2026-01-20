// lib/widgets/item_toggle_grid.dart

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/cookware.dart'; // 确保引入 Model

class ItemToggleGrid extends StatelessWidget {
  final List<Cookware> items;
  final Function(Cookware) onToggle; // 点击回调，把被点的 item 传出去

  const ItemToggleGrid({
    super.key,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 这里改为 3，让图标更紧凑一点，适合调料
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9, // 稍微调整比例，防溢出
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildToggleCard(context, items[index]);
      },
    );
  }

  Widget _buildToggleCard(BuildContext context, Cookware item) {
    // 根据状态决定颜色
    final color = item.isAvailable ? Colors.orange : Colors.grey;
    final bgColor = item.isAvailable
        ? Colors.orange.shade50
        : Colors.grey.shade100;
    final borderColor = item.isAvailable ? Colors.orange : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => onToggle(item), // 🔥 点击时只触发回调，不处理逻辑
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: item.isAvailable
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 35, color: color),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2, // 防止名字太长报错
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: item.isAvailable ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
