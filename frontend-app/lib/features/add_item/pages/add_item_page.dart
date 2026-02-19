import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_sous_chef/features/add_item/pages/review_ingredients_page.dart';
import 'package:personal_sous_chef/services/ai/cloud_vision_service.dart';
import 'package:personal_sous_chef/services/ai/yolo_service.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/shared/widgets/common/programmatic_sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_button.dart';
import 'package:personal_sous_chef/navigation/main_scaffold.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage>
    with SingleTickerProviderStateMixin {
  // 字体配置
  static const String _fontFamily = 'PatrickHand';
  // 主题色：River Deep Brown
  static const Color _themeBrown = Color(0xFF6B4F4F);

  final YoloService _yoloService = YoloService();
  final CloudVisionService _cloudService = CloudVisionService();
  final ImagePicker _picker = ImagePicker();

  // 状态变量
  bool _isLoading = false; // 是否正在推理分析（本地）
  bool _isModelReady = false; // 模型是否加载完毕
  bool _isAnalyzingCloud = false; // 云端识别中

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initModel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      if (!mounted) return;

      if (result == 'kitchen') {
        // 🔥 切换到厨房页面（索引3）
        // ReviewIngredientsPage 已经通过 Navigator.pop 关闭了
        // 现在只需要切换到厨房 tab
        context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(3);
      } else if (result == 'recipe') {
        // 🔥 切换到食谱页面（索引1）
        // ReviewIngredientsPage 已经通过 Navigator.pop 关闭了
        // 现在只需要切换到食谱 tab
        context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(1);
      }
      // 如果 result 为 null 或其他值，不需要特殊处理
      // ReviewIngredientsPage 已经通过 Navigator.pop 关闭了
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // 云端识别入口：选图 -> Gemini 多食材识别 -> 跳转 ReviewIngredientsPage
  Future<void> _handleCloudRecognition() async {
    setState(() => _isAnalyzingCloud = true);
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo == null) {
        setState(() => _isAnalyzingCloud = false);
        return;
      }
      final File imageFile = File(photo.path);
      final List<Ingredient> ingredients = await _cloudService
          .identifyIngredients(imageFile);
      if (!mounted) return;
      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cloud AI couldn't identify any ingredients."),
          ),
        );
        return;
      }
      // 与 YOLO 流程一致：直接跳转审核页，由 ReviewIngredientsPage 做单位校验
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReviewIngredientsPage(analyzedIngredients: ingredients),
        ),
      );
      if (!mounted) return;
      if (result == 'kitchen') {
        context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(3);
      } else if (result == 'recipe') {
        context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Network Error. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzingCloud = false);
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

  /// 本地扫描 Tab：YOLO 拍照/选图
  Widget _buildLocalScanTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 36.0, // 与 Tab 标签之间留出空隙
          bottom: 4.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _showPickerOptions(context),
                  child: AspectRatio(
                    aspectRatio: 0.85,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SketchyButton(
                text: _isModelReady ? "Start Scanning" : "Loading AI...",
                onPressed: _isModelReady
                    ? () => _showPickerOptions(context)
                    : () {},
                isFullWidth: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 28,
                ),
                backgroundColor: _isModelReady
                    ? _themeBrown
                    : Colors.grey.shade400,
                textColor: Colors.white,
                borderColor: _isModelReady
                    ? _themeBrown.withOpacity(0.8)
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  /// 云端识别 Tab：选图 -> Gemini 多食材识别
  Widget _buildCloudScanTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 36.0, // 与 Tab 标签之间留出空隙
          bottom: 4.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _isAnalyzingCloud
                      ? null
                      : () => _handleCloudRecognition(),
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFFFFF0).withOpacity(0.9),
                        shape: const SketchyRectBorder(
                          borderWidth: 2.5,
                          wobbleAmount: 3.0,
                          seed: 99,
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.15),
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
                              color: Colors.deepOrange.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload,
                              size: 70,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Cloud Expert",
                            style: _pangolin(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Upload a photo. Gemini AI will identify all ingredients and estimate quantities & units.",
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SketchyButton(
                text: _isAnalyzingCloud ? "Analyzing..." : "Choose Image",
                onPressed: _isAnalyzingCloud
                    ? () {}
                    : () => _handleCloudRecognition(),
                isFullWidth: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 28,
                ),
                backgroundColor: _isAnalyzingCloud
                    ? Colors.grey.shade400
                    : Colors.deepOrange,
                textColor: Colors.white,
                borderColor: _isAnalyzingCloud
                    ? Colors.grey.shade400
                    : Colors.deepOrange.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
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

          // 3. 主内容层（双 Tab：本地扫描 / 云端识别）
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
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
              bottom: TabBar(
                controller: _tabController,
                labelColor: _themeBrown,
                unselectedLabelColor: _themeBrown.withOpacity(0.6),
                indicatorColor: _themeBrown,
                labelStyle: _pangolin(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Local Scan'),
                  Tab(text: 'Cloud AI'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [_buildLocalScanTab(), _buildCloudScanTab()],
            ),
          ),

          // 4. 全局 Loading 遮罩（本地 / 云端共用）
          if (_isLoading || _isAnalyzingCloud)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 25),
                    Text(
                      _isAnalyzingCloud
                          ? "Cloud AI is analyzing..."
                          : "Analyzing Ingredients...",
                      style: _pangolin(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isAnalyzingCloud
                          ? "Identifying ingredients & quantities"
                          : "Looking for veggies, meats & more",
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
}
