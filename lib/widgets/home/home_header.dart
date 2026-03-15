import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/theme/theme_notifier.dart';
import 'package:video_downloader/screens/settings_screen.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        final isDark = themeNotifier.themeMode == ThemeMode.dark;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              themeNotifier.setThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceFor(brightness),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderFor(brightness)),
              ),
              child: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44),
          Text(
            'ClipCatch',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              letterSpacing: -1,
            ),
          ),
          Row(
            children: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceFor(brightness),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderFor(brightness)),
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
