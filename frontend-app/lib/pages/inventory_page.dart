import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 假数据：库存列表
    final List<Map<String, dynamic>> inventory = [
      {
        'name': '鸡蛋',
        'amount': '6个',
        'expiry': '2025-01-15',
        'icon': Icons.egg,
      },
      {
        'name': '番茄',
        'amount': '500g',
        'expiry': '2025-01-12',
        'icon': Icons.eco,
      },
      {
        'name': '牛奶',
        'amount': '1L',
        'expiry': '2025-01-10',
        'icon': Icons.local_drink,
      },
      {
        'name': '鸡肉',
        'amount': '300g',
        'expiry': '2025-01-11',
        'icon': Icons.set_meal,
      },
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(item['icon'] as IconData, color: Colors.green),
              ),
              title: Text(item['name'] as String),
              subtitle: Text(
                '${item['amount']} • 过期: ${item['expiry']}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: 显示编辑/删除菜单
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

