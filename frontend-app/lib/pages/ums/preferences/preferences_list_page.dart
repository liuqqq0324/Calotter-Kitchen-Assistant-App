import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Modified by Chase: Import user static data and user service / 由 Chase 修改：导入用户静态数据和服务
import '../../../data/user_static_data.dart';
import '../../../services/user_service.dart';

class PreferencesListPage extends StatefulWidget {
  const PreferencesListPage({super.key});

  @override
  State<PreferencesListPage> createState() => _PreferencesListPageState();
}

class _PreferencesListPageState extends State<PreferencesListPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  List<String> _cuisineTypes = [];
  String _dietaryType = '';
  String _spiceLevel = '';
  String _cookingTimePreference = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserPreferences();
    if (result['success'] == true && mounted) {
      final prefs = result['data']['preferences'] ?? {};
      setState(() {
        _cuisineTypes = List<String>.from(prefs['cuisineTypes'] ?? []);
        _dietaryType = prefs['dietaryType'] ?? '';
        _spiceLevel = prefs['spiceLevel'] ?? '';
        _cookingTimePreference = prefs['cookingTimePreference'] ?? '';
        // Also update local static data for compatibility (only cuisineTypes)
        kCurrentUser.preferences = List.from(_cuisineTypes);
        _isLoading = false;
      });
    } else {
      // Fallback to static data if API fails
      if (mounted) {
        setState(() {
          _cuisineTypes = List.from(kCurrentUser.preferences);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    final result = await UserService.updateUserPreferences(
      cuisineTypes: _cuisineTypes,
      dietaryType: _dietaryType.isEmpty ? null : _dietaryType,
      spiceLevel: _spiceLevel.isEmpty ? null : _spiceLevel,
      cookingTimePreference: _cookingTimePreference.isEmpty
          ? null
          : _cookingTimePreference,
    );
    if (result['success'] == true) {
      // Also update local static data for compatibility
      kCurrentUser.preferences = List.from(_cuisineTypes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to save preferences',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
          ),
        );
      }
    }
  }

  void _addPreference() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _cuisineTypes.add(text);
        kCurrentUser.preferences = List.from(_cuisineTypes);
        _textController.clear();
      });
      _savePreferences();
    }
  }

  void _removePreference(int index) {
    setState(() {
      _cuisineTypes.removeAt(index);
      kCurrentUser.preferences = List.from(_cuisineTypes);
    });
    _savePreferences();
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
        appBar: AppBar(title: const Text('Preferences')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cuisine Preferences')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cuisineTypes.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('${_cuisineTypes[index]}-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removePreference(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(title: Text(_cuisineTypes[index])),
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
                      hintText: 'Add cuisine type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addPreference(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addPreference,
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
