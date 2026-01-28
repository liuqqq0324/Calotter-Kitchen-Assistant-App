import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_sous_chef/features/add_item/pages/review_ingredients_page.dart';
import 'package:personal_sous_chef/services/ai/yolo_service.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  // 字体配置
  static const String _fontFamily = 'PatrickHand';
  // 主题色：River Deep Brown
  static const Color _themeBrown = Color(0xFF6B4F4F);

  final YoloService _yoloService = YoloService();
  final ImagePicker _picker = ImagePicker();

  // 状态变量
  bool _isLoading = false; // 是否正在推理分析
  bool _isModelReady = false; // 模型是否加载完毕

  @override
  void initState() {
    super.initState();
    // 页面进入时立即预加载模型
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _yoloService.loadModel();
      if (mounted) {
        setState(() => _isModelReady = true);
      }
    } catch (e) {
      debugPrint("Error loading model: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("AI Model failed to load: $e")));
      }
    }
  }

  TextStyle _pangolin({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // 🔥 核心逻辑：拍照/选图 -> 推理 -> 跳转
  Future<void> _handleImageInput(ImageSource source) async {
    // 1. 再次防御性检查模型
    if (!_isModelReady) {
      await _initModel(); // 尝试最后一次急救加载
      if (!_isModelReady) return;
    }

    try {
      // 2. 选择图片
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) return; // 用户取消

      // 3. 开始 Loading
      setState(() => _isLoading = true);

      // 4. 执行推理 (Service 内部已移除 loadModel 重复调用)
      final List<Ingredient> ingredients = await _yoloService.analyzeImage(
        photo.path,
      );

      // 5. 结束 Loading
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (ingredients.isEmpty) {
        _showNoResultDialog();
        return;
      }

      // 6. 跳转结果页
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReviewIngredientsPage(analyzedIngredients: ingredients),
        ),
      );

      // 7. 处理返回结果
      if (result != null && mounted) {
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

  // 无结果时的友好提示
  void _showNoResultDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFF0),
        shape: const SketchyRectBorder(borderWidth: 2, wobbleAmount: 1.5),
        title: Text(
          "Oops!",
          style: _pangolin(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _themeBrown,
          ),
        ),
        content: Text(
          "I couldn't spot any ingredients.\n\nTry getting closer or ensuring better lighting.",
          style: _pangolin(fontSize: 18, color: _themeBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Try Again",
              style: _pangolin(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _themeBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 底部弹窗选项
  void _showPickerOptions(BuildContext context) {
    if (!_isModelReady) return; // 模型未就绪时不弹出

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFF0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: _themeBrown,
                    size: 28,
                  ),
                  title: Text(
                    'Take a Photo',
                    style: _pangolin(fontSize: 20, color: _themeBrown),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleImageInput(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: _themeBrown,
                    size: 28,
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: _pangolin(fontSize: 20, color: _themeBrown),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleImageInput(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 1. 背景层
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFD7CCC8)),
            ),
          ),
          // 2. 泛黄纸张滤镜
          Positioned.fill(
            child: Container(color: const Color(0xFFF3E5AB).withOpacity(0.35)),
          ),

          // 3. 主内容层
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, // 如果是 Tab 首页通常不需要返回箭头
              centerTitle: true,
              title: Text(
                "Add Items",
                style: _pangolin(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _themeBrown,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // 移除了 TabBarView，直接显示单一视图
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 4.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- 手绘风格卡片区域 ---
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _showPickerOptions(context),
                          child: AspectRatio(
                            aspectRatio: 0.85, // 稍微高一点的长方形
                            child: Container(
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFFFF0).withOpacity(0.9),
                                shape: const SketchyRectBorder(
                                  borderWidth: 2.5,
                                  wobbleAmount: 3.0,
                                  seed: 88,
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: _themeBrown.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(4, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(25),
                                    decoration: BoxDecoration(
                                      color: _themeBrown.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.center_focus_strong_outlined,
                                      size: 70,
                                      color: _themeBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Snap & Cook",
                                    style: _pangolin(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: _themeBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      "Take a photo of your fridge or groceries.\nAI will detect the ingredients for you.",
                                      textAlign: TextAlign.center,
                                      style: _pangolin(
                                        fontSize: 17,
                                        color: _themeBrown.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 底部主按钮 ---
                    _buildSketchyButton(
                      onPressed: _isModelReady
                          ? () => _showPickerOptions(context)
                          : null,
                      width: double.infinity,
                      backgroundColor: _isModelReady
                          ? _themeBrown
                          : Colors.grey.shade400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isModelReady)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          if (!_isModelReady) const SizedBox(width: 10),
                          Text(
                            _isModelReady ? "Start Scanning" : "Loading AI...",
                            style: _pangolin(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40), // 底部留白，避免被系统栏遮挡
                  ],
                ),
              ),
            ),
          ),

          // 4. 全局 Loading 遮罩 (推理时显示)
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 25),
                    Text(
                      "Analyzing Ingredients...",
                      style: _pangolin(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Looking for veggies, meats & more",
                      style: _pangolin(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 手绘按钮组件 (保留) ---
  Widget _buildSketchyButton({
    required VoidCallback? onPressed,
    required Widget child,
    double? width,
    Color? backgroundColor,
  }) {
    // 禁用状态下的透明度
    final isEnabled = onPressed != null;
    final effectiveBgColor = backgroundColor ?? Colors.transparent;
    final borderColor = isEnabled
        ? _themeBrown.withOpacity(0.8)
        : Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: 60, // 稍微加大高度
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _SketchyButtonBorderPainter(
              borderColor: borderColor,
              borderWidth: 2.0,
              wobbleAmount: 1.5,
              seed: 123,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

// --- 手绘边框 Painter (保持不变) ---
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
    const double step = 8.0;
    final double wobble = wobbleAmount;

    path.moveTo(0, 0);
    // Top
    for (double x = step; x < size.width; x += step) {
      path.lineTo(x, (_random.nextDouble() * 2 - 1) * wobble);
    }
    path.lineTo(size.width, 0);
    // Right
    for (double y = step; y < size.height; y += step) {
      path.lineTo(size.width + (_random.nextDouble() * 2 - 1) * wobble, y);
    }
    path.lineTo(size.width, size.height);
    // Bottom
    for (double x = size.width - step; x > 0; x -= step) {
      path.lineTo(x, size.height + (_random.nextDouble() * 2 - 1) * wobble);
    }
    path.lineTo(0, size.height);
    // Left
    for (double y = size.height - step; y > 0; y -= step) {
      path.lineTo((_random.nextDouble() * 2 - 1) * wobble, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
