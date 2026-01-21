import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 🔥 1. 引入图片选择库
import 'package:personal_sous_chef/features/add_item/pages/review_ingredients_page.dart';
import 'package:personal_sous_chef/services/ai/yolo_service.dart'; // 🔥 2. 引入 YOLO 服务
import 'package:personal_sous_chef/data/models/ingredient.dart'; // 引入 Ingredient 模型

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  // 🔥 3. 定义状态变量
  final YoloService _yoloService = YoloService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // 控制加载遮罩显示

  // 🔥 4. 核心逻辑：拍照 -> 识别 -> 跳转
  Future<void> _handleImageInput(ImageSource source) async {
    try {
      // A. 拍照或选图
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) return; // 用户取消了

      // B. 显示 Loading
      setState(() => _isLoading = true);

      // C. 调用 AI 服务
      // 确保模型加载（虽然 Service 内部也会检查，这里显式调用更安全）
      await _yoloService.loadModel();
      final List<Ingredient> ingredients = await _yoloService.analyzeImage(
        photo.path,
      );

      // D. 隐藏 Loading
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No ingredients detected. Please try again."),
          ),
        );
        return;
      }

      // E. 跳转到 Review 页面，并传入识别结果
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewIngredientsPage(
            analyzedIngredients: ingredients, // 🔥 传入真实数据
          ),
        ),
      );

      // F. 如果 Review 页面完成了添加，继续回传结果给首页
      // ✅ 修改后的写法
      if (result != null) {
        // 先检查页面是否还在
        if (!mounted) return;
        // 确认安全后，再使用 context
        Navigator.pop(context, result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // 🔥 5. 辅助弹窗：让用户选相机还是相册
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleImageInput(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleImageInput(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // 去掉返回按钮，因为现在是tab切换
          title: const Text(
            "Add Items",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
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
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
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

        // 🔥 6. 使用 Stack 覆盖 Loading 层
        body: Stack(
          children: [
            TabBarView(
              children: [
                // 1. Photo Tab
                _buildUploadView(
                  title: "Upload Photo",
                  instruction: "Tap to take a photo or upload from gallery",
                  icon: Icons.add_a_photo_outlined,
                  btnText: "Take Photo / Upload",
                  onTap: () => _showPickerOptions(context), // 🔥 绑定点击事件
                ),

                // 2. Video Tab (逻辑类似，暂时也绑一样的方法，或者后续你单独处理)
                _buildUploadView(
                  title: "Upload Video",
                  instruction: "Select a video file to analyze ingredients",
                  icon: Icons.video_file_outlined,
                  btnText: "Upload Video",
                  onTap: () => _showPickerOptions(context),
                ),

                // 3. Live Detection Tab
                _buildLiveDetectionView(),
              ],
            ),

            // 🔥 7. Loading 遮罩层
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.orange),
                      const SizedBox(height: 20),
                      Text(
                        "AI is identifying ingredients...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- 通用组件：上传视图 ---
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
          Expanded(
            child: GestureDetector(
              // 让整个区域都能点击
              onTap: onTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
        Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.center_focus_weak, size: 100, color: Colors.white54),
                SizedBox(height: 20),
                Text(
                  "Coming Soon: Real-time Detection",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
