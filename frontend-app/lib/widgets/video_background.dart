import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final String? videoPath;
  final String? videoUrl;
  final Widget child;

  const VideoBackground({
    super.key,
    this.videoPath,
    this.videoUrl,
    required this.child,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoPath != null) {
      _controller = VideoPlayerController.asset(widget.videoPath!);
    } else if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      // 如果没有提供视频，使用占位背景
      setState(() {
        _isInitialized = true;
      });
      return;
    }

    await _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.play();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      // 加载中或没有视频时显示渐变背景
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade200,
              Colors.green.shade300,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: widget.child,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 视频背景
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        // 半透明遮罩（可选，让文字更清晰）
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        // 内容
        widget.child,
      ],
    );
  }
}

