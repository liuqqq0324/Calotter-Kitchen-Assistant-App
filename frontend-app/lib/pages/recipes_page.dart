import 'package:flutter/material.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 假数据：食谱列表
    final List<Map<String, dynamic>> recipes = [
      {
        'name': '番茄炒蛋',
        'time': '15 min',
        'difficulty': 'Easy',
        'image': Icons.restaurant,
      },
      {
        'name': '宫保鸡丁',
        'time': '30 min',
        'difficulty': 'Medium',
        'image': Icons.restaurant,
      },
      {
        'name': '麻婆豆腐',
        'time': '20 min',
        'difficulty': 'Easy',
        'image': Icons.restaurant,
      },
      {
        'name': '红烧肉',
        'time': '60 min',
        'difficulty': 'Hard',
        'image': Icons.restaurant,
      },
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(recipe['image'] as IconData, color: Colors.green),
              ),
              title: Text(recipe['name'] as String),
              subtitle: Text(
                '${recipe['time']} • ${recipe['difficulty']}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: 导航到食谱详情页
              },
            ),
          );
        },
      ),
    );
  }
}

