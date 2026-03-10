import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundFor(brightness),
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
