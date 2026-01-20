// lib/design_b_rafting.dart
import 'package:flutter/material.dart';
import 'mock_data_source.dart';

/// 漂流风格的食材展示页面
/// 设计灵感：河流中的鹅卵石，由海草连接在一起
/// 特点：扁平设计、大量留白、柔和的圆角、垂直连接线
class DesignBRaftingPage extends StatelessWidget {
  const DesignBRaftingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 纯白色背景
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rafting Down the River',
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppPalette.riverDeepBrown,
          ),
        ),
        centerTitle: true,
      ),
      
      body: Stack(
        children: [
          // 背景垂直连接线（海草）
          _buildSeaweedLine(),
          
          // 主内容列表
          _buildContentList(),
        ],
      ),
      
      // 浮动操作按钮（药丸形状）
      floatingActionButton: _buildPillButton(
        icon: Icons.add,
        label: 'Add Item',
        onTap: () {
          debugPrint('Add new item');
        },
      ),
    );
  }

  /// 构建垂直连接线（海草效果）
  Widget _buildSeaweedLine() {
    return Positioned(
      left: 40, // 与卡片左侧的圆点对齐
      top: 0,
      bottom: 0,
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          color: AppPalette.seaweedGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 构建主内容列表
  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: mockFridgeItems.length,
      itemBuilder: (context, index) {
        final item = mockFridgeItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24), // 卡片间距
          child: _buildPebbleCard(item),
        );
      },
    );
  }

  /// 构建鹅卵石风格卡片
  Widget _buildPebbleCard(MockIngredient item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧连接点（附着在海草线上）
        CircleAvatar(
          radius: 6,
          backgroundColor: AppPalette.seaweedGreen,
        ),
        
        const SizedBox(width: 16),
        
        // 主卡片容器
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.waterBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(32),
              // 无边框、无阴影（扁平设计）
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 食材名称行
                Row(
                  children: [
                    // 类别颜色标记
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.riverDeepBrown,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 数量和剩余天数信息
                Row(
                  children: [
                    // 数量
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.inventory_2_outlined,
                        text: '${item.quantity} ${item.unit}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 剩余天数
                    Expanded(
                      child: _buildInfoChip(
                        icon: _getExpiryIcon(item.daysLeft),
                        text: '${item.daysLeft}d left',
                        color: _getExpiryColor(item.daysLeft),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 操作按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildPillButton(
                    icon: Icons.restaurant_menu,
                    label: 'Use',
                    compact: true,
                    onTap: () {
                      debugPrint('Use ${item.name}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建信息芯片
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppPalette.riverDeepBrown.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color ?? AppPalette.riverDeepBrown.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建药丸形状按钮
  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: AppPalette.riverDeepBrown,
            borderRadius: BorderRadius.circular(30), // StadiumBorder 效果
            boxShadow: [
              BoxShadow(
                color: AppPalette.riverDeepBrown.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
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
      return Icons.schedule;
    } else {
      return Icons.check_circle_outline;
    }
  }

  /// 根据剩余天数获取颜色
  Color _getExpiryColor(int daysLeft) {
    if (daysLeft <= 1) {
      return Colors.red[600]!;
    } else if (daysLeft <= 3) {
      return AppPalette.appetiteOrange;
    } else {
      return AppPalette.seaweedGreen;
    }
  }
}
