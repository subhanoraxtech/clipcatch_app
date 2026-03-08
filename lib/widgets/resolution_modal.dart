import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/widgets/quality_options.dart';

/// A bottom-sheet modal that lets users select a video quality before downloading.
class ResolutionModal extends StatefulWidget {
  final VoidCallback onDownload;

  const ResolutionModal({super.key, required this.onDownload});

  @override
  State<ResolutionModal> createState() => _ResolutionModalState();
}

class _ResolutionModalState extends State<ResolutionModal> {
  String _selected = '720p';

  void _select(String value) => setState(() => _selected = value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(isDark),
          _buildHeader(isDark),
          const Divider(height: 1),
          _buildContent(isDark),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 6,
      width: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Quality',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Free tier
            const SectionHeader(title: 'Free'),
            const SizedBox(height: 16),
            QualityOptionCard(
              title: '720p',
              subtitle: 'High Definition',
              isSelected: _selected == '720p',
              onTap: () => _select('720p'),
            ),
            const SizedBox(height: 12),
            QualityOptionCard(
              title: '480p',
              subtitle: 'Standard Definition',
              isSelected: _selected == '480p',
              onTap: () => _select('480p'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                QualityPill(label: '360p', isSelected: _selected == '360p', onTap: () => _select('360p')),
                const SizedBox(width: 8),
                QualityPill(label: '240p', isSelected: _selected == '240p', onTap: () => _select('240p')),
                const SizedBox(width: 8),
                QualityPill(label: '144p', isSelected: _selected == '144p', onTap: () => _select('144p')),
              ],
            ),

            const SizedBox(height: 32),

            // Premium tier
            const SectionHeader(title: 'Premium', accentColor: Colors.amber),
            const SizedBox(height: 16),
            PremiumQualityCard(
              title: '4K Ultra HD',
              subtitle: 'Crisp detail for large screens',
              badgeText: 'Best',
              isSelected: _selected == '4K Ultra HD',
              onTap: () => _select('4K Ultra HD'),
            ),
            const SizedBox(height: 12),
            QualityOptionCard(
              title: '2K Quad HD',
              subtitle: 'Professional quality',
              isPremium: true,
              isSelected: _selected == '2K Quad HD',
              onTap: () => _select('2K Quad HD'),
            ),
            const SizedBox(height: 12),
            QualityOptionCard(
              title: '1080p Full HD',
              subtitle: 'Perfect for phones',
              isPremium: true,
              isSelected: _selected == '1080p Full HD',
              onTap: () => _select('1080p Full HD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Download Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                widget.onDownload();
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'By downloading, you agree to our Terms of Service. '
            'Premium features require an active subscription.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Show the resolution selection bottom sheet.
void showResolutionModal(BuildContext context, VoidCallback onDownload) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ResolutionModal(onDownload: onDownload),
  );
}
