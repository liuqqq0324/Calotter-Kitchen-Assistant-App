import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 个人中心页面（UI Playground 版）
/// 所有数据为本地 Mock，便于独立调试 UI。
class PersonalCenterPage extends StatelessWidget {
  const PersonalCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS 风浅灰背景
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '个人中心',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        border: null, // 去掉底部分割线，更加干净
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildProfileCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMenuCard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部个人信息卡片（Mock 数据）
  Widget _buildProfileCard() {
    const String mockUserName = 'Emma';
    const String mockUserId = 'ID: 12345678';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 大头像（Mock）
          const CircleAvatar(
            radius: 32,
            backgroundColor: CupertinoColors.systemGrey4,
            child: Icon(
              CupertinoIcons.person_fill,
              size: 32,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mockUserName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  mockUserId,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 三个功能列表（Mock）
  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            context,
            icon: CupertinoIcons.cube_box_fill,
            iconColor: CupertinoColors.activeBlue,
            title: '我的订单',
            onTap: () {
              _showMockDialog(context, '我的订单');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: CupertinoIcons.settings_solid,
            iconColor: CupertinoColors.systemGrey,
            title: '设置',
            onTap: () {
              _showMockDialog(context, '设置');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: CupertinoIcons.info_circle_fill,
            iconColor: CupertinoColors.activeGreen,
            title: '关于我们',
            onTap: () {
              _showMockDialog(context, '关于我们');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: CupertinoColors.white,
      borderRadius: BorderRadius.zero,
      pressedOpacity: 0.7,
      alignment: Alignment.centerLeft,
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.label,
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_forward,
            size: 18,
            color: CupertinoColors.systemGrey3,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 56), // 与图标左对齐
      color: CupertinoColors.systemGrey5,
    );
  }

  /// 点击菜单后的 Mock 弹窗
  void _showMockDialog(BuildContext context, String title) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: const Text('这是一个用于 UI 展示的 Mock 弹窗，未接入真实后端。'),
          actions: [
            CupertinoDialogAction(
              child: const Text('知道了'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}

