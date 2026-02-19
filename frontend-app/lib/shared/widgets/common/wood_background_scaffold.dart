import 'package:flutter/material.dart';

/// 与 profile_view_page 一致的木板背景 + 透明 Scaffold 包装
class WoodBackgroundScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const WoodBackgroundScaffold({
    super.key,
    this.appBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
