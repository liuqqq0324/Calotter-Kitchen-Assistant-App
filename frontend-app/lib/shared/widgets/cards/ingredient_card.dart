import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/config/ingredient_icon_config.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/forms/quantity_selector.dart';
import 'package:personal_sous_chef/shared/widgets/tags/expiry_tag.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';
import 'package:personal_sous_chef/shared/widgets/painters/sketchy_box_painter.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient item;

  // --- 交互回调 ---
  final VoidCallback? onTap; // 点击卡片本身 (用于跳转详情)
  final Function(double) onQuantityChanged; // 🔥 数量变化（支持小数）
  final Function(String)? onUnitChanged; // 单位变化 (如果为 null，说明单位不可改)
  final VoidCallback? onExpiryTap; // 点击过期时间 (如果为 null，说明不可改)

  // --- 样式配置 ---
  final bool useStatusColors; // true: 开启红/橙/灰变色 (库存页); false: 纯白底 (Review页)

  // --- 可选配置 ---
  final List<String>? unitOptions; // 如果传入，数量选择器会显示下拉框

  const IngredientCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    this.onTap,
    this.onUnitChanged,
    this.onExpiryTap,
    this.useStatusColors = true, // 默认开启变色
    this.unitOptions,
  });

  /// 左侧图标：优先标准食材资源图（ingredient_icon_config），否则默认占位图或 emoji
  Widget _buildIngredientIcon() {
    final path = getIngredientIconPath(item.name);
    if (path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          path,
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _emojiPlaceholder(),
        ),
      );
    }
    final defaultPath = defaultIngredientIconPath;
    return Image.asset(
      defaultPath,
      width: 56,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _emojiPlaceholder(),
    );
  }

  Widget _emojiPlaceholder() {
    return Text(
      item.imagePlaceholder,
      style: const TextStyle(fontSize: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 文本颜色（根据状态可能变化）
    Color textColor = AppStyle.inkColorDark;

    // 如果开启状态颜色，可以为过期/临期的卡片添加颜色提示
    if (useStatusColors) {
      if (item.isExpired) {
        // 过期：文本变红
        textColor = Colors.red.shade800;
      } else if (item.isExpiringSoon) {
        // 临期：文本变橙色
        textColor = AppStyle.accentColor;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          FocusScope.of(context).unfocus(); // 统一处理键盘收起
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
            // 必须设置 padding，防止内容盖住图片边缘的毛边
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
                // --- 左侧：手绘风图标框（优先标准食材资源图，否则 emoji 占位）---
                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: CustomPaint(
                    painter: SketchyBoxPainter(color: const Color(0xFF8D6E63)),
                    child: Center(
                      child: _buildIngredientIcon(),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // --- 右侧：信息 ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 0.75,
                          // fontFamily: 'Patrick Hand', // 建议在 pubspec.yaml 中引入
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 数量选择器
                      GestureDetector(
                        onTap: () {}, // 拦截点击穿透
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: QuantitySelector(
                            initialValue: item.quantity,
                            unit: item.unit,
                            unitOptions: unitOptions,
                            onUnitChanged: onUnitChanged,
                            onChanged: onQuantityChanged,
                            totalWidth: unitOptions != null ? 75 : 60,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 过期时间标签
                      ExpiryTag(
                        expiryDate: item.expiryDate,
                        useStatusColors: useStatusColors,
                        onTap: onExpiryTap,
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
