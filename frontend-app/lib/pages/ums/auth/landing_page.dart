import 'package:flutter/material.dart';
import 'login_page.dart';
import 'registration_page.dart';
// Modified by Chase: Fixed import paths after moving to ums/auth/ folder / 由 Chase 修改：移动到 ums/auth/ 文件夹后修复导入路径
// Need to go up 3 levels to reach lib/widgets/ and lib/main.dart / 需要向上3级才能到达 lib/widgets/ 和 lib/main.dart
import '../../../widgets/video_background.dart';
import '../../../widgets/handwriting_animation.dart';
import '../../../widgets/sketchy_button.dart';
import '../../../main.dart'; // 引入 routeObserver

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with RouteAware {
  int _animationKey = 0; // 用于重置动画的 key

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 注册路由观察者
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 取消订阅路由观察者
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 当从其他页面返回到此页面时调用
  @override
  void didPopNext() {
    // 从其他页面返回时，重置动画
    if (mounted) {
      // 延迟一下确保路由已经完全激活
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _animationKey++; // 改变 key 以强制重建 HandwritingAnimation
          });
        }
      });
    }
  }

  // 当此页面被推入路由栈时调用（首次显示）
  @override
  void didPush() {
    // 首次显示时不需要重置，动画会自动播放
  }

  // 当此页面从路由栈弹出时调用
  @override
  void didPop() {
    // 页面被弹出时不需要处理
  }

  // 当其他页面被推入到此页面之上时调用
  @override
  void didPushNext() {
    // 跳转到其他页面时不需要处理
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBackground(
        // 视频路径（本地）
        videoPath: 'assets/videos/meow.mp4',
        // 或者使用网络视频（备用，已注释）
        // videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App 名称 - 手写动画（使用 key 确保每次返回时重新播放）
                HandwritingAnimation(
                  key: ValueKey(_animationKey),
                  text: 'Calotter',
                  fontSize: 64,
                  color: Colors.white,
                  animationDuration: const Duration(seconds: 2),
                ),
                const SizedBox(height: 60),
                // Log in 按钮 - 手绘风格
                SketchyButton(
                  text: 'Log in',
                  icon: Icons.arrow_forward,
                  backgroundColor: Colors.orange.shade400,
                  borderColor: Colors.deepOrange.shade700,
                  onPressed: () async {
                    // 等待页面返回
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    // 返回时重置动画
                    if (mounted) {
                      setState(() {
                        _animationKey++;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Sign up 按钮 - 手绘风格
                SketchyButton(
                  text: 'Sign up',
                  icon: Icons.arrow_forward,
                  backgroundColor: Colors.green.shade400,
                  borderColor: Colors.green.shade700,
                  onPressed: () async {
                    // 等待页面返回
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationPage(),
                      ),
                    );
                    // 返回时重置动画
                    if (mounted) {
                      setState(() {
                        _animationKey++;
                      });
                    }
                  },
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
