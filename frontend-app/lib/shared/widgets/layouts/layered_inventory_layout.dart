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

            // 2. 顶部横向书签栏
            SizedBox(
              height: 50, // 书签高度
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        // 选中时给一个浅色背景，未选中透明
                        color: isSelected
                            ? const Color(0xFFFFF9E6) // 纸张色
                            : Colors.white.withOpacity(0.5), // 半透明白
                        // 顶部圆角，模仿书签/文件夹标签
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                          bottom: Radius.circular(0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 只有选中时显示图标，节省空间
                          if (isSelected && tab.imagePath != null) ...[
                            Image.asset(
                              tab.imagePath!,
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.bookmark,
                                size: 20,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.orange[900]
                                  : Colors.grey[700],
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
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
        if (floatingContent != null)
          Positioned.fill(child: floatingContent!),
      ],
    );
  }
}

/// 书签Tab数据模型
class BookmarkTabData {
  final String label;
  final String? imagePath;

  const BookmarkTabData({
    required this.label,
    this.imagePath,
  });
}
