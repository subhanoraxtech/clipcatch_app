import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/widgets/resolution_modal.dart';

class HomeInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isDownloading;
  final String initialResolution;
  final Function(String resolution) onDownloadTriggered;

  const HomeInputSection({
    super.key,
    required this.controller,
    required this.isDownloading,
    required this.initialResolution,
    required this.onDownloadTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Paste video link here...',
            prefixIcon: const Icon(LucideIcons.link, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(LucideIcons.clipboardList, size: 20),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  controller.text = data!.text!;
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isDownloading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                   if (controller.text.isNotEmpty) {
                    showResolutionModal(
                      context,
                      (resolution) => onDownloadTriggered(resolution),
                      initialSelection: initialResolution,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please paste a link first')),
                    );
                  }
                },
          child: isDownloading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Download Video'),
        ),
      ],
    );
  }
}
