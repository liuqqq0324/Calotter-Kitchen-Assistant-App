import 'package:flutter/material.dart';

class AllergiesListPage extends StatefulWidget {
  const AllergiesListPage({super.key});

  @override
  State<AllergiesListPage> createState() => _AllergiesListPageState();
}

class _AllergiesListPageState extends State<AllergiesListPage> {
  // 假数据
  List<String> allergies = ['Peanuts', 'Shellfish', 'Dairy'];

  final TextEditingController _textController = TextEditingController();

  void _addAllergy() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        allergies.add(text);
        _textController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      allergies.removeAt(index);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergies'),
      ),
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
                    child: ListTile(
                      title: Text(allergies[index]),
                    ),
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

