import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
// Modified by Chase: Import user static data and user service / 由 Chase 修改：导入用户静态数据和服务
import '../../../data/user_static_data.dart';
import '../../../services/user_service.dart';

class AllergiesListPage extends StatefulWidget {
  const AllergiesListPage({super.key});

  @override
  State<AllergiesListPage> createState() => _AllergiesListPageState();
}

class _AllergiesListPageState extends State<AllergiesListPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserAllergies();
    if (result['success'] == true && mounted) {
      setState(() {
        _allergies = List<String>.from(result['data']['allergies'] ?? []);
        // Also update local static data for compatibility
        kCurrentUser.allergies = List.from(_allergies);
        _isLoading = false;
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        setState(() {
          _allergies = List.from(kCurrentUser.allergies);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAllergies() async {
    final result = await UserService.updateUserAllergies(allergies: _allergies);
    if (result['success'] == true) {
      // Also update local static data for compatibility
      kCurrentUser.allergies = List.from(_allergies);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Allergies saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to save allergies',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

  void _addAllergy() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _allergies.add(text);
        kCurrentUser.allergies = List.from(_allergies);
        _textController.clear();
      });
      _saveAllergies();
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
      kCurrentUser.allergies = List.from(_allergies);
    });
    _saveAllergies();
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
        appBar: AppBar(title: const Text('Allergies')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Allergies')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allergies.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('${_allergies[index]}-$index'),
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
                    child: ListTile(title: Text(_allergies[index])),
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
