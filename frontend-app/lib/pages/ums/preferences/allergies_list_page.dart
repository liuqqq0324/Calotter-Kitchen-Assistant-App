import 'package:flutter/material.dart';
import 'package:personal_sous_chef/theme/fallback_google_fonts.dart';
import '../../../services/user_service.dart';
import '../../../services/standard_library_service.dart';

class AllergiesListPage extends StatefulWidget {
  const AllergiesListPage({super.key});

  @override
  State<AllergiesListPage> createState() => _AllergiesListPageState();
}

class _AllergiesListPageState extends State<AllergiesListPage> {
  bool _isLoading = true;
  bool _isEditing = false; // 编辑模式标志
  
  Set<String> _selectedAllergies = {}; // 使用 Set 存储选中的过敏原
  List<Map<String, dynamic>> _standardAllergens = []; // 标准库
  bool _isLoadingAllergens = true;

  @override
  void initState() {
    super.initState();
    _loadAllergies();
    _loadStandardAllergens();
  }

  Future<void> _loadAllergies() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserAllergies();
    if (result['success'] == true && mounted) {
      setState(() {
        _selectedAllergies = Set<String>.from(result['data']['allergies'] ?? []);
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _selectedAllergies = {};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStandardAllergens() async {
    try {
      // ✅ 使用 StandardLibraryService，优先使用缓存（登录时已预加载）
      final allergens = await StandardLibraryService.getStandardAllergens();
      if (mounted) {
        setState(() {
          _standardAllergens = allergens;
          _isLoadingAllergens = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAllergens = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load standard allergens: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveAllergies() async {
    final result = await UserService.updateUserAllergies(
      allergies: _selectedAllergies.toList(),
    );
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Allergies saved', style: GoogleFonts.kalam()),
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
              result['error'] ?? 'Failed to save allergies',
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
    if (_isLoading || _isLoadingAllergens) {
      return Scaffold(
        appBar: AppBar(title: const Text('Allergies')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergies'),
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
                _loadAllergies(); // 取消编辑，重新加载
              },
              child: const Text('Cancel'),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveAllergies,
              child: const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Allergies'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _standardAllergens.map((allergen) {
              final name = allergen['name'] as String;
              final selected = _selectedAllergies.contains(name);
              return FilterChip(
                label: Text(name),
                selected: selected,
                onSelected: _isEditing
                    ? (val) {
                        setState(() {
                          if (val) {
                            _selectedAllergies.add(name);
                          } else {
                            _selectedAllergies.remove(name);
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
