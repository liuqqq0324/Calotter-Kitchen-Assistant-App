import 'package:flutter/material.dart';

/// 使用定格动画关键帧的滑动删除包装器
///
/// 使用 frame_0, frame_2 作为关键帧，实现"揉成团"的视觉效果
/// - 保持卡片的真实高度，使用 centerSlice
/// - 居中显示，从右向左滑动
/// - 一旦开始滑动，完全用关键帧取代内容
class StopMotionDismissible extends StatefulWidget {
  final Widget child;
  final Function(DismissDirection)? onDismissed;
  final String dismissKey;

  // 两帧关键帧图片路径（已移除中间帧 frame_1）
  final List<String> frameImages = const [
    'assets/images/frame_0.png',
    'assets/images/frame_2.png',
  ];

  const StopMotionDismissible({
    super.key,
    required this.child,
    required this.dismissKey,
    required this.onDismissed,
  });

  @override
  State<StopMotionDismissible> createState() => _StopMotionDismissibleState();
}

class _StopMotionDismissibleState extends State<StopMotionDismissible> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.dismissKey),
      direction: DismissDirection.endToStart, // 只允许从右向左滑
      dismissThresholds: const {DismissDirection.endToStart: 0.6},

      onUpdate: (details) {
        setState(() {
          _progress = details.progress;
        });
      },

      onDismissed: widget.onDismissed,

      // 背景设为透明，因为我们用关键帧完全覆盖
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(color: Colors.transparent),

      child: Stack(
        alignment: Alignment.center, // 居中（不固定左侧）
        children: [
          // 1. 真实 UI (刚开始滑动就隐藏)
          Opacity(opacity: _progress > 0.1 ? 0.0 : 1.0, child: widget.child),

          // 2. 两帧动画替身（frame_0 和 frame_2）
          if (_progress > 0.01)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // --- 核心逻辑 ---

                  // A. 计算显示哪一张图 (0, 1)
                  // 0.0~0.5 -> Frame 0 (起皱)
                  // 0.5~1.0 -> Frame 2 (成团)
                  // 🔄 已移除中间帧 frame_1
                  int frameIndex;
                  if (_progress < 0.35) {
                    frameIndex = 0;
                  } else {
                    frameIndex = 1; // 对应 frame_2.png（原索引 2）
                  }

                  // B. 持续缩放 (Interpolation)
                  // 进度 0.0 -> 1.0，大小 1.0 -> 0.4
                  double scale = 1.0 - (_progress * 0.6);

                  // C. 持续旋转 (Rotation)
                  // 随着揉搓，纸团会滚动。逆时针转
                  // 进度 0.0 -> 1.0，角度 0 -> -0.2弧度 (约 -11.5度)
                  double rotation = -_progress * 0.1;

                  // D. 保持卡片真实高度，使用 centerSlice
                  // 获取子组件的实际高度
                  double cardHeight = constraints.maxHeight;

                  return Align(
                    alignment: Alignment.center, // 居中（不固定左侧）
                    child: Transform(
                      alignment: Alignment.center, // 以中心为基准进行变换
                      transform: Matrix4.identity()
                        // 🔥 恢复：均匀缩放整个图片，配合轻微旋转
                        ..scale(scale) // 持续变小（均匀缩放）
                        ..rotateZ(rotation), // 持续旋转
                      // 🔄 已注释：只缩放 X 轴（宽度）的实现
                      // ..scale(scale, 1.0) // scaleX 变小，scaleY 保持 1.0
                      // ..rotateZ(rotation), // 持续旋转
                      child: Container(
                        height: cardHeight, // 保持真实高度
                        width: constraints.maxWidth * scale, // 宽度随缩放变化
                        child: Image.asset(
                          widget.frameImages[frameIndex],
                          fit: BoxFit.fill,
                          // 🔥 使用 centerSlice 保持边缘不变形
                          // 假设关键帧图片也是 410x410，使用与 sketch_paper_transparent.png 相同的切片
                          centerSlice: const Rect.fromLTWH(25, 15, 360, 380),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
