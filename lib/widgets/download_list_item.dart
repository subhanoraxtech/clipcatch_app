import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';

/// A single download history list item with thumbnail, title, metadata and actions.
class DownloadListItem extends StatelessWidget {
  final String title;
  final String resolution;
  final String size;
  final String date;
  final String duration;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const DownloadListItem({
    super.key,
    required this.title,
    required this.resolution,
    required this.size,
    required this.date,
    required this.duration,
    required this.imageUrl,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surfaceColor = AppTheme.surfaceFor(brightness);
    final secondaryTextColor = AppTheme.textMutedFor(brightness);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            _Thumbnail(
              imageUrl: imageUrl,
              duration: duration,
              surfaceColor: surfaceColor,
            ),
            const SizedBox(width: 16),

            // Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textFor(brightness),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$resolution • $size',
                    style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Downloaded on $date',
                    style: TextStyle(
                      color: secondaryTextColor.withOpacity01(0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              icon: Icon(Icons.more_vert, color: secondaryTextColor),
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private thumbnail widget ────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final String duration;
  final Color surfaceColor;

  const _Thumbnail({
    required this.imageUrl,
    required this.duration,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: surfaceColor,
        image: DecorationImage(
          image: imageUrl.startsWith('http') 
              ? NetworkImage(imageUrl) as ImageProvider
              : FileImage(File(imageUrl)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black26,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                duration,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
