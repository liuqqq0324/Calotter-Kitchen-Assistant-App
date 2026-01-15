// lib/design_a_scrapbook.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mock_data_source.dart';

/// 剪贴簿风格的食材展示页面
/// 设计灵感：手工粘贴的照片墙，每张卡片都带有胶带和随机倾斜效果
class DesignAScrapbookPage extends StatelessWidget {
  const DesignAScrapbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 纯色背景：泡沫白
      backgroundColor: AppPalette.foamWhite,
      
      appBar: AppBar(
        backgroundColor: AppPalette.foamWhite,
        elevation: 0,
        title: const Text(
          'My Fridge Scrapbook',
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppPalette.riverDeepBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          // 添加按钮（贴纸风格）
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildStickerButton(
              icon: Icons.add,
              onTap: () {
                // 添加新食材的逻辑
                debugPrint('Add new ingredient');
              },
            ),
          ),
        ],
      ),
      
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mockFridgeItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = mockFridgeItems[index];
            return _buildScrapbookCard(item, index);
          },
        ),
      ),
      
      // 底部浮动操作按钮（贴纸风格）
      floatingActionButton: _buildStickerButton(
        icon: Icons.camera_alt,
        size: 60,
        iconSize: 30,
        onTap: () {
          debugPrint('Take a photo');
        },
      ),
    );
  }

  /// 构建剪贴簿卡片（带胶带和随机旋转效果）
  Widget _buildScrapbookCard(MockIngredient item, int index) {
    // 根据索引生成稳定的随机角度（-0.02 到 0.02 弧度）
    final random = math.Random(index);
    final rotationAngle = (random.nextDouble() - 0.5) * 0.04; // -0.02 到 0.02

    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 主卡片容器
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppPalette.riverDeepBrown,
                  width: 2.0,
                ),
                // 硬阴影效果（无模糊）
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 食材名称（主文本）
                    Row(
                      children: [
                        // 类别颜色标记
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.categoryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontFamily: 'Caveat',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.riverDeepBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 数量信息
                    Row(
                      children: [
                        Text(
                          'Qty:',
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.riverDeepBrown.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.appetiteOrange,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 剩余天数
                    Row(
                      children: [
                        Icon(
                          _getExpiryIcon(item.daysLeft),
                          size: 20,
                          color: _getExpiryColor(item.daysLeft),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getExpiryText(item.daysLeft),
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _getExpiryColor(item.daysLeft),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 操作按钮行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          label: 'Edit',
                          icon: Icons.edit,
                          onTap: () {
                            debugPrint('Edit ${item.name}');
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          label: 'Cook',
                          icon: Icons.restaurant,
                          color: AppPalette.seaweedGreen,
                          onTap: () {
                            debugPrint('Cook with ${item.name}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 胶带装饰（顶部中心）
            Positioned(
              top: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppPalette.seaweedGreen.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建贴纸风格按钮（圆形）
  Widget _buildStickerButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 48,
    double iconSize = 24,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppPalette.appetiteOrange,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppPalette.riverDeepBrown,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: AppPalette.riverDeepBrown,
        ),
      ),
    );
  }

  /// 构建操作按钮（圆角矩形）
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color ?? AppPalette.appetiteOrange,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppPalette.riverDeepBrown,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppPalette.riverDeepBrown,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Caveat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.riverDeepBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据剩余天数获取图标
  IconData _getExpiryIcon(int daysLeft) {
    if (daysLeft <= 1) {
      return Icons.warning;
    } else if (daysLeft <= 3) {
      return Icons.access_time;
    } else {
      return Icons.check_circle;
    }
  }

  /// 根据剩余天数获取颜色
  Color _getExpiryColor(int daysLeft) {
    if (daysLeft <= 1) {
      return Colors.red[700]!;
    } else if (daysLeft <= 3) {
      return AppPalette.appetiteOrange;
    } else {
      return AppPalette.seaweedGreen;
    }
  }

  /// 根据剩余天数获取文本
  String _getExpiryText(int daysLeft) {
    if (daysLeft == 0) {
      return 'Expires TODAY!';
    } else if (daysLeft == 1) {
      return 'Expires TOMORROW';
    } else if (daysLeft <= 3) {
      return 'Expires in $daysLeft days';
    } else {
      return 'Fresh ($daysLeft days left)';
    }
  }
}
