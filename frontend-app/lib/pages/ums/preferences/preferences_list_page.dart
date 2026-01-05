import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import '../../../services/user_service.dart';
import '../../../services/standard_library_service.dart';

class PreferencesListPage extends StatefulWidget {
  const PreferencesListPage({super.key});

  @override
  State<PreferencesListPage> createState() => _PreferencesListPageState();
}

class _PreferencesListPageState extends State<PreferencesListPage> {
  bool _isLoading = true;
  bool _isEditing = false; // 编辑模式标志
  
  // 两个大类的偏好
  Set<String> _selectedTastes = {}; // 口味偏好
  Set<String> _selectedCuisines = {}; // 菜系偏好

  // 标准库选项（从 StandardLibraryService 获取，与后端 PreferenceStandardLibrary 保持一致）
  List<String> get _cuisineOptions => 
      StandardLibraryService.getStandardPreferences()['cuisines']!;
  List<String> get _tasteOptions => 
      StandardLibraryService.getStandardPreferences()['tastes']!;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserPreferencesMap();
    if (result['success'] == true && mounted) {
      final data = result['data'] ?? {};
      setState(() {
        _selectedTastes = Set<String>.from(data['tastes'] ?? []);
        _selectedCuisines = Set<String>.from(data['cuisines'] ?? []);
        _isLoading = false;
      });
    } else {
      // Fallback to empty if API fails
      if (mounted) {
        setState(() {
          _selectedTastes = {};
          _selectedCuisines = {};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    final result = await UserService.updateUserPreferencesMap(
      tastes: _selectedTastes.toList(),
      cuisines: _selectedCuisines.toList(),
    );
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences saved', style: GoogleFonts.kalam()),
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
              result['error'] ?? 'Failed to save preferences',
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
        appBar: AppBar(title: const Text('Preferences')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
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
                _loadPreferences(); // 取消编辑，重新加载
              },
              child: const Text('Cancel'),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _savePreferences,
              child: const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. 口味偏好 (Taste Preferences)
          _buildSectionTitle('Taste Preferences'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tasteOptions.map((taste) {
              final selected = _selectedTastes.contains(taste);
              return FilterChip(
                label: Text(taste),
                selected: selected,
                onSelected: _isEditing
                    ? (val) {
                        setState(() {
                          if (val) {
                            _selectedTastes.add(taste);
                          } else {
                            _selectedTastes.remove(taste);
                          }
                        });
                      }
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 2. 菜系偏好 (Cuisine Preferences)
          _buildSectionTitle('Cuisine Preferences'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cuisineOptions.map((cuisine) {
              final selected = _selectedCuisines.contains(cuisine);
              return FilterChip(
                label: Text(cuisine),
                selected: selected,
                onSelected: _isEditing
                    ? (val) {
                        setState(() {
                          if (val) {
                            _selectedCuisines.add(cuisine);
                          } else {
                            _selectedCuisines.remove(cuisine);
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
