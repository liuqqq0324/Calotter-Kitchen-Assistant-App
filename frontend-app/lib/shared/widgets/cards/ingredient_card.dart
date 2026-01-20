import 'package:flutter/material.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/forms/quantity_selector.dart';
import 'package:personal_sous_chef/shared/widgets/tags/expiry_tag.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';
import 'package:personal_sous_chef/shared/widgets/painters/rough_paper_painter.dart';
import 'package:personal_sous_chef/shared/widgets/painters/watercolor_tape_painter.dart';
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

  @override
  Widget build(BuildContext context) {
    // 纸张颜色（根据状态可能变化）
    Color paperColor = const Color(0xFFFDFBF7); // 米白纸
    Color textColor = AppStyle.inkColorDark;

    // 如果开启状态颜色，可以为过期/临期的卡片添加轻微的颜色提示
    if (useStatusColors) {
      if (item.isExpired) {
        // 过期：纸张稍微偏红一点，但还是很淡
        paperColor = const Color(0xFFFFF0F0);
        textColor = Colors.red.shade800;
      } else if (item.isExpiringSoon) {
        // 临期：纸张稍微偏橙一点
        paperColor = const Color(0xFFFFF8E1);
        textColor = AppStyle.accentColor;
      }
    }

    // 整个卡片是一个 Stack，为了放置左侧的胶带
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          FocusScope.of(context).unfocus(); // 统一处理键盘收起
          onTap!();
        }
      },
      child: Container(
        // 外层 Margin：左侧留出更多空间给胶带
        margin: const EdgeInsets.fromLTRB(20, 12, 16, 12),
        child: Stack(
          clipBehavior: Clip.none, // 允许胶带超出边界
          alignment: Alignment.centerLeft,
          children: [
            // --- 1. 手工纸张主体（毛边纸 + 内描边）---
            CustomPaint(
              painter: RoughPaperPainter(
                paperColor: paperColor,
                borderColor: AppStyle.inkColorDark,
                borderPadding: 6.0,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 20, 20, 20), // 左侧留给胶带
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- 左侧：手绘风图标框 ---
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: CustomPaint(
                        painter: SketchyBoxPainter(
                          color: const Color(0xFF8D6E63),
                        ),
                        child: Center(
                          child: Text(
                            item.imagePlaceholder,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

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
                              letterSpacing: 0.5,
                              // fontFamily: 'Patrick Hand', // 建议在 pubspec.yaml 中引入
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // 数量选择器
                          GestureDetector(
                            onTap: () {}, // 拦截点击穿透
                            child: QuantitySelector(
                              initialValue: item.quantity,
                              unit: item.unit,
                              unitOptions: unitOptions,
                              onUnitChanged: onUnitChanged,
                              onChanged: onQuantityChanged,
                              totalWidth: unitOptions != null ? 95 : 70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. 底部日期 (手绘风格) ---
            Positioned(
              bottom: 12,
              right: 16, // 放在右下角
              child: ExpiryTag(
                expiryDate: item.expiryDate,
                useStatusColors: useStatusColors,
                onTap: onExpiryTap,
              ),
            ),

            // --- 3. 蓝色水彩胶带装饰 (Watercolor Tape) ---
            Positioned(
              left: -8, // 往左探出
              top: 15,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.03, // 微微倾斜
                  child: CustomPaint(
                    size: const Size(40, 90), // 扁平胶带
                    painter: WatercolorTapePainter(
                      tearHeight: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

