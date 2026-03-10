import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
    final brightness = Theme.of(context).brightness;
    final mutedColor = AppTheme.textMutedFor(brightness);

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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isLoading
              ? _buildShimmer(brightness)
              : services.isEmpty
                  ? _buildEmptyState()
                  : _buildServicesGrid(brightness),
        ),
      ],
    );
  }

  Widget _buildShimmer(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(6, (index) => Container(
          width: 80 + (index % 3) * 20.0,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        )),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Opacity(
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
    );
  }

  Widget _buildServicesGrid(Brightness brightness) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceFor(brightness),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderFor(brightness),
            ),
          ),
          child: Text(
            service.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textFor(brightness),
            ),
          ),
        );
      }).toList(),
    );
  }
}
