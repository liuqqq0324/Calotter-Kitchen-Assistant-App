import 'package:flutter/material.dart';
import 'package:personal_sous_chef/pages/add_item/review_ingredients_page.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  @override
  Widget build(BuildContext context) {
    // 使用 DefaultTabController 管理 3 个 Tab
    return DefaultTabController(
      length: 3, // Photo, Video, Live
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Add Items",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,

          // 🔥 核心布局：Tab 导航栏
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // 灰色背景
                borderRadius: BorderRadius.circular(20), // 圆角胶囊形状
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                // 选中时的样式：橙色胶囊
                indicator: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white, // 选中的文字颜色
                unselectedLabelColor: Colors.grey.shade600, // 未选中的文字颜色
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Photo"),
                  Tab(text: "Video"),
                  Tab(text: "Live"),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            // 1. Photo Tab
            _buildUploadView(
              title: "Upload Photo",
              instruction:
                  "Tap the icon to take a photo or upload from gallery",
              icon: Icons.add_a_photo_outlined,
              btnText: "Upload Photo",
              onTap: () async {
                // 🔥 加上 async
                // 1. 等待 Review 页面返回结果
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewIngredientsPage(),
                  ),
                );

                // 2. 如果拿到了结果 (List<Ingredient>)，就继续往回传
                if (result != null && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
            ),

            // 2. Video Tab
            _buildUploadView(
              title: "Upload Video",
              instruction: "Select a video file to analyze ingredients",
              icon: Icons.video_file_outlined,
              btnText: "Upload Video",
              onTap: () async {
                // 🔥 加上 async
                // 1. 等待 Review 页面返回结果
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewIngredientsPage(),
                  ),
                );

                // 2. 如果拿到了结果 (List<Ingredient>)，就继续往回传
                if (result != null && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
            ),

            // 3. Live Detection Tab (实时检测)
            _buildLiveDetectionView(),
          ],
        ),
      ),
    );
  }

  // --- 通用组件：上传视图 (用于 Photo 和 Video) ---
  Widget _buildUploadView({
    required String title,
    required String instruction,
    required IconData icon,
    required String btnText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // 中间的虚线框占位符
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle
                      .solid, // Flutter 原生不支持虚线，先用实线，或者引入 dotted_border 库
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 大图标背景
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 50, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  // 文字说明
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      instruction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 底部橙色按钮
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // 暖色调
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: Text(
                btnText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 专用组件：实时检测视图 ---
  Widget _buildLiveDetectionView() {
    return Stack(
      children: [
        // 模拟相机预览背景
        Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.center_focus_weak, size: 100, color: Colors.white54),
                SizedBox(height: 20),
                Text(
                  "Camera Preview Initializing...",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),

        // 底部的操作栏
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                const Text(
                  "Point camera at ingredients",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // 开始检测按钮
                FloatingActionButton.large(
                  onPressed: () async {
                    // 🔥 加上 async
                    // 1. 等待返回
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReviewIngredientsPage(),
                      ),
                    );

                    // 2. 接力回传
                    if (result != null && context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
