import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// Profile / Settings / Invite 等页面统一的区块标题样式（与 profile_view_page 一致）
const Color kPassportSectionTitleColor = Color(0xFF6B4F4F); // River Deep Brown

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.kalam(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kPassportSectionTitleColor,
        ),
      ),
    );
  }
}
