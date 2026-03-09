import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';

class SupportedPlatformsList extends StatelessWidget {
  final List<String> services;
  final bool isLoading;

  const SupportedPlatformsList({
    super.key,
    required this.services,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppTheme.textMutedDark;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'WORKS WITH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: mutedColor,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (services.isEmpty)
          const Opacity(
            opacity: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.play_circle_fill_rounded, size: 28),
                Icon(Icons.camera_rounded, size: 28),
                Icon(Icons.video_library_rounded, size: 28),
                Icon(Icons.music_note_rounded, size: 28),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: services.map((service) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderDark,
                  ),
                ),
                child: Text(
                  service.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
