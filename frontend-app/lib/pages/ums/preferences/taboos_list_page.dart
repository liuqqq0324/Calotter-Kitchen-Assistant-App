import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
// Modified by Chase: Import user static data and user service / 由 Chase 修改：导入用户静态数据和服务
import '../../../data/user_static_data.dart';
import '../../../services/user_service.dart';

class TaboosListPage extends StatefulWidget {
  const TaboosListPage({super.key});

  @override
  State<TaboosListPage> createState() => _TaboosListPageState();
}

class _TaboosListPageState extends State<TaboosListPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  List<String> _taboos = [];

  @override
  void initState() {
    super.initState();
    _loadTaboos();
  }

  Future<void> _loadTaboos() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserTaboos();
    if (result['success'] == true && mounted) {
      setState(() {
        _taboos = List<String>.from(result['data']['taboos'] ?? []);
        // Also update local static data for compatibility
        kCurrentUser.taboos = List.from(_taboos);
        _isLoading = false;
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        setState(() {
          _taboos = List.from(kCurrentUser.taboos);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveTaboos() async {
    final result = await UserService.updateUserTaboos(taboos: _taboos);
    if (result['success'] == true) {
      // Also update local static data for compatibility
      kCurrentUser.taboos = List.from(_taboos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Taboos saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to save taboos',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

  void _addTaboo() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _taboos.add(text);
        kCurrentUser.taboos = List.from(_taboos);
        _textController.clear();
      });
      _saveTaboos();
    }
  }

  void _removeTaboo(int index) {
    setState(() {
      _taboos.removeAt(index);
      kCurrentUser.taboos = List.from(_taboos);
    });
    _saveTaboos();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Taboos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Taboos')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _taboos.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('${_taboos[index]}-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removeTaboo(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(title: Text(_taboos[index])),
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
                      hintText: 'Add taboo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addTaboo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTaboo,
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
