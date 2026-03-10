import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/widgets/quality_options.dart';

/// A bottom-sheet modal that lets users select a video quality before downloading.
class ResolutionModal extends StatefulWidget {
  final Function(String) onDownload;
  final String? initialSelection;
  final String? buttonLabel;
  final IconData? buttonIcon;

  const ResolutionModal({
    super.key, 
    required this.onDownload,
    this.initialSelection,
    this.buttonLabel,
    this.buttonIcon,
  });

  @override
  State<ResolutionModal> createState() => _ResolutionModalState();
}

class _ResolutionModalState extends State<ResolutionModal> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection ?? '720p';
  }

  void _select(String value) {
    if (_selected != value) {
      HapticFeedback.lightImpact();
      setState(() => _selected = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundFor(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Quality',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 24,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceFor(brightness),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderFor(brightness)),
              ),
              child: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Flexible(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Standard'),
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
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  QualityPill(label: '360p', isSelected: _selected == '360p', onTap: () => _select('360p')),
                  const SizedBox(width: 8),
                  QualityPill(label: '240p', isSelected: _selected == '240p', onTap: () => _select('240p')),
                  const SizedBox(width: 8),
                  QualityPill(label: '144p', isSelected: _selected == '144p', onTap: () => _select('144p')),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const SectionHeader(title: 'Ultra Premium', accentColor: AppTheme.accentColor),
            const SizedBox(height: 16),
            PremiumQualityCard(
              title: '4K Ultra HD',
              subtitle: 'Maximum cinematic detail',
              badgeText: 'Elite',
              isSelected: _selected == '4K Ultra HD',
              onTap: () => _select('4K Ultra HD'),
            ),
            const SizedBox(height: 12),
            PremiumQualityCard(
              title: '2K Quad HD',
              subtitle: 'Professional sharp quality',
              badgeText: 'Pro',
              isSelected: _selected == '2K Quad HD',
              onTap: () => _select('2K Quad HD'),
            ),
            const SizedBox(height: 12),
            PremiumQualityCard(
              title: '1080p Full HD',
              subtitle: 'Best for standard displays',
              badgeText: 'Pro',
              isSelected: _selected == '1080p Full HD',
              onTap: () => _select('1080p Full HD'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundFor(brightness),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity01(0.05),
            offset: const Offset(0, -10),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              widget.onDownload(_selected);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.buttonIcon ?? Icons.download_rounded, size: 20),
                const SizedBox(width: 8),
                Text(widget.buttonLabel ?? 'Start Download'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'High quality downloads may take longer depending on connection speed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMutedFor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show the resolution selection bottom sheet.
void showResolutionModal(
  BuildContext context, 
  Function(String) onDownload, {
  String? initialSelection,
  String? buttonLabel,
  IconData? buttonIcon,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity01(0.5),
    builder: (_) => ResolutionModal(
      onDownload: onDownload, 
      initialSelection: initialSelection,
      buttonLabel: buttonLabel,
      buttonIcon: buttonIcon,
    ),
  );
}
