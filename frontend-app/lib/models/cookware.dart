import 'package:flutter/material.dart';

class Cookware {
  String name;
  IconData icon;
  bool isAvailable;

  Cookware({
    required this.name,
    required this.icon,
    this.isAvailable = false, // 默认没有，需要用户点选
  });
}
