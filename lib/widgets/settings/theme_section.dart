import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';

class ThemeSection extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const ThemeSection({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final mutedColor = AppTheme.textMutedFor(brightness);
    final cardBg = AppTheme.surfaceFor(
      brightness,
    ).withOpacity01(brightness == Brightness.dark ? 0.55 : 0.92);
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'THEME',
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
            border: Border.all(color: AppTheme.borderFor(brightness)),
            boxShadow: [
              BoxShadow(
                color:
                    (brightness == Brightness.dark
                            ? Colors.black
                            : Colors.black)
                        .withOpacity01(
                          brightness == Brightness.dark ? 0.03 : 0.04,
                        ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildSettingTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Dark mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: isDark,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light);
              },
              activeTrackColor: AppTheme.primaryColor.withOpacity01(0.3),
              activeThumbColor: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    final brightness = Theme.of(context).brightness;
    final titleColor = AppTheme.textFor(brightness);
    final subtitleColor = AppTheme.textMutedFor(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(24))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity01(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
