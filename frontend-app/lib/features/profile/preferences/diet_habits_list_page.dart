import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import '../../../services/business/user_service.dart';
import '../../../services/business/standard_library_service.dart';

class DietHabitsListPage extends StatefulWidget {
  const DietHabitsListPage({super.key});

  @override
  State<DietHabitsListPage> createState() => _DietHabitsListPageState();
}

class _DietHabitsListPageState extends State<DietHabitsListPage> {
  bool _isLoading = true;

  Set<String> _selectedDietHabits =
      {}; // 使用 Set 存储选中的饮食习惯（发送给后端时字段名为 dietHabits）

  // 标准饮食习惯选项（从 StandardLibraryService 获取，与后端 PreferenceStandardLibrary.DIET_HABITS_OPTIONS 保持一致）
  List<Map<String, String>> get _dietHabitsOptions =>
      StandardLibraryService.getStandardDietHabits();

  @override
  void initState() {
    super.initState();
    _loadDietHabits();
  }

  Future<void> _loadDietHabits() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.getUserDietHabits();
    if (result['success'] == true && mounted) {
      setState(() {
        _selectedDietHabits = Set<String>.from(
          result['data']['dietHabits'] ?? [],
        );
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _selectedDietHabits = {};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDietHabits() async {
    final result = await UserService.updateUserDietHabits(
      dietHabits: _selectedDietHabits.toList(),
    );
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dietary habits saved', style: GoogleFonts.kalam()),
            backgroundColor: Colors.green.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
        // ✅ 保存成功后直接返回上一页
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to save dietary habits',
              style: GoogleFonts.kalam(),
            ),
            backgroundColor: Colors.red.shade300,
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dietary Habits')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Habits'),
        actions: [
          TextButton(
            onPressed: () {
              // ✅ 取消编辑，直接返回上一页
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: _saveDietHabits, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Dietary Habits'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietHabitsOptions.map((option) {
              final value = option['value']!;
              final label = option['label']!;
              final selected = _selectedDietHabits.contains(value);
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedDietHabits.add(value);
                    } else {
                      _selectedDietHabits.remove(value);
                    }
                  });
                },
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
