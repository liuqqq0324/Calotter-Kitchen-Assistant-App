import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/leftover.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';
import 'package:personal_sous_chef/shared/widgets/painters/sketchy_box_painter.dart';

/// 烹饪分类与 dish_category 下非 SKETCH 图标的映射（与后端 CookingCategory 枚举一致）
const Map<String, String> _dishCategoryAssetMap = {
  'STIR_FRY_PAN_FRY': 'assets/dish_category/STIR_FRY_PAN_FRY.png',
  'STEAM_BOIL': 'assets/dish_category/STEAM_BOIL.png',
  'BRAISE_STEW': 'assets/dish_category/BRAISE_STEW.png',
  'COLD_SALAD': 'assets/dish_category/COLD_SALAD.png',
  'SOUP': 'assets/dish_category/SOUP.png',
  'ROAST_BAKE': 'assets/dish_category/ROAST_BAKE.png',
};

class LeftoverCard extends StatelessWidget {
  final Leftover item;

  // --- 交互回调 ---
  final VoidCallback? onTap; // 点击卡片本身

  const LeftoverCard({super.key, required this.item, this.onTap});

  /// 左侧图标：优先封面图，否则按 category 显示 assets/dish_category 下非 SKETCH 的 PNG
  Widget _buildLeftoverIcon(BuildContext context) {
    if (item.coverImage != null && item.coverImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.coverImage!,
          width: 75,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _categoryOrPlaceholder(),
        ),
      );
    }
    return _categoryOrPlaceholder();
  }

  Widget _categoryOrPlaceholder() {
    final assetPath = item.category != null
        ? _dishCategoryAssetMap[item.category!]
        : null;
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: 75,
          height: 75,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              item.imagePlaceholder ?? '🍽️',
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Text(
        item.imagePlaceholder ?? '🍽️',
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 文本颜色（根据状态可能变化）
    Color textColor = AppStyle.inkColorDark;

    // 如果过期或临期，改变文本颜色
    if (item.isExpired) {
      textColor = Colors.red.shade800;
    } else if (item.isExpiringSoon) {
      textColor = AppStyle.accentColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          FocusScope.of(context).unfocus();
          onTap!();
        }
      },
      child: Container(
        // 外层 Margin：增大上下 margin 以减少误触
        margin: const EdgeInsets.fromLTRB(16, 2, 16, 2),
        // --- 手工纸张主体（使用图片背景 + 九宫格拉伸）---
        // 使用 IntrinsicHeight 让容器根据内容自动调整高度
        child: IntrinsicHeight(
          child: Container(
            // 🔥 修复：减小上下 padding 各 10px（从 20, 35 改为 10, 25）；上 padding 再增加 5px
            padding: const EdgeInsets.fromLTRB(40, 15, 25, 25),
            decoration: BoxDecoration(
              image: DecorationImage(
                // 使用手绘纸张背景图片（410px * 410px）
                image: const AssetImage(
                  'assets/images/sketch_paper_transparent.png',
                ),
                fit: BoxFit.fill,
                // 🔥 核心计算：
                // Rect.fromLTWH(左切线, 上切线, 宽, 高)
                // 注意：这里的值是基于"原图尺寸 410x410"的坐标
                // 已将预留边缘再减少15px，进一步扩大可拉伸区域
                // 左边 25px 是毛边（不许拉伸）
                // 右边 25px 是毛边（不许拉伸）
                // 上边 15px 是毛边（不许拉伸）
                // 下边 15px 是毛边（不许拉伸）
                // 中间剩下的区域（宽360px，高380px）才是可以随便拉伸的
                centerSlice: const Rect.fromLTWH(25, 15, 360, 380),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 左侧：手绘风图标框（优先封面图，否则按 category 显示 dish_category 下非 SKETCH 图标）---
                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: CustomPaint(
                    painter: SketchyBoxPainter(color: const Color(0xFF8D6E63)),
                    child: _buildLeftoverIcon(context),
                  ),
                ),

                const SizedBox(width: 24),

                // --- 右侧：信息 ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 菜品名称
                      Text(
                        item.dishName ?? 'Unknown Dish',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 0.75,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 显示总卡路里（当前剩余重量对应的卡路里）
                      Text(
                        item.currentCalories != null
                            ? '${item.currentCalories} kcal'
                            : '— kcal',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Production time / days remaining
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: item.isExpired
                                ? Colors.red
                                : (item.isExpiringSoon
                                      ? Colors.orange
                                      : Colors.grey[600]),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.isExpired
                                  ? 'Expired ${item.daysSinceProduced} days ago'
                                  : (item.isExpiringSoon
                                        ? 'Expiring soon (${3 - item.daysSinceProduced} days left)'
                                        : 'Made ${item.daysSinceProduced} days ago'),
                              style: TextStyle(
                                fontSize: 14,
                                color: item.isExpired
                                    ? Colors.red
                                    : (item.isExpiringSoon
                                          ? Colors.orange
                                          : Colors.grey[600]),
                                fontWeight:
                                    item.isExpired || item.isExpiringSoon
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
