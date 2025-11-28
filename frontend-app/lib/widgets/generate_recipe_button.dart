// lib/widgets/generate_recipe_button.dart

import 'package:flutter/material.dart';

class GenerateRecipeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isFullWidth; // 新增控制：是否撑满宽度 (用于不同场景)

  const GenerateRecipeButton({
    super.key,
    required this.onPressed,
    this.label = "Generate Recipes", // 默认文案
    this.icon = Icons.auto_awesome, // 默认图标 (AI 魔法棒)
    this.isFullWidth = false, // 默认是胶囊形状 (不撑满)
  });

  @override
  Widget build(BuildContext context) {
    // 按钮主体
    Widget buttonContent = Container(
      height: 56, // 标准 FAB 高度
      decoration: BoxDecoration(
        // 统一的橙色渐变风格
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28), // 完全圆角 (胶囊形)
        // 统一的阴影效果
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // 必须透明，否则会挡住渐变
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          // 触摸反馈色
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: isFullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min, // 关键：控制宽度
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 如果不需要撑满宽度，就直接返回
    if (!isFullWidth) {
      return buttonContent;
    }

    // 如果需要撑满，外面不需要额外包 Center，由父级布局决定
    return buttonContent;
  }
}
