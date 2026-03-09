import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/screens/settings_screen.dart';

class HistoryHeader extends StatelessWidget {
  final bool isEmpty;
  final VoidCallback onDeleteAll;

  const HistoryHeader({
    super.key,
    required this.isEmpty,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
      ),
      child: Row(
        children: [
          const SizedBox(width: 48), // Spacer for symmetry with back button layout if needed
          Expanded(
            child: Text(
              'Downloads',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: isEmpty ? null : onDeleteAll,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isEmpty 
                ? Colors.white24
                : AppTheme.textDark,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SettingsScreen())
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
