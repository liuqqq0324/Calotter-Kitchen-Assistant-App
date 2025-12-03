import 'package:flutter/material.dart';
// Modified by Chase: Import user static data / 由 Chase 修改：导入用户静态数据
import '../../../data/user_static_data.dart';

class AllergiesListPage extends StatefulWidget {
  const AllergiesListPage({super.key});

  @override
  State<AllergiesListPage> createState() => _AllergiesListPageState();
}

class _AllergiesListPageState extends State<AllergiesListPage> {
  final TextEditingController _textController = TextEditingController();

  // Modified by Chase: Use global kCurrentUser.allergies instead of local data / 由 Chase 修改：使用全局 kCurrentUser.allergies 而不是本地数据
  void _addAllergy() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // Modified by Chase: Directly modify global kCurrentUser.allergies / 由 Chase 修改：直接修改全局 kCurrentUser.allergies
        kCurrentUser.allergies.add(text);
        _textController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      // Modified by Chase: Directly modify global kCurrentUser.allergies / 由 Chase 修改：直接修改全局 kCurrentUser.allergies
      kCurrentUser.allergies.removeAt(index);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Modified by Chase: Sync with global data in build method (following InventoryPage pattern) / 由 Chase 修改：在 build 方法中同步全局数据（遵循 InventoryPage 模式）
    final allergies = kCurrentUser.allergies;

    return Scaffold(
      appBar: AppBar(title: const Text('Allergies')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(allergies[index]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removeAllergy(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(title: Text(allergies[index])),
                  ),
                );
              },
            ),
          ),
          // 底部输入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add allergy',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addAllergy(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addAllergy,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
