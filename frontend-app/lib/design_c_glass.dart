// lib/design_c_glass.dart
import 'dart:ui'; // 必须导入以使用 ImageFilter
import 'package:flutter/material.dart';
import 'mock_data_source.dart';

/// 玻璃态（Glassmorphism）风格的食材展示页面
/// 设计灵感：磨砂玻璃效果，带有模糊、透明度和柔和发光
/// 特点：BackdropFilter 模糊、低透明度、白色边框、蓝色发光
class DesignCGlassPage extends StatelessWidget {
  const DesignCGlassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 渐变背景：从淡蓝色到白色
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPalette.waterBlue.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题（玻璃风格）
              _buildGlassAppBar(context),
              
              const SizedBox(height: 16),
              
              // 主内容列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: mockFridgeItems.length,
                  itemBuilder: (context, index) {
                    final item = mockFridgeItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGlassCard(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 玻璃风格浮动按钮
      floatingActionButton: _buildGlassFloatingButton(
        onTap: () {
          debugPrint('Add new item');
        },
      ),
    );
  }

  /// 构建玻璃风格 AppBar
  Widget _buildGlassAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.waterBlue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Glass Fridge',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.riverDeepBrown,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppPalette.seaweedGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${mockFridgeItems.length} items',
                    style: TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.riverDeepBrown.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建玻璃风格卡片
  Widget _buildGlassCard(MockIngredient item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25), // 低透明度实现玻璃效果
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            // 蓝色发光效果（关键！）
            boxShadow: [
              BoxShadow(
                color: AppPalette.waterBlue.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：名称和类别标记
              Row(
                children: [
                  // 类别颜色点
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.categoryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.riverDeepBrown,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 信息行
              Row(
                children: [
                  // 数量信息
                  Expanded(
                    child: _buildInfoBadge(
                      icon: Icons.scale_outlined,
                      label: 'Quantity',
                      value: '${item.quantity} ${item.unit}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 剩余天数信息
                  Expanded(
                    child: _buildInfoBadge(
                      icon: _getExpiryIcon(item.daysLeft),
                      label: 'Freshness',
                      value: _getExpiryText(item.daysLeft),
                      valueColor: _getExpiryColor(item.daysLeft),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildGlassButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {
                      debugPrint('Edit ${item.name}');
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildGlassButton(
                    icon: Icons.restaurant_menu,
                    label: 'Cook',
                    isPrimary: true,
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
    );
  }

  /// 构建信息徽章
  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppPalette.riverDeepBrown.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.riverDeepBrown.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppPalette.riverDeepBrown,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建玻璃风格按钮
  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppPalette.appetiteOrange.withOpacity(0.8)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppPalette.appetiteOrange.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppPalette.riverDeepBrown,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.white : AppPalette.riverDeepBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建玻璃风格浮动按钮
  Widget _buildGlassFloatingButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppPalette.appetiteOrange.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.appetiteOrange.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 根据剩余天数获取图标
  IconData _getExpiryIcon(int daysLeft) {
    if (daysLeft <= 1) {
      return Icons.warning_amber_rounded;
    } else if (daysLeft <= 3) {
      return Icons.access_time;
    } else {
      return Icons.verified;
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
      return 'Today!';
    } else if (daysLeft == 1) {
      return '1 day';
    } else {
      return '$daysLeft days';
    }
  }
}
