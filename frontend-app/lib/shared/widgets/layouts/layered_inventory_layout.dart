import 'package:flutter/material.dart';

/// 分层库存页面布局组件
///
/// 实现透明/悬浮风格：
/// 1. 顶部横向书签栏
/// 2. 透明内容区域
/// 3. 浮动层（浮动按钮等）
class LayeredInventoryLayout extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;
  final List<BookmarkTabData> bookmarkTabs;
  final Widget mainContent;
  final Widget? floatingContent;

  const LayeredInventoryLayout({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.bookmarkTabs,
    required this.mainContent,
    this.floatingContent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主体布局：顶部 Tabs + 底部内容
        Column(
          children: [
            // 1. 顶部留白 (可选，避开状态栏)
            const SizedBox(height: 10),

            // 2. 顶部横向书签栏（图片卡片样式）
            SizedBox(
              height: 80, // 增加高度以容纳图片卡片
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: bookmarkTabs.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedTabIndex == index;
                  final tab = bookmarkTabs[index];

                  return GestureDetector(
                    onTap: () {
                      print('BookmarkTab tapped: ${tab.label}');
                      onTabChanged?.call(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: isSelected ? 70 : 60, // 选中时稍大
                      height: 70,
                      decoration: BoxDecoration(
                        // 使用图片作为背景
                        image: tab.imagePath != null
                            ? DecorationImage(
                                image: AssetImage(tab.imagePath!),
                                fit: BoxFit.cover,
                                opacity: isSelected ? 1.0 : 0.7,
                              )
                            : null,
                        // 选中时给一个浅色背景，未选中透明
                        color: tab.imagePath == null
                            ? (isSelected
                                  ? const Color(0xFFFFF9E6)
                                  : Colors.white.withOpacity(0.5))
                            : Colors.white.withOpacity(0.1),
                        // 圆角，做成卡片样式
                        borderRadius: BorderRadius.circular(12),
                        // 选中时的边框
                        border: isSelected
                            ? Border.all(color: Colors.orange, width: 3)
                            : Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                        // 阴影效果
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      alignment: Alignment.center,
                      child: tab.imagePath != null
                          ? // 如果有图片，显示图片和标签
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 图片已经作为背景，这里可以显示文字标签
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tab.label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : // 如果没有图片，显示图标和文字
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark,
                                  size: 24,
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey[600],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tab.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange[900]
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),

            // 3. 内容区域 (透明容器)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  // 纯透明背景
                  color: Colors.transparent,
                ),
                // Clip.none 允许子元素的阴影溢出
                clipBehavior: Clip.none,
                child: mainContent,
              ),
            ),
          ],
        ),

        // 4. 浮动层 (FAB) - 仍然在最顶层
        if (floatingContent != null) Positioned.fill(child: floatingContent!),
      ],
    );
  }
}

/// 书签Tab数据模型
class BookmarkTabData {
  final String label;
  final String? imagePath;

  const BookmarkTabData({required this.label, this.imagePath});
}
