import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import '../../../data/models/user_profile.dart';
import '../../../services/business/auth_service.dart';
import '../../../services/business/user_service.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/pages/landing_page.dart';

/// 与 Home 页一致的颜色
const Color _kPassportBrown = Color(0xFF6B4F4F); // River Deep Brown
const Color _kPaperWhite = Color(0xFFFFFFF0); // Paper White（与 Home 卡片一致）
const Color _kOverlayTint = Color(0xFFF3E5AB); // 纸张泛黄蒙版
const Color _kSeaweedGreen = Color(0xFF4E785E); // 加载指示器颜色

/// 字体大小缩放（整体放大）
const double _kFontSizeTitle = 28.0; // 标题（原 22）
const double _kFontSizeSubtitle = 22.0; // 副标题/按钮（原 18）
const double _kFontSizeLabel = 20.0; // 标签（原 16）
const double _kFontSizeBody = 19.0; // 正文/输入框（原 ~14）

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;
  DateTime? _selectedBirthdate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _loadBasicInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadBasicInfo() async {
    final result = await UserService.getUserBriefInfo();
    if (result['success'] == true && mounted) {
      setState(() {
        final data = result['data'];
        _usernameController.text = data['userName']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _selectedGender = data['profile']?['gender']?.toString();
        final birthdateStr = data['profile']?['birthdate'];
        if (birthdateStr != null && birthdateStr.toString().isNotEmpty) {
          try {
            _selectedBirthdate = DateTime.parse(birthdateStr.toString());
          } catch (e) {
            _selectedBirthdate = null;
          }
        } else {
          _selectedBirthdate = null;
        }
        _heightController.text =
            data['profile']?['height']
                ?.toString()
                .replaceAll(' cm', '')
                .trim() ??
            '';
        _weightController.text =
            data['profile']?['weight']
                ?.toString()
                .replaceAll(' kg', '')
                .trim() ??
            '';
      });
    } else if (mounted) {
      final user = kCurrentUser;
      setState(() {
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _selectedGender = user.gender.isNotEmpty ? user.gender : null;
        if (user.age.isNotEmpty) {
          try {
            _selectedBirthdate = DateTime.parse(user.age);
          } catch (e) {
            _selectedBirthdate = null;
          }
        } else {
          _selectedBirthdate = null;
        }
        _heightController.text = user.height.replaceAll(' cm', '').trim();
        _weightController.text = user.weight.replaceAll(' kg', '').trim();
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveBasicInfo() async {
    final birthdate = _selectedBirthdate != null
        ? _selectedBirthdate!.toIso8601String().split('T')[0]
        : null;
    final height = double.tryParse(
      _heightController.text.replaceAll(' cm', '').trim(),
    )?.toInt();
    final weight = double.tryParse(
      _weightController.text.replaceAll(' kg', '').trim(),
    )?.toInt();

    final result = await UserService.updateUserInfo(
      birthdate: birthdate,
      gender: _selectedGender,
      height: height,
      weight: weight,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      kCurrentUser.age = birthdate ?? '';
      kCurrentUser.gender = _selectedGender ?? '';
      kCurrentUser.height = _heightController.text;
      kCurrentUser.weight = _weightController.text;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Basic info saved',
            style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
          ),
          backgroundColor: Colors.green.shade300,
          duration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] ?? 'Failed to save',
            style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
          ),
          backgroundColor: Colors.red.shade300,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({String? hintText, String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: GoogleFonts.kalam(
        fontSize: _kFontSizeBody,
        color: _kPassportBrown.withOpacity(0.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _kPassportBrown),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _kPassportBrown.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPassportBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.kalam(
          fontSize: _kFontSizeLabel,
          fontWeight: FontWeight.bold,
          color: _kPassportBrown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 与 Home 页一致的布局：木纹背景 + 纸张泛黄蒙版 + 网格纸内容区
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wood_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: _kOverlayTint.withOpacity(0.35)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kPassportBrown),
        title: Text(
          'Settings',
          style: GoogleFonts.kalam(
            fontSize: _kFontSizeTitle,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveBasicInfo,
              child: Text(
                'Save',
                style: GoogleFonts.kalam(
                  fontSize: _kFontSizeSubtitle,
                  fontWeight: FontWeight.bold,
                  color: _kPassportBrown,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图层 1: 木纹背景
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/sketch_paper_transparent.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 背景图层 2: 纸张泛黄蒙版（与 Home 一致）
          Positioned.fill(
            child: Container(color: _kOverlayTint.withOpacity(0.35)),
          ),
          // 内容层: WoodBoard 仅包裹表单和按钮（较小范围），木纹为底层全屏背景
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _kSeaweedGreen),
                )
              : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 36,
                  ),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: const Offset(0, -56),
                        child: Builder(
                          builder: (context) {
                            final w = MediaQuery.of(context).size.width + 70;
                            return Transform.scale(
                              scale: 0.95,
                              alignment: Alignment.center,
                              child: Container(
                                width: w,
                                height: 840,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/profile_passport/WoodBoard.png',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  w * 0.09,
                                  52,
                                  w * 0.09,
                                  66,
                                ),
                                child: Transform.translate(
                                  offset: const Offset(0, 60),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Basic Info 表单
                                      SketchyCard(
                                        backgroundColor: _kPaperWhite,
                                        borderColor: _kPassportBrown,
                                        borderWidth: 2.5,
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('User name'),
                                            TextField(
                                              controller: _usernameController,
                                              decoration: _inputDecoration(),
                                              style: GoogleFonts.kalam(
                                                fontSize: _kFontSizeBody,
                                                color: _kPassportBrown,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            _buildLabel('Email'),
                                            TextField(
                                              controller: _emailController,
                                              decoration: _inputDecoration(),
                                              style: GoogleFonts.kalam(
                                                fontSize: _kFontSizeBody,
                                                color: _kPassportBrown,
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                            ),
                                            const SizedBox(height: 14),
                                            // Gender 与 Birthdate 同一行
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildLabel('Gender'),
                                                      DropdownButtonFormField<
                                                        String
                                                      >(
                                                        value:
                                                            (_selectedGender ==
                                                                    '1' ||
                                                                _selectedGender ==
                                                                    '2')
                                                            ? _selectedGender
                                                            : null,
                                                        decoration: _inputDecoration()
                                                            .copyWith(
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        16,
                                                                  ),
                                                            ),
                                                        dropdownColor:
                                                            _kPaperWhite,
                                                        items: [
                                                          DropdownMenuItem(
                                                            value: '1',
                                                            child: Text(
                                                              'Male',
                                                              style: GoogleFonts.kalam(
                                                                fontSize:
                                                                    _kFontSizeBody,
                                                                color:
                                                                    _kPassportBrown,
                                                              ),
                                                            ),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: '2',
                                                            child: Text(
                                                              'Female',
                                                              style: GoogleFonts.kalam(
                                                                fontSize:
                                                                    _kFontSizeBody,
                                                                color:
                                                                    _kPassportBrown,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          setState(
                                                            () =>
                                                                _selectedGender =
                                                                    value,
                                                          );
                                                        },
                                                        hint: Text(
                                                          'Select',
                                                          style: GoogleFonts.kalam(
                                                            fontSize:
                                                                _kFontSizeBody,
                                                            color:
                                                                _kPassportBrown
                                                                    .withOpacity(
                                                                      0.7,
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildLabel('Birthdate'),
                                                      InkWell(
                                                        onTap: () async {
                                                          final DateTime?
                                                          picked = await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                _selectedBirthdate ??
                                                                DateTime.now()
                                                                    .subtract(
                                                                      const Duration(
                                                                        days:
                                                                            365 *
                                                                            25,
                                                                      ),
                                                                    ),
                                                            firstDate: DateTime(
                                                              1900,
                                                            ),
                                                            lastDate:
                                                                DateTime.now(),
                                                            helpText:
                                                                'Select birthdate',
                                                          );
                                                          if (picked != null &&
                                                              picked !=
                                                                  _selectedBirthdate &&
                                                              mounted) {
                                                            setState(
                                                              () =>
                                                                  _selectedBirthdate =
                                                                      picked,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 16,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: _kPassportBrown
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  _selectedBirthdate !=
                                                                          null
                                                                      ? '${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}'
                                                                      : 'Select',
                                                                  style: GoogleFonts.kalam(
                                                                    fontSize:
                                                                        _kFontSizeBody,
                                                                    color:
                                                                        _selectedBirthdate !=
                                                                            null
                                                                        ? _kPassportBrown
                                                                        : _kPassportBrown.withOpacity(
                                                                            0.5,
                                                                          ),
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                size: 24,
                                                                color:
                                                                    _kPassportBrown,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            // Height 与 Weight 同一行
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildLabel('Height'),
                                                      TextField(
                                                        controller:
                                                            _heightController,
                                                        decoration:
                                                            _inputDecoration(
                                                              suffixText: 'cm',
                                                            ),
                                                        style: GoogleFonts.kalam(
                                                          fontSize:
                                                              _kFontSizeBody,
                                                          color:
                                                              _kPassportBrown,
                                                        ),
                                                        keyboardType:
                                                            const TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildLabel('Weight'),
                                                      TextField(
                                                        controller:
                                                            _weightController,
                                                        decoration:
                                                            _inputDecoration(
                                                              suffixText: 'kg',
                                                            ),
                                                        style: GoogleFonts.kalam(
                                                          fontSize:
                                                              _kFontSizeBody,
                                                          color:
                                                              _kPassportBrown,
                                                        ),
                                                        keyboardType:
                                                            const TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 0),
                                      _buildSettingsCard(
                                        icon: Icons.lock_outline,
                                        title: 'Change Password',
                                        onTap: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Change Password (To be implemented)',
                                                style: GoogleFonts.kalam(
                                                  fontSize: _kFontSizeBody,
                                                ),
                                              ),
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 0),
                                      _buildSettingsCard(
                                        icon: Icons.logout,
                                        title: 'Log out',
                                        titleColor: Colors.red.shade700,
                                        onTap: () => _showLogoutDialog(),
                                      ),
                                      const SizedBox(height: 0),
                                      _buildSettingsCard(
                                        icon: Icons.delete_outline,
                                        title: 'Delete Account',
                                        titleColor: Colors.red.shade700,
                                        onTap: () => _showDeleteAccountDialog(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return SketchyCard(
      backgroundColor: _kPaperWhite,
      borderColor: _kPassportBrown,
      borderWidth: 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: titleColor ?? _kPassportBrown),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.kalam(
                fontSize: _kFontSizeSubtitle,
                fontWeight: FontWeight.bold,
                color: titleColor ?? _kPassportBrown,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: titleColor ?? _kPassportBrown,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log out',
          style: GoogleFonts.kalam(
            fontSize: _kFontSizeTitle,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.kalam(
            fontSize: _kFontSizeLabel,
            color: _kPassportBrown,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(
                fontSize: _kFontSizeBody,
                color: _kPassportBrown,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Log out',
              style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    final result = await AuthService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Logged out successfully',
            style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
          ),
          backgroundColor: Colors.green.shade300,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.kalam(
            fontSize: _kFontSizeTitle,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.kalam(
            fontSize: _kFontSizeLabel,
            color: _kPassportBrown,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(
                fontSize: _kFontSizeBody,
                color: _kPassportBrown,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Delete Account (To be implemented)',
                    style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
                  ),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.kalam(fontSize: _kFontSizeBody),
            ),
          ),
        ],
      ),
    );
  }
}
