import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 🔥 1. 引入图片选择库
import 'package:personal_sous_chef/features/add_item/pages/review_ingredients_page.dart';
import 'package:personal_sous_chef/services/ai/yolo_service.dart'; // 🔥 2. 引入 YOLO 服务
import 'package:personal_sous_chef/data/models/ingredient.dart'; // 引入 Ingredient 模型
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart'; // 引入 SketchyRectBorder

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  // 字体：使用本地字体 PatrickHand（在 pubspec.yaml 中注册）
  static const String _fontFamily = 'PatrickHand';

  TextStyle _pangolin({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

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
      child: SizedBox.expand(
        // 使用木纹海浪图片作为背景，确保填满整个页面
        child: Stack(
          children: [
            // 背景图层：填满整个屏幕
            Positioned.fill(
              child: Image.asset(
                'assets/wood_background.png',
                fit: BoxFit.cover,
                // 如果背景图路径不对/资源未打包，先用现有的 sketch_paper_transparent.png 兜底，避免崩溃
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/sketch_paper_transparent.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 可选：加一层轻薄的"纸张泛黄"蒙版，让内容更易读
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF3E5AB).withOpacity(0.35),
              ),
            ),
            // 内容层
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: const Color(0xFF6B4F4F), // River Deep Brown
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Add Items",
                  style: _pangolin(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B4F4F), // River Deep Brown
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4F4F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFF6B4F4F), // River Deep Brown
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B4F4F).withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(
                        0xFF6B4F4F,
                      ).withOpacity(0.6),
                      labelStyle: _pangolin(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: _pangolin(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
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
                        instruction:
                            "Tap to take a photo or upload from gallery",
                        icon: Icons.add_a_photo_outlined,
                        btnText: "Take Photo / Upload",
                        onTap: () => _showPickerOptions(context), // 🔥 绑定点击事件
                      ),

                      // 2. Video Tab (逻辑类似，暂时也绑一样的方法，或者后续你单独处理)
                      _buildUploadView(
                        title: "Upload Video",
                        instruction:
                            "Select a video file to analyze ingredients",
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
                            CircularProgressIndicator(
                              color: const Color(
                                0xFF6B4F4F,
                              ), // River Deep Brown
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "AI is identifying ingredients...",
                              style: _pangolin(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建手绘边框按钮
  Widget _buildSketchyButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    Color? backgroundColor,
  }) {
    final borderColor = const Color(0xFF6B4F4F).withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              borderWidth: 1.5,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5), // Account for border width
              child: Center(child: child), // Center the content
            ),
          ),
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
                decoration: ShapeDecoration(
                  color: const Color(
                    0xFFFFFFF0,
                  ).withOpacity(0.8), // Off-white/cream color
                  shape: const SketchyRectBorder(
                    borderWidth: 2.0,
                    wobbleAmount: 2.5,
                    seed: 42,
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF6B4F4F).withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4F4F).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 50,
                        color: const Color(0xFF6B4F4F).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        instruction,
                        textAlign: TextAlign.center,
                        style: _pangolin(
                          fontSize: 16,
                          color: const Color(0xFF6B4F4F).withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSketchyButton(
            onPressed: onTap,
            width: double.infinity,
            backgroundColor: const Color(0xFF6B4F4F), // River Deep Brown
            child: Text(
              btnText,
              style: _pangolin(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.center_focus_weak,
            size: 100,
            color: const Color(0xFF6B4F4F).withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "Coming Soon: Real-time Detection",
            style: _pangolin(
              fontSize: 18,
              color: const Color(0xFF6B4F4F).withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for sketchy button border
class _SketchyButtonBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wobbleAmount;
  final int seed;
  final math.Random _random;

  _SketchyButtonBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.wobbleAmount = 1.5,
    this.seed = 123,
  }) : _random = math.Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createSketchyPath(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  Path _createSketchyPath(Size size) {
    final path = Path();
    const double step = 8.0; // Distance between points on the path
    final double wobble = wobbleAmount;

    // Top edge: left to right
    path.moveTo(0, 0);
    for (double x = step; x < size.width; x += step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, noise);
    }
    path.lineTo(size.width, 0);

    // Right edge: top to bottom
    for (double y = step; y < size.height; y += step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(size.width + noise, y);
    }
    path.lineTo(size.width, size.height);

    // Bottom edge: right to left
    for (double x = size.width - step; x > 0; x -= step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(x, size.height + noise);
    }
    path.lineTo(0, size.height);

    // Left edge: bottom to top
    for (double y = size.height - step; y > 0; y -= step) {
      final noise = (_random.nextDouble() * 2 - 1) * wobble;
      path.lineTo(noise, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
