import 'package:flutter/material.dart';
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/widgets/quantity_selector.dart';
import 'package:personal_sous_chef/widgets/expiry_tag.dart';

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
    // 1. 计算颜色逻辑 (复用之前的逻辑)
    Color cardColor = Colors.white;
    Color textColor = Colors.black87;
    double elevation = 2.0;

    if (useStatusColors) {
      if (item.isExpired) {
        cardColor = Colors.red.shade50;
        textColor = Colors.red;
        elevation = 5.0; // 过期稍微浮起来一点
      } else if (item.isExpiringSoon) {
        cardColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        elevation = 3.0;
      }
    }

    // 2. 构建卡片
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          FocusScope.of(context).unfocus(); // 统一处理键盘收起
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
                child: Center(
                  child: Text(
                    item.imagePlaceholder,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // --- 右侧：三层错落布局 ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. 名字 (左对齐)
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 2. 数量控制器 (右对齐)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        // 给数量控制器单独包一个 GestureDetector 拦截点击穿透
                        child: GestureDetector(
                          onTap: () {},
                          child: QuantitySelector(
                            initialValue: item.quantity,
                            unit: item.unit,
                            // 如果传入了单位选项，说明是编辑模式，稍微宽一点
                            totalWidth: unitOptions != null ? 95 : 70,
                            unitOptions: unitOptions,
                            onUnitChanged: onUnitChanged,
                            onChanged: onQuantityChanged,
                          ),
                        ),
                      ),
                    ),

                    // 3. 过期时间 (左对齐)
                    ExpiryTag(
                      expiryDate: item.expiryDate,
                      // 如果 useStatusColors 为 true，ExpiryTag 也开启变色模式
                      useStatusColors: useStatusColors,
                      onTap: onExpiryTap, // 点击弹出日历
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
