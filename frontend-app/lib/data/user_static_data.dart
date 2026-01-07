// lib/data/user_static_data.dart
// Modified by Chase: Static data management for user-related pages / 由 Chase 修改：用户相关页面的静态数据管理
// This file manages all user profile data including personal info, preferences, diet habits, and allergies / 此文件管理所有用户资料数据，包括个人信息、偏好、饮食习惯和过敏

// User Profile Model / 用户资料模型
class UserProfile {
  // Personal Information / 个人信息
  String username;
  String email;
  String age;
  String gender;
  String height;
  String weight;

  // Preferences and Restrictions / 偏好和限制
  List<String> preferences;
  List<String> dietHabits;
  List<String> allergies;

  // Constructor / 构造函数
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
  }) : preferences = preferences ?? [],
       dietHabits = dietHabits ?? [],
       allergies = allergies ?? [];

  // Copy method for creating a new instance / 复制方法，用于创建新实例
  UserProfile copyWith({
    String? username,
    String? email,
    String? age,
    String? gender,
    String? height,
    String? weight,
    List<String>? preferences,
    List<String>? dietHabits,
    List<String>? allergies,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      preferences: preferences ?? List<String>.from(this.preferences),
      dietHabits: dietHabits ?? List<String>.from(this.dietHabits),
      allergies: allergies ?? List<String>.from(this.allergies),
    );
  }
}

// Global User Profile Instance / 全局用户资料实例
// Modified by Chase: This is the single source of truth for user data / 由 Chase 修改：这是用户数据的唯一数据源
// All pages should read from and modify this instance / 所有页面都应该读取和修改此实例
// Note: age, height, weight are empty by default - user should set them on first edit
// 注意：age、height、weight 默认为空 - 用户应在首次编辑时设置它们
final UserProfile kCurrentUser = UserProfile(
  username: 'Chase_70_70',
  email: 'chase666@gmail.com',
  age: '', // No default value - empty until user sets it
  gender: '', // No default value - empty until user sets it
  height: '', // No default value - empty until user sets it
  weight: '', // No default value - empty until user sets it
  preferences: [], // Empty by default
  dietHabits: [], // Empty by default
  allergies: [], // Empty by default
);
