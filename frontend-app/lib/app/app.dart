import 'package:flutter/material.dart';
import 'package:personal_sous_chef/app/app_config.dart';
import 'package:personal_sous_chef/core/routing/route_observer.dart';
import 'package:personal_sous_chef/core/theme/app_theme.dart';
import 'package:personal_sous_chef/features/auth/pages/landing_page.dart';

// 主应用 Widget
// 已从 main.dart 拆分出来

class SousChefApp extends StatelessWidget {
  const SousChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      navigatorObservers: [routeObserver], // 添加路由观察者
      theme: AppTheme.lightTheme,
      // Start with landing page for authentication
      home: const LandingPage(),
    );
  }
}

