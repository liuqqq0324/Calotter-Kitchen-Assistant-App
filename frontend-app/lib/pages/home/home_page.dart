import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前时间段，简单的问候语逻辑
    final hour = DateTime.now().hour;
    String greeting = "Hello, Chef!";
    if (hour < 12) {
      greeting = "Good Morning, Chef!";
    } else if (hour < 18) {
      greeting = "Good Afternoon, Chef!";
    } else {
      greeting = "Good Evening, Chef!";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 欢迎标语 - 手绘风格
          Text(
            greeting,
            style: SketchyTextStyle.title(context),
          ),
          const SizedBox(height: 8),
          Text(
            "Ready to cook something delicious?",
            style: SketchyTextStyle.body(context).copyWith(
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 30),

          // 2. 厨房状态卡片 - 手绘风格
          SketchyCard(
            backgroundColor: Colors.orange.shade400,
            borderColor: Colors.deepOrange.shade700,
            borderWidth: 2.5,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.kitchen, size: 50, color: Colors.white),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Kitchen",
                      style: GoogleFonts.kalam(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "3 Items Expiring", // 这里以后接真实数据
                      style: GoogleFonts.caveat(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. 每日推荐标题 - 手绘风格
          Text(
            "Recipe of the Day",
            style: SketchyTextStyle.heading(context),
          ),
          const SizedBox(height: 15),

          // 4. 推荐食谱卡片 - 手绘风格
          SketchyCard(
            backgroundColor: Colors.white,
            borderColor: Colors.black87,
            borderWidth: 2.0,
            padding: EdgeInsets.zero,
            child: Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  // 模拟图片背景
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // 渐变遮罩
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // 文字信息
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Creamy Mushroom Soup",
                          style: GoogleFonts.caveat(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "20 mins • Easy",
                          style: GoogleFonts.kalam(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
    );
  }
}
