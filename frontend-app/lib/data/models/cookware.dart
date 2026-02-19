import 'package:flutter/material.dart';

class Cookware {
  String? id; // ✅ household厨具/调料的ID（用于API调用）
  String? standardId; // ✅ 标准库的ID（用于创建新的household厨具/调料）
  String name;
  IconData icon;
  bool isAvailable;

  Cookware({
    this.id,
    this.standardId,
    required this.name,
    required this.icon,
    this.isAvailable = false, // 默认没有，需要用户点选
  });

  /// 从API响应创建Cookware对象
  factory Cookware.fromApiResponse(
    Map<String, dynamic> data,
    IconData defaultIcon,
  ) {
    return Cookware(
      id: data['id']?.toString(),
      name:
          data['standardUtensilName'] ??
          data['standardSpiceName'] ??
          data['name'] ??
          'Unknown',
      icon: defaultIcon,
      isAvailable: data['isAvailable'] ?? false,
    );
  }
}
