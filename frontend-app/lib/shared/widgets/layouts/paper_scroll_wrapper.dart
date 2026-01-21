import 'package:flutter/material.dart';

/// 纸张滚动包装器
/// 
/// 实现"手绘书页"随内容拉长的效果，使用三段式切图法：
/// 1. 页头 (Header): 纸张的顶部撕边效果（固定高度）
/// 2. 页身 (Body): 纸张的中间纹理（可循环平铺/拉伸，随内容高度变化）
/// 3. 页脚 (Footer): 纸张的底部撕边效果（固定高度）
/// 
/// 这样当用户滚动列表时，纸张会随内容一起移动，而不是固定在背景上。
class PaperScrollWrapper extends StatelessWidget {
  /// 要显示的内容列表
  final List<Widget> children;

  /// 内容区域的内边距
  final EdgeInsets padding;

  /// 顶部留白（避免被书签遮挡）
  final double topSpacing;

  /// 底部留白（避免被浮动按钮遮挡）
  final double bottomSpacing;

  /// 纸张顶部图片路径
  final String? paperTopImage;

  /// 纸张中间纹理图片路径
  final String? paperBodyImage;

  /// 纸张底部图片路径
  final String? paperBottomImage;

  const PaperScrollWrapper({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.topSpacing = 20.0,
    this.bottomSpacing = 100.0,
    this.paperTopImage,
    this.paperBodyImage,
    this.paperBottomImage,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了三段式图片，使用三段式布局
    if (paperTopImage != null && paperBodyImage != null && paperBottomImage != null) {
      return _buildThreeSliceLayout();
    }

    // 否则使用单张图片作为背景（兼容现有资源）
    return _buildSingleImageLayout();
  }

  /// 三段式布局（推荐）
  Widget _buildThreeSliceLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部留白（避免被书签遮挡）
          SizedBox(height: topSpacing),

          // 1. 纸张顶部 (页头)
          Image.asset(
            paperTopImage!,
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
          ),

          // 2. 纸张中间 (随内容拉伸)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(paperBodyImage!),
                repeat: ImageRepeat.repeatY, // 关键：垂直平铺
                fit: BoxFit.fitWidth,
              ),
            ),
            padding: padding,
            child: Column(
              children: children,
            ),
          ),

          // 3. 纸张底部 (页脚)
          Image.asset(
            paperBottomImage!,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),

          // 底部留白
          SizedBox(height: bottomSpacing),
        ],
      ),
    );
  }

  /// 单张图片布局（兼容模式）
  /// 
  /// 使用现有的 inventory_container.png，通过 centerSlice 实现拉伸效果
  Widget _buildSingleImageLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/inventory_container.png'),
            fit: BoxFit.fill,
            // 使用 centerSlice 保持边缘不变形
            centerSlice: const Rect.fromLTWH(25, 15, 360, 380),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部留白
            SizedBox(height: topSpacing),

            // 内容区域
            Padding(
              padding: padding,
              child: Column(
                children: children,
              ),
            ),

            // 底部留白
            SizedBox(height: bottomSpacing),
          ],
        ),
      ),
    );
  }
}

