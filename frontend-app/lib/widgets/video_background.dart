import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:personal_sous_chef/main.dart'; // 必须导入 main.dart 以获取 routeObserver

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

// 1. 添加 RouteAware 混入
class _VideoBackgroundState extends State<VideoBackground> with RouteAware {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // 2. 注册路由监听
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 3. 取消路由监听
    routeObserver.unsubscribe(this);
    _controller?.dispose();
    super.dispose();
  }

  // 4. 核心修复：当当前页面被覆盖后重新显示时（比如从 Login 返回 Landing）
  @override
  void didPopNext() {
    if (_isInitialized && _controller != null) {
      // 重新播放视频
      _controller!.play();
    }
  }

  // 5. 优化：当跳转到下一个页面时（比如去 Login）
  @override
  void didPushNext() {
    if (_isInitialized && _controller != null) {
      // 暂停视频以节省资源
      _controller!.pause();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoPath != null) {
      _controller = VideoPlayerController.asset(widget.videoPath!);
    } else if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
    } else {
      setState(() {
        _isInitialized = true;
      });
      return;
    }

    await _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.play();

    // 确保组件还在树中再调用 setState
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
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
        Container(color: Colors.black.withOpacity(0.3)),
        widget.child,
      ],
    );
  }
}
