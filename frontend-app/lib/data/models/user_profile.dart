// 用户资料数据模型
// 用于替代已删除的 mockdata 中的 kCurrentUser

class UserProfile {
  String username;
  String email;
  String age; // 存储 birthdate 字符串（ISO 格式）或年龄数字字符串
  String gender;
  String height;
  String weight;
  List<String> preferences;
  List<String> dietHabits;
  List<String> allergies;

  UserProfile({
    required this.username,
    required this.email,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    List<String>? preferences,
    List<String>? dietHabits,
    List<String>? allergies,
  })  : preferences = preferences ?? [],
        dietHabits = dietHabits ?? [],
        allergies = allergies ?? [];

  // 从 API 数据创建 UserProfile
  factory UserProfile.fromApiData(Map<String, dynamic> data) {
    return UserProfile(
      username: data['userName'] ?? 'Unknown',
      email: data['email'] ?? '',
      age: data['profile']?['birthdate']?.toString() ??
          data['profile']?['age']?.toString() ??
          '',
      gender: data['profile']?['gender'] ?? '',
      height: data['profile']?['height']?.toString() ?? '',
      weight: data['profile']?['weight']?.toString() ?? '',
    );
  }

  // 创建默认的空用户资料
  factory UserProfile.empty() {
    return UserProfile(
      username: 'Unknown',
      email: '',
      age: '',
      gender: '',
      height: '',
      weight: '',
    );
  }
}

// 全局用户资料实例（替代 kCurrentUser）
// ⚠️ 注意：这只是一个临时解决方案，理想情况下应该使用状态管理（如 Provider、Riverpod 等）
final UserProfile kCurrentUser = UserProfile.empty();

