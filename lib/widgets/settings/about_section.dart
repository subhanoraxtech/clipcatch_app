import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppTheme.textMutedDark;
    final textColor = Colors.white;
    final cardBg = const Color(0xFF0F172A).withOpacity(0.5);
    final dividerColor = AppTheme.surfaceDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ABOUT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: mutedColor,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderDark),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAboutTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailing: Text(
                  '1.0.0 (Build 12)',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildAboutTile(
                context,
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                trailing: Icon(Icons.open_in_new_rounded, size: 16, color: mutedColor),
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildAboutTile(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                trailing: Icon(Icons.open_in_new_rounded, size: 16, color: mutedColor),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: isLast 
        ? const BorderRadius.vertical(bottom: Radius.circular(24))
        : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
