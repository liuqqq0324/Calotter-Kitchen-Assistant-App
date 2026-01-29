// lib/widgets/item_toggle_grid.dart

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/cookware.dart'; // 确保引入 Model
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/painters/sketchy_box_painter.dart';

/// 调料/厨具网格卡片：使用代码生成的手绘风格（SketchyCard）。
/// 食材卡、剩菜卡则继续使用 assets/images/sketch_paper_transparent.png。
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
      // 外层页面（Seasonings / Cookware）已经有统一的边距，这里不再重复 padding，
      // 以便整体布局与 Ingredients 页的卡片对齐
      padding: EdgeInsets.zero,
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
    final bool isOn = item.isAvailable;
    final Color accentColor = Colors.orange;
    final Color iconColor = isOn ? Colors.black87 : Colors.grey;
    final Color frameColor = isOn
        ? const Color(0xFF8D6E63)
        : Colors.grey.shade500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: SketchyCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        margin: EdgeInsets.zero,
        backgroundColor: isOn ? Colors.white : Colors.grey.shade100,
        borderColor: frameColor,
        borderWidth: 1.5,
        onTap: () => onToggle(item),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: SketchyBoxPainter(color: frameColor),
                child: Center(
                  child: Icon(item.icon, size: 26, color: iconColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
