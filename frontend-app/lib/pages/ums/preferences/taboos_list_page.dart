import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import '../../../services/user_service.dart';
import '../../../services/standard_library_service.dart';

class TaboosListPage extends StatefulWidget {
  const TaboosListPage({super.key});

  @override
  State<TaboosListPage> createState() => _TaboosListPageState();
}

class _TaboosListPageState extends State<TaboosListPage> {
  bool _isLoading = true;
  bool _isEditing = false; // 编辑模式标志
  
  Set<String> _selectedTaboos = {}; // 使用 Set 存储选中的饮食习惯（发送给后端时字段名为 taboos）

  // 标准饮食习惯选项（从 StandardLibraryService 获取，与后端 PreferenceStandardLibrary.TABOO_OPTIONS 保持一致）
  List<Map<String, String>> get _tabooOptions => StandardLibraryService.getStandardTaboos();

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
        _selectedTaboos = Set<String>.from(result['data']['taboos'] ?? []);
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _selectedTaboos = {};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveTaboos() async {
    final result = await UserService.updateUserTaboos(
      taboos: _selectedTaboos.toList(),
    );
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dietary restrictions saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to save dietary restrictions',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dietary Restrictions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Restrictions'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadTaboos(); // 取消编辑，重新加载
              },
              child: const Text('Cancel'),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveTaboos,
              child: const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Dietary Restrictions'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tabooOptions.map((option) {
              final value = option['value']!;
              final label = option['label']!;
              final selected = _selectedTaboos.contains(value);
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: _isEditing
                    ? (val) {
                        setState(() {
                          if (val) {
                            _selectedTaboos.add(value);
                          } else {
                            _selectedTaboos.remove(value);
                          }
                        });
                      }
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
