import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/wood_background_scaffold.dart';
import 'profile_edit_page.dart';
import '../../../services/business/auth_service.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/pages/landing_page.dart';

/// Profile 风格主色（与 profile_view_page 一致）
const Color _kPassportBrown = Color(0xFF6B4F4F);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return WoodBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kPassportBrown),
        title: Text(
          'Settings',
          style: GoogleFonts.kalam(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingsCard(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditPage(),
                  ),
                );
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change Password (To be implemented)'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.logout,
              title: 'Log out',
              titleColor: Colors.red.shade700,
              onTap: () => _showLogoutDialog(),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              titleColor: Colors.red.shade700,
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ),
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
      backgroundColor: Colors.blue.shade50,
      borderColor: _kPassportBrown,
      borderWidth: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: titleColor ?? _kPassportBrown),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.kalam(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor ?? _kPassportBrown,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.kalam(fontSize: 16, color: _kPassportBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(color: _kPassportBrown),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Log out', style: GoogleFonts.kalam()),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    final result = await AuthService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingPage(),
        ),
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
            style: GoogleFonts.kalam(),
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.kalam(fontSize: 16, color: _kPassportBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(color: _kPassportBrown),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete Account (To be implemented)'),
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.kalam()),
          ),
        ],
      ),
    );
  }
}
