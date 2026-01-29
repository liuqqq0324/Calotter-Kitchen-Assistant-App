// lib/widgets/item_toggle_grid.dart

import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/cookware.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/painters/sketchy_box_painter.dart';

/// 调料/厨具网格卡片：使用代码生成的手绘风格（SketchyCard）。
/// 食材卡、剩菜卡则继续使用 assets/images/sketch_paper_transparent.png。
class ItemToggleGrid extends StatelessWidget {
  final List<Cookware> items;
  final Function(Cookware) onToggle;

  const ItemToggleGrid({
    super.key,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // 🔥 改回 3 列
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        // 🔥 0.85 让卡片略高，给文字留垂直空间，防止 BOTTOM OVERFLOWED
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildToggleCard(context, items[index]);
      },
    );
  }

  /// 多个词时拆成两行显示（如 "Cooking Wine" → 第一行 "Cooking"，第二行 "Wine"）
  Widget _buildNameText(BuildContext context, String name, bool isOn) {
    final style = TextStyle(
      fontSize: 14,
      fontFamily: 'PatrickHand',
      fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
      color: isOn ? Colors.black87 : Colors.grey.shade600,
      height: 1.1,
    );
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final line1 = parts.first;
      final line2 = parts.skip(1).join(' ');
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(line1, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          Text(line2, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ],
      );
    }
    return Text(
      name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  Widget _buildToggleCard(BuildContext context, Cookware item) {
    final bool isOn = item.isAvailable;

    final Color iconColor = isOn ? Colors.black87 : Colors.grey.shade400;
    final Color frameColor = isOn
        ? const Color(0xFF5D4037)
        : Colors.grey.shade400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SketchyCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        margin: EdgeInsets.zero,
        backgroundColor: isOn ? Colors.white : Colors.white.withOpacity(0.5),
        borderColor: frameColor,
        borderWidth: isOn ? 2.0 : 1.5,
        onTap: () => onToggle(item),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: CustomPaint(
                painter: SketchyBoxPainter(color: frameColor),
                child: Center(
                  child: Icon(item.icon, size: 24, color: iconColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _buildNameText(context, item.name, isOn),
            ),
          ],
        ),
      ),
    );
  }
}
