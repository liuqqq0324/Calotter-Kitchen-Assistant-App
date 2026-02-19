/// 头像库配置
/// 头像图片位于 assets/avatar/
class AvatarConfig {
  /// 默认头像（otter）
  static const String defaultAvatar = 'otter';

  /// 所有可选头像
  static const List<AvatarOption> options = [
    AvatarOption(id: 'otter', path: 'assets/avatar/otter.png', label: 'Otter'),
    AvatarOption(id: 'penguin', path: 'assets/avatar/penguin.png', label: 'Penguin'),
    AvatarOption(id: 'polarbear', path: 'assets/avatar/polarbear.png', label: 'Polar Bear'),
    AvatarOption(id: 'seal', path: 'assets/avatar/seal.png', label: 'Seal'),
  ];

  static String getPath(String avatarId) {
    final found = options.where((o) => o.id == avatarId).firstOrNull;
    return found?.path ?? 'assets/avatar/otter.png';
  }
}

class AvatarOption {
  final String id;
  final String path;
  final String label;

  const AvatarOption({
    required this.id,
    required this.path,
    required this.label,
  });
}
