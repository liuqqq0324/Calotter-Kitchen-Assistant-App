class Ingredient {
  String name; // 食材名称
  DateTime expiryDate; // 过期时间
  int quantity; // 数量 (整数)
  String unit; // 单位 (如 'g', 'pcs')
  String imagePlaceholder; // 用Emoji代替图片占位

  // 构造函数：创建食材对象时必须传入这些参数
  Ingredient({
    required this.name,
    required this.expiryDate,
    this.quantity = 1,
    this.unit = 'pcs',
    this.imagePlaceholder = '📦',
  });

  // Getter: 判断是否已过期 (当前时间在过期时间之后)
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  // Getter: 判断是否临期 (过期时间 - 当前时间 <= 3天)
  bool get isExpiringSoon {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }
}
